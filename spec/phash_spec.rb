require File.dirname(__FILE__) + '/spec_helper.rb'

describe :Phash do
  data_dir = FSPath(__FILE__).dirname / 'data'

  shared_examples :swapping do
    it "should return same distance if swapping instances" do
      collection.combination(2) do |a, b|
        a.distance(b).should == b.distance(a)
      end
    end
  end

  describe :Audio do
    let(:collection){ Phash::Audio.for_paths(data_dir.glob('*.mp3')) }
    include_examples :swapping

    it "should return valid distances" do
      collection.combination(2) do |a, b|
        distance = a.distance(b)
        if a.path.main_name == b.path.main_name
          distance.should > 0.9
        else
          distance.should < 0.5
        end
      end
    end
  end

  describe :Image do
    let(:collection){ Phash::Image.for_paths(data_dir.glob('**/*.{jpg,png}')) }
    include_examples :swapping

    it "should return valid distances" do
      collection.combination(2) do |a, b|
        distance = a.distance(b)
        if a.path.main_name == b.path.main_name
          distance.should <= 10
        else
          distance.should >= 30
        end
      end
    end
  end

  describe :Text do
    let(:collection){ Phash::Text.for_paths(data_dir.glob('*.h')) }
    include_examples :swapping

    it "should return valid distances" do
      collection.combination(2) do |a, b|
        distance = a.distance(b)
        if a.path.main_name == b.path.main_name
          distance.should > 1
        else
          distance.should < 0.5
        end
      end
    end
  end

  describe :Video do
    let(:collection){ Phash::Video.for_paths(data_dir.glob('*.mp4')) }
    include_examples :swapping

    it "should return valid distances" do
      collection.combination(2) do |a, b|
        distance = a.distance(b)
        if a.path.main_name == b.path.main_name
          distance.should > 0.9
        else
          distance.should < 0.5
        end
      end
    end
  end
end
