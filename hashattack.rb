#!/usr/bin/env ruby

FILE_OUT = "data_out.csv" # where to store the data.
TEST_BIT_SIZES = [6, 8, 10, 12, 14, 16, 18, 20] # the digest bit sizes to test
TRIALS_PER_BIT_SIZE = 50 # how many trials to do per bit size. The average will be recorded
MAX_STRING_LENGTH = 2 # the maximum length of the preimages to test with. larger values require heavy pre-computation and aren't really necessary
THREAD_COUNT = 2

# set up the application path
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "benchmark"
require 'digest/sha1'

# this method creates hashes a string and truncates it to fit the given bit size. the result is returned
def create_digest(string, bit_size)
  Digest::SHA1.hexdigest(string).hex.to_s(2).rjust(40*4, '0')[0..bit_size-1].to_i(2)
end

# every possible preimage is precalculated to save time
# this is useful because it also prevents guessing the same preimage twice
print "calculating combinations..."
# first, figure out the largest hexadecimal value that can fit in a given preimage
ALL_RAND_STRINGS=MAX_STRING_LENGTH.times.map do
  "ff"
#second, go through each value and convert it to a character string (since the sha1 library takes a standard string [a-zA-z0-9])
end.join.to_i(16).times.map do |num|
  to_return = num.to_s(16)
  if (to_return.length % 2 != 0)
    "0"+to_return
  else
    to_return
  end
end

# preshuffle the preimages and create a few different sets so each attack trial is unique
SHUFFLED_RAND_STRINGS=TRIALS_PER_BIT_SIZE.times.map do
  ALL_RAND_STRINGS.shuffle
end

print "done\n"

# perform a single collision attack given the bit size
def collision_attack(bit_size, set_index = 0)
  # randomize the set of preimages to make each trial different
  digests = Array.new(SHUFFLED_RAND_STRINGS[set_index].size)
  found = false
  # measure the runtime of this process
  to_return = Benchmark.measure do
    # for every new digest computed, compare it against the list of known digests to find a match
    SHUFFLED_RAND_STRINGS[set_index].each_with_index do |rstring1, index1|
      digests[index1] = create_digest(rstring1, bit_size)
      # the '-1' prevents the digest from being compared with itself
      (index1-1).times.each do |index2|
        if digests[index1] == digests[index2] then
          found = true
          break
        end
      end
      break if found
    end
  end.real
  raise "no collision found" if !found
  to_return
end

def preimage_attack(bit_size, set_index = 0)
  # create random preimage and digest to create attack against
  preimage = SHUFFLED_RAND_STRINGS[set_index].sample
  digest = create_digest(preimage, bit_size)
  found = false
  # record the runtime of the process
  to_return = Benchmark.measure do
    SHUFFLED_RAND_STRINGS[set_index].each do |rstring|
      if create_digest(rstring, bit_size) == digest then
        found = true
        break
      end
    end
  end.real
  raise "preimage attack failed" if !found
  to_return
end

Thread.abort_on_exception=true
# start calculating all the collision attacks
collision_data = Hash[TEST_BIT_SIZES.map do |bit_size|
  # display which attack is being processed
  print "testing collision attack for " + bit_size.to_s + " bits: "
  # create an array for each thread to store its result in
  to_return = Array.new
  # create one thread per trial
  TRIALS_PER_BIT_SIZE.times.each_slice(THREAD_COUNT).each do |chunk|
    chunk.map do |t_num|
      Thread.new do
        # store the result of the collision attack in the array
        to_return.push(collision_attack(bit_size, t_num))
      end
    # wait for all threads to finish
    end.each do |t|
      t.join
    end
  end
  # compute the average
  to_return = to_return.inject(&:+)*1000/TRIALS_PER_BIT_SIZE
  # finish displaying status
  print to_return.to_s + " ms\n"
  # return the data as a hash from bit size to runtime
  [bit_size, to_return]
end]

# start calculating all the preimage attacks
preimage_data = Hash[TEST_BIT_SIZES.map do |bit_size|
  # display which attack is being processed
  print "testing preimage attack for " + bit_size.to_s + " bits: "
  # create an array for each thread to store its result in
  to_return = Array.new
  # create one thread per trial
  TRIALS_PER_BIT_SIZE.times.each_slice(THREAD_COUNT).each do |chunk|
    chunk.map do |t_num|
      Thread.new do
        to_return.push(preimage_attack(bit_size, t_num))
      end
    # wait for all threads to finish
    end.each do |t|
      t.join
    end
  end
  # compute the average
  to_return = to_return.inject(&:+)*1000/TRIALS_PER_BIT_SIZE
  # finish displaying status
  print to_return.to_s + " ms\n"
  # return the data as a hash from bit size to runtime
  [bit_size, to_return]
end]

# write the data to a comma separated variable file
puts "writing data to file..."
File.write(FILE_OUT, "bit size, preimage times, collision times\n" + TEST_BIT_SIZES.map do |bit_size|
  bit_size.to_s + ", " + preimage_data[bit_size].to_s + ", " + collision_data[bit_size].to_s
end.join("\n"))
