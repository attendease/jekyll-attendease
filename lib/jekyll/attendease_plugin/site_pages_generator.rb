module Jekyll
  module AttendeasePlugin
    class SitePagesGenerator < Generator
      safe true
      PLACEHOLDER_REGEX = /\{\{/.freeze

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

            zones = {}
            keys = %w[content preferences]

            if page['block_instances'].length
              # create zone buckets
              page['block_instances'].each do |i|
                # go through all content
                if site.config.event?
                  keys.each do |key|
                    i[key].each do |k, v|
                      if placeholder?(v)
                        # maintain the {{ t.foo }} variables
                        v.gsub!(/(\{\{\s*t\.[a-z_.]+\s*\}\})/, '{% raw %}\1{% endraw %}')
                        i[key][k] = render_with_substitutions(v, 'event' => site.data['event'], 'mappable' => site.data['mappable'])
                      end
                    end
                  end

                  unless site.data['mappable'].nil? || site.data['mappable'].empty?
                    perform_substitution!(i, 'mappable' => site.data['mappable'])
                  end
                end

                zones[i['zone']] = [] if zones[i['zone']].nil?
                zones[i['zone']] << i
              end

              # sort each bucket by widget weight
              zones.each do |k, zone|
                zone.sort! { |x, y| x['weight'] <=> y['weight'] }
              end

              page_source_path = File.join(site.source, page['slug'])
              FileUtils.mkdir_p(page_source_path) unless File.exists?(page_source_path)

              json_filename = site.config.attendease['private_site'] ? 'index-private.json' : 'index.json'

              File.open(File.join(page_source_path, json_filename), 'w') do |f|
                f.write zones.to_json
                f.close
              end

              site.static_files << StaticFile.new(site, site.source, File.join('', page['slug']), json_filename)
            end
          end
        end
      end

      private

      def perform_substitution!(object, substitution_lookup)
        if object.is_a?(Hash)
          object.each_pair do |k, v|
            if placeholder?(v)
              object[k] = render_with_substitutions(v, substitution_lookup)
            else
              perform_substitution!(v, substitution_lookup)
            end
          end
        elsif object.is_a?(Array)
          object.each_with_index do |e, i|
            if placeholder?(e)
              object[i] = render_with_substitutions(e, substitution_lookup)
            else
              perform_substitution!(e, substitution_lookup)
            end
          end
        end
      end

      def placeholder?(object)
        object.is_a?(String) && object =~ PLACEHOLDER_REGEX
      end

      def render_with_substitutions(template_string, substitution_lookup)
        Liquid::Template.parse(template_string).render(substitution_lookup)
      end
    end
  end
end

