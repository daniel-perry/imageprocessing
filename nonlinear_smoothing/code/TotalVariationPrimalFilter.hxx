/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef TotalVariationPrimalFilter_hxx
#define TotalVariationPrimalFilter_hxx

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
TotalVariationPrimalFilter< TInputImage, TOutputImage >
::BeforeThreadedGenerateData()
{
  //typename InputImageType::ConstPointer input = this->GetInput();
  //typename OutputImageType::Pointer output = this->GetOutput();
  m_Deltas.resize( this->GetNumberOfThreads() );
}

template< class TInputImage, class TOutputImage >
void
TotalVariationPrimalFilter< TInputImage, TOutputImage >
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
    PixelType div;
    IndexType center = it.GetIndex();
    GradientType gradCenter = gradIt.Get();
    for(size_t i=0; i<gradCenter.Size(); ++i)
    {
      if(!(center[i] == 0 || center[i] == size[i]-1)) // not on edge
      {
        IndexType overOne = center;
        overOne[i] += 1;

        GradientType gradOverOne = m_X->GetPixel(overOne);
        div += gradOverOne[i] - gradCenter[i];
      }
    }

    ///////////////////////
    // Primal Step:
    PixelType y = it.Get();
    y = (1-m_PrimalStepSize) * y + m_PrimalStepSize * (originalIt.Get() - (1/m_Lambda) * div);

    output->SetPixel( it.GetIndex(), y ); // save result
  }
}

template< class TInputImage, class TOutputImage >
void
TotalVariationPrimalFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
  os << "Chambolle: " << m_Chambolle << std::endl;
}

} // end namespace

#endif
