# frozen_string_literal: true

RSpec.describe ChordPro::Song do
  context "#chord" do
    it "returns all chords through the song" do
      song = ChordPro.parse('
{soc}
Some [D] chord [A]
| [B] [C] |
{eoc}
')

      expect(song.chords).to eq(%w[D A B C])
    end
  end

  context "#to_html" do
    it "generates divs" do
      infile = File.read("spec/fixtures/bad-moon-rising.pro")
      outfile = File.read("spec/fixtures/bad-moon-rising.html")
      song = ChordPro.parse(infile)

      html = song.to_html + "\n"

      expect(html).to include outfile
    end
  end
end
