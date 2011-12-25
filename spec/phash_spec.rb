require File.dirname(__FILE__) + '/spec_helper.rb'

describe :Phash do
  data_dir = FSPath(__FILE__).dirname / 'data'

  shared_examples :similarity do
    it "should return valid similarities" do
      collection.combination(2) do |a, b|
        if a.path.main_name == b.path.main_name
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
    let(:collection){ Phash::Audio.for_paths(data_dir.glob('*.mp3')) }
    include_examples :similarity
  end

  describe :Image do
    let(:collection){ Phash::Image.for_paths(data_dir.glob('**/*.{jpg,png}')) }
    include_examples :similarity
  end

  describe :Text do
    let(:collection){ Phash::Text.for_paths(data_dir.glob('*.txt')) }
    include_examples :similarity
  end

  describe :Video do
    let(:collection){ Phash::Video.for_paths(data_dir.glob('*.mp4')) }
    include_examples :similarity
  end
end
