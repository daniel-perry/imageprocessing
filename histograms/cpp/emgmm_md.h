#ifndef emgmm_H
#define emgmm_H

// std
#include <vector>
#include <string>
#include <cstdlib>

// itk
#include <itkNeighborhoodIterator.h>
#include <itkVector.h>
#include <itkMatrix.h>

template < unsigned int D >
struct GaussianModel
{
  typedef itk::Vector<float,D> FeatureVector;
  typedef itk::Matrix<float,D,D> CovarianceMatrix;
  FeatureVector mean;
  CovarianceMatrix covariance;
  CovarianceMatrix inv_covariance;
  float determinant;
  float mix;

  /** update the inverse and determinants 
   *   of the covariance matrix
   */
  void update_inv()
  {
    // need the determinant and inverse covariance (for guassian equation)
    typedef itk::SymmetricEigenAnalysis<CovarianceMatrix,FeatureVector> EigenAnalysisType;
    EigenAnalysisType eigenAnalysis;
    eigenAnalysis.SetOrderEigenMagnitudes(true); // order by abs val of eigenvals..
    eigenAnalysis.SetDimension(CovarianceMatrix::RowDimensions);
    FeatureVector eigenVals;
    CovarianceMatrix eigenVecs;
    eigenAnalysis.ComputeEigenValuesAndVectors( covariance, eigenVals, eigenVecs );

    // determinant:
    determinant = 1.f;
    float totalPower = 0.f;
    size_t i;
    std::cerr << "eigenvals: ";
    for(i=0; i<eigenVals.Size(); ++i)
    {
      std::cerr << eigenVals[i] << ",";
      determinant *= eigenVals[i];
      totalPower += fabs(eigenVals[i]);
    }
    std::cerr << std::endl;

    // inverse:
    float multiplier = 0.f;
    float epsilon = 10e-4;
    if( fabs(determinant) < epsilon ) // avoid singular matrices
    {
      float power = 0.f;
      // analysis sorts in reverse order..
      for(i=eigenVals.Size(); i>=0; --i)
      {
        power += fabs(eigenVals[i]);
        if( power/totalPower > .95 )
        {
          break; // found "most" of the power of the matrix
        }
      }
      multiplier = fabs(eigenVals[i]);
    }
    inv_covariance.Fill(0);
    for(size_t i=0; i<eigenVals.Size(); ++i)
    {
      if( eigenVals[i] < 0 )
      {
        inv_covariance[i][i] = 1/(eigenVals[i] - multiplier);
      }
      else
      {
        inv_covariance[i][i] = 1/(eigenVals[i] + multiplier);
      }
    }
    // Inv = V' * Sigma^(-1) * V
    inv_covariance = CovarianceMatrix(eigenVecs.GetTranspose()) * inv_covariance * eigenVecs;
  }

  float pdf(const FeatureVector & x) const
  {
    //float sd = std::sqrt(covariance);
    //float scale = 1.f / (sd * std::sqrt(2*M_PI));
    //float e_part = std::exp( -0.5 * ( (x-mean)*(x-mean) / covariance ) );
    //return scale * e_part;
    // calc the multi-variate gaussian log-likelihood:
    // set https://en.wikipedia.org/wiki/Multivariate_normal_distribution
    FeatureVector diff = x - mean;
    const float LOG_2PI = std::log(2*M_PI);
    float dimscale = diff.Size()*LOG_2PI;
    float covscale = std::log(determinant);
    float mahal = diff * (inv_covariance * diff);
    return -0.5*(dimscale + covscale + mahal);
  }

  std::string str() const
  {
    std::stringstream s;
    s << "m=" << mean << " det cov=" << determinant << " mix=" << mix;
    return s.str();
  }
};

typedef std::vector< float > Weight;
typedef std::vector< Weight > WeightList;
typedef std::vector< GaussianModel<9> > GMM;

template<class Vector, class Matrix>
Matrix outer_product(const Vector & v1, const Vector & v2)
{
  Matrix out;
  for(size_t r=0; r<v1.Size(); ++r)
  {
    for(size_t c=0; c<v2.Size(); ++c)
    {
      out[r][c] = v1[r]*v2[c];
    }
  }
}

template<class ImageType>
void maximization( const typename ImageType::Pointer & image, const WeightList & r, GMM & gmm)
{
   for(size_t i=0; i<gmm.size(); ++i)
   {
     gmm[i].mean.Fill(0);
     gmm[i].covariance.Fill(0);
     gmm[i].mix = 0;
   }

  typename ImageType::SizeType r;
  r.Fill(1); // 3x3 neighborhood
  itk::NeighborhoodIterator<ImageType> it(r, image, image->GetLargestPossibleRegion());
  size_t sample_i;
  for(sample_i=0,it.GoToBegin(); !it.IsAtEnd(); ++it,++sample_i)
  {
    FeatureVector x;
    for(size_t i=0; i<it.Size(); ++i)
    {
      x[i] = it.GetPixel(i);
    }
    for(size_t i=0; i<gmm.size(); ++i)
    {
      gmm[i].mean += r[sample_i][i] * x;
      gmm[i].mix += r[sample_i][i];
    }
  }
  for(size_t i=0; i<gmm.size(); ++i)
  {
    gmm[i].mean /= gmm[i].mix;
  }
  typedef typename GMM::value_type::FeatureVector FeatureVector;
  typedef typename GMM::value_type::CovarianceMatrix CovarianceMatrix;
  for(sample_i=0,it.GoToBegin(); !it.IsAtEnd(); ++it,++sample_i)
  {
    FeatureVector x;
    for(size_t i=0; i<it.Size(); ++i)
    {
      x[i] = it.GetPixel(i);
    }
    for(size_t i=0; i<gmm.size(); ++i)
    {
      FeatureVector diff = gmm[i].mean-x;
      gmm[i].variance += r[sample_i][i] * outer_product(diff,diff);
    }
  }
  for(size_t i=0; i<gmm.size(); ++i)
  {
    gmm[i].variance /= gmm[i].mix;
    gmm[i].mix /= r.size();
    gmm[i].update_inv();
  }
}

template<class ImageType>
float expectation( const typename ImageType::Pointer & image, const GMM & gmm, WeightList & r )
{
  typedef typename GMM::value_type::FeatureVector FeatureVector;
  typename ImageType::SizeType r;
  r.Fill(1); // 3x3 neighborhood
  itk::NeighborhoodIterator<ImageType> it(r, image, image->GetLargestPossibleRegion());
  size_t sample_i;
  float total_like = 0.f;
  for(sample_i=0, it.GoToBegin(); !it.IsAtEnd(); ++it,++sample_i)
  {
    FeatureVector x;
    for(size_t i=0; i<it.Size(); ++i)
    {
      x[i] = it.GetPixel(i);
    }
    float sample_like = 0.f;
    for(size_t i=0; i<gmm.size(); ++i)
    {
      r[sample_i][i] = gmm[i].mix * gmm[i].pdf(x);
      sample_like += r[sample_i][i];
    }
    for(size_t i=0; i<gmm.size(); ++i)
    {
      r[sample_i][i] /= sample_like;
    }
    total_like += sample_like;
  }
  return total_like/r.size();
}

template<class ImageType>
float simple_expectation( const typename ImageType::Pointer & image, const GMM & gmm, WeightList & r )
{
  typedef typename GMM::value_type::FeatureVector FeatureVector;
  typename ImageType::SizeType r;
  r.Fill(1); // 3x3 neighborhood
  itk::NeighborhoodIterator<ImageType> it(r, image, image->GetLargestPossibleRegion());
  size_t sample_i;
  float compactness = 0.f;
  for(sample_i=0, it.GoToBegin(); !it.IsAtEnd(); ++it,++sample_i)
  {
    FeatureVector x;
    for(size_t i=0; i<it.Size(); ++i)
    {
      x[i] = it.GetPixel(i);
    }
    float sample_like = 0.f;

    float min_dist = 1e5;
    size_t min_i = 0;
    for(size_t i=0; i<gmm.size(); ++i)
    {
      float dist =  (x-gmm[i].mean).GetNorm();
      if( dist < min_dist )
      {
        min_dist = dist;
        min_i = i;
      }
    }
    for(size_t i=0; i<gmm.size(); ++i)
    {
      if(i==min_i) 
        r[sample_i][i] = 1;
      else
        r[sample_i][i] = 0;
    }
    compactness += min_dist;
  }
  return compactness/r.size();
}

void randweight( Weight & rk )
{
  float norm = 0.f;
  for(size_t i=0; i<rk.size(); ++i)
  {
    rk[i] = static_cast<float>(rand()) / RAND_MAX;
    norm += rk[i];
  }
  norm = std::sqrt(norm);
  for(size_t i=0; i<rk.size(); ++i)
  {
    rk[i] /= norm;
  }
}

#endif
