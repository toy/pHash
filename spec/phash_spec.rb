require 'phash'

{
  Phash::Audio => '*.mp3',
  Phash::Image => '**/*.{jpg,png}',
  Phash::Text => '*.txt',
  Phash::Video => '*.mp4',
}.each do |klass, glob|
  describe klass do
    filenames = Dir.glob(File.join(File.dirname(__FILE__), 'data', glob))

    klass.for_paths(filenames).combination(2) do |a, b|
      similar = a.path.split('-')[0] == b.path.split('-')[0]

      if similar
        it "finds #{a.path} and #{b.path} similar" do
          expect(a % b).to be > 0.8
        end
      else
        it "finds #{a.path} and #{b.path} not similar" do
          expect(a % b).to be <= 0.5
        end
      end

      it 'returns same result when switching arguments' do
        expect(a % b).to eq(b % a)
      end
    end
  end
end
