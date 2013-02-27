/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef GaussSeidelFilter_hxx
#define GaussSeidelFilter_hxx

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
GaussSeidelFilter< TInputImage, TOutputImage >
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
      outputPtr->Allocate(); // don't allocate, just need region definition..
    }
  }
}

template< class TInputImage, class TOutputImage >
void
GaussSeidelFilter< TInputImage, TOutputImage >
::BeforeThreadedGenerateData()
{
  m_Deltas.resize( this->GetNumberOfThreads() );
}

template< class TInputImage, class TOutputImage >
void
GaussSeidelFilter< TInputImage, TOutputImage >
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
  itk::ImageRegionConstIteratorWithIndex<InputImageType> originalIt(m_OriginalImage, outputRegionForThread);
  itk::ImageRegionIterator<VectorImageType> shrinkIt(m_Shrink, outputRegionForThread);
  itk::ImageRegionIterator<VectorImageType> bregIt(m_Bregman, outputRegionForThread);
  for(it.GoToBegin(),shrinkIt.GoToBegin(),bregIt.GoToBegin(),originalIt.GoToBegin(); 
      !it.IsAtEnd(); 
      ++it,++shrinkIt,++bregIt,++originalIt)
  {
    IndexType center = it.GetIndex();
    float gs = 0;
    for(size_t i=0; i<center.GetIndexDimension(); ++i)
    {
      IndexType backOne = center;
      backOne[i] -= 1;
      IndexType forwardOne = center;
      forwardOne[i] += 1;
      if(center[i] == 0) 
      {
        gs += input->GetPixel(forwardOne); 
        gs -= shrinkIt.Get()[i];
        gs += bregIt.Get()[i];
      }
      else if(center[i] == size[i]-1)
      {
        gs += input->GetPixel(backOne);
        gs += m_Shrink->GetPixel(backOne)[i] - shrinkIt.Get()[i];
        gs -= m_Bregman->GetPixel(backOne)[i] + bregIt.Get()[i];
      }
      else
      {
        gs += input->GetPixel(forwardOne) + input->GetPixel(backOne);
        gs += m_Shrink->GetPixel(backOne)[i] - shrinkIt.Get()[i];
        gs += - m_Bregman->GetPixel(backOne)[i] + bregIt.Get()[i];
      }
    }

    gs = gs * m_Lambda/(m_Mu+4*m_Lambda) + originalIt.Get() * m_Mu/(m_Mu+4*m_Lambda);

    m_Deltas[threadId] += fabs(gs-it.Get());

    output->SetPixel( it.GetIndex(), gs ); // save result
  }
}

template< class TInputImage, class TOutputImage >
void
GaussSeidelFilter< TInputImage, TOutputImage >
::AfterThreadedGenerateData()
{
  m_Delta = 0;
  for(size_t i=0; i<m_Deltas.size(); ++i)
    m_Delta += m_Deltas[i];
}


template< class TInputImage, class TOutputImage >
void
GaussSeidelFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
}

} // end namespace

#endif
