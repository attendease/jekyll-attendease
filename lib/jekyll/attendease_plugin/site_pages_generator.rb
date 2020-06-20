module Jekyll
  module AttendeasePlugin
    class SitePagesGenerator < Generator
      safe true
      # site.config:
      #    Is where you can find the configs generated for your site
      #    To check the structure sample go in your vagrant to
      #    /home/vagrant/attendease/var/organizations/attendease/portal_site/_config.yml
      def generate(site)
        site.data['pages'].each do |page|
          if !page['external']
            require 'cgi'

            page['name'] = CGI.escapeHTML(page['name']) if page['name']
            site.pages << SitePage.new(site, site.source, page)
            site.pages << SitePageData.new(site, site.source, page, site.config.private_site?)
          end
        end
      end
    end
  end
end

