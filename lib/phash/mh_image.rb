require 'phash'

module Phash
  # compute MH image hash
  # param filename string name of image file
  # param N (out) int value for length of image hash returned
  # return uint8_t array
  #
  # uint8_t* ph_mh_imagehash(const char *filename, int &N, float alpha=2.0f, float lvl = 1.0f);
  #
  attach_function :ph_mh_imagehash, [:string, :pointer], :pointer, :blocking => true

  # compute hamming distance between two byte arrays
  # param hashA byte array for first hash
  # param lenA int length of hashA 
  # param hashB byte array for second hash
  # param lenB int length of hashB
  # return double value for normalized hamming distance
  #
  # double ph_hammingdistance2(uint8_t *hashA, int lenA, uint8_t *hashB, int lenB);
  #
  attach_function :ph_hammingdistance2, [:pointer, :int, :pointer, :int], :double, :blocking => true

  # free memory allocated by C malloc
  #
  attach_function :libc_free, :free, [:pointer], :void

  class << self
    # Get image file hash using <tt>ph_mh_imagehash</tt>
    def mh_image_hash(path)
      return unless File.readable?(path) # phash lib throws on io errors, and we core dump
      out_len = FFI::MemoryPointer.new :int
      hash_p = ph_mh_imagehash(path.to_s, out_len)
      if !hash_p.null?
        hash = hash_p.get_array_of_uint8(0, out_len.get_int(0))
        libc_free(hash_p)

        MhImageHash.new(hash)
      end
    end

    def mh_image_similarity(hash_a, hash_b)
      hash_a.is_a?(MhImageHash) or raise ArgumentError.new('hash_a is not an MhImageHash')
      hash_b.is_a?(MhImageHash) or raise ArgumentError.new('hash_b is not an MhImageHash')
      hash_a.data.length == hash_b.data.length or raise ArgumentError.new('hash_a and hash_b have incompatible lenghts')

      hash_a_p = FFI::MemoryPointer.new(:uint8, hash_a.data.length)
      hash_a_p.put_array_of_uint8(0, hash_a.data)
      hash_b_p = FFI::MemoryPointer.new(:uint8, hash_b.data.length)
      hash_b_p.put_array_of_uint8(0, hash_b.data)

      1 - ph_hammingdistance2(hash_a_p, hash_a_p.size, hash_b_p, hash_b_p.size)
    end
  end

  # Class to store Mexican Hat image hash and compare to other
  class MhImageHash < HashData
  private

    def to_s
      data.pack("C*").unpack("H*").first
    end
  end

  # Class to store Mexican Hat image file hash and compare to other
  class MhImage < FileHash
  end
end
