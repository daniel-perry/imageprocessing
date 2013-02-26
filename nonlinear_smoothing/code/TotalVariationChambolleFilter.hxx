/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef TotalVariationChambolleFilter_hxx
#define TotalVariationChambolleFilter_hxx

// itk
#include "itkImageRegionConstIterator.h"
#include "itkImageRegionIterator.h"
#include "itkProgressReporter.h"

// local
#include "UnitGradientFilter.h"
#include "DivergenceFilter.h"
#include "TotalVariationChambollePrimalFilter.h"
#include "TotalVariationChambolleDualFilter.h"
#include "DeepCopy.h"

namespace imageprocessing
{

template< class TInputImage, class TOutputImage >
void
TotalVariationChambolleFilter< TInputImage, TOutputImage >
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

  typedef TotalVariationChambolleDualFilter<InternalImageType> DualFilter;
  typename DualFilter::Pointer dualFilter = DualFilter::New();
  dualFilter->SetChambolle(this->GetChambolle());
  dualFilter->SetLambda(this->GetLambda());
  dualFilter->SetInput(internal);
  dualFilter->SetNumberOfThreads(1);

  typedef TotalVariationChambollePrimalFilter<InternalImageType> PrimalFilter;
  typename PrimalFilter::Pointer primalFilter = PrimalFilter::New();
  primalFilter->SetChambolle(this->GetChambolle());
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
    std::cerr << m_Iters << ": " << std::endl;
 
    //for(size_t iters=0; iters<GetMaxIters(); ++iters)
    for(size_t iters=0; iters<300; ++iters)
    {
      // update steps sizes
      float tau = GetDualStepSize();
   
      dualFilter->Modified(); // force to run
      dualFilter->SetDualStepSize(tau);
      dualFilter->SetX(gradImage);
      dualFilter->SetDiv(divImage);
      try
      {
        //std::cerr << "running dual.." << std::endl;
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
    //float theta = (0.5 - (5/(15+m_Iters)))/tau;
    primalFilter->SetPrimalStepSize(1); // theta = 1
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

    // check convergence
    if(delta < epsilon*pixels)
    {
      break;
    }
    std::cerr << "delta: " << delta << std::endl;
  }

  if(m_Iters < m_MaxIters)
  {
    std::cerr << "converged in " << m_Iters << " iterations." << std::endl;
  }
  else
  {
    std::cerr << "warning: iters exceeded max iters, did not converge." << std::endl;
  }

  { // debug
    typedef itk::ImageFileWriter<InternalImageType> TmpWriter;
    typename TmpWriter::Pointer tmpwriter = TmpWriter::New();
    tmpwriter->SetInput(filterOutput);
    tmpwriter->SetFileName("tmp_filterout.nrrd");
    tmpwriter->Update();
  }

  typename OutputImageType::Pointer output = this->GetOutput();
  output->SetRegions(input->GetLargestPossibleRegion());
  output->Allocate();
  DeepCopy<InternalImageType,OutputImageType>(filterOutput,output); // need to convert to unsigned char.
  /*
  // set output to be tv filter output
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
TotalVariationChambolleFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
  os << "Chambolle: " << m_Chambolle << std::endl;
}

} // end namespace

#endif
