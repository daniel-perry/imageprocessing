/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef TotalVariationImageFilter_hxx
#define TotalVariationImageFilter_hxx

#include "itkImageRegionConstIterator.h"
#include "itkImageRegionIterator.h"
#include "itkProgressReporter.h"

namespace imageprocessing
{

template< class TInputImage, class TOutputImage >
void
TotalVariationImageFilter< TInputImage, TOutputImage >
::GenerateData()
{
  typename InputImageType::ConstPointer input = this->GetInput();
  typename OutputImageType::Pointer output = this->GetOutput();
  
  itk::ImageRegionConstIterator<InputImageType> it(input, outputRegionForThread);
  for(it.GoToBegin(); !it.IsAtEnd(); ++it)
  {
  }
}

template< class TInputImage, class TOutputImage >
void
TotalVariationImageFilter< TInputImage, TOutputImage >
::PrintSelf(std::ostream & os, itk::Indent indent) const
{
  Superclass::PrintSelf(os, indent);
  os << "chambolle: " << m_chambolle << std::endl;
}

} // end namespace

#endif
