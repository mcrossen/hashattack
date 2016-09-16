# Hash Attack
An experiment in brute force hash attacks for CS465 (computer security) at BYU.

## Problem
For this project, it is my intent to see if the complexity of pre-image and collision attacks against SHA-1 matches the expected values.

## Summary
To start, I created a wrapper around SHA-1 that would hash a pre-image and truncate the result to the length passed in. In this way, I analyzed the complexity of attacking SHA-1 as digest length increases.
Two types of attacks were attempted: pre-image and collision. The first of those involves finding a pre-image and digest pair that match another random pre-image and digest pair. This has a predicted complexity of 2<sup>n</sup> where ‘n’ is the digest bit length. The second attack involves finding any two separate pre-images that hashed to the same digest. This attack has a lower predicted complexity of 2<sup>n/2</sup>. The pre-image attack has a much higher complexity because the hashing algorithm is non-reversable; therefore, random pre-images must be used until a valid digest is found. In the collision attack on the other hand, computed digests are effectively reused until a newly computed digest matches an older digest.
To gather data, I wrote a script to try each type of attack 50 times against 8 different digest sizes. This script would record how many pre-images were hashed until a valid digest was found. To speed up the process, the trials were multithreaded 3 at a time. This script was created in the Ruby language.

## Results
The average hash attempts before a valid digest was found is listed in the table below. Each bit length was tested 50 times, and the averages were recorded.

                     | 6 bits | 8 bits | 10 bits | 12 bits | 14 bits | 16 bits | 18 bits 
-------------------- | ------ | ------ | ------- | ------- | ------- | ------- | -------
**pre-image attack** | 62     | 235    | 1000    | 4131    | 17550   | 68023   | 217350  
**collision attack** | 11     | 22     | 38      | 82      | 159     | 289     | 711     

The graph for the table above is given below (on the next page). The results are given by the discrete squares, and the lines correspond to the expected values based on the given complexities: 2<sup>n/2</sup> and 2<sup>n</sup>. To see the non-linear collision data more clearly, extra data points were measured and added.

![alt text](https://github.com/mcrossen/hashattack/raw/master/results.png)

## Analysis
The results of this experiment match what I expected. As I said earlier, the pre-image attack has a complexity of 2<sup>n</sup>. whereas the collision attack only has a complexity of 2<sup>n/2</sup>. This is clearly shown in the graph where both curves fit their expected complexities almost exactly.

## Conclusion
The data from this experiment shows that original complexity calculations of 2<sup>n</sup> and 2<sup>n/2</sup> for pre-image and collision attacks (respectively) was correct.
