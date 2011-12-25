require 'phash'

module Phash
  # read audio
  #
  # param filename - path and name of audio file to read
  # param sr - sample rate conversion
  # param channels - nb channels to convert to (always 1) unused
  # param buf - preallocated buffer
  # param buflen - (in/out) param for buf length
  # param nbsecs - float value for duration (in secs) to read from file
  #
  # return float* - float pointer to start of buffer - one channel of audio, NULL if error
  #
  # float* ph_readaudio(const char *filename, int sr, int channels, float *sigbuf, int &buflen, const float nbsecs = 0);
  #
  attach_function :ph_readaudio, [:string, :int, :int, :pointer, :pointer, :float], :pointer

  # audio hash calculation
  # purpose: hash calculation for each frame in the buffer.
  #          Each value is computed from successive overlapping frames of the input buffer.
  #          The value is based on the bark scale values of the frame fft spectrum. The value
  #          computed from temporal and spectral differences on the bark scale.
  #
  # param buf - pointer to start of buffer
  # param N   - length of buffer
  # param sr  - sample rate on which to base the audiohash
  # param nb_frames - (out) number of frames in audio buf and length of audiohash buffer returned
  #
  # return uint32 pointer to audio hash, NULL for error
  #
  # uint32_t* ph_audiohash(float *buf, int nbbuf, const int sr, int &nbframes);
  #
  attach_function :ph_audiohash, [:pointer, :int, :int, :pointer], :pointer

  # distance function between two hashes
  #
  # param hash_a - first hash
  # param Na     - length of first hash
  # param hash_b - second hash
  # param Nb     - length of second hash
  # param threshold - threshold value to compare successive blocks, 0.25, 0.30, 0.35
  # param block_size - length of block_size, 256
  # param Nc     - (out) length of confidence score vector
  #
  # return double - ptr to confidence score vector
  #
  # double* ph_audio_distance_ber(uint32_t *hash_a, const int Na, uint32_t *hash_b, const int Nb, const float threshold, const int block_size, int &Nc);
  #
  attach_function :ph_audio_distance_ber, [:pointer, :int, :pointer, :int, :float, :int, :pointer], :pointer

  class << self
    class AudioHash < HashData; end

    # Read audio file specified by path and optional length using <tt>ph_readaudio</tt> and get its hash using <tt>ph_audiohash</tt>
    def audio_hash(path, length = 0)
      sample_rate = 8000
      audio_data_length_p = FFI::MemoryPointer.new :int
      if audio_data = ph_readaudio(path.to_s, sample_rate, 1, nil, audio_data_length_p, length.to_f)
        audio_data_length = audio_data_length_p.get_int(0)
        audio_data_length_p.free

        hash_data_length_p = FFI::MemoryPointer.new :int
        if hash_data = ph_audiohash(audio_data, audio_data_length, sample_rate, hash_data_length_p)
          hash_data_length = hash_data_length_p.get_int(0)
          hash_data_length_p.free

          AudioHash.new(hash_data, hash_data_length)
        end
      end
    end

    # Get distance between two audio hashes using <tt>ph_audio_distance_ber</tt>
    def audio_distance_ber(hash_a, hash_b, threshold = 0.25, block_size = 256)
      distance_vector_length_p = FFI::MemoryPointer.new :int
      block_size = [block_size, hash_a.length, hash_b.length].min
      if distance_vector = ph_audio_distance_ber(hash_a.data, hash_a.length, hash_b.data, hash_b.length, threshold, block_size, distance_vector_length_p)
        distance_vector_length = distance_vector_length_p.get_int(0)
        distance_vector_length_p.free

        distance = distance_vector.get_array_of_double(0, distance_vector_length)
        distance_vector.free
        distance
      end
    end
  end

  # Class to store audio file hash and compare to other
  class Audio
    attr_reader :path, :length

    # Audio path and optional length in seconds to read
    def initialize(path, length = 0)
      @path, @length = path, length
    end

    # Init multiple audio instances
    def self.for_paths(paths, length = 0)
      paths.map do |path|
        new(path, length)
      end
    end

    # Distance from other file
    def distance(other)
      Phash.audio_distance_ber(phash, other.phash).max
    end

    # Cached hash of audio
    def phash
      @phash ||= Phash.audio_hash(@path, @length)
    end
  end
end
