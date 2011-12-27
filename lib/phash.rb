require 'ffi'

module Phash
  class Data
    attr_reader :data, :length
    def initialize(data, length = nil)
      @data, @length = data, length
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

    # Similarity with other phash
    def similarity(other, *args)
      phash.similarity(other.phash, *args)
    end
    alias_method :%, :similarity
  end

  extend FFI::Library

  ffi_lib(ENV['PHASH_LIB'] || Dir['/{usr,usr/local,opt/local}/lib/libpHash.{dylib,so}'].first)

  autoload :Audio, 'phash/audio'
  autoload :Image, 'phash/image'
  autoload :Text, 'phash/text'
  autoload :Video, 'phash/video'
end
