require 'ffi'

module Phash
  extend FFI::Library

  ffi_lib(ENV['PHASH_LIB'] || Dir['/{usr,usr/local,opt/local}/lib/libpHash.{dylib,so}'].first)

  autoload :Audio, 'phash/audio'
  autoload :Image, 'phash/image'
  autoload :Text, 'phash/text'
  autoload :Video, 'phash/video'
end
