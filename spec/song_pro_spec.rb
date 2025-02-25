# frozen_string_literal: true

RSpec.describe ChordPro do
  context "custom attributes" do
    it "parses custom attributes" do
      song = ChordPro.parse('
{meta: difficulty Easy}
{meta: spotify_url https://open.spotify.com/track/5zADxJhJEzuOstzcUtXlXv?si=SN6U1oveQ7KNfhtD2NHf9A}
')

      expect(song.custom[:difficulty]).to eq("Easy")
      expect(song.custom[:spotify_url]).to eq("https://open.spotify.com/track/5zADxJhJEzuOstzcUtXlXv?si=SN6U1oveQ7KNfhtD2NHf9A")
    end
  end

  context "attributes" do
    it "parses attributes" do
      song = ChordPro.parse('
{title:Bad Moon Rising}
{artist:Creedence Clearwater Revival}
{capo:1st Fret}
{key:C# Minor}
{tempo:120}
{year:1975 Hundewelpen Records}
{year:1975}
{album:Foo Bar Baz}
{tuning:Eb Standard}
')

      expect(song.title).to eq("Bad Moon Rising")
      expect(song.artist).to eq("Creedence Clearwater Revival")
      expect(song.capo).to eq("1st Fret")
      expect(song.key).to eq("C# Minor")
      expect(song.tempo).to eq("120")
      expect(song.year).to eq("1975")
      expect(song.album).to eq("Foo Bar Baz")
      expect(song.tuning).to eq("Eb Standard")
    end
  end

  context "sections" do
    it "parses section names" do
      song = ChordPro.parse("{start_of_verse: Verse 1}")

      expect(song.sections.size).to eq 1
      expect(song.sections[0].name).to eq "Verse 1"
    end

    it "parses multiple section names" do
      song = ChordPro.parse('
{start_of_verse: Verse 1}
{start_of_verse}
{start_of_chorus: Chorus 1}
{start_of_chorus}
{chorus}
{chorus:Final}
')
      expect(song.sections.size).to eq 6
      expect(song.sections[0].name).to eq "Verse 1"
      expect(song.sections[1].name).to eq "Verse"
      expect(song.sections[2].name).to eq "Chorus 1"
      expect(song.sections[3].name).to eq "Chorus"
      expect(song.sections[4].name).to eq "Chorus"
      expect(song.sections[5].name).to eq "Final"
    end
  end

  context "lyrics" do
    it "parses lyrics" do
      song = ChordPro.parse("I don't see! a bad, moon a-rising. (a-rising)")

      expect(song.sections.size).to eq 1
      expect(song.sections[0].lines.size).to eq 1
      expect(song.sections[0].lines[0].parts.size).to eq 1
      expect(song.sections[0].lines[0].parts[0].lyric).to eq "I don't see! a bad, moon a-rising. (a-rising)"
    end

    it "handles parenthesis in lyics" do
      song = ChordPro.parse("singing something (something else)")

      expect(song.sections.size).to eq 1
      expect(song.sections[0].lines.size).to eq 1
      expect(song.sections[0].lines[0].parts.size).to eq 1
      expect(song.sections[0].lines[0].parts[0].lyric)
        .to eq "singing something (something else)"
    end

    it "handles special characters" do
      song = ChordPro.parse("singing sömething with Röck dots")

      expect(song.sections.size).to eq 1
      expect(song.sections[0].lines.size).to eq 1
      expect(song.sections[0].lines[0].parts.size).to eq 1
      expect(song.sections[0].lines[0].parts[0].lyric)
        .to eq "singing sömething with Röck dots"
    end
  end

  context "chords" do
    it "parses chords" do
      song = ChordPro.parse("[D] [D/F#] [C] [A7]")
      expect(song.sections.size).to eq 1
      expect(song.sections[0].lines.size).to eq 1
      expect(song.sections[0].lines[0].parts.size).to eq 4
      expect(song.sections[0].lines[0].parts[0].chord).to eq "D"
      expect(song.sections[0].lines[0].parts[0].lyric).to eq " "
      expect(song.sections[0].lines[0].parts[1].chord).to eq "D/F#"
      expect(song.sections[0].lines[0].parts[1].lyric).to eq " "
      expect(song.sections[0].lines[0].parts[2].chord).to eq "C"
      expect(song.sections[0].lines[0].parts[2].lyric).to eq " "
      expect(song.sections[0].lines[0].parts[3].chord).to eq "A7"
      expect(song.sections[0].lines[0].parts[3].lyric).to eq ""
    end
  end

  context "chords and lyrics" do
    it "parses chords and lyrics" do
      song = ChordPro.parse("[G]Don't go 'round tonight")
      expect(song.sections.size).to eq 1
      expect(song.sections[0].lines.size).to eq 1
      expect(song.sections[0].lines[0].parts.size).to eq 1
      expect(song.sections[0].lines[0].parts[0].chord).to eq "G"
      expect(song.sections[0].lines[0].parts[0].lyric)
        .to eq "Don't go 'round tonight"
    end

    it "parses lyrics before chords" do
      song = ChordPro.parse("It's [D]bound to take your life")
      expect(song.sections.size).to eq 1
      expect(song.sections[0].lines.size).to eq 1
      expect(song.sections[0].lines[0].parts.size).to eq 2
      expect(song.sections[0].lines[0].parts[0].chord).to eq ""
      expect(song.sections[0].lines[0].parts[0].lyric).to eq "It's "
      expect(song.sections[0].lines[0].parts[1].chord).to eq "D"
      expect(song.sections[0].lines[0].parts[1].lyric)
        .to eq "bound to take your life"
    end

    it "parses lyrics before chords" do
      song = ChordPro.parse("It's a[D]bout a [E]boy")
      expect(song.sections.size).to eq 1
      expect(song.sections[0].lines.size).to eq 1
      expect(song.sections[0].lines[0].parts.size).to eq 3
      expect(song.sections[0].lines[0].parts[0].chord).to eq ""
      expect(song.sections[0].lines[0].parts[0].lyric).to eq "It's a"
      expect(song.sections[0].lines[0].parts[1].chord).to eq "D"
      expect(song.sections[0].lines[0].parts[1].lyric).to eq "bout a "
      expect(song.sections[0].lines[0].parts[2].chord).to eq "E"
      expect(song.sections[0].lines[0].parts[2].lyric).to eq "boy"
    end
  end

  context "measures" do
    it "parses chord-only measures" do
      song = ChordPro.parse('
| [A] [B] | [C] | [D] [E] [F] [G] |
')

      expect(song.sections.size).to eq 1
      expect(song.sections[0].lines[0].measures?).to eq true
      expect(song.sections[0].lines[0].measures.length).to eq 3
      expect(song.sections[0].lines[0].measures[0].chords).to eq %w[A B]
      expect(song.sections[0].lines[0].measures[1].chords).to eq %w[C]
      expect(song.sections[0].lines[0].measures[2].chords).to eq %w[D E F G]
    end
  end

  context "tablature" do
    it "parses tablature" do
      song = ChordPro.parse('
{start_of_tab}
|-3---5-|
|---4---|
{end_of_tab}
')
      expect(song.sections.size).to eq 1
      expect(song.sections[0].lines[0].tablature?).to eq true
      expect(song.sections[0].lines[0].tablature).to eq "|-3---5-|"
      expect(song.sections[0].lines[1].tablature?).to eq true
      expect(song.sections[0].lines[1].tablature).to eq "|---4---|"
    end
  end

  context "comments" do
    it "parses comments" do
      song = ChordPro.parse('
{c:This is a comment.}
{comment:This is a comment.}
{highlight:This is a comment.}

{ci:This is an italic comment.}
{comment_italic:This is an italic comment.}

{cb:This is a box comment.}
{comment_box:This is a box comment.}
')

      expect(song.sections.size).to eq 6
      expect(song.sections[0].lines[0].comment?).to eq true
      expect(song.sections[0].lines[0].comment).to eq "This is a comment."
    end
  end

  context "full song" do
    it "parses the whole song" do
      bmr = File.read("spec/fixtures/bad-moon-rising.pro")
      song = ChordPro.parse(bmr)
      expect(song.title).to eq "Bad Moon Rising"
      expect(song.artist).to eq "Creedence Clearwater Revival"
      expect(song.capo).to eq "1"
      expect(song.sections.size).to eq 9
      expect(song.custom[:difficulty]).to eq "Easy"
      expect(song.custom[:spotify_url])
        .to eq "https://open.spotify.com/track/20OFwXhEXf12DzwXmaV7fj?si=cE76lY5TT26fyoNmXEjNpA"
    end
  end
end
