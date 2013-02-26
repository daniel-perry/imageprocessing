/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 
#ifndef DualFilter_h 
#define DualFilter_h 

// itk includes
#include "itkImage.h"
#include "itkImageToImageFilter.h"
#include "itkSmartPointer.h"

namespace imageprocessing
{
/**
 * DualFilter
 *  Implementation of total variation.  Initially done for 
 *  CS 7640 - Advanced Image Processing, Spring 2013, University of Utah
 */
template< class TInputImage,
          class TOutputImage=TInputImage
        >
class DualFilter:
  public itk::ImageToImageFilter<TInputImage,TOutputImage>
{
public:
  /**
   * Standard class typedefs
   */
  typedef DualFilter Self;
  typedef itk::ImageToImageFilter< TInputImage, TOutputImage > Superclass;
  typedef itk::SmartPointer< Self > Pointer;
  typedef itk::SmartPointer< const Self > ConstPointer;

  itkStaticConstMacro(ImageDimension, unsigned int,
                      TInputImage::ImageDimension);

  /** Method for creation through the object factory. */
  itkNewMacro(Self);

  /** Run-time type information (and related methods). */
  itkTypeMacro(DualFilter, ImageToImageFilter);

  /** Image type typedef support. */
  typedef TInputImage InputImageType;
  typedef TOutputImage OutputImageType;
  typedef typename OutputImageType::RegionType OutputImageRegionType;
  typedef typename InputImageType::SizeType ImageSizeType;
  typedef itk::Image<itk::Vector<float,InputImageType::ImageDimension>,InputImageType::ImageDimension> VectorImageType;
  typedef typename VectorImageType::Pointer VectorImagePointer;
  typedef typename VectorImageType::ConstPointer VectorImageConstPointer;

  /** 
   * Chambolle - whether to compute the TV using the
   *   Chambolle method, instead of primal/dual (default).
   */
  itkSetMacro(Chambolle, bool);
  itkGetConstMacro(Chambolle, bool);
  /**
   * Step size for dual solution.
   */
  itkSetMacro(DualStepSize, float);
  itkGetConstMacro(DualStepSize, float);
  /**
   * Normalizing parameter - makes it less sensitive to step sizes.
   */
  itkSetMacro(Lambda, float);
  itkGetConstMacro(Lambda, float);
  /**
   * Delta - the change in solution after running.
   */
  itkSetMacro(Delta, float);
  itkGetConstMacro(Delta, float);

  /**
   * X - the unit vector dual image
   */
  itkSetMacro(X, VectorImagePointer)
  itkGetMacro(X, VectorImagePointer)

protected:
  DualFilter()
  :m_Chambolle(false),
  m_DualStepSize(1),
  m_Lambda(1),
  m_Delta(10e10),
  m_X()
  {}

  virtual ~DualFilter(){}
  void PrintSelf(std::ostream & os, itk::Indent indent) const;

  /**
   * Standard parallel pipeline methods
   */
  void AllocateOutputs();
  void BeforeThreadedGenerateData();
  void ThreadedGenerateData( const OutputImageRegionType & outputRegionForThread,
                              itk::ThreadIdType threadId);
  void AfterThreadedGenerateData();

private:
  DualFilter(const Self &); // not allowed
  void operator=(const Self &); // not allowed 

  bool m_Chambolle;
  float m_DualStepSize;
  float m_Lambda;
  float m_Delta;

  std::vector<float> m_Deltas; // per thread

  typename VectorImageType::Pointer m_X; // dual unit gradient image.
};
} // end namespace itk

#include "DualFilter.hxx"

#endif
