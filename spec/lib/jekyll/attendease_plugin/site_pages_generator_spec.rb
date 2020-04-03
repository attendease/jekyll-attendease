require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::SitePagesGenerator do
  let(:site) { build_site }
  let(:site_pages_generator) { find_generator(site, described_class) }
  let(:index_file) { 'index.html' }
  let(:page) { site.data['pages'].detect { |p| p['slug'] == 'test' } }
  let(:external_page) { site.data['pages'].detect { |p| p['external'] == true } }
  let(:xss_page) { site.data['pages'].detect { |p| p['slug'] == 'agenda' } }

  context 'regular page' do
    it 'creates a page using the provided slug' do
      slug = page['slug']
      file = File.join(site.config['destination'], slug, 'index.html')
      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
      expect(File.read(file)).to include '<title>Test Page</title>'
    end

    it 'creates a block instance json file using the provided slug' do
      slug = page['slug']
      file = File.join(site.config['destination'], slug, 'index.json')
      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
    end

    it 'parses mappable placeholders' do
      slug = page['slug']
      file = File.join(site.config['destination'], slug, 'index.json')
      require 'pry'
      json = JSON.parse(File.read(file))
      expect(json['dropzone1'][0]['content']['text']).to eq('Hello world')
      expect(json['dropzone1'][0]['preferences']['foo']).to eq('Hello world')
    end
  end

  context 'page with XSS' do
    it 'escapes HTML in the page title' do
      slug = xss_page['slug']
      file = File.join(site.config['destination'], slug, 'index.html')
      expect(File.exists?(file)).to eq(true)
      expect(File.file?(file)).to eq(true)
      expect(File.read(file)).to include '<title>Agenda &lt;script&gt;alert()&lt;/script&gt;</title>'
    end
  end

  context 'external page' do
    before do
      expect(external_page).not_to be_nil
      expect(external_page['external']).to eq(true)
    end

    let(:home_page) do
      site.data['pages'].detect { |page| page['name'] == 'Home' }
    end

    it 'does not create a page using the provided slug' do
      external_page_slug = external_page['slug']
      expect(external_page_slug).to eq("")

      home_page_slug = home_page['slug']
      expect(home_page_slug).to eq(external_page_slug)

      file = File.join(site.config['destination'], external_page_slug, 'index.html')

      #
      # file exists but it's for the Home page:
      #
      expect(File.exists?(file)).to eq(true)
      expect(File.read(file)).to include("<title>#{home_page['name']}</title>")
    end
  end

  context 'when site is a private site' do
    let(:site) do
      build_site({ 'attendease' => { 'private_site' => true }})
    end

    before do
      expect(site.config.attendease['private_site']).to eq(true)
    end

    context 'regular page' do
      it 'creates a page using the provided slug' do
        slug = page['slug']
        file = File.join(site.config['destination'], slug, 'index.html')
        expect(File.exists?(file)).to eq(true)
        expect(File.file?(file)).to eq(true)
        expect(File.read(file)).to include '<title>Test Page</title>'
      end

      it 'creates a block instance private json file using the provided slug' do
        slug = page['slug']
        file = File.join(site.config['destination'], slug, 'index-private.json')
        expect(File.exists?(file)).to eq(true)
        expect(File.file?(file)).to eq(true)
      end
    end
  end
end

