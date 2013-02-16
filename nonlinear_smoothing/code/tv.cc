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
using imageprocessing::TotalVariationFilter;

int main(int argc, char * argv[] )
{
  if(argc < 2)
  {
    std::cerr << "usage: " << argv[0] << " [image.png] <chambolle-flag>" << std::endl;
    std::cerr << "note: chambolle-flag=1 means use chambolled instead of primal-dual" << std::endl;
    return 1;
  }

  std::string input_fn = argv[1];
  bool chambolleFlag = 0;
  if(argc > 2)
  {
    chambolleFlag = atoi(argv[2]) == 1;
  }

  const size_t Dimension = 2;
  typedef float PixelType;
  typedef itk::Image<PixelType,Dimension> ImageType;

  // read in images:
  typedef itk::ImageFileReader<ImageType> ReaderType;
  ReaderType::Pointer reader = ReaderType::New();
  reader->SetFileName( input_fn );
  ImageType::Pointer input = reader->GetOutput();
  try
  {
    reader->Update();
  }
  catch(itk::ExceptionObject e)
  {
    std::cerr << "Error reading file " << input_fn << ": " << e << std::endl;
    return 1;
  }

  // run filter:
  typedef TotalVariationFilter<ImageType> TVFilter;
  TVFilter::Pointer tv = TVFilter::New();
  tv->SetInput(input);
  ImageType::Pointer output = tv->GetOutput();
  try
  {
    tv->Update();
  }
  catch(itk::ExceptionObject e)
  {
    std::cerr << "Error running TV filter :" << e << std::endl;
    return 1;
  }

  return 0;
}
