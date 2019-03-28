require 'phash'

{
  Phash::Audio => '*.mp3',
  Phash::Image => '**/*.{jpg,png}',
  Phash::Text => '*.txt',
  Phash::Video => '*.mp4',
  # mh hash does not perform well on the includes samples,
  # but as a sanity test this is good enough
  Phash::MhImage => ['**/*.{jpg,png}', 0.7, 0.5],
}.each do |klass, (glob, not_similar_threshold, similar_threshold)|
  describe klass do
    not_similar_threshold ||= 0.5
    similar_threshold ||= 0.8
    filenames = Dir.glob(File.join(File.dirname(__FILE__), 'data', glob))

    klass.for_paths(filenames).combination(2) do |a, b|
      similar = a.path.split('-')[0] == b.path.split('-')[0]

      if similar
        it "finds #{a.path} and #{b.path} similar" do
          expect(a % b).to be > similar_threshold
        end
      else
        it "finds #{a.path} and #{b.path} not similar" do
          expect(a % b).to be <= not_similar_threshold
        end
      end

      it 'returns same result when switching arguments' do
        expect(a % b).to eq(b % a)
      end
    end
  end
end
