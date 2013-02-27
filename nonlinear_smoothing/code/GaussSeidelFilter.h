/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 
#ifndef GaussSeidelFilter_h 
#define GaussSeidelFilter_h 

// itk includes
#include "itkImage.h"
#include "itkImageToImageFilter.h"
#include "itkSmartPointer.h"

namespace imageprocessing
{
/**
 * GaussSeidelFilter
 *  Implementation of TV denoising using Split Bregman  Initially done for 
 *  CS 7640 - Advanced Image Processing, Spring 2013, University of Utah
 */
template< class TInputImage,
          class TOutputImage=TInputImage
        >
class GaussSeidelFilter:
  public itk::ImageToImageFilter<TInputImage,TOutputImage>
{
public:
  /**
   * Standard class typedefs
   */
  typedef GaussSeidelFilter Self;
  typedef itk::ImageToImageFilter< TInputImage, TOutputImage > Superclass;
  typedef itk::SmartPointer< Self > Pointer;
  typedef itk::SmartPointer< const Self > ConstPointer;

  itkStaticConstMacro(ImageDimension, unsigned int,
                      TInputImage::ImageDimension);

  /** Method for creation through the object factory. */
  itkNewMacro(Self);

  /** Run-time type information (and related methods). */
  itkTypeMacro(GaussSeidelFilter, ImageToImageFilter);

  /** Image type typedef support. */
  typedef TInputImage InputImageType;
  typedef TOutputImage OutputImageType;
  typedef typename OutputImageType::Pointer OutputImagePointer;
  typedef typename OutputImageType::RegionType OutputImageRegionType;
  typedef typename InputImageType::SizeType ImageSizeType;
  typedef itk::Image<itk::Vector<float,InputImageType::ImageDimension>,InputImageType::ImageDimension> VectorImageType;
  typedef typename VectorImageType::Pointer VectorImagePointer;
  typedef typename VectorImageType::ConstPointer VectorImageConstPointer;

  /**
   * Step size for dual solution.
   */
  itkSetMacro(Mu, float);
  itkGetConstMacro(Mu, float);
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
   * Shrink 
   */
  itkSetMacro(Shrink, VectorImagePointer)
  itkGetMacro(Shrink, VectorImagePointer)
  /**
   * Bregman 
   */
  itkSetMacro(Bregman, VectorImagePointer)
  itkGetMacro(Bregman, VectorImagePointer)
  /**
   * OriginalImage 
   */
  itkSetMacro(OriginalImage, OutputImagePointer)
  itkGetMacro(OriginalImage, OutputImagePointer)



protected:
  GaussSeidelFilter()
  :m_Mu(1),
  m_Lambda(1),
  m_Delta(10e10),
  m_Shrink(),
  m_Bregman(),
  m_OriginalImage()
  {}

  virtual ~GaussSeidelFilter(){}
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
  GaussSeidelFilter(const Self &); // not allowed
  void operator=(const Self &); // not allowed 

  float m_Mu;
  float m_Lambda;
  float m_Delta;

  std::vector<float> m_Deltas; // per thread

  typename VectorImageType::Pointer m_Shrink; 
  typename VectorImageType::Pointer m_Bregman; 
  typename OutputImageType::Pointer m_OriginalImage; 
};
} // end namespace itk

#include "GaussSeidelFilter.hxx"

#endif
