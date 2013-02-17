#ifndef _DeepCopy_H
#define _DeepCopy_H

namespace imageprocessing {

template<class TInImage, class TOutImage>
void DeepCopy(typename TInImage::ConstPointer input, typename TOutImage::Pointer output)
{
  /*
  { // debug
    std::cerr << "DeepCopy(constpointer,pointer)" << std::endl;
  }
  */
  // only create a new image and allocate if output is null...
  if(output->GetLargestPossibleRegion().GetSize()[0] == 0)
  {
    output->SetRegions(input->GetLargestPossibleRegion());
    output->Allocate();
  }

  itk::ImageRegionConstIterator<TInImage> inputIterator(input, input->GetLargestPossibleRegion());
  itk::ImageRegionIterator<TOutImage> outputIterator(output, output->GetLargestPossibleRegion());
 
  /*
  // debug
  float mean = 0;
  float count = 0;
  float max = 0;
  float min = 10e5;
  */
  while(!inputIterator.IsAtEnd())
  {
    /*
    {// debug
      float sample = inputIterator.Get();
      mean += sample;
      count += 1;
      if(sample < min) min = sample;
      if(sample > max) max = sample;
    }
    */
    outputIterator.Set(inputIterator.Get());
    ++inputIterator;
    ++outputIterator;
  }
  /*
  { // debug
    std::cerr << "min: " << min << std::endl;
    std::cerr << "mean: " << mean/count << std::endl;
    std::cerr << "max: " << max << std::endl;
  }
  */
}


template<class TInImage, class TOutImage>
void DeepCopy(typename TInImage::Pointer input, typename TOutImage::Pointer output)
{
  /*
  { // debug
    std::cerr << "DeepCopy(pointer_a,pointer_b)" << std::endl;
  }
  */
  // only create a new image and allocate if output is null...
  if(output->GetLargestPossibleRegion().GetSize()[0] == 0)
  {
    output->SetRegions(input->GetLargestPossibleRegion());
    output->Allocate();
  }

  itk::ImageRegionConstIterator<TInImage> inputIterator(input, input->GetLargestPossibleRegion());
  itk::ImageRegionIterator<TOutImage> outputIterator(output, output->GetLargestPossibleRegion());

  /*
  // debug
  float mean = 0;
  float count = 0;
  float max = 0;
  float min = 10e5;
  */
  while(!inputIterator.IsAtEnd())
  {
    /*
    {// debug
      float sample = inputIterator.Get();
      mean += sample;
      count += 1;
      if(sample < min) min = sample;
      if(sample > max) max = sample;
    }
    */
    outputIterator.Set(inputIterator.Get());
    ++inputIterator;
    ++outputIterator;
  }
  /*
  { // debug
    std::cerr << "min: " << min << std::endl;
    std::cerr << "mean: " << mean/count << std::endl;
    std::cerr << "max: " << max << std::endl;
  }
  */
}

template<class TImage>
void DeepCopy(typename TImage::Pointer input, typename TImage::Pointer output)
{
  // only create a new image and allocate if output is null...
  if(output->GetLargestPossibleRegion().GetSize()[0] == 0)
  {
    output->SetRegions(input->GetLargestPossibleRegion());
    output->Allocate();
  }

  itk::ImageRegionConstIterator<TImage> inputIterator(input, input->GetLargestPossibleRegion());
  itk::ImageRegionIterator<TImage> outputIterator(output, output->GetLargestPossibleRegion());
 
  while(!inputIterator.IsAtEnd())
  {
    outputIterator.Set(inputIterator.Get());
    ++inputIterator;
    ++outputIterator;
  }
}


} // end namespace bambam

#endif
