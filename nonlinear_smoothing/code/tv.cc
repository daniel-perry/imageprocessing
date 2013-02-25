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
#include "itkImageFileWriter.h"

// local includes
#include "TotalVariationPrimalDualFilter.h"
#include "TotalVariationChambolleFilter.h"
using imageprocessing::TotalVariationPrimalDualFilter;
using imageprocessing::TotalVariationChambolleFilter;

int main(int argc, char * argv[] )
{
  if(argc < 2)
  {
    std::cerr << "usage: " << argv[0] << " <in.png> <out.png> <lambda> <dual-step> <iters> [chambolle-flag]" << std::endl;
    std::cerr << "note: chambolle-flag=1 means use chambolled instead of primal-dual" << std::endl;
    return 1;
  }

  std::string input_fn = argv[1];
  std::string output_fn = argv[2];
  float lambda = atof(argv[3]);
  float dualStep = atof(argv[4]);
  size_t iters = atoi(argv[5]);
  bool chambolleFlag = 0;
  if(argc > 6)
  {
    chambolleFlag = atoi(argv[6]) == 1;
  }

  const size_t Dimension = 2;
  typedef unsigned char PixelType;
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
  ImageType::Pointer output;
  if(chambolleFlag)
  {
    typedef TotalVariationChambolleFilter<ImageType> TVFilter;
    TVFilter::Pointer tv = TVFilter::New();
    tv->SetLambda(lambda);
    tv->SetDualStepSize(dualStep);
    tv->SetMaxIters(iters);
    tv->SetInput(input);
    output = tv->GetOutput();
    try
    {
      tv->Update();
    }
    catch(itk::ExceptionObject e)
    {
      std::cerr << "Error running TV filter :" << e << std::endl;
      return 1;
    }
  }
  else
  {
    typedef TotalVariationPrimalDualFilter<ImageType> TVFilter;
    TVFilter::Pointer tv = TVFilter::New();
    tv->SetLambda(lambda);
    tv->SetDualStepSize(dualStep);
    tv->SetMaxIters(iters);
    tv->SetInput(input);
    output = tv->GetOutput();
    try
    {
      tv->Update();
    }
    catch(itk::ExceptionObject e)
    {
      std::cerr << "Error running TV filter :" << e << std::endl;
      return 1;
    }
  }

  typedef itk::ImageFileWriter< ImageType > WriterType;
  WriterType::Pointer writer = WriterType::New();
  writer->SetInput( output );
  writer->SetFileName( output_fn );
  writer->UseCompressionOn();

  try
  {
    writer->Update();
  }
  catch(itk::ExceptionObject e)
  {
    std::cerr << "Error writing file " << output_fn << ": " << e << std::endl;
  }

  return 0;
}
