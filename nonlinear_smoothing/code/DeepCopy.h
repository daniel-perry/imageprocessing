#ifndef _DeepCopy_H
#define _DeepCopy_H

namespace imageprocessing {

template<class TInImage, class TOutImage>
void DeepCopy(typename TInImage::Pointer input, typename TOutImage::Pointer output)
{
  // only create a new image and allocate if output is null...
  if(output->GetLargestPossibleRegion().GetSize()[0] == 0)
  {
    output->SetRegions(input->GetLargestPossibleRegion());
    output->Allocate();
  }

  itk::ImageRegionConstIterator<TInImage> inputIterator(input, input->GetLargestPossibleRegion());
  itk::ImageRegionIterator<TOutImage> outputIterator(output, output->GetLargestPossibleRegion());
 
  while(!inputIterator.IsAtEnd())
  {
    outputIterator.Set(inputIterator.Get());
    ++inputIterator;
    ++outputIterator;
  }
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
