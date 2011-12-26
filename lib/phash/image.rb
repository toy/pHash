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

  class << self
    # Get image file hash using <tt>ph_dct_imagehash</tt>
    def image_hash(path)
      hash_p = FFI::MemoryPointer.new :ulong_long
      if -1 != ph_dct_imagehash(path.to_s, hash_p)
        hash = hash_p.get_uint64(0)
        hash_p.free

        hash
      end
    end

    # Get distance between two image hashes using <tt>ph_hamming_distance</tt>
    def image_hamming_distance(hash_a, hash_b)
      hash_a.is_a?(Integer) or raise ArgumentError.new('hash_a is not an Integer')
      hash_b.is_a?(Integer) or raise ArgumentError.new('hash_b is not an Integer')

      ph_hamming_distance(hash_a, hash_b)
    end

    # Get similarity from hamming_distance
    def image_similarity(hash_a, hash_b)
      1 - image_hamming_distance(hash_a, hash_b) / 64.0
    end
  end

  # Class to store image file hash and compare to other
  class Image < FileHash
    # Similarity with other image
    def similarity(other)
      Phash.image_similarity(phash, other.phash)
    end

  private

    def compute_phash
      Phash.image_hash(@path)
    end
  end
end
