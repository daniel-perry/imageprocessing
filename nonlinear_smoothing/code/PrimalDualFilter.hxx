/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef PrimalDualFilter_hxx
#define PrimalDualFilter_hxx

// itk
#include "itkImageRegionConstIterator.h"
#include "itkImageRegionIterator.h"
#include "itkProgressReporter.h"

// local
#include "UnitGradientFilter.h"
#include "PrimalFilter.h"
#include "DualFilter.h"
#include "DeepCopy.h"

namespace imageprocessing
{

template< class TInputImage, class TOutputImage >
void
PrimalDualFilter< TInputImage, TOutputImage >
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

  typedef DualFilter<InternalImageType> DualFilter;
  typename DualFilter::Pointer dualFilter = DualFilter::New();
  dualFilter->SetLambda(this->GetLambda());
  dualFilter->SetX(gradImage);
  dualFilter->SetInput(internal);
  dualFilter->SetNumberOfThreads(1);

  typedef PrimalFilter<InternalImageType> PrimalFilter;
  typename PrimalFilter::Pointer primalFilter = PrimalFilter::New();
  primalFilter->SetLambda(this->GetLambda());
  primalFilter->SetInput(internal);
  primalFilter->SetOriginalImage(internal);
  primalFilter->SetNumberOfThreads(1);

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

    // update steps sizes
    float tau = GetDualStepSize() + 0.08 * m_Iters;
    float theta = (0.5 - (5/(15+m_Iters)))/tau;
 
    dualFilter->Modified(); // force to run
    dualFilter->SetDualStepSize(tau);
    if(m_Iters>0) dualFilter->SetInput(filterOutput);
    try
    {
      std::cerr << "running dual.." << std::endl;
      dualFilter->Update();
    }
    catch(itk::ExceptionObject e)
    {
      std::cerr << "error running dual filter: " << e << std::endl;
      return;
    }
    primalFilter->Modified(); // force to run
    primalFilter->SetPrimalStepSize(theta);
    primalFilter->SetX(dualFilter->GetX());
    if(m_Iters>0) primalFilter->SetInput(filterOutput);
    try
    {
      std::cerr << "running primal.." << std::endl;
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
  output->SetRegions(input->GetLargestPossibleRegion());
  output->Allocate();
  DeepCopy<InternalImageType,OutputImageType>(filterOutput,output); // need to convert to unsigned char.
}

template< class TInputImage, class TOutputImage >
void
PrimalDualFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
}

} // end namespace

#endif
