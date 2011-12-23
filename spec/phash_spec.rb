require File.dirname(__FILE__) + '/spec_helper.rb'

describe :Phash do
  data_dir = FSPath(__FILE__).dirname / 'data'

  describe :Audio do
    let(:paths){ data_dir.glob('*.mp3') }
    let(:audios){ Phash::Audio.for_paths(paths) }

    it "should return valid distances" do
      audios.permutation(2) do |a, b|
        distance = a.distance(b)
        if a.path.main_name == b.path.main_name
          distance.should > 0.9
        else
          distance.should < 0.5
        end
      end
    end

    it "should return same distance if swapping audios" do
      audios.permutation(2) do |a, b|
        a.distance(b).should == b.distance(a)
      end
    end
  end
end
