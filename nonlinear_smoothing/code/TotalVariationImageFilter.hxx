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
#include "DeepCopy.h"

namespace imageprocessing
{

template< class TInputImage, class TOutputImage >
void
TotalVariationImageFilter< TInputImage, TOutputImage >
::GenerateData()
{
  typename InputImageType::ConstPointer input = this->GetInput();

  typedef itk::Image<float,InputImageType::ImageDimension> InternalImageType;
  typename InternalImageType::Pointer internal = InternalImageType::New();
  DeepCopy<InputImageType,InternalImageType>(input,internal);

  typedef UnitGradientFilter<InternalImageType> GradFilter;
  typedef typename GradFilter::OutputImageType VectorImageType;
  typename GradFilter::Pointer gradFilter = GradFilter::New();
  if(GetThreadCount()>0) gradFilter->SetNumberOfThreads(GetThreadCount());
  gradFilter->SetInput(internal);
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

  typedef TotalVariationDualFilter<InternalImageType> DualFilter;
  typename DualFilter::Pointer dualFilter = DualFilter::New();
  dualFilter->SetChambolle(this->GetChambolle());
  dualFilter->SetDualStepSize(this->GetDualStepSize());
  dualFilter->SetLambda(this->GetLambda());
  dualFilter->SetX(gradImage);
  dualFilter->SetInput(internal);

  typedef TotalVariationPrimalFilter<InternalImageType> PrimalFilter;
  typename PrimalFilter::Pointer primalFilter = PrimalFilter::New();
  primalFilter->SetChambolle(this->GetChambolle());
  primalFilter->SetPrimalStepSize(this->GetPrimalStepSize());
  primalFilter->SetLambda(this->GetLambda());
  primalFilter->SetInput(internal);
  primalFilter->SetOriginalImage(internal);


  typename InternalImageType::Pointer filterOutput;
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
    dualFilter->Modified(); // force to run
    try
    {
      dualFilter->Update();
    }
    catch(itk::ExceptionObject e)
    {
      std::cerr << "error running dual filter: " << e << std::endl;
      return;
    }
    primalFilter->Modified(); // force to run
    primalFilter->SetX(dualFilter->GetX());
    try
    {
      primalFilter->Update();
    }
    catch(itk::ExceptionObject e)
    {
      std::cerr << "error running primal filter: " << e << std::endl;
      return;
    }
    filterOutput = primalFilter->GetOutput();
    delta = primalFilter->GetDelta();

    std::cerr << "delta: " << delta << std::endl;

    // check convergence
    if(delta < epsilon*pixels)
    {
      break;
    }
    
    // update steps sizes
    
    dualFilter->SetInput(filterOutput);
    primalFilter->SetInput(filterOutput);
  }
  if(m_Iters < m_MaxIters)
  {
    std::cerr << "converged in " << m_Iters << " iterations." << std::endl;
  }
  else
  {
    std::cerr << "warning: iters exceeded max iters, did not converge." << std::endl;
  }

  // set output to be tv filter output
  typename OutputImageType::Pointer output = this->GetOutput();
  output->SetRegions(input->GetLargestPossibleRegion());
  output->Allocate();
  DeepCopy<InternalImageType,OutputImageType>(filterOutput,output); // need to convert to unsigned char.
  /*
  output->SetOrigin(filterOutput->GetOrigin());
  output->SetSpacing(filterOutput->GetSpacing());
  output->SetLargestPossibleRegion(filterOutput->GetLargestPossibleRegion());
  output->SetBufferedRegion(filterOutput->GetBufferedRegion());
  output->SetRequestedRegion(filterOutput->GetRequestedRegion());
  output->SetPixelContainer(filterOutput->GetPixelContainer());
  */
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
