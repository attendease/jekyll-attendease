module Jekyll
  module AttendeasePlugin
    class ScheduleWidgetTag < Liquid::Tag
      def render(context)
        schedule_data = ScheduleDataParser.new(context.registers[:site])
        base = File.join(context.registers[:site].config['source'])

        instances = schedule_data.sessions.inject([]) do |memo, s|
          s['instances'].each do |instance|
            instance['session'] = s
            memo << instance
          end
          memo
        end
        instances.sort!{|x,y| [x['time'], x['session']['name']] <=> [y['time'], y['session']['name']]}

        source_template_path = File.join(base, '_attendease', 'templates', 'schedule', 'widget.html')

        Liquid::Template.parse(File.read(source_template_path)).render('dates' => schedule_data.event['dates'], 'instances' => instances, 'filters' => schedule_data.filters)
      end
    end

    class AuthScriptTag < Liquid::Tag
      def render(context)
        api_host = context.registers[:site].config['attendease']['api_host']
        '<script type="text/javascript" src="' + api_host + 'assets/attendease_event/auth.js"></script>'
      end
    end

    class SchedulerScriptTag < Liquid::Tag
      def render(context)
        api_host = context.registers[:site].config['attendease']['api_host']
        '<script type="text/javascript" src="' + api_host + 'assets/attendease_event/schedule.js"></script>'
      end
    end

    class LocalesScriptTag < Liquid::Tag
      def render(context)
        locale = context.registers[:site].config['attendease']['locale']
        api_host = context.registers[:site].config['attendease']['api_host']
        "<script type=\"text/javascript\">String.locale=\"#{locale}\";String.toLocaleString(\"#{api_host}api/lingo.json\");</script>"
      end
    end

    class TranslateTag < Liquid::Tag
      def initialize(tag_name, params, tokens)
        super
        args = split_params(params)
        @key = args.shift
        @options = { 't_size' => 0 }
        if args.length
          args.each do |a|
            match = a.match(/^(.+):\s*(.+)$/)
            @options[match[1]] = match[2].to_i if match
          end
        end
      end

      def split_params(params)
        params.split(",").map(&:strip)
      end

      def render(context)
        I18n::Backend::Simple.include(I18n::Backend::Pluralization)
        I18n.enforce_available_locales = false
        i18n_path = File.join(context.registers[:site].config['source'], '_attendease', 'data', 'lingo.yml')
        I18n.load_path << i18n_path unless I18n.load_path.include?(i18n_path)
        I18n.locale = context.registers[:page]['lang'] || context.registers[:site].config['attendease']['locale'] || context.registers[:site].config['attendease']['lang'] || :en
        I18n.t(@key, :count => @options['t_size'])
      end
    end

    class AuthAccountTag < Liquid::Tag
      def render(context)
        '<div id="attendease-auth-account"></div>'
      end
    end

    class AuthActionTag < Liquid::Tag
      def render(context)
        '<div id="attendease-auth-action"></div>'
      end
    end

    class PortalNavigationTag < Liquid::Block
      def initialize(tag_name, params, tokens)
        super
        @options = {}
        params.split(/\s/).each do |keypair|
          opt = keypair.split('=')
          @options[opt[0]] = opt[1] if opt.length == 2
        end
      end

      def render(context)
        portal_pages = context.registers[:site].data['portal_pages']

        nav = []
        if portal_pages.is_a?(Array)
          portal_pages.sort! { |a, b| a['weight'] <=> b['weight'] }
          portal_pages.select { |p| p['top_level'] }.each do |page|
            if page['active'] && !page['hidden']
              template = Liquid::Template.parse(super)
              template.assigns['page'] = page
              nav << template.render
            end
          end
          nav.join("\n")
        else
          ''
        end
      end
    end

    class NavigationTag < Liquid::Block
      def initialize(tag_name, params, tokens)
        super
        @options = {}
        params.split(/\s/).each do |keypair|
          opt = keypair.split('=')
          @options[opt[0]] = opt[1] if opt.length == 2
        end
      end

      def render(context)
        pages = context.registers[:site].data['pages']

        nav = []
        if pages.is_a?(Array)
          pages.sort! { |a, b| a['weight'] <=> b['weight'] }
          pages.select { |p| p['top_level'] }.each do |page|
            if page['active'] && !page['hidden']
              template = Liquid::Template.parse(super)
              template.assigns['page'] = page
              nav << template.render
            end
          end
          nav.join("\n")
        else
          ''
        end
      end
    end

    class BlockRendererTag < Liquid::Tag
      def initialize(tag_name, url_override, tokens)
        super
        @url_override = url_override
      end

      def render(context)
        config = context.registers[:site].config['attendease']
        site_settings = context.registers[:site].data['site_settings'].clone
        analytics = site_settings.delete 'analytics'
        site_settings.delete_if {|key, value| ['analytics', 'meta', 'general'].include? key }

        organization_site_settings = {}
        if context.registers[:site].data['organization_site_settings']
          organization_site_settings = context.registers[:site].data['organization_site_settings'].clone
          organization_site_settings.delete_if {|key, value| ['analytics', 'meta', 'general'].include? key }
        end

        parent_pages_are_clickable = config['parent_pages_are_clickable']

        pages = Helpers.public_pages(context.registers[:site].data['pages'])

        portal_pages = Helpers.public_pages(context.registers[:site].data['portal_pages']) || []
        env = config['environment']

        # IMPORTANT NOTE: The script variables below must NOT be changed without making sure that blockrenderer.js and other
        # related code in the platform is backwards-compatible.

        if config['mode'] == 'organization'
          constants = {
            'locale' => 'en',
            'siteName' => config['organization_name'],
            'orgURL' => config['api_host'],
            'orgId' => config['source_id'],
            'privateSite' => config['private_site'],
            'authApiEndpoint' => "#{config['auth_host']}api",
            'orgLocales' => config['available_portal_locales'],
            'features' => config['features'],
            'pages' => pages,
            'settings' => { parentPagesAreClickable: !!parent_pages_are_clickable },
            'siteSettings' => site_settings,
            'analytics' => analytics
          }
        else
          constants = {
            'locale' => config['locale'],
            'siteName' => config['data']['event_name'],
            'eventApiEndpoint' => "#{config['api_host']}api",
            'eventId' => config['source_id'],
            'orgURL' => config['organization_url'],
            'orgId' => config['organization_id'],
            'privateSite' => config['private_site'],
            'authApiEndpoint' => "#{config['auth_host']}api",
            'features' => config['features'],
            'pages' => pages,
            'portalPages' => portal_pages,
            'settings' => { parentPagesAreClickable: !!parent_pages_are_clickable },
            'siteSettings' => site_settings,
            'organizationSiteSettings' => organization_site_settings,
            'analytics' => analytics
        }
        end

        script = <<_EOT
<script type="text/javascript">
(function(w) {
  w.AttendeaseConstants = {
#{ constants.map{ |k, v| "    #{k}: #{v.to_json}," }.join("\n") }
  }
})(window)
</script>

_EOT

        if @url_override.match(/^(https:)?\/\/.+/)
          url = @url_override
        else
          case env
          when 'development'
            url = '//dashboard.localhost.attendease.com/webpack_assets/blockrenderer.bundle.js'
          when 'prerelease'
            url = '//cdn.attendease.com/blockrenderer/prerelease-latest.js'
          when 'preview'
            url = '//cdn.attendease.com/blockrenderer/ci-latest.js'
          else
            url = '//dashboard.attendease.com/webpack_assets/blockrenderer.bundle.js'
          end
        end

        script << <<_EOT
<script type="text/javascript" src="#{ url }"></script>
_EOT

        script
      end
    end

    class AnalyticsGoogleTagManagerHeadTag < Liquid::Tag
      def render(context)
        site_settings = context.registers[:site].data['site_settings'].clone
        analytics = site_settings['analytics']

        return '' if analytics.nil? \
          || analytics['googleTagManagerId'].nil? \
          || analytics['googleTagManagerId'].empty?

        script = <<_EOT
<script>
  window.dataLayer = [];
</script>
<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','#{analytics['googleTagManagerId']}');</script>
<!-- End Google Tag Manager -->
_EOT
        script
      end
    end

    class AnalyticsGoogleTagManagerBodyTag < Liquid::Tag
      def render(context)
        site_settings = context.registers[:site].data['site_settings'].clone
        analytics = site_settings['analytics']

        return '' if analytics.nil? \
          || analytics['googleTagManagerId'].nil? \
          || analytics['googleTagManagerId'].empty?

        script = <<_EOT
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=#{analytics['googleTagManagerId']}"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->
_EOT
        script
      end
    end

    class AnalyticsGoogleAnalyticsGtagTag < Liquid::Tag
      def render(context)
        site_settings = context.registers[:site].data['site_settings'].clone
        analytics = site_settings['analytics']

        has_analytics_id = !analytics.nil? && !analytics['googleAnalyticsTrackingId'].nil? && !analytics['googleAnalyticsTrackingId'].empty?
        has_adwords_id = !analytics.nil? && !analytics['googleAnalyticsAdwordsId'].nil? && !analytics['googleAnalyticsAdwordsId'].empty?
        return '' if analytics.nil? || (!has_analytics_id && !has_adwords_id)

        gtag_id = has_analytics_id ? analytics['googleAnalyticsTrackingId'] : analytics['googleAnalyticsAdwordsId']

        script = <<_EOT
<!-- Global Site Tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=#{gtag_id}"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

#{ has_analytics_id ? "  gtag('config', '#{analytics['googleAnalyticsTrackingId']}');" : ''}
#{ has_adwords_id ? "  gtag('config', '#{analytics['googleAnalyticsAdwordsId']}');" : ''}
</script>
_EOT
        script
      end
    end

    class AnalyticsLinkedInTag < Liquid::Tag
      def render(context)
        site_settings = context.registers[:site].data['site_settings'].clone
        analytics = site_settings['analytics']

        return '' if analytics.nil? \
          || analytics['linkedinInsightsId'].nil? \
          || analytics['linkedinInsightsId'].empty?

        script = <<_EOT
  <script type="text/javascript">
  _linkedin_partner_id = "#{analytics['linkedinInsightsId']}";
  window._linkedin_data_partner_ids = window._linkedin_data_partner_ids || [];
  window._linkedin_data_partner_ids.push(_linkedin_partner_id);
  </script><script type="text/javascript">
  (function(){var s = document.getElementsByTagName("script")[0];
  var b = document.createElement("script");
  b.type = "text/javascript";b.async = true;
  b.src = "https://snap.licdn.com/li.lms-analytics/insight.min.js";
  s.parentNode.insertBefore(b, s);})();
  </script>
  <noscript>
  <img height="1" width="1" style="display:none;" alt="" src="https://dc.ads.linkedin.com/collect/?pid=#{analytics['linkedinInsightsId']}&fmt=gif" />
  </noscript>
_EOT
        script
      end
    end

    class AnalyticsFacebookPixelTag < Liquid::Tag
      def render(context)
        site_settings = context.registers[:site].data['site_settings'].clone
        analytics = site_settings['analytics']

        return '' if analytics.nil? \
          || analytics['facebookPixelId'].nil? \
          || analytics['facebookPixelId'].empty?
        script = <<_EOT
<!-- Facebook Pixel Code -->
<script>
  !function(f,b,e,v,n,t,s)
  {if(f.fbq)return;n=f.fbq=function(){n.callMethod?
  n.callMethod.apply(n,arguments):n.queue.push(arguments)};
  if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
  n.queue=[];t=b.createElement(e);t.async=!0;
  t.src=v;s=b.getElementsByTagName(e)[0];
  s.parentNode.insertBefore(t,s)}(window, document,'script',
  'https://connect.facebook.net/en_US/fbevents.js');
  fbq('init', '#{analytics['facebookPixelId']}');
  fbq('track', 'PageView');
</script>
<noscript><img height="1" width="1" style="display:none"
  src="https://www.facebook.com/tr?id=#{analytics['facebookPixelId']}&ev=PageView&noscript=1"
/></noscript>
<!-- End Facebook Pixel Code -->
_EOT
        script
      end
    end

    class AnalyticsSettingsTag < Liquid::Tag
      def render(context)
        site_settings = context.registers[:site].data['site_settings'].clone
        analytics = site_settings['analytics']

        return '' if analytics.nil? \

        # the id keys we want to expose
        keys = %w[ googleAnalyticsTrackingId ]
        analytic_ids = analytics.select { |k, v| keys.include?(k) }

        script = <<_EOT
<!-- Global Analytics Settings -->
<script>
  window.AnalyticsSettings = {
#{ analytic_ids.map { |k, v| "    #{k}: #{v.to_json}" }.join(",\n")}
  }
</script>
_EOT
        script
      end
    end
  end
end
