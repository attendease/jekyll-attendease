require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::EventDataGenerator do
  context 'legacy site' do
    let(:site) { build_site }

    it 'populates a site wide presenters array' do
      expect(site.data['presenters'].class).to eq(Array)
      expect(site.data['presenters'].length).to eq(2)
    end

    it 'populates a site wide rooms array' do
      expect(site.data['rooms'].class).to eq(Array)
      expect(site.data['rooms'].length).to eq(1)
    end

    it 'populates a site wide sessions array' do
      expect(site.data['sessions'].class).to eq(Array)
      expect(site.data['sessions'].length).to eq(3)
    end

    it 'populates a site wide venues array' do
      expect(site.data['venues'].class).to eq(Array)
      expect(site.data['venues'].length).to eq(2)
    end

    it 'populates a site wide filters array' do
      expect(site.data['filters'].class).to eq(Array)
      expect(site.data['filters'].length).to eq(1)
    end

    it 'populates a site wide days array' do
      expect(site.config['attendease']['days'].class).to eq(Array)
      expect(site.config['attendease']['days'].length).to eq(2)
    end

    it 'populates a site wide sponsors array' do
      expect(site.data['sponsors'].class).to eq(Array)
      expect(site.data['sponsors'].length).to eq(1)
    end

    it 'populates a site wide pages array' do
      expect(site.data['pages'].class).to eq(Array)
      expect(site.data['pages'].length).to eq(7)
    end

    it 'populates a site wide event object' do
      expect(site.data['event'].class).to eq(Hash)
    end

    it 'populates a site wide settings object' do
      expect(site.data['site_settings'].class).to eq(Hash)
      expect(site.data['site_settings']['look_and_feel']['body_font_family']).to eq('serif')
    end
  end

  context 'new cms site' do
    let(:site) { build_site({ 'attendease' => { 'jekyll33' => true }}) }

    it 'populates a site wide pages array' do
      expect(site.data['pages'].class).to eq(Array)
      expect(site.data['pages'].length).to eq(7)
    end

    it 'populates a site wide event object' do
      expect(site.data['event'].class).to eq(Hash)
    end

    it 'populates a site wide settings object' do
      expect(site.data['site_settings'].class).to eq(Hash)
      expect(site.data['site_settings']['look_and_feel']['body_font_family']).to eq('serif')
    end

    it 'populates a site wide organization settings object' do
      expect(site.data['organization_site_settings'].class).to eq(Hash)
      expect(site.data['organization_site_settings']['look_and_feel']['heading_color']['h1']).to eq('rgba(55,27,184,1)')
    end

    it 'does not populate a site wide sponsors array' do
      expect(site.data['sponsors']).to be_nil
    end

    it 'populates a site wide portal pages array' do
      expect(site.data['portal_pages'].class).to eq(Array)
      expect(site.data['portal_pages'].length).to eq(2)
    end

  end

end
