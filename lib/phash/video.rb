require 'phash'

module Phash
  # no info in pHash.h
  #
  # ulong64* ph_dct_videohash(const char *filename, int &Length);
  #
  attach_function :ph_dct_videohash, [:string, :pointer], :pointer, :blocking => true

  # no info in pHash.h
  #
  # double ph_dct_videohash_dist(ulong64 *hashA, int N1, ulong64 *hashB, int N2, int threshold=21);
  #
  attach_function :ph_dct_videohash_dist, [:pointer, :int, :pointer, :int, :int], :double, :blocking => true

  class VideoHash < HashData; end
  class << self
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
      hash_a.is_a?(VideoHash) or raise ArgumentError.new('hash_a is not a VideoHash')
      hash_b.is_a?(VideoHash) or raise ArgumentError.new('hash_b is not a VideoHash')

      ph_dct_videohash_dist(hash_a.data, hash_a.length, hash_b.data, hash_b.length, threshold.to_i)
    end

    # Get similarity from video_dct_distance
    alias_method :video_similarity, :video_dct_distance
  end

  # Class to store video file hash and compare to other
  class Video < FileHash
    # Similarity with other video
    def similarity(other, *args)
      Phash.video_similarity(phash, other.phash, *args)
    end

  private

    def compute_phash
      Phash.video_hash(@path)
    end
  end
end
