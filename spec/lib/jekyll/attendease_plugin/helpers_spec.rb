# encoding: UTF-8
require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::Helpers do
  describe '#parameterize' do
    it 'converts a typical filter item into a predictable CSS-friendly class name' do
      expect(Jekyll::AttendeasePlugin::Helpers.parameterize('Super Hyper Advanced', '-')).to eq('super-hyper-advanced')
    end

    it 'converts a title to a snake-case style string' do
      expect(Jekyll::AttendeasePlugin::Helpers.parameterize(' That quick brown fox? Jumps over the lazy dog...')).to eq('that_quick_brown_fox_jumps_over_the_lazy_dog')
    end

    it 'converts accented characters to an ASCII-equivalent' do
      expect(Jekyll::AttendeasePlugin::Helpers.parameterize('Pepé Le Pew')).to eq('pepe_le_pew')
    end

    it 'will not repeat the separator' do
      expect(Jekyll::AttendeasePlugin::Helpers.parameterize('What--the--hell?')).to eq('what_the_hell')
    end

    it 'will strip leading and trailing separators' do
      expect(Jekyll::AttendeasePlugin::Helpers.parameterize('-, What--the--hell? ::')).to eq('what_the_hell')
    end
  end

  describe '#convert_to_ascii' do
    it 'converts accented characters to plain letters' do
      expect(Jekyll::AttendeasePlugin::Helpers.convert_to_ascii('café')).to eq('cafe')
    end
  end

  describe '#public_pages' do
    let(:pages) { JSON.parse(File.read(fixtures_path.join('_attendease', 'data', 'pages.json'))) }
    let(:public_pages) { Jekyll::AttendeasePlugin::Helpers.public_pages(pages) }
    let(:all_pages_hidden) do
      hidden_pages = pages.map { |p| p['hidden'] = true; p }
      Jekyll::AttendeasePlugin::Helpers.public_pages(hidden_pages)
    end

    it 'sorts pages by weight' do
      expect(public_pages[0]['weight']).to eq(0)
      expect(public_pages[0]['href']).to eq('/')

      expect(public_pages[1]['weight']).to eq(1)
      expect(public_pages[1]['href']).to eq('/product/')

      expect(public_pages[2]['weight']).to eq(2)
      expect(public_pages[2]['href']).to eq('/agenda/')

      expect(public_pages[3]['weight']).to eq(3)
      expect(public_pages[3]['href']).to eq('/sponsors/')
    end

    it 'sorts children by weight' do
      expect(public_pages[1]['children'][0]['name']).to eq('Product Child 2')
      expect(public_pages[1]['children'][1]['name']).to eq('Product Child 1')
    end

    it 'publishes the home page regardless of hidden status' do
      expect(all_pages_hidden.length).to eq(1)
      expect(all_pages_hidden[0]['href']).to eq('/')
    end

    it 'only has the declared keys in each page object' do
      expect(public_pages[0].keys.length).to eq(8)
    end

    it 'handles nil input' do
      expect(Jekyll::AttendeasePlugin::Helpers.public_pages(nil)).to be_nil
    end
  end
end
