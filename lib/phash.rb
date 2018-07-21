require 'ffi'

module Phash
  class Data
    attr_reader :data, :length
    def initialize(data, length = nil)
      @data = data
      @length = length if length
    end

    def inspect
      "#<#{self.class.name} #{to_s}>"
    end
  end

  class HashData < Data
    def similarity(other, *args)
      Phash.send("#{self.class.hash_type}_similarity", self, other, *args)
    end

    def self.hash_type
      @hash_type ||= self.name.split('::').last.sub(/Hash$/, '').downcase
    end
  end

  class FileHash
    attr_reader :path

    # File path
    def initialize(path)
      @path = path
    end

    # Init multiple image instances
    def self.for_paths(paths, *args)
      paths.map do |path|
        new(path, *args)
      end
    end

    # Cached hash of text
    def phash
      @phash ||= compute_phash
    end

    def compute_phash
      Phash.send("#{self.class.hash_type}_hash", @path)
    end

    # Similarity with other phash
    def similarity(other, *args)
      phash.similarity(other.phash, *args)
    end
    alias_method :%, :similarity

    def self.hash_type
      @hash_type ||= self.name.split('::').last.downcase
    end
  end

  extend FFI::Library

  begin
    ffi_lib 'pHash'
  rescue LoadError => e
    raise LoadError, "Specify path to pHash library using PHASH_LIB environment variable. #{e.message}"
  end

  autoload :Audio, 'phash/audio'
  autoload :Image, 'phash/image'
  autoload :Text, 'phash/text'
  autoload :Video, 'phash/video'
end
