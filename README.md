# Hash Attack
An experiment in brute force hash attacks for CS465 (computer security) at BYU.

## Problem
For this project, it is my intent to see if the complexity of pre-image and collision attacks against SHA-1 matches the expected values.

## Summary
To start, I created a wrapper around SHA-1 that would hash a pre-image and truncate the result to the length passed in. In this way, I analyzed the complexity of attacking SHA-1 as digest length increases.
Two types of attacks were attempted: pre-image and collision. The first of those involves finding a pre-image and digest pair that match another random pre-image and digest pair. This has a predicted complexity of O(2<sup>n</sup>) because the hashing algorithm is non-reversable; therefore, random pre-images must be hashed until a digest is found that matches the original. The second attack involved finding any two separate pre-images that hashed to the same digest. This attack has a lower predicted complexity of O(2<sup>n/2</sup>)
To gather data, I wrote a script to try each type of attack 50 times against 8 different digest sizes. To speed up the process, the trials were multithreaded 3 at a time. This script was created in the Ruby language, and the source code is attached to this assignment.

## Results
The average runtime (given in miliseconds) for the experiment is listed in the table below. Each bit length was tested 50 times, and the averages were recorded.

## Analysis
The results of this experiment match what I expected. As I said earlier, the pre-image attack has a complexity of O(2<sup>n</sup>) whereas the collision attack only has a complexity of O(2<sup>n/2</sup>). This is clearly shown in the graph where both curves are exponential, but the pre-image attack starts growing much sooner and at a faster rate.

                     | 6 bits | 8 bits | 10 bits | 12 bits | 14 bits | 16 bits | 18 bits | 20 bits
-------------------- | ------ | ------ | ------- | ------- | ------- | ------- | ------- | -------
**pre-image attack** | 0.5    | 1.3    | 6.4     | 26.3    | 140     | 290.4   | 343.3   | 385.1
**collision attack** | 1.5    | 0.5    | 0.6     | 3.2     | 4.1     | 16.6    | 86      | 308.8

The graph for the table above is given below:
![alt text](https://github.com/mcrossen/hashattack/raw/master/results.png)

## Conclusion
The data from this experiment shows that original complexity calculations of O(2<sup>n</sup>) and O(2<sup>n/2</sup>) for pre-image and collision attacks (respectively) was correct.
