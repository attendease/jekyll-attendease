module Jekyll
  module AttendeasePlugin
    class SitePageData < Page
      attr_reader :page
      attr_reader :site

      PLACEHOLDER_REGEX = /\{\{/.freeze

      def initialize(site, base, page, private_site)
        @site = site
        @base = base
        @dir = page['slug']
        @page = page
        @name = "index#{private_site ? '-private' : ''}.json"

        # The Jekyll::Regenerator expects data to exist and crashes without it.
        # https://github.com/jekyll/jekyll/blob/v3.3.1/lib/jekyll/regenerator.rb#L166
        @data = {}

        self.process(@name)
      end

      def render_with_liquid?
        false
      end

      def place_in_layout?
        false
      end

      # Override the accessor:
      #
      # https://github.com/jekyll/jekyll/blob/v3.3.1/lib/jekyll/renderer.rb#L78
      #
      # The Jekyll::Rendereer calls document.content, so this seems like the
      # best way to set our "page" content with what we want.
      #
      def content
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
        end

        zones.to_json
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
