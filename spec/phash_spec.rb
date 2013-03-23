require File.dirname(__FILE__) + '/spec_helper.rb'

describe :Phash do
  include SpecHelpers

  shared_examples :similarity do
    it "should return valid similarities" do
      collection.combination(2) do |a, b|
        if main_name(a.path) == main_name(b.path)
          (a % b).should > 0.8
        else
          (a % b).should <= 0.5
        end
      end
    end

    it "should return same similarity if swapping instances" do
      collection.combination(2) do |a, b|
        (a % b).should == (b % a)
      end
    end
  end

  describe :Audio do
    let(:collection){ Phash::Audio.for_paths filenames('*.mp3') }
    include_examples :similarity
  end

  describe :Image do
    let(:collection){ Phash::Image.for_paths filenames('**/*.{jpg,png}') }
    include_examples :similarity
  end

  describe :Text do
    let(:collection){ Phash::Text.for_paths filenames('*.txt') }
    include_examples :similarity
  end

  describe :Video do
    let(:collection){ Phash::Video.for_paths filenames('*.mp4') }
    include_examples :similarity
  end
end
