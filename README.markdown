# pHash

Interface to [pHash](http://pHash.org/).

## Installation

    gem install pHash

Audio hash functions needs to be compiled with C linkage, so if you get `FFI::NotFoundError` check names of methods in `libpHash`. Tiny patch for pHash 0.9.4 is in `audiophash.diff`.

## Dependencies

* [pHash](http://www.phash.org/download/)
* [ffi](https://github.com/ffi/ffi#readme) ~> 1.0

## Usage

Compare two mp3s:

    require 'phash/audio'

    a = Phash::Audio.new('first.mp3')
    b = Phash::Audio.new('second.mp3')
    a.similarity(b)

or just

    a % b

Get bunch of comparators and work with them:

    audios = Phash::Audio.for_paths(Dir['**/*.{mp3,wav}'])
    audios.combination(2) do |a, b|
      similarity = a % b
      # work with similarity
    end

Videos:

    require 'phash/video'

    Phash::Video.new('first.mp4') % Phash::Video.new('second.mp4')

Images:

    require 'phash/image'

    Phash::Image.new('first.jpg') % Phash::Image.new('second.png')

Texts:

    require 'phash/text'

    Phash::Text.new('first.txt') % Phash::Text.new('second.txt')

## Copyright

Copyright (c) 2011-2013 Ivan Kuchin.
Released under the GPLv3 as required by license of underlying pHash library.
See LICENSE.txt for details.
