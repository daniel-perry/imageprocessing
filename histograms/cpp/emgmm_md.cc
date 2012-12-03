// std
#include <iostream>
#include <ctime>

// itk
#include <itkImage.h>
#include <itkImageFileReader.h>
#include <itkImageFileWriter.h>
#include <itkNumericTraits.h>
#include <itkExceptionObject.h>

// local
#include "emgmm.h"

int main(int argc, char * argv[])
{
  if(argc < 2)
  {
    std::cerr << "usage: " << argv[0] << " <k> <iters> <original.nrrd> <out.nrrd>" << std::endl;
    return 1;
  }

  int k = atoi(argv[1]);
  int iters = atoi(argv[2]);
  std::string original_fn(argv[3]);
  std::string out_fn(argv[4]);

  srand(time(0));

  // setup ITK types...
  const unsigned int dim = 2;
  typedef unsigned char PixelType;
  typedef itk::Image< PixelType,  dim >   ImageType;
  typedef itk::ImageRegionIterator< ImageType > IteratorType;

  // read in the nrrds
  typedef itk::ImageFileReader< ImageType  >  ReaderType;
  ReaderType::Pointer reader = ReaderType::New();
  reader->SetFileName( original_fn );
  ImageType::Pointer original = reader->GetOutput();
  try
  {
    reader->Update();
  }
  catch(itk::ExceptionObject e)
  {
    std::cerr << "Error reading file " << original_fn << ": " << e << std::endl;
    return 1;
  }

  IteratorType it(original, original->GetLargestPossibleRegion());

  WeightList r;
  Weight weight(k);

  // Initialize
  for(it.GoToBegin(); !it.IsAtEnd(); ++it)
  {
    //float v = it.Get();
    randweight(weight);
    r.push_back(weight);
  }

  GMM gmm(k);
  float epsilon = 1e-4;
  float log_like = 0;
  float old_log_like = 1e6;
  size_t iter;

  // kmeans-like initialization loop
  for(iter=0; iter<iters; ++iter)
  {
    std::cerr << "i=" << iter << std::endl;
    std::cerr << "model:" << std::endl;
    for(size_t i=0; i<gmm.size(); ++i)
      std::cerr << i << ": " << gmm[i].str() << std::endl;
    maximization<ImageType>( original, r, gmm );
    //log_like = expectation<ImageType>( original, gmm, r );
    log_like = simple_expectation<ImageType>( original, gmm, r );
    std::cerr << "compactness: " << log_like << std::endl;
    if( fabs(old_log_like - log_like) < epsilon ) break;
    old_log_like = log_like;
  }
 
  std::cout << "======================" << std::endl;
  std::cout << "simple loop done" << std::endl;
  std::cout << "======================" << std::endl;

  old_log_like = 1e6;

  // EM loop
  for(iter=0; iter<iters; ++iter)
  {
    std::cerr << "i=" << iter << std::endl;
    std::cerr << "model:" << std::endl;
    for(size_t i=0; i<gmm.size(); ++i)
      std::cerr << i << ": " << gmm[i].str() << std::endl;
    maximization<ImageType>( original, r, gmm );
    log_like = expectation<ImageType>( original, gmm, r );
    if( fabs(old_log_like - log_like) < epsilon ) break;
    old_log_like = log_like;
  }
  std::cout << "======================" << std::endl;
  std::cout << "======================" << std::endl;
  if( iter >= iters )
  {
    std::cerr << "warning: reached maximum iterations, did not converge." << std::endl;
  }
  else
  {
    std::cerr << "converged in " << iter << " iterations." << std::endl;
  }

  std::cout << "model: " << std::endl;
  for(size_t i=0; i<gmm.size(); ++i)
  {
    std::cout << i << ": " << gmm[i].str() << std::endl;
  }
  std::cout << "log likelihood: " << log_like << std::endl;
  
  // Write label map:
  ImageType::Pointer out = ImageType::New();
  out->SetRegions( original->GetLargestPossibleRegion() );
  out->Allocate();
  itk::ImageRegionIterator<ImageType> out_it(out, out->GetLargestPossibleRegion());
  size_t sample_i = 0;
  for(out_it.GoToBegin(); !out_it.IsAtEnd(); ++out_it,++sample_i)
  {
    int max_i = -1;
    float max = 0.f;
    for(size_t i=0; i<k; ++i)
    {
      if( r[sample_i][i] > max )
      {
        max_i = i;
        max = r[sample_i][i];
      }
    }
    if(max_i < 0)
      out->SetPixel(out_it.GetIndex(), 0);
    else
      out->SetPixel(out_it.GetIndex(), 255-100*(max_i));
  }

  typedef itk::ImageFileWriter<ImageType> WriterType;
  WriterType::Pointer writer = WriterType::New();
  writer->SetFileName(out_fn);
  writer->SetInput(out);
  try
  {
    writer->Update();
  }
  catch(itk::ExceptionObject e)
  {
    std::cerr << "Error writing file " << out_fn << ": " << e << std::endl;
    return 1;
  }

  return 0;
}
