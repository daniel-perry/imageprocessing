/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef ChambolleDualFilter_hxx
#define ChambolleDualFilter_hxx

#include "itkConstNeighborhoodIterator.h"
#include "itkNeighborhoodIterator.h"
#include "itkImageRegionConstIterator.h"
#include "itkImageRegionIterator.h"
#include "itkImageRegionConstIteratorWithIndex.h"
#include "itkImageRegionIteratorWithIndex.h"
#include "itkProgressReporter.h"

namespace imageprocessing
{

template< class TInputImage, class TOutputImage >
void
ChambolleDualFilter< TInputImage, TOutputImage >
::AllocateOutputs()
{
  typename OutputImageType::Pointer outputPtr;

  // Allocate the output memory
  for ( typename itk::OutputDataObjectIterator it(this); !it.IsAtEnd(); it++ )
  {
    // Check whether the output is an image of the appropriate
    // dimension (use ProcessObject's version of the GetInput()
    // method since it returns the input as a pointer to a
    // DataObject as opposed to the subclass version which
    // static_casts the input to an TInputValue).
    outputPtr = dynamic_cast< OutputImageType * >( it.GetOutput() );

    if ( outputPtr )
    {
      // need some output object... making a tmp 1x1x1 image..
      typename InputImageType::ConstPointer input = this->GetInput();
      typename OutputImageType::RegionType outputSize = input->GetLargestPossibleRegion();
      outputPtr->SetRegions( outputSize );
      //outputPtr->Allocate(); // don't allocate, just need region definition..
    }
  }
}

template< class TInputImage, class TOutputImage >
void
ChambolleDualFilter< TInputImage, TOutputImage >
::BeforeThreadedGenerateData()
{
  m_Deltas.resize( this->GetNumberOfThreads() );
  m_StepSizeEst.resize( this->GetNumberOfThreads() );
  for(size_t i=0; i<m_Deltas.size(); ++i)
  {
    m_Deltas[i] = 0;
    m_StepSizeEst[i] = 0;
  }
}

template< class TInputImage, class TOutputImage >
void
ChambolleDualFilter< TInputImage, TOutputImage >
::ThreadedGenerateData( const OutputImageRegionType & outputRegionForThread,
                        itk::ThreadIdType threadId)
{
  typedef typename VectorImageType::PixelType GradientType;
  typedef typename InputImageType::PixelType PixelType;
  typedef typename InputImageType::SizeType SizeType;
  typedef typename InputImageType::IndexType IndexType;

  typename InputImageType::ConstPointer input = this->GetInput();
  typename OutputImageType::Pointer output = this->GetOutput();
  SizeType size = input->GetLargestPossibleRegion().GetSize();
  
  itk::ImageRegionConstIteratorWithIndex<InputImageType> it(input, outputRegionForThread);
  itk::ImageRegionIterator<OutputImageType> outIt(output, outputRegionForThread);
  itk::ImageRegionIterator<VectorImageType> gradIt(m_X, outputRegionForThread);
  itk::ImageRegionIterator<OutputImageType> divIt(m_Div, outputRegionForThread);
  for(it.GoToBegin(),outIt.GoToBegin(),gradIt.GoToBegin(),divIt.GoToBegin(); 
      !it.IsAtEnd(); 
      ++it,++outIt,++gradIt,++divIt)
  {
    /////////////////////////////////
    // compute gradient on modified divergence
    GradientType grad;
    GradientType originalGrad;
    IndexType center = it.GetIndex();
    for(size_t i=0; i<grad.Size(); ++i)
    {
      if(center[i] == 0 || center[i] == size[i]-1) // on edge
      {
        grad[i] = 0;
      }
      else
      {
        IndexType overOne = center;
        overOne[i] += 1;
        grad[i] = m_Div->GetPixel(overOne) - divIt.Get();

        originalGrad[i] = input->GetPixel(overOne) - it.Get();
      }
    }

    ///////////////////////
    // Dual Step:
    GradientType x = gradIt.Get();
    GradientType xp = (grad + originalGrad*m_Lambda);

    float norm = xp.GetNorm();
    if(norm > m_StepSizeEst[threadId])
      m_StepSizeEst[threadId] = norm;

    xp = x - m_DualStepSize * xp;

    // normalize
    xp /= xp.GetNorm() + itk::NumericTraits<float>::min();
    for(size_t i=0; i<x.Size(); ++i)
    {
      if(std::isnan(xp[i])) 
      {
        throw itk::ExceptionObject("NaN detected in Dual step");
      }
    }

    m_Deltas[threadId] += (xp-x).GetNorm();

    m_X->SetPixel( gradIt.GetIndex(), xp ); // save result
  }
}

template< class TInputImage, class TOutputImage >
void
ChambolleDualFilter< TInputImage, TOutputImage >
::AfterThreadedGenerateData()
{
  m_Delta = 0;
  m_DualStepSize = 0;
  for(size_t i=0; i<m_Deltas.size(); ++i)
  {
    m_Delta += m_Deltas[i];
    if(m_DualStepSize < m_StepSizeEst[i])
      m_DualStepSize = m_StepSizeEst[i];
  }
  m_DualStepSize = 1/(2.5*m_DualStepSize + itk::NumericTraits<float>::min()); // step size for next iter
}


template< class TInputImage, class TOutputImage >
void
ChambolleDualFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
}

} // end namespace

#endif
