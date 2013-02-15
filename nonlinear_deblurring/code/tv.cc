/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

// itk includes
#include "itkImage.h"
#include "itkImageFileReader.h"

// local includes
#include "TotalVariationFilter.h"

int main(int argc, char * argv[] )
{
  
  const size_t Dimension = 2;
  typedef float PixelType;
  typedef itk::Image<PixelType,Dimension> ImageType;

  // read in images:

  // run filter:
  typedef TotalVariationFilter<ImageType> TVFilter;
  TVFilter::Pointer tv = TVFilter::New();

  

  return 0;
}
