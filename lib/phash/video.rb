require 'phash'

module Phash
  # no info in pHash.h
  #
  # ulong64* ph_dct_videohash(const char *filename, int &Length);
  #
  attach_function :ph_dct_videohash, [:string, :pointer], :pointer

  # no info in pHash.h
  #
  # double ph_dct_videohash_dist(ulong64 *hashA, int N1, ulong64 *hashB, int N2, int threshold=21);
  #
  attach_function :ph_dct_videohash_dist, [:pointer, :int, :pointer, :int, :int], :double

  class << self
    class VideoHash < HashData; end

    # Get video hash using <tt>ph_dct_videohash</tt>
    def video_hash(path)
      hash_data_length_p = FFI::MemoryPointer.new :int
      if hash_data = ph_dct_videohash(path.to_s, hash_data_length_p)
        hash_data_length = hash_data_length_p.get_int(0)
        hash_data_length_p.free

        VideoHash.new(hash_data, hash_data_length)
      end
    end

    # Get distance between two video hashes using <tt>ph_dct_videohash_dist</tt>
    def video_dct_distance(hash_a, hash_b, threshold = 21)
      ph_dct_videohash_dist(hash_a.data, hash_a.length, hash_b.data, hash_b.length, threshold)
    end
  end

  # Class to store video file hash and compare to other
  class Video
    attr_reader :path

    # Video path
    def initialize(path)
      @path = path
    end

    # Init multiple video instances
    def self.for_paths(paths)
      paths.map do |path|
        new(path)
      end
    end

    # Distance from other file
    def distance(other)
      Phash.video_dct_distance(phash, other.phash)
    end

    # Cached hash of video
    def phash
      @phash ||= Phash.video_hash(@path)
    end
  end
end
