require 'phash'

module Phash
  # compute dct robust image hash
  #
  # param file string variable for name of file
  # param hash of type ulong64 (must be 64-bit variable)
  # return int value - -1 for failure, 1 for success
  #
  # int ph_dct_imagehash(const char* file, ulong64 &hash);
  #
  attach_function :ph_dct_imagehash, [:string, :pointer], :int, :blocking => true

  # no info in pHash.h
  #
  # int ph_hamming_distance(const ulong64 hash1,const ulong64 hash2);
  #
  attach_function :ph_hamming_distance, [:uint64, :uint64], :int, :blocking => true

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

  # free from libc
  #
  attach_function :libc_free, :free, [:pointer], :void

  class << self
    # Get image file hash using <tt>ph_dct_imagehash</tt>
    def image_hash(path)
      hash_p = FFI::MemoryPointer.new :ulong_long
      if -1 != ph_dct_imagehash(path.to_s, hash_p)
        hash = hash_p.get_uint64(0)
        hash_p.free

        ImageHash.new(hash)
      end
    end

    # Get distance between two image hashes using <tt>ph_hamming_distance</tt>
    def image_hamming_distance(hash_a, hash_b)
      hash_a.is_a?(ImageHash) or raise ArgumentError.new('hash_a is not an ImageHash')
      hash_b.is_a?(ImageHash) or raise ArgumentError.new('hash_b is not an ImageHash')

      ph_hamming_distance(hash_a.data, hash_b.data)
    end

    # Get similarity from hamming_distance
    def image_similarity(hash_a, hash_b)
      1 - image_hamming_distance(hash_a, hash_b) / 64.0
    end

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

  # Class to store image hash and compare to other
  class ImageHash < HashData
  private

    def to_s
      format('%016x', data)
    end
  end

  # Class to store Mexican Hat image hash and compare to other
  class MhImageHash < HashData
  private

    def to_s
      data.pack("C*").unpack("H*").first
    end
  end

  # Class to store image file hash and compare to other
  class Image < FileHash
  end

  # Class to store Mexican Hat image file hash and compare to other
  class MhImage < FileHash
  end
end
