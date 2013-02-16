/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 
#ifndef UnitGradientFilter_h 
#define UnitGradientFilter_h 

// itk includes
#include "itkImage.h"
#include "itkVector.h"
#include "itkImageToImageFilter.h"
#include "itkSmartPointer.h"

namespace imageprocessing
{
/**
 * UnitGradientFilter
 *  Takes the one-sided gradient and normalizes it at each pixel.
 *  Initially done for 
 *  CS 7640 - Advanced Image Processing, Spring 2013, University of Utah
 */
template< class TInputImage,
          class TOutputImage=itk::Image<itk::Vector<float,TInputImage::ImageDimension>,TInputImage::ImageDimension>
        >
class UnitGradientFilter:
  public itk::ImageToImageFilter<TInputImage,TOutputImage>
{
public:
  /**
   * Standard class typedefs
   */
  typedef UnitGradientFilter Self;
  typedef itk::ImageToImageFilter< TInputImage, TOutputImage > Superclass;
  typedef itk::SmartPointer< Self > Pointer;
  typedef itk::SmartPointer< const Self > ConstPointer;

  itkStaticConstMacro(ImageDimension, unsigned int,
                      TInputImage::ImageDimension);

  /** Method for creation through the object factory. */
  itkNewMacro(Self);

  /** Run-time type information (and related methods). */
  itkTypeMacro(UnitGradientFilter, ImageToImageFilter);

  /** Image type typedef support. */
  typedef TInputImage InputImageType;
  typedef TOutputImage OutputImageType;
  typedef typename OutputImageType::RegionType OutputImageRegionType;
  typedef typename InputImageType::SizeType ImageSizeType;

protected:
  UnitGradientFilter()
  {}

  virtual ~UnitGradientFilter(){}
  void PrintSelf(std::ostream & os, itk::Indent indent) const;

  /**
   * Standard parallel pipeline method
   */
  void BeforeThreadedGenerateData();
  void ThreadedGenerateData( const OutputImageRegionType & outputRegionForThread,
                              itk::ThreadIdType threadId);

private:
  UnitGradientFilter(const Self &); // not allowed
  void operator=(const Self &); // not allowed 
};
} // end namespace itk

#include "UnitGradientFilter.hxx"

#endif
