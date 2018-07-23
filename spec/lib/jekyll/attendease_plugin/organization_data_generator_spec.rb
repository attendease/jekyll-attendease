require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::OrganizationDataGenerator do
  context 'new cms site' do
    let(:site) { build_org_site }

    it 'populates a site wide pages array' do
      expect(site.data['pages'].class).to eq(Array)
      expect(site.data['pages'].length).to eq(7)
    end

    it 'populates a site wide settings object' do
      expect(site.data['site_settings'].class).to eq(Hash)
      expect(site.data['site_settings']['look_and_feel']['body_font_family']).to eq('serif')
    end

    it 'responds to GET from HTTParty' do
      expect(subject).to respond_to(:get)
    end
  end
end

