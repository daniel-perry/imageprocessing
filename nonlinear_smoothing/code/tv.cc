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
#include "PrimalDualFilter.h"
#include "ChambolleFilter.h"
#include "SplitBregmanFilter.h"
using imageprocessing::PrimalDualFilter;
using imageprocessing::ChambolleFilter;
using imageprocessing::SplitBregmanFilter;

int main(int argc, char * argv[] )
{
  if(argc < 2)
  {
    std::cerr << "usage: " << argv[0] << " <in.png> <out.png> <lambda> <dual-step> <iters> <threads> [algorithm-flag]" << std::endl;
    std::cerr << "note: algorithm-flag = 0 -> primal-dual (default)" << std::endl
              << "                       1 -> chambolle" << std::endl
              << "                       2 -> split-bregman (anisotropic)" << std::endl;
    return 1;
  }

  std::string input_fn = argv[1];
  std::string output_fn = argv[2];
  float lambda = atof(argv[3]);
  float dualStep = atof(argv[4]);
  size_t iters = atoi(argv[5]);
  size_t threads = atoi(argv[6]);
  int chambolleFlag = 0;
  if(argc > 7)
  {
    chambolleFlag = atoi(argv[7]);
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
  if(chambolleFlag == 1)
  {
    typedef ChambolleFilter<ImageType> TVFilter;
    TVFilter::Pointer tv = TVFilter::New();
    tv->SetLambda(lambda);
    tv->SetDualStepSize(dualStep);
    tv->SetMaxIters(iters);
    tv->SetInput(input);
    tv->SetThreadCount(threads);
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
  else if(chambolleFlag == 2)
  {
    typedef SplitBregmanFilter<ImageType> TVFilter;
    TVFilter::Pointer tv = TVFilter::New();
    tv->SetMu(lambda);
    tv->SetMaxIters(iters);
    tv->SetInput(input);
    tv->SetThreadCount(threads);
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
  else // default = primal-dual
  {
    typedef PrimalDualFilter<ImageType> TVFilter;
    TVFilter::Pointer tv = TVFilter::New();
    tv->SetLambda(lambda);
    tv->SetDualStepSize(dualStep);
    tv->SetMaxIters(iters);
    tv->SetInput(input);
    tv->SetThreadCount(threads);
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
