#!/usr/bin/env ruby

FILE_OUT = "data_out.csv"
TEST_BIT_SIZES = [4, 8, 12, 16, 20, 24, 28, 32, 36, 40]
TRIALS_PER_BIT_SIZE = 3
MAX_STRING_LENGTH = TEST_BIT_SIZES.last/8

# set up the application path
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "sha1wrapper"
require "benchmark"

print "calculting combinations..."
ALL_RAND_STRINGS=MAX_STRING_LENGTH.times.map do
  "f"
end.join.to_i(16).times.map do |num|
  to_return = num.to_s(16)
  if (to_return.length % 2 != 0)
    "0"+to_return
  else
    to_return
  end
end
print "done\n"


def collision_attack(bit_size)
  rstrings1 = ALL_RAND_STRINGS.shuffle
  rstrings2 = ALL_RAND_STRINGS.shuffle
  found = false
  to_return = Benchmark.measure do
    rstrings1.each do |rstring1|
      rstrings2.each do |rstring2|
        if rstring1 != rstring2 && HashAttack.create_digest(rstring1, bit_size) == HashAttack.create_digest(rstring2, bit_size) then
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

def preimage_attack(bit_size)
  # create random preimage and digest to create attack against
  preimage = ALL_RAND_STRINGS.sample
  digest = HashAttack.create_digest(preimage, bit_size)
  rstrings = ALL_RAND_STRINGS.shuffle
  found = false
  to_return = Benchmark.measure do
    rstrings.each do |rstring|
      if HashAttack.create_digest(rstring, bit_size) == digest && preimage == rstring then
        found = true
        break
      end
    end
  end.real
  raise "preimage attack failed" if !found
  to_return
end

preimage_data = Hash[TEST_BIT_SIZES.map do |bit_size|
  print "testing preimage attack for " + bit_size.to_s + " bits: "
  to_return = (TRIALS_PER_BIT_SIZE.times.map do
    preimage_attack(bit_size)
  end.inject(&:+)*1000/TRIALS_PER_BIT_SIZE)
  print to_return.to_s + " ms\n"
  [bit_size, to_return]
end]

collision_data = Hash[TEST_BIT_SIZES.map do |bit_size|
  print "testing collision attack for " + bit_size.to_s + " bits: "
  to_return = (TRIALS_PER_BIT_SIZE.times.map do
    collision_attack(bit_size)
  end.inject(&:+)*1000/TRIALS_PER_BIT_SIZE).to_s + " ms\n"
  print to_return.to_s + " ms\n"
  [bit_size, to_return]
end]

File.write(FILE_OUT, "bit size, preimage times, collision times\n" + TEST_BIT_SIZES.map do |bit_size|
  bit_size + ", " + preimage_data[bit_size] + ", " + collision_data[bit_size]
end.join("\n"))