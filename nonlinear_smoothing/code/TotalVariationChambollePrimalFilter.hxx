/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef TotalVariationChambollePrimalFilter_hxx
#define TotalVariationChambollePrimalFilter_hxx

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
TotalVariationChambollePrimalFilter< TInputImage, TOutputImage >
::BeforeThreadedGenerateData()
{
  //typename InputImageType::ConstPointer input = this->GetInput();
  //typename OutputImageType::Pointer output = this->GetOutput();
  if(m_Deltas.size() != this->GetNumberOfThreads())
    m_Deltas.resize( this->GetNumberOfThreads() );
  for(size_t i=0; i<m_Deltas.size(); ++i)
    m_Deltas[i] = 0;
}

template< class TInputImage, class TOutputImage >
void
TotalVariationChambollePrimalFilter< TInputImage, TOutputImage >
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
      if(!(center[i] == 0 || center[i] == size[i]-1)) // not on edge
      {
        IndexType overOne = center;
        overOne[i] -= 1;

        GradientType gradOverOne = m_X->GetPixel(overOne);
        div += gradOverOne[i] - gradCenter[i];
      }
    }
    div = -div; // we want the negative divergence

    ///////////////////////
    // Primal Step:
    PixelType y = it.Get();
    PixelType tmp = y;

    y = (1-m_PrimalStepSize) * y + m_PrimalStepSize * (originalIt.Get() - (1/m_Lambda) * div);
    if(std::isnan(y))
    {
      throw itk::ExceptionObject("NaN detected in Primal step");
    }

    //////////////////////
    // Convergence criteria

    output->SetPixel( it.GetIndex(), y ); // save result
    m_Deltas[threadId] += fabs(tmp-y);
  }
}

template< class TInputImage, class TOutputImage >
void
TotalVariationChambollePrimalFilter< TInputImage, TOutputImage >
::AfterThreadedGenerateData()
{
  m_Delta = 0;
  for(size_t i=0; i<m_Deltas.size(); ++i)
    m_Delta += m_Deltas[i];
}



template< class TInputImage, class TOutputImage >
void
TotalVariationChambollePrimalFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
  os << "Chambolle: " << m_Chambolle << std::endl;
}

} // end namespace

#endif
