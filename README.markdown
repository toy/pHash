# pHash

Interface to [pHash](http://pHash.org/).

## Installation

    gem install pHash

You can specify path to pHash library explicitly using environment variable like `PHASH_LIB=/opt/local/lib/libpHash.dylib`.

There are two problems with official version 0.9.6 of pHash. Both are fixed in a [fork of pHash](https://github.com/hszcg/pHash-0.9.6).

- Audio hash functions are not compiled with C linkage - you will get `FFI::NotFoundError` when comparing audio files. [Patch](https://github.com/hszcg/pHash-0.9.6/commit/e93af6d).

- Video hash functions are not compatible with latest ffmpeg changes - they will cause Segmentation Fault as explained in [Segmentation Fault error when trying to compare two videos with pHash library and its ruby bindings](http://stackoverflow.com/q/23414036/96823). [Patch](https://github.com/hszcg/pHash-0.9.6/commit/85218a6).

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

Copyright (c) 2011-2019 Ivan Kuchin.
Released under the GPLv3 as required by license of underlying pHash library.
See LICENSE.txt for details.
