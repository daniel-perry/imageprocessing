/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef ChambolleFilter_hxx
#define ChambolleFilter_hxx

// itk
#include "itkImageRegionConstIterator.h"
#include "itkImageRegionIterator.h"
#include "itkProgressReporter.h"

// local
#include "UnitGradientFilter.h"
#include "DivergenceFilter.h"
#include "ChambollePrimalFilter.h"
#include "ChambolleDualFilter.h"
#include "DeepCopy.h"

namespace imageprocessing
{

template< class TInputImage, class TOutputImage >
void
ChambolleFilter< TInputImage, TOutputImage >
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

  typedef DivergenceFilter<VectorImageType> DivFilter;
  typename DivFilter::Pointer divFilter = DivFilter::New();
  if(GetThreadCount()>0) divFilter->SetNumberOfThreads(GetThreadCount());
  divFilter->SetInput(gradImage);
  typename InternalImageType::Pointer divImage = divFilter->GetOutput();
  try
  {
    divFilter->Update();
  }
  catch(itk::ExceptionObject e)
  {
    std::cerr << "Error running divergence filter: " << e << std::endl;
    return;
  }

  typedef ChambolleDualFilter<InternalImageType> DualFilter;
  typename DualFilter::Pointer dualFilter = DualFilter::New();
  dualFilter->SetLambda(this->GetLambda());
  dualFilter->SetDualStepSize(this->GetDualStepSize());
  dualFilter->SetInput(internal);
  dualFilter->SetNumberOfThreads(1);

  typedef ChambollePrimalFilter<InternalImageType> PrimalFilter;
  typename PrimalFilter::Pointer primalFilter = PrimalFilter::New();
  primalFilter->SetLambda(this->GetLambda());
  primalFilter->SetInput(internal);
  primalFilter->SetOriginalImage(internal);
  primalFilter->SetNumberOfThreads(1);

  typename InternalImageType::Pointer filterOutput;
  float delta = itk::NumericTraits<float>::max();
  float innerDelta = itk::NumericTraits<float>::max();
  float epsilon = 0.001; //itk::NumericTraits<float>::min() * 10e3;
  size_t pixels = 1;
  typename InputImageType::SizeType size = input->GetLargestPossibleRegion().GetSize();
  for(size_t i=0; i<InputImageType::ImageDimension; ++i)
  {
    pixels *= size[i];
  }

  for(m_Iters=0; m_Iters<GetMaxIters(); ++m_Iters)
  {
    std::cerr << std::endl;
    std::cerr << "================" << std::endl;
    std::cerr << "outer iter: " << m_Iters << std::endl;
    std::cerr << "================" << std::endl;

    if(m_Iters>0)
    {
      gradFilter->SetInput(filterOutput);
      gradFilter->Modified();
      gradImage = gradFilter->GetOutput();
      try
      {
        gradFilter->Update();
      }
      catch(itk::ExceptionObject e)
      {
        std::cerr << "Error running gradient filter: " << e << std::endl;
        return;
      }

      divFilter->SetInput(gradImage);
      divFilter->Modified();
      divImage = divFilter->GetOutput();
      try
      {
        divFilter->Update();
      }
      catch(itk::ExceptionObject e)
      {
        std::cerr << "Error running divergence filter: " << e << std::endl;
        return;
      }
    }
 
    for(size_t iters=0; iters<1000; ++iters)
    {
      dualFilter->Modified(); // force to run
      dualFilter->SetX(gradImage);
      dualFilter->SetDiv(divImage);
      if(m_Iters>0) dualFilter->SetInput(filterOutput); // set original to be output of primal step..
      try
      {
        dualFilter->Update();
      }
      catch(itk::ExceptionObject e)
      {
        std::cerr << "error running dual filter: " << e << std::endl;
        return;
      }
      innerDelta = dualFilter->GetDelta();

      if(innerDelta < epsilon*pixels)
      {
        std::cerr << "inner converged!" << std::endl;
        break;
      }

      gradImage = dualFilter->GetX();

      divFilter->SetInput(gradImage);
      divFilter->Modified(); // force to run
      typename InternalImageType::Pointer divImage = divFilter->GetOutput();
      try
      {
        divFilter->Update();
      }
      catch(itk::ExceptionObject e)
      {
        std::cerr << "Error running divergence filter: " << e << std::endl;
        return;
      }
      divImage = divFilter->GetOutput();

      if(iters%50==0)
      {
        std::cerr << std::endl << "inner delta: " << innerDelta << std::endl;
        std::cerr << "frob norm of div: " << divFilter->GetNorm() << std::endl;
      }

      std::cerr << ".";
    }
    std::cerr << std::endl;
    std::cerr << "inner delta: " << innerDelta << std::endl;

    primalFilter->Modified(); // force to run
    primalFilter->SetPrimalStepSize(1); // theta = 1
    primalFilter->SetX(dualFilter->GetX());
    if(m_Iters>0) primalFilter->SetInput(filterOutput);
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

    // check convergence
    if(delta < epsilon*pixels)
    {
      break;
    }
    std::cerr << "outer delta: " << delta << std::endl;
  }

  if(m_Iters < m_MaxIters)
  {
    std::cerr << "converged in " << m_Iters << " iterations." << std::endl;
  }
  //else
  //{
  //  std::cerr << "warning: iters exceeded max iters, did not converge." << std::endl;
  //}

  typename OutputImageType::Pointer output = this->GetOutput();
  output->SetRegions(input->GetLargestPossibleRegion());
  output->Allocate();
  DeepCopy<InternalImageType,OutputImageType>(filterOutput,output); // need to convert to unsigned char.
}

template< class TInputImage, class TOutputImage >
void
ChambolleFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
}

} // end namespace

#endif
