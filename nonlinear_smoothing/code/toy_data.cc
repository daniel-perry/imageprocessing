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
    std::cerr << "usage: " << argv[0] << " x y out.png [sd]" << std::endl;
    return 1;
  }
 
  size_t sx = atoi(argv[1]);
  size_t sy = atoi(argv[2]);
  std::string output_fn(argv[3]);
  bool noise = true;
  float sd = 1.0;
  if( argc > 4 )
  {
    sd = atof(argv[4]);
    if(sd == 0) noise = false;
  }

  // setup ITK types...
  typedef unsigned char PixelType;
  typedef itk::Image< PixelType,  2 >   ImageType;

  ImageType::SizeType size;
  size[0] = sx;
  size[1] = sy;
  ImageType::IndexType corner;
  corner.Fill(0);
  ImageType::RegionType region(corner,size);

  ImageType::Pointer image = ImageType::New();
  image->SetRegions(region);
  image->Allocate();

  // Generate toy data:
  float half_x = sx/2.0;
  float half_y = sy/2.0;
  float r = .8*(sx/2.0+sy/2.0)/2.;
  ImageType::IndexType index;
  for(size_t x=0; x<sx; ++x)
  {
    index[0] = x;
    for(size_t y=0; y<sy; ++y)
    {
      index[1] = y;
      if( (x-half_x)*(x-half_x) + (y-half_y)*(y-half_y) < r*r )
      {
        if(noise)
          image->SetPixel(index, static_cast<unsigned char>(rand_normal(100,sd)));
        else
          image->SetPixel(index, 100);
      }
      else
      {
        if(noise)
          image->SetPixel(index, static_cast<unsigned char>(rand_normal(200,sd)));
        else
          image->SetPixel(index, 200);
      }
    }
  }

  typedef itk::ImageFileWriter< ImageType > WriterType;
  WriterType::Pointer writer = WriterType::New();
  writer->SetInput( image );
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
