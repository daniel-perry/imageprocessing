/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef TotalVariationChambolleDualFilter_hxx
#define TotalVariationChambolleDualFilter_hxx

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
TotalVariationChambolleDualFilter< TInputImage, TOutputImage >
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
TotalVariationChambolleDualFilter< TInputImage, TOutputImage >
::BeforeThreadedGenerateData()
{
  //typename InputImageType::ConstPointer input = this->GetInput();
  //typename OutputImageType::Pointer output = this->GetOutput();
  m_Deltas.resize( this->GetNumberOfThreads() );
}

template< class TInputImage, class TOutputImage >
void
TotalVariationChambolleDualFilter< TInputImage, TOutputImage >
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
  for(it.GoToBegin(),outIt.GoToBegin(),gradIt.GoToBegin(); 
      !it.IsAtEnd(); 
      ++it,++outIt,++gradIt)
  {
    ////////////////////////////////////
    // compute divergence on current X:
    PixelType div = 0;
    IndexType center = it.GetIndex();
    GradientType gradCenter = gradIt.Get();
    for(size_t i=0; i<gradCenter.Size(); ++i)
    {
      if(!(center[i] == 0 || center[i] == size[i]-1)) // not on edge
      {
        IndexType overOne = center;
        overOne[i] -= 1;

        GradientType gradOverOne = m_X->GetPixel(overOne);
        div += gradOverOne[i] - gradCenter[i];
      }
    }
    div = -div; // we want the negative divergence

    /////////////////////////////////
    // compute gradient on current Y:
    GradientType grad;
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
        grad[i] = input->GetPixel(overOne) - it.Get();
      }
    }
    grad = -grad;

    ///////////////////////
    // Dual Step:
    GradientType x = gradIt.Get();
    GradientType xp = x + m_DualStepSize * m_Lambda * grad;

    // project onto X (see Remark 2 on p. 10)
    for(size_t i=0; i<xp.Size(); ++i)
    {
      typename GradientType::ComponentType den=fabs(xp[i]);
      if( den > 1 )
      {
        xp[i] /= den;
      }
    }
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
TotalVariationChambolleDualFilter< TInputImage, TOutputImage >
::AfterThreadedGenerateData()
{
  m_Delta = 0;
  for(size_t i=0; i<m_Deltas.size(); ++i)
    m_Delta += m_Deltas[i];
}


template< class TInputImage, class TOutputImage >
void
TotalVariationChambolleDualFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
  os << "Chambolle: " << m_Chambolle << std::endl;
}

} // end namespace

#endif
