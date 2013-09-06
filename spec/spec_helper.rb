$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rspec'
require 'phash'

module SpecHelpers
  def filenames(pattern)
    data_dir = File.join File.dirname(__FILE__), 'data'
    Dir.glob(File.join data_dir, pattern)
  end

  def main_name(path)
    File.basename(path).split('-', 2).first
  end
end
