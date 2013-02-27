/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef ShrinkBregmanFilter_hxx
#define ShrinkBregmanFilter_hxx

#include "itkConstNeighborhoodIterator.h"
#include "itkNeighborhoodIterator.h"
#include "itkImageRegionConstIterator.h"
#include "itkImageRegionIterator.h"
#include "itkImageRegionConstIteratorWithIndex.h"
#include "itkImageRegionIteratorWithIndex.h"
#include "itkProgressReporter.h"

namespace imageprocessing
{

float shrink(float a,float b)
{
  if( a>0 && (a-b)>0) return a-b;
  if( a<0 && (a+b)<0) return a+b;
  return 0;
}

template< class TInputImage, class TOutputImage >
void
ShrinkBregmanFilter< TInputImage, TOutputImage >
::ThreadedGenerateData( const OutputImageRegionType & outputRegionForThread,
                        itk::ThreadIdType threadId)
{
  typedef typename VectorImageType::PixelType VectorType;
  typedef typename InputImageType::PixelType PixelType;
  typedef typename InputImageType::SizeType SizeType;
  typedef typename InputImageType::IndexType IndexType;

  typename InputImageType::ConstPointer input = this->GetInput();
  typename OutputImageType::Pointer output = this->GetOutput();
  SizeType size = input->GetLargestPossibleRegion().GetSize();
  
  itk::ImageRegionConstIteratorWithIndex<InputImageType> it(input, outputRegionForThread);
  itk::ImageRegionIterator<VectorImageType> bregIt(m_Bregman, outputRegionForThread);
  for(it.GoToBegin(),bregIt.GoToBegin();
      !it.IsAtEnd(); 
      ++it,++bregIt)
  {
    VectorType d;
    VectorType b = bregIt.Get();
    VectorType grad = it.Get();
    for(size_t i=0; i<d.Size(); ++i)
    {
      d[i] = shrink(grad[i]+b[i],1/m_Lambda);
      b[i] = b[i] + (grad[i]-d[i]);
    }
    output->SetPixel( it.GetIndex(), d );
    m_Bregman->SetPixel( it.GetIndex(), b );
  }
}

template< class TInputImage, class TOutputImage >
void
ShrinkBregmanFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
}

} // end namespace

#endif
