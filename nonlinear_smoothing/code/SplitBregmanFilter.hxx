/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef SplitBregmanFilter_hxx
#define SplitBregmanFilter_hxx

// itk
#include "itkImageRegionConstIterator.h"
#include "itkImageRegionIterator.h"
#include "itkProgressReporter.h"

// local
#include "GradientFilter.h"
#include "GaussSeidelFilter.h"
#include "ShrinkBregmanFilter.h"
#include "DeepCopy.h"

namespace imageprocessing
{

template< class TInputImage, class TOutputImage >
void
SplitBregmanFilter< TInputImage, TOutputImage >
::GenerateData()
{
  typename InputImageType::ConstPointer input = this->GetInput();

  typedef itk::Image<float,InputImageType::ImageDimension> InternalImageType;
  typedef itk::Vector<float,InputImageType::ImageDimension> VectorType;
  typedef itk::Image<VectorType,InputImageType::ImageDimension> VectorImageType;

  typename InternalImageType::Pointer internal = InternalImageType::New();
  DeepCopy<InputImageType,InternalImageType>(input,internal);
  
  typename InternalImageType::Pointer u = InternalImageType::New();
  DeepCopy<InputImageType,InternalImageType>(input,u); // initial guess 

  typename VectorImageType::Pointer shrinkImage = VectorImageType::New();
  shrinkImage->SetRegions(u->GetLargestPossibleRegion());
  shrinkImage->Allocate();
  VectorType zero;
  zero.Fill(0);
  shrinkImage->FillBuffer(zero);

  typename VectorImageType::Pointer bregmanImage = VectorImageType::New();
  bregmanImage->SetRegions(u->GetLargestPossibleRegion());
  bregmanImage->Allocate();
  bregmanImage->FillBuffer(zero);

  m_Lambda = m_Mu*2; // intialize the regularization coefficients

  typedef GaussSeidelFilter<InternalImageType> GS;
  typename GS::Pointer gsFilter = GS::New();
  gsFilter->SetMu(m_Mu);
  gsFilter->SetLambda(m_Lambda);
  gsFilter->SetOriginalImage(internal);
  if(m_ThreadCount > 0)
    gsFilter->SetNumberOfThreads(m_ThreadCount);

  typedef ShrinkBregmanFilter<VectorImageType> ShrinkFilter;
  typename ShrinkFilter::Pointer shrinkFilter = ShrinkFilter::New();
  shrinkFilter->SetLambda(m_Lambda);
  if(m_ThreadCount > 0)
    shrinkFilter->SetNumberOfThreads(m_ThreadCount);

  typedef GradientFilter<InternalImageType> GradFilter;
  typename GradFilter::Pointer gradFilter = GradFilter::New();
  if(m_ThreadCount > 0) 
    gradFilter->SetNumberOfThreads(m_ThreadCount);
  typename VectorImageType::Pointer gradImage;
 
  float delta = itk::NumericTraits<float>::max();
  float epsilon = 0.001; //itk::NumericTraits<float>::min() * 10e3;
  size_t pixels = 1;
  typename InputImageType::SizeType size = input->GetLargestPossibleRegion().GetSize();
  for(size_t i=0; i<InputImageType::ImageDimension; ++i)
  {
    pixels *= size[i];
  }
  for(m_Iters=0; m_Iters<GetMaxIters(); ++m_Iters)
  {
    std::cerr << m_Iters << ": " << std::endl;

    gsFilter->Modified(); // force to run
    gsFilter->SetShrink(shrinkImage);
    gsFilter->SetBregman(bregmanImage);
    gsFilter->SetInput(u);
    try
    {
      gsFilter->Update();
    }
    catch(itk::ExceptionObject e)
    {
      std::cerr << "error running Gauss-Seidel: " << e << std::endl;
      return;
    }
    u = gsFilter->GetOutput();
    delta = gsFilter->GetDelta();

    // check convergence
    std::cerr << "delta: " << delta << std::endl;
    if((m_Iters > 0 && delta < epsilon*pixels) || (m_Iters+1)>=GetMaxIters())
    {
      break;
    }

    gradFilter->Modified(); // force to run
    gradFilter->SetInput(u);
    try
    {
      gradFilter->Update();
    }
    catch(itk::ExceptionObject e)
    {
      std::cerr << "error running gradient: " << e << std::endl;
      return;
    }
    gradImage = gradFilter->GetOutput();

    shrinkFilter->Modified(); // force to run
    shrinkFilter->SetBregman(bregmanImage);
    shrinkFilter->SetInput(gradImage);
    try
    {
      shrinkFilter->Update();
    }
    catch(itk::ExceptionObject e)
    {
      std::cerr << "error running shrink/bregman filter: " << e << std::endl;
      return;
    }
    bregmanImage = shrinkFilter->GetBregman();
    shrinkImage = shrinkFilter->GetOutput();
  }
  if(m_Iters < m_MaxIters)
  {
    std::cerr << "converged in " << m_Iters << " iterations." << std::endl;
  }
  //else
  //{
  //  std::cerr << "warning: iters exceeded max iters." << std::endl;
  //}

  typename OutputImageType::Pointer output = this->GetOutput();
  DeepCopy<InternalImageType,OutputImageType>(u,output); // need to convert to unsigned char.
}

template< class TInputImage, class TOutputImage >
void
SplitBregmanFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
}

} // end namespace

#endif
