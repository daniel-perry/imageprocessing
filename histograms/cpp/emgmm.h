#ifndef emgmm_H
#define emgmm_H

// std
#include <vector>
#include <string>
#include <cstdlib>

// itk
#include <itkImageRegionIterator.h>

struct GaussianModel
{
  float mean;
  float variance;
  float mix;

  float pdf(float x) const
  {
    float sd = std::sqrt(variance);
    float scale = 1.f / (sd * std::sqrt(2*M_PI));
    float e_part = std::exp( -0.5 * ( (x-mean)*(x-mean) / variance ) );
    return scale * e_part;
  }

  std::string str() const
  {
    std::stringstream s;
    s << "m=" << mean << " v=" << variance << " mix=" << mix;
    return s.str();
  }
};

typedef std::vector< float > Weight;
typedef std::vector< Weight > WeightList;
typedef std::vector<GaussianModel> GMM;

template<class ImageType>
void maximization( const typename ImageType::Pointer & image, const WeightList & r, GMM & gmm)
{
   for(size_t i=0; i<gmm.size(); ++i)
   {
     gmm[i].mean = 0;
     gmm[i].variance = 0;
     gmm[i].mix = 0;
   }

  itk::ImageRegionIterator<ImageType> it(image, image->GetLargestPossibleRegion());
  size_t sample_i;
  for(sample_i=0,it.GoToBegin(); !it.IsAtEnd(); ++it,++sample_i)
  {
    float x = static_cast<float>(it.Get());
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

  for(sample_i=0,it.GoToBegin(); !it.IsAtEnd(); ++it,++sample_i)
  {
    float x = static_cast<float>(it.Get());
    for(size_t i=0; i<gmm.size(); ++i)
    {
      gmm[i].variance += r[sample_i][i] * (gmm[i].mean-x)*(gmm[i].mean-x);
    }
  }
  for(size_t i=0; i<gmm.size(); ++i)
  {
    gmm[i].variance /= gmm[i].mix;
    gmm[i].mix /= r.size();
  }
}

template<class ImageType>
float expectation( const typename ImageType::Pointer & image, const GMM & gmm, WeightList & r )
{
  itk::ImageRegionIterator<ImageType> it(image, image->GetLargestPossibleRegion());
  size_t sample_i;
  float total_like = 0.f;
  for(sample_i=0, it.GoToBegin(); !it.IsAtEnd(); ++it,++sample_i)
  {
    typename ImageType::PixelType x = it.Get();
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
  itk::ImageRegionIterator<ImageType> it(image, image->GetLargestPossibleRegion());
  size_t sample_i;
  float compactness = 0.f;
  for(sample_i=0, it.GoToBegin(); !it.IsAtEnd(); ++it,++sample_i)
  {
    typename ImageType::PixelType x = it.Get();
    float sample_like = 0.f;

    float min_dist = 1e5;
    size_t min_i = 0;
    for(size_t i=0; i<gmm.size(); ++i)
    {
      float dist = std::fabs( static_cast<float>(x)-gmm[i].mean );
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
