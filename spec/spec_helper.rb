require 'jekyll'
require 'coveralls'
Coveralls.wear!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path('../support', __FILE__) + '/**/*.rb']
  .each { |f| require f }

RSpec.configure do |config|
  config.include FixturesHelpers
  config.extend  FixturesHelpers

  config.disable_monkey_patching!

  config.before(:all) do
    if Gem::Version.new('2') <= Gem::Version.new(Jekyll::VERSION)
      Jekyll.logger.log_level = ENV['debug'].nil? ? :warn : :debug
    else
      Jekyll.logger.log_level = Jekyll::Stevenson::WARN
    end

    @template_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'templates'))
    FileUtils.touch Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '_attendease', 'data', '*.*'))
    #let!(:site) { build_site }
    #let!(:org_site) { build_site({ attendease: { mode: 'organization' } }) }
    #let!(:page) { Jekyll::Page.new(@site, File.join(File.dirname(__FILE__), 'fixtures'), '', 'page.html') }
  end

  def site
    @site
  end

  def dest
    @dest ||= fixtures_path.join('_site')
  end

  def page
    Jekyll::Page.new(site, File.join(File.dirname(__FILE__), 'fixtures'), '', 'page.html')
  end

  def test_dir(*subdirs)
    File.join(File.dirname(__FILE__), *subdirs)
  end

  def dest_dir(*subdirs)
    test_dir('dest', *subdirs)
  end

  def source_dir(*subdirs)
    test_dir('source', *subdirs)
  end

  def build_configs(overrides, base_hash = Jekyll::Configuration::DEFAULTS)
    Jekyll::Utils.deep_merge_hashes(base_hash, overrides)
  end

  def find_generator(site, generator_class)
    site.generators.select { |m| m.class == generator_class }.first
  end

  def find_page(site, page_class, lambda_matcher = false)
    site.pages.detect do |m|
      if m.class == page_class
        match = true
        if lambda_matcher
          match = lambda_matcher.call(m)
        end
        m if match
      end
    end
  end

  def site_configuration(overrides = {})
    Jekyll::Utils.deep_merge_hashes(build_configs({
      'source'               => fixtures_path.to_s,
      'destination'          => dest.to_s,
      'attendease'           => {
        'api_host'                 => 'https://foobar/',
        'has_sessions'             => true,
        'has_presenters'           => true,
        'has_sponsors'             => true,
        'has_rooms'                => true,
        'has_filters'              => true,
        'has_venues'               => true,
        'has_mappable'             => true,
        'environment'              => 'test',
        'locale'                   => 'en',
        'source_id'                => 'foobar',
        'auth_host'                => 'https://foobar.auth/',
        'organization_url'         => 'https://foobar.org/',
        'organization_id'          => 'batbaz',
        'organization_name'        => 'Foo Bar Widgets',
        'available_portal_locales' => %w{ en fr it es de },
        'features'                 => { 'sentry' => true },
        'sentry_client_version'    => '5.2.0',
        'sentry_dsn'               => 'https://foobar@sentry.io/baz'
      }
    }), overrides)
  end

  def build_site(config = {})
    #dest.rmtree if dest.exist?
    @site = Jekyll::Site.new(site_configuration(config))
    @site.process
    @site
  end

  def build_org_site
    build_site({ 'attendease' => { 'mode' => 'organization', 'jekyll33' => true } })
  end

  config.after(:each) do |foo|
    puts "Removing #{dest}"
    dest.rmtree if dest.exist?
    fixtures_path.join('_attendease', 'templates').rmtree if File.exists?(fixtures_path.join('_attendease', 'templates'))
    fixtures_path.join('attendease_layouts').rmtree if File.exists?(fixtures_path.join('attendease_layouts'))
    unless @site.nil?
      Dir.glob(File.join(@site.source, '**', 'index.json')).map do |i|
        if (Pathname.new(i).parent == fixtures_path)
          FileUtils.rm i
        else
          FileUtils.rm_r Pathname.new(i).parent
        end
      end

      Dir.glob(File.join(@site.source, '**', 'index-private.json')).map do |i|
        if (Pathname.new(i).parent == fixtures_path)
          FileUtils.rm i
        else
          FileUtils.rm_r Pathname.new(i).parent
        end
      end
    end
  end
end

