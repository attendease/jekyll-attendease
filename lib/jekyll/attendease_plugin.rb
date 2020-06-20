# Helper class that handles loading & parsing schedule data.
require 'jekyll/attendease_plugin/schedule_data_parser'

# Generators:
require 'jekyll/attendease_plugin/event_data_generator'
require 'jekyll/attendease_plugin/organization_data_generator'
require 'jekyll/attendease_plugin/event_layout_generator'
require 'jekyll/attendease_plugin/event_template_generator'
require 'jekyll/attendease_plugin/home_page_generator'
require 'jekyll/attendease_plugin/schedule_generator'
require 'jekyll/attendease_plugin/sponsor_generator'
require 'jekyll/attendease_plugin/site_pages_generator'
require 'jekyll/attendease_plugin/pre_zero_point_six_link_redirect_generator'

# Redirect page
require 'jekyll/attendease_plugin/redirect_page'

# Tags, filters and helpers
require 'jekyll/attendease_plugin/tags'
require 'jekyll/attendease_plugin/filters'
require 'jekyll/attendease_plugin/helpers'

# Pages
require 'jekyll/attendease_plugin/event_layout_page'
require 'jekyll/attendease_plugin/home_page'
require 'jekyll/attendease_plugin/presenters_index_page'
require 'jekyll/attendease_plugin/presenter_page'
require 'jekyll/attendease_plugin/schedule_day_page'
require 'jekyll/attendease_plugin/schedule_index_page'
require 'jekyll/attendease_plugin/schedule_sessions_page'
require 'jekyll/attendease_plugin/schedule_session_page'
require 'jekyll/attendease_plugin/sponsors_index_page'
require 'jekyll/attendease_plugin/venues_index_page'
require 'jekyll/attendease_plugin/venue_page'
require 'jekyll/attendease_plugin/site_page'
require 'jekyll/attendease_plugin/site_page_data'

# Ve.rs.ion
require 'jekyll/attendease_plugin/version'

# Register our config hook
require 'jekyll/attendease_plugin/config_mixin'

Jekyll::Hooks.register :site, :after_reset do |site|
  default = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), 'attendease_plugin', '_config.yaml'))

  site.config['attendease'] = site.config['attendease'].nil? ? default : Jekyll::Utils.deep_merge_hashes(default['attendease'], site.config['attendease'])

  site.config['attendease_source'] ||= site.config['source']

  site.config.extend(AttendeaseJekyllConfigMixin)

  if site.config.attendease['api_host'].nil?
    raise 'Fatal: You must configure attendease:api_host in your _config.yml to point to the API host of your event or organization.'
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  if pages = site.data['pages']
    pages.each do |page|
      if File.exists?(file = File.join(site.config['attendease_source'], page['slug'], 'index.html'))
        File.unlink(file)
      end

      if File.exists?(file = File.join(site.config['attendease_source'], page['slug'], 'index.json'))
        File.unlink(file)
      end
    end
  end
end
