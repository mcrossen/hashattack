module HashAttack
  require 'digest/sha1'
  def self.create_digest(string, bit_size)
    # string = string.bytes.map do |n|
    #   n.to_s(16)
    # end.join("")
    throw "error: bit size must be divisible by 4" if (bit_size % 4 > 0)
    Digest::SHA1.hexdigest(string)[0..bit_size/4]
  end
end
