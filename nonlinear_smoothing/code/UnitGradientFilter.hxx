/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef UnitGradientFilter_hxx
#define UnitGradientFilter_hxx

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
UnitGradientFilter< TInputImage, TOutputImage >
::BeforeThreadedGenerateData()
{
}

template< class TInputImage, class TOutputImage >
void
UnitGradientFilter< TInputImage, TOutputImage >
::ThreadedGenerateData( const OutputImageRegionType & outputRegionForThread,
                        itk::ThreadIdType threadId)
{
  typedef typename OutputImageType::PixelType GradientType;
  typedef typename InputImageType::SizeType SizeType;
  typedef typename InputImageType::IndexType IndexType;

  typename InputImageType::ConstPointer input = this->GetInput();
  typename OutputImageType::Pointer output = this->GetOutput();
  SizeType size = input->GetLargestPossibleRegion().GetSize();
  
  itk::ImageRegionConstIteratorWithIndex<InputImageType> it(input, outputRegionForThread);
  itk::ImageRegionIterator<OutputImageType> out(output, outputRegionForThread);
  for(it.GoToBegin(),out.GoToBegin(); !it.IsAtEnd(); ++it,++out)
  {
    GradientType grad;
    //grad.SetSize(InputImageType::Dimension);
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
    grad = grad / grad.GetNorm();
    output->SetPixel( out.GetIndex(), grad );
  }
}

template< class TInputImage, class TOutputImage >
void
UnitGradientFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
}

} // end namespace

#endif
