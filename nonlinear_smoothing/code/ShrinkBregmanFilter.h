/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 
#ifndef ShrinkBregmanFilter_h 
#define ShrinkBregmanFilter_h 

// itk includes
#include "itkImage.h"
#include "itkImageToImageFilter.h"
#include "itkSmartPointer.h"

namespace imageprocessing
{
/**
 * ShrinkBregmanFilter
 *  Implementation of TV denoising using Split Bregman  Initially done for 
 *  CS 7640 - Advanced Image Processing, Spring 2013, University of Utah
 */
template< class TInputImage,
          class TOutputImage=TInputImage
        >
class ShrinkBregmanFilter:
  public itk::ImageToImageFilter<TInputImage,TOutputImage>
{
public:
  /**
   * Standard class typedefs
   */
  typedef ShrinkBregmanFilter Self;
  typedef itk::ImageToImageFilter< TInputImage, TOutputImage > Superclass;
  typedef itk::SmartPointer< Self > Pointer;
  typedef itk::SmartPointer< const Self > ConstPointer;

  itkStaticConstMacro(ImageDimension, unsigned int,
                      TInputImage::ImageDimension);

  /** Method for creation through the object factory. */
  itkNewMacro(Self);

  /** Run-time type information (and related methods). */
  itkTypeMacro(ShrinkBregmanFilter, ImageToImageFilter);

  /** Image type typedef support. */
  typedef TInputImage InputImageType;
  typedef TOutputImage OutputImageType;
  typedef typename OutputImageType::RegionType OutputImageRegionType;
  typedef typename InputImageType::SizeType ImageSizeType;
  typedef itk::Image<itk::Vector<float,InputImageType::ImageDimension>,InputImageType::ImageDimension> VectorImageType;
  typedef typename VectorImageType::Pointer VectorImagePointer;
  typedef typename VectorImageType::ConstPointer VectorImageConstPointer;

  /**
   * Normalizing parameter - makes it less sensitive to step sizes.
   */
  itkSetMacro(Lambda, float);
  itkGetConstMacro(Lambda, float);
  /**
   * Bregman 
   */
  itkSetMacro(Bregman, VectorImagePointer)
  itkGetMacro(Bregman, VectorImagePointer)

protected:
  ShrinkBregmanFilter()
  :m_Lambda(1),
  m_Bregman()
  {}

  virtual ~ShrinkBregmanFilter(){}
  void PrintSelf(std::ostream & os, itk::Indent indent) const;

  /**
   * Standard parallel pipeline methods
   */
  void ThreadedGenerateData( const OutputImageRegionType & outputRegionForThread,
                              itk::ThreadIdType threadId);

private:
  ShrinkBregmanFilter(const Self &); // not allowed
  void operator=(const Self &); // not allowed 

  float m_Lambda;

  typename VectorImageType::Pointer m_Bregman; 
};
} // end namespace

#include "ShrinkBregmanFilter.hxx"

#endif
