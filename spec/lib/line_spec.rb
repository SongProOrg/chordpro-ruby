# frozen_string_literal: true

RSpec.describe ChordPro::Line do
  let(:line) { ChordPro::Line.new }

  describe '#tablature?' do
    subject { line.tablature? }

    context 'tablature set' do
      before { line.tablature = 'abc' }

      it { is_expected.to be_truthy }
    end

    context 'tablature not set' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#measures?' do
    subject { line.measures? }

    context 'measures set' do
      before { line.measures = [double] }

      it { is_expected.to be_truthy }
    end

    context 'measures not set' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#comment?' do
    subject { line.comment? }

    context 'comment set' do
      before { line.comment = double }

      it { is_expected.to be_truthy }
    end

    context 'comment not set' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#parts?' do
    subject { line.parts? }

    context 'parts has values' do
      before { line.parts = [double] }

      it { is_expected.to be_truthy }
    end

    context 'parts not set' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#empty?' do
    subject { line.empty? }

    context 'has parts' do
      before { line.parts = [double] }

      it { is_expected.to be_falsey }
    end

    context 'is tablature' do
      before { line.tablature = double }

      it { is_expected.to be_falsey }
    end

    context 'is comment' do
      before { line.comment = double }

      it { is_expected.to be_falsey }
    end

    context 'is measures' do
      before { line.measures = [double] }

      it { is_expected.to be_falsey }
    end

    it { is_expected.to be_truthy }
  end
end
