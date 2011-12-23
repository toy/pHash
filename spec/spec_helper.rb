$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rspec'
require 'fspath'
require 'phash'

class FSPath
  def main_name
    basename.to_s.split('-', 2).first
  end
end
