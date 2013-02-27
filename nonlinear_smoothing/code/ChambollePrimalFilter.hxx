/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef ChambollePrimalFilter_hxx
#define ChambollePrimalFilter_hxx

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
ChambollePrimalFilter< TInputImage, TOutputImage >
::BeforeThreadedGenerateData()
{
  if(m_Deltas.size() != this->GetNumberOfThreads())
    m_Deltas.resize( this->GetNumberOfThreads() );
  for(size_t i=0; i<m_Deltas.size(); ++i)
    m_Deltas[i] = 0;
}

template< class TInputImage, class TOutputImage >
void
ChambollePrimalFilter< TInputImage, TOutputImage >
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
  itk::ImageRegionConstIterator<InputImageType> originalIt(m_OriginalImage, outputRegionForThread);
  for(it.GoToBegin(),outIt.GoToBegin(),gradIt.GoToBegin(),originalIt.GoToBegin(); 
      !it.IsAtEnd(); 
      ++it,++outIt,++gradIt,++originalIt)
  {
    ////////////////////////////////////
    // compute divergence on current X:
    PixelType div = 0;
    IndexType center = it.GetIndex();
    GradientType gradCenter = gradIt.Get();
    for(size_t i=0; i<gradCenter.Size(); ++i)
    {
      IndexType overOne = center;
      overOne[i] -= 1;
      GradientType gradOverOne = m_X->GetPixel(overOne);
      if(center[i] == 0)
      {
        div += gradCenter[i]; // border case - see Chambolle's paper, p.2
      }
      else if(center[i] == size[i]-1)
      {
        div += -gradOverOne[i]; // border case - see Chambolle's paper, p.2
      }
      else // not on border
      {
        div += gradCenter[i] - gradOverOne[i];
      }
 
    }

    ///////////////////////
    // Primal Step:
    PixelType y = it.Get();
    PixelType tmp = y;

    y = y + m_Lambda * div;
    if(std::isnan(y))
    {
      throw itk::ExceptionObject("NaN detected in Primal step");
    }

    output->SetPixel( it.GetIndex(), y ); // save result
    m_Deltas[threadId] += fabs(tmp-y);
  }
}

template< class TInputImage, class TOutputImage >
void
ChambollePrimalFilter< TInputImage, TOutputImage >
::AfterThreadedGenerateData()
{
  m_Delta = 0;
  for(size_t i=0; i<m_Deltas.size(); ++i)
    m_Delta += m_Deltas[i];
}



template< class TInputImage, class TOutputImage >
void
ChambollePrimalFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
}

} // end namespace

#endif
