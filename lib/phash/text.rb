require 'phash'

module Phash
  class TxtHashPoint < FFI::Struct
    layout  :hash, :uint64,
            :index, :off_t
  end

  class TxtMatch < FFI::Struct
    layout  :index_a, :off_t,
            :index_b, :off_t,
            :length, :uint32
  end

  # textual hash for file
  #
  # param filename - char* name of file
  # param nbpoints - int length of array of return value (out)
  # return TxtHashPoint* array of hash points with respective index into file.
  #
  # TxtHashPoint* ph_texthash(const char *filename, int *nbpoints);
  #
  attach_function :ph_texthash, [:string, :pointer], :pointer, :blocking => true

  # compare 2 text hashes
  #
  # param hash1 -TxtHashPoint
  # param N1 - int length of hash1
  # param hash2 - TxtHashPoint
  # param N2 - int length of hash2
  # param nbmatches - int number of matches found (out)
  # return TxtMatch* - list of all matches
  #
  # TxtMatch* ph_compare_text_hashes(TxtHashPoint *hash1, int N1, TxtHashPoint *hash2, int N2, int *nbmatches);
  #
  attach_function :ph_compare_text_hashes, [:pointer, :int, :pointer, :int, :pointer], :pointer, :blocking => true

  attach_function :free, [:pointer], :void

  class << self
    # Get text file hash using <tt>ph_texthash</tt>
    def text_hash(path)
      hash_data_length_p = FFI::MemoryPointer.new :int
      if hash_data = ph_texthash(path.to_s, hash_data_length_p)
        hash_data_length = hash_data_length_p.get_int(0)
        hash_data_length_p.free

        TextHash.new(hash_data, hash_data_length)
      end
    end

    # Get distance between two text hashes using <tt>text_distance</tt>
    def text_similarity(hash_a, hash_b)
      hash_a.is_a?(TextHash) or raise ArgumentError.new('hash_a is not a TextHash')
      hash_b.is_a?(TextHash) or raise ArgumentError.new('hash_b is not a TextHash')

      matches_length_p = FFI::MemoryPointer.new :int
      if data = ph_compare_text_hashes(hash_a.data, hash_a.length, hash_b.data, hash_b.length, matches_length_p)
        matches_length = matches_length_p.get_int(0)
        matches_length_p.free

        matches = matches_length.times.map{ |i| TxtMatch.new(data + i * TxtMatch.size) }

        matched_a = Array.new(hash_a.length)
        matched_b = Array.new(hash_b.length)
        matches.each do |match|
          index_a = match[:index_a]
          index_b = match[:index_b]
          match[:length].times do |i|
            matched_a[index_a + i] = true
            matched_b[index_b + i] = true
          end
        end
        coverage_a = matched_a.compact.length / hash_a.length.to_f
        coverage_b = matched_b.compact.length / hash_b.length.to_f

        similarity = (coverage_a + coverage_b) * 0.5
        free(data)
        similarity
      end
    end
  end

  # Class to store text hash and compare to other
  class TextHash < HashData
  private

    def to_s
      length.times.map do |i|
        p = TxtHashPoint.new(data + TxtHashPoint.size * i)
        format('%016x(%i)', p[:hash], p[:index])
      end.join(' ')
    end
  end

  # Class to store text file hash and compare to other
  class Text < FileHash
  end
end
