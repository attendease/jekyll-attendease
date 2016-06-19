module Jekyll
  module AttendeasePlugin
    class EventDataGenerator < Generator
      safe true

      priority :highest

      include HTTParty

      def get(url, options = {})
        begin
          self.class.get(url, options)
        rescue => e
          Jekyll.logger.error "Could not connect to #{url}."
          puts e.inspect
        end
      end

      def use_cache?(file)
        (Time.now.to_i - File.mtime(file).to_i) <= (@attendease_config['cache_expiry'].nil? ? 30 : @attendease_config['cache_expiry'])  # file is less than 30 seconds old
      end

      def generate(site)
        if @attendease_config = site.config['attendease']
          if @attendease_config['api_host'] && !@attendease_config['api_host'].match(/^http/)
            raise "Is your Attendease api_host site properly in _config.yml? Needs to be something like https://myevent.attendease.com/"
          else
            # add a trailing slash if we are missing one.
            if @attendease_config['api_host'][-1, 1] != '/'
              @attendease_config['api_host'] += '/'
            end

            @attendease_data_path = File.join(site.source, '_attendease', 'data')

            FileUtils.mkdir_p(@attendease_data_path)

            data_files = %w{ site event sessions presenters rooms filters venues sponsors }.map { |m| "#{m}.json"} << 'lingo.yml'

            data_files.each do |file_name|
              update_data = true
              data = nil

              file = File.join(@attendease_data_path, file_name)
              if File.exists?(file) && use_cache?(file)
                update_data = false

                if file_name.match(/json$/)
                  begin
                    data = JSON.parse(File.read(file))
                  rescue => e
                    raise "Error parsing #{file}: #{e.inspect}"
                  end
                else
                  data = File.read(file)
                end
              end

              key = "has_#{file_name.split('.')[0]}"

              # don't bother making a request for resources that don't exist in the event
              if !@attendease_config[key].nil? && !@attendease_config[key]
                update_data = false
                data = []
              end

              if update_data
                options = {}
                options.merge!(:headers => {'X-Event-Token' => @attendease_config['access_token']}) if @attendease_config['access_token']

                request_filename = file_name.gsub(/yml$/, 'yaml')
                response = get("#{@attendease_config['api_host']}api/#{request_filename}?meta=true", options)

                #if (file_name.match(/yaml$/) || data.is_a?(Hash) && !data['error']) || data.is_a?(Array)
                if (!response.nil? && response.response.is_a?(Net::HTTPOK))
                  Jekyll.logger.info "[Attendease] Saving #{file_name} data..."

                  if file_name.match(/json$/)
                    data = response.parsed_response
                    File.open(file, 'w+') { |f| f.write(data.to_json) }
                  else # yaml
                    File.open(file, 'w+') { |f| f.write(response.body) }
                  end
                else
                  raise "Request failed for #{@attendease_config['api_host']}api/#{request_filename}. Is your Attendease api_host site properly in _config.yml?"
                end
              end

              # make this data available to anything that wants it
              site.config['attendease'][File.basename(file_name, '.*')] = data

              if data.is_a?(Hash)
                if file_name == 'site.json'
                  # Adding to site config so we can access these variables globally wihtout using a Liquid Tag so we can use if/else
                  site.config['attendease']['data'] = {}
                  site.config['attendease']['data']['core'] = {}

                  data.keys.each do |tag|
                    site.config['attendease']['data'][tag] = data[tag]
                    # memorandum from the department of redundancy department:
                    # --------------------------------------------------------
                    # support accessing the attendease_* variables without the
                    # attendease_ prefix because they're already namespaced in
                    # site.attendease.data
                    #
                    # TODO: update all themes to not use attendease_ variables
                    #       and then retire them from the ThemeManager.
                    if tag.match(/^attendease_/)
                      # only set keys that aren't already defined from the theme
                      site.config['attendease']['data']['core'][tag.gsub(/^attendease_/, '')] = data[tag]
                    end
                  end
                end
              end
            end

            # make the event available to anyone
            event = JSON.parse(File.read("#{@attendease_data_path}/event.json"))
            site.config['attendease']['event'] = event

            if @attendease_config['copy_data']
              FileUtils.cp_r(@attendease_data_path, File.join(site.source, 'attendease_data'))
              # tell Jekyll about these new static files to publish
              site.read_directories 'attendease_data'
            end
          end

        else
          raise "Please set the Attendease event data in your _config.yml"
        end
      end
    end
  end
end
