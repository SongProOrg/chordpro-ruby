# frozen_string_literal: true

require "chord_pro/version"
require "chord_pro/song"
require "chord_pro/section"
require "chord_pro/line"
require "chord_pro/part"
require "chord_pro/measure"

module ChordPro
  SECTION_REGEX = /\{(?:chorus|soc|sov|start_of_verse|start_of_chorus|sob|start_of_bridge|start_of_tab|sot|start_of_grid|sog):?\n?(.*)\}/m
  ATTRIBUTE_REGEX = /\{(\w*):([^%]*)\}/
  CUSTOM_ATTRIBUTE_REGEX = /\{meta:\s*(\w*) ([^%]*)\}/
  CHORDS_AND_LYRICS_REGEX = %r{(\[[\w#b\/]+\])?([^\[]*)}i

  MEASURES_REGEX = %r{([\[[\w#b\/]+\]\s]+)[|]*}i
  CHORDS_REGEX = %r{\[([\w#b\/]+)\]?}i
  COMMENT_REGEX = /\{(?:c|comment|comment_italic|ci|comment_box|cb):([^$]*)\}/
  SANITIZE_REGEX = /\{end_of_chorus|eoc|end_of_verse|eov|end_of_tab|eot|end_of_tab|eog|end_of_grid|colb\}/

  class << self
    def parse(lines)
      song = Song.new
      current_section = nil

      lines.split("\n").each do |text|
        if text.start_with?("{meta:")
          process_custom_attribute(song, text)
        elsif section_start?(text)
          current_section = process_section(song, text)
        elsif !comment_starts?(text) && attribute_start?(text)
          process_attribute(song, text)
        elsif text.match(SANITIZE_REGEX)
          # ignore
        else
          process_lyrics_and_chords(song, current_section, text)
        end
      end

      song
    end

    def process_section(song, text)
      matches = SECTION_REGEX.match(text)
      name = (!matches[1].empty?) ? matches[1].strip : section_name_by_directive(text)

      current_section = Section.new(name: name)
      song.sections << current_section

      current_section
    end

    def process_attribute(song, text)
      matches = ATTRIBUTE_REGEX.match(text)
      key = matches[1]
      value = matches[2].strip

      if song.respond_to?(:"#{key}=")
        song.send(:"#{key}=", value)
      else
        puts "WARNING: Unknown attribute '#{key}'"
      end
    end

    def process_custom_attribute(song, text)
      matches = CUSTOM_ATTRIBUTE_REGEX.match(text)
      key = matches[1]
      value = matches[2].strip

      song.set_custom(key, value)
    end

    def process_lyrics_and_chords(song, current_section, text)
      return if text == ""

      if current_section.nil?
        current_section = Section.new(name: "")
        song.sections << current_section
      end

      line = Line.new

      if text.start_with?("|-")
        line.tablature = text
      elsif text.start_with?("| ")
        captures = text.scan(MEASURES_REGEX).flatten

        measures = []

        captures.each do |capture|
          chords = capture.scan(CHORDS_REGEX).flatten
          measure = Measure.new
          measure.chords = chords
          measures << measure
        end

        line.measures = measures
      elsif comment_starts?(text)
        matches = COMMENT_REGEX.match(text)
        comment = matches[1].strip
        line.comment = comment
      else
        captures = text.scan(CHORDS_AND_LYRICS_REGEX).flatten

        captures.each_slice(2) do |pair|
          part = Part.new
          chord = pair[0]&.strip || ""
          part.chord = chord.delete("[").delete("]")
          part.lyric = pair[1] || ""

          line.parts << part unless (part.chord == "") && (part.lyric == "")
        end
      end

      current_section.lines << line unless line.empty?
    end

    private

    def attribute_start?(text)
      text.match(/\{(.+):(.*)\}/)
    end

    def section_start?(text)
      text.match(SECTION_REGEX)
    end

    def comment_starts?(text)
      text.match(/\{(?:c|comment|comment_italic|ci|comment_box|cb):/)
    end

    def section_name_by_directive(text)
      return "Chorus" if /soc|start_of_chorus|chorus/.match?(text)
      return "Verse" if /sov|start_of_verse/.match?(text)
      return "Tab" if /sot|start_of_tab/.match?(text)
      "Grid" if /sot|start_of_grid/.match?(text)
    end
  end
end
