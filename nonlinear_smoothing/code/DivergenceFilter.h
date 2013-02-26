/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 
#ifndef DivergenceFilter_h 
#define DivergenceFilter_h 

// itk includes
#include "itkImage.h"
#include "itkVector.h"
#include "itkImageToImageFilter.h"
#include "itkSmartPointer.h"

namespace imageprocessing
{
/**
 * DivergenceFilter
 *  Takes the one-sided divergence it at each gradient.
 *  Initially done for 
 *  CS 7640 - Advanced Image Processing, Spring 2013, University of Utah
 */
template< class TInputImage,
          class TOutputImage=itk::Image<float,TInputImage::ImageDimension>
        >
class DivergenceFilter:
  public itk::ImageToImageFilter<TInputImage,TOutputImage>
{
public:
  /**
   * Standard class typedefs
   */
  typedef DivergenceFilter Self;
  typedef itk::ImageToImageFilter< TInputImage, TOutputImage > Superclass;
  typedef itk::SmartPointer< Self > Pointer;
  typedef itk::SmartPointer< const Self > ConstPointer;

  itkStaticConstMacro(ImageDimension, unsigned int,
                      TInputImage::ImageDimension);

  /** Method for creation through the object factory. */
  itkNewMacro(Self);

  /** Run-time type information (and related methods). */
  itkTypeMacro(DivergenceFilter, ImageToImageFilter);

  /** Image type typedef support. */
  typedef TInputImage InputImageType;
  typedef TOutputImage OutputImageType;
  typedef typename OutputImageType::RegionType OutputImageRegionType;
  typedef typename InputImageType::SizeType ImageSizeType;

  /**
   * Norm - a norm of the image..
   */
  itkSetMacro(Norm, float);
  itkGetConstMacro(Norm, float);

protected:
  DivergenceFilter()
  {}

  virtual ~DivergenceFilter(){}
  void PrintSelf(std::ostream & os, itk::Indent indent) const;

  /**
   * Standard parallel pipeline method
   */
  void BeforeThreadedGenerateData();
  void ThreadedGenerateData( const OutputImageRegionType & outputRegionForThread,
                              itk::ThreadIdType threadId);
  void AfterThreadedGenerateData();

private:
  DivergenceFilter(const Self &); // not allowed
  void operator=(const Self &); // not allowed 

  float m_Norm;
  std::vector<float> m_Norms; // per thread
};
} // end namespace itk

#include "DivergenceFilter.hxx"

#endif
