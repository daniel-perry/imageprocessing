/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 
#ifndef ChambollePrimalFilter_h 
#define ChambollePrimalFilter_h 

// itk includes
#include "itkImage.h"
#include "itkImageToImageFilter.h"
#include "itkSmartPointer.h"

namespace imageprocessing
{
/**
 * ChambollePrimalFilter
 *  Implementation of total variation.  Initially done for 
 *  CS 7640 - Advanced Image Processing, Spring 2013, University of Utah
 */
template< class TInputImage,
          class TOutputImage=TInputImage
        >
class ChambollePrimalFilter:
  public itk::ImageToImageFilter<TInputImage,TOutputImage>
{
public:
  /**
   * Standard class typedefs
   */
  typedef ChambollePrimalFilter Self;
  typedef itk::ImageToImageFilter< TInputImage, TOutputImage > Superclass;
  typedef itk::SmartPointer< Self > Pointer;
  typedef itk::SmartPointer< const Self > ConstPointer;

  itkStaticConstMacro(ImageDimension, unsigned int,
                      TInputImage::ImageDimension);

  /** Method for creation through the object factory. */
  itkNewMacro(Self);

  /** Run-time type information (and related methods). */
  itkTypeMacro(ChambollePrimalFilter, ImageToImageFilter);

  /** Image type typedef support. */
  typedef TInputImage InputImageType;
  typedef typename InputImageType::ConstPointer InputImageConstPointer;
  typedef typename InputImageType::Pointer InputImagePointer;
  typedef TOutputImage OutputImageType;
  typedef typename OutputImageType::RegionType OutputImageRegionType;
  typedef typename InputImageType::SizeType ImageSizeType;
  typedef itk::Image<itk::Vector<float,InputImageType::ImageDimension>,InputImageType::ImageDimension> VectorImageType;
  typedef typename VectorImageType::Pointer VectorImagePointer;
  typedef typename VectorImageType::ConstPointer VectorImageConstPointer;

  /**
   * Step size for primal solution.
   */
  itkSetMacro(PrimalStepSize, float);
  itkGetConstMacro(PrimalStepSize, float);
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

  /**
   * OriginalImage - the original image.
   */
  itkSetMacro(OriginalImage, InputImagePointer)
  itkGetMacro(OriginalImage, InputImagePointer)


protected:
  ChambollePrimalFilter()
  :m_PrimalStepSize(1),
  m_Lambda(1),
  m_Delta(10e10),
  m_X(),
  m_OriginalImage()
  {}

  virtual ~ChambollePrimalFilter(){}
  void PrintSelf(std::ostream & os, itk::Indent indent) const;

  /**
   * Standard parallel pipeline method
   */
  void BeforeThreadedGenerateData();
  void ThreadedGenerateData( const OutputImageRegionType & outputRegionForThread,
                              itk::ThreadIdType threadId);
  void AfterThreadedGenerateData();

private:
  ChambollePrimalFilter(const Self &); // not allowed
  void operator=(const Self &); // not allowed 

  float m_PrimalStepSize;
  float m_Lambda;
  float m_Delta;

  std::vector<float> m_Deltas; // per thread

  VectorImagePointer m_X; // dual unit gradient image.
  InputImagePointer m_OriginalImage;
};
} // end namespace itk

#include "ChambollePrimalFilter.hxx"

#endif
