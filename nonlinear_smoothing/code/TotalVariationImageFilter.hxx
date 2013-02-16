/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef TotalVariationImageFilter_hxx
#define TotalVariationImageFilter_hxx

// itk
#include "itkImageRegionConstIterator.h"
#include "itkImageRegionIterator.h"
#include "itkProgressReporter.h"

// local
#include "UnitGradientFilter.h"
#include "TotalVariationPrimalFilter.h"
#include "TotalVariationDualFilter.h"

namespace imageprocessing
{

template< class TInputImage, class TOutputImage >
void
TotalVariationImageFilter< TInputImage, TOutputImage >
::GenerateData()
{
  typename InputImageType::ConstPointer input = this->GetInput();

  typedef UnitGradientFilter<InputImageType> GradFilter;
  typedef typename GradFilter::OutputImageType VectorImageType;
  typename GradFilter::Pointer gradFilter = GradFilter::New();
  if(GetThreadCount()>0) gradFilter->SetNumberOfThreads(GetThreadCount());
  gradFilter->SetInput(input);
  typename VectorImageType::Pointer gradImage = gradFilter->GetOutput();
  try
  {
    gradFilter->Update();
  }
  catch(itk::ExceptionObject e)
  {
    std::cerr << "Error running gradient filter: " << e << std::endl;
    return;
  }

  typedef TotalVariationDualFilter<TInputImage,TOutputImage> DualFilter;
  typename DualFilter::Pointer dualFilter = DualFilter::New();
  dualFilter->SetChambolle(this->GetChambolle());
  dualFilter->SetDualStepSize(this->GetDualStepSize());
  dualFilter->SetLambda(this->GetLambda());
  dualFilter->SetX(gradImage);
  dualFilter->SetInput(input);

  typedef TotalVariationPrimalFilter<TInputImage,TOutputImage> PrimalFilter;
  typename PrimalFilter::Pointer primalFilter = PrimalFilter::New();
  primalFilter->SetChambolle(this->GetChambolle());
  primalFilter->SetPrimalStepSize(this->GetPrimalStepSize());
  primalFilter->SetLambda(this->GetLambda());
  primalFilter->SetInput(input);
  primalFilter->SetOriginalImage(input);


  typename OutputImageType::Pointer filterOutput;
  float delta = itk::NumericTraits<float>::max();
  float epsilon = itk::NumericTraits<float>::min() * 10e3;
  size_t pixels = 1;
  typename InputImageType::SizeType size = input->GetLargestPossibleRegion().GetSize();
  for(size_t i=0; i<InputImageType::ImageDimension; ++i)
  {
    pixels *= size[i];
  }
  size_t iters;
  for(iters=0; iters<GetMaxIters(); ++iters)
  {
    dualFilter->Modified(); // force to run
    try
    {
      dualFilter->Update();
    }
    catch(itk::ExceptionObject e)
    {
      std::cerr << "error running total variation filter: " << e << std::endl;
      return;
    }
    primalFilter->SetX(dualFilter->GetX());
    filterOutput = primalFilter->GetOutput();
    delta = primalFilter->GetDelta();

    // check convergence
    if(delta < epsilon*pixels)
    {
      break;
    }
    
    // update steps sizes
    
    dualFilter->SetInput(filterOutput);
    primalFilter->SetInput(filterOutput);
  }
  if(iters < GetMaxIters())
  {
    std::cerr << "converged!" << std::endl;
  }
  else
  {
    std::cerr << "warning: iters exceeded max iters, did not converge." << std::endl;
  }

  // set output to be tv filter output
  typename OutputImageType::Pointer output = this->GetOutput();
  output->SetOrigin(filterOutput->GetOrigin());
  output->SetSpacing(filterOutput->GetSpacing());
  output->SetLargestPossibleRegion(filterOutput->GetLargestPossibleRegion());
  output->SetBufferedRegion(filterOutput->GetBufferedRegion());
  output->SetRequestedRegion(filterOutput->GetRequestedRegion());
  output->SetPixelContainer(filterOutput->GetPixelContainer());
}

template< class TInputImage, class TOutputImage >
void
TotalVariationImageFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
  os << "Chambolle: " << m_Chambolle << std::endl;
}

} // end namespace

#endif
