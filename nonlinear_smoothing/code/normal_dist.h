/*========================================================================= 
 * 
 *  Copyright (c) 2013 Daniel Perry 
 * 
 *  MIT license 
 * 
 *=========================================================================*/ 

#ifndef normal_dist_H
#define normal_dist_H

float rand1()
{
  return static_cast<float>(rand())/RAND_MAX;
}

float rand_normal()
//float gasdev()
// returns a normally distributed deviate with zero mean and unit variance,
// using ran1() as the source of uniform deviates
// got this code from Ross Whitaker
{
    static int iset=0;
    static float gset;
    float fac, rsq, v1, v2;

    if (iset == 0)
    {
      do
      {
        v1 = 2.0f*rand1() - 1;
        v2 = 2.0f*rand1() - 1;
        rsq = v1*v1 + v2*v2;
      }
      // make sure they are within the unit circle
      while ((rsq >= 1.0f)||(rsq == 0.0f));

      fac = sqrt(-2.0*log(rsq)/rsq);
      // now make the Box-Muller transformation to get two normal deviates.
      // Return one and save the other for next time
      gset = v1*fac;
      iset = 1;
      return(v2*fac);
    }
    else
    {
      iset = 0;
      return gset;
    }
}

// generate a sample from the normal distribution with mean = 0 and sd = var = 1
/*
float rand_normal()
{
  // make use of law of large numbers
  // (https://en.wikipedia.org/wiki/Normal_distribution)
  // (https://en.wikipedia.org/wiki/Irwin%E2%80%93Hall_distribution)
  float sample = 0.f;
  for(size_t i=0; i<12; ++i)
  {
    sample += (static_cast<float>(rand())/RAND_MAX);
  }
  return sample-6.f;
}
*/

// generate a sample from the normal distribution with specified mean and sd
float rand_normal( float mean, float sd )
{
  return mean + rand_normal()*sd;
}

#endif
