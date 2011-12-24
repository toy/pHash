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
  attach_function :ph_dct_imagehash, [:string, :pointer], :int

  # no info in pHash.h
  #
  # int ph_hamming_distance(const ulong64 hash1,const ulong64 hash2);
  #
  attach_function :ph_hamming_distance, [:uint64, :uint64], :int

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
      ph_hamming_distance(hash_a, hash_b)
    end
  end

  # Class to store image file hash and compare to other
  class Image
    attr_reader :path

    # File path
    def initialize(path)
      @path = path
    end

    # Init multiple image instances
    def self.for_paths(paths)
      paths.map do |path|
        new(path)
      end
    end

    # Distance from other file, for now bit useless thing
    def distance(other)
      Phash.image_hamming_distance(phash, other.phash)
    end

    # Cached hash of image
    def phash
      @phash ||= Phash.image_hash(@path)
    end
  end
end
