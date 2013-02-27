/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef DivergenceFilter_hxx
#define DivergenceFilter_hxx

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
DivergenceFilter< TInputImage, TOutputImage >
::BeforeThreadedGenerateData()
{
  m_Norms.resize(this->GetNumberOfThreads());
  for(size_t i=0; i<m_Norms.size(); ++i)
    m_Norms[i] = 0;
}

template< class TInputImage, class TOutputImage >
void
DivergenceFilter< TInputImage, TOutputImage >
::ThreadedGenerateData( const OutputImageRegionType & outputRegionForThread,
                        itk::ThreadIdType threadId)
{
  typedef typename InputImageType::PixelType GradientType;
  typedef typename InputImageType::SizeType SizeType;
  typedef typename InputImageType::IndexType IndexType;
  typedef typename OutputImageType::PixelType PixelType;

  typename InputImageType::ConstPointer input = this->GetInput();
  typename OutputImageType::Pointer output = this->GetOutput();
  SizeType size = input->GetLargestPossibleRegion().GetSize();
  
  itk::ImageRegionConstIteratorWithIndex<InputImageType> it(input, outputRegionForThread);
  itk::ImageRegionIterator<OutputImageType> out(output, outputRegionForThread);
  for(it.GoToBegin(),out.GoToBegin(); !it.IsAtEnd(); ++it,++out)
  {
    PixelType div = 0;
    GradientType grad = it.Get();
    IndexType center = it.GetIndex();
    for(size_t i=0; i<grad.Size(); ++i)
    {
      if(!(center[i] == 0 || center[i] == size[i]-1)) // on edge
      {
        IndexType overOne = center;
        overOne[i] -= 1;
        GradientType gradOverOne = input->GetPixel(overOne);
        div += grad[i] - gradOverOne[i];
      }
    }
    output->SetPixel( out.GetIndex(), -div );

    m_Norms[threadId] += div*div; // frob norm
  }
}

template< class TInputImage, class TOutputImage >
void
DivergenceFilter< TInputImage, TOutputImage >
::AfterThreadedGenerateData()
{
  m_Norm = 0;
  for(size_t i=0; i<m_Norms.size(); ++i)
    m_Norm += m_Norms[i];
  m_Norm = ::sqrt(m_Norm);
}

template< class TInputImage, class TOutputImage >
void
DivergenceFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
}

} // end namespace

#endif
