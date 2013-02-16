/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 
#ifndef TotalVariationImageFilter_h 
#define TotalVariationImageFilter_h 

// itk includes
#include "itkImage.h"
#include "itkImageToImageFilter.h"
#include "itkSmartPointer.h"

namespace imageprocessing
{
/**
 * TotalVariationImageFilter
 *  Implementation of total variation.  Initially done for 
 *  CS 7640 - Advanced Image Processing, Spring 2013, University of Utah
 */
template< class TInputImage,
          class TOutputImage=TInputImage
        >
class TotalVariationImageFilter:
  public itk::ImageToImageFilter<TInputImage,TOutputImage>
{
public:
  /**
   * Standard class typedefs
   */
  typedef TotalVariationImageFilter Self;
  typedef itk::ImageToImageFilter< TInputImage, TOutputImage > Superclass;
  typedef itk::SmartPointer< Self > Pointer;
  typedef itk::SmartPointer< const Self > ConstPointer;

  itkStaticConstMacro(ImageDimension, unsigned int,
                      TInputImage::ImageDimension);

  /** Method for creation through the object factory. */
  itkNewMacro(Self);

  /** Run-time type information (and related methods). */
  itkTypeMacro(TotalVariationImageFilter, ImageToImageFilter);

  /** Image type typedef support. */
  typedef TInputImage InputImageType;
  typedef TOutputImage OutputImageType;
  typedef typename OutputImageType::RegionType OutputImageRegionType;
  typedef typename InputImageType::SizeType ImageSizeType;

  /** 
   * chambolle - whether to compute the TV using the
   *   chambolle method, instead of primal/dual (default).
   */
  itkSetMacro(chambolle, bool);
  itkGetConstMacro(chambolle, bool);
  /**
   * Step size for primal solution.
   */
  itkSetMacro(primalStepSize, float);
  itkGetConstMacro(primalStepSize, float);
  /**
   * Step size for dual solution.
   */
  itkSetMacro(dualStepSize, float);
  itkGetConstMacro(dualStepSize, float);

protected:
  TotalVariationImageFilter()
  :m_chambolle(false),
  m_primalStepSize(1),
  m_dualStepSize(1)
  {}

  virtual ~TotalVariationImageFilter(){}
  void PrintSelf(std::ostream & os, itk::Indent indent) const;

  void GenerateData();

private:
  TotalVariationImageFilter(const Self &); // not allowed
  void operator=(const Self &); // not allowed 

  bool m_chambolle;
  float m_primalStepSize;
  float m_dualStepSize;
};
} // end namespace itk

#include "TotalVariationImageFilter.hxx"

#endif
