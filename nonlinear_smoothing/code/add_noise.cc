/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

// std
#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>

// itk
#include <itkImage.h>
#include <itkImageFileReader.h>
#include <itkImageFileWriter.h>
#include <itkNumericTraits.h>
#include <itkExceptionObject.h>
#include <itkNeighborhoodIterator.h>
#include <itkConstNeighborhoodIterator.h>
#include <itkImageRegionIterator.h>
#include <itkSymmetricEigenAnalysis.h>

// local
#include "normal_dist.h"

int main(int argc, char * argv[])
{
  srand(time(0));

  if(argc < 2)
  {
    std::cerr << "usage: " << argv[0] << " <in.png> <out.png> [sd]" << std::endl;
    return 1;
  }
 
  std::string input_fn(argv[1]);
  std::string output_fn(argv[2]);
  bool noise = true;
  float sd = 1.0;
  if( argc > 3 )
  {
    sd = atof(argv[3]);
    if(sd == 0) noise = false;
  }

  // setup ITK types...
  typedef unsigned char PixelType;
  typedef itk::Image< PixelType,  2 >   ImageType;

  typedef itk::ImageFileReader<ImageType> Reader;
  Reader::Pointer reader = Reader::New();
  reader->SetFileName(input_fn);
  ImageType::Pointer input = reader->GetOutput();
  try
  {
    reader->Update();
  }
  catch(itk::ExceptionObject e)
  {
    std::cerr << "Error reading file " << input_fn << ": " << e << std::endl;
  }

  // add noise:
  typedef itk::ImageRegionIterator<ImageType> IteratorType;
  IteratorType it(input, input->GetLargestPossibleRegion());
  for(it.GoToBegin();!it.IsAtEnd();++it)
  {
    if(noise)
    {
      input->SetPixel(it.GetIndex(), static_cast<unsigned char>(std::max(0.f,std::floor(rand_normal(it.Get(),sd)))));
    }
  }

  typedef itk::ImageFileWriter< ImageType > WriterType;
  WriterType::Pointer writer = WriterType::New();
  writer->SetInput( input );
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
