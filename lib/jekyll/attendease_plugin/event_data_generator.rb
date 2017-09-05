module Jekyll
  module AttendeasePlugin
    class EventDataGenerator < Generator
      safe true

      priority :highest

      def get(url, options = {})
        begin
          HTTParty.get(url, options)
        rescue => e
          Jekyll.logger.error "Could not connect to #{url}."
          puts e.inspect
        end
      end

      def use_cache?(site, file)
        (Time.now.to_i - File.mtime(file).to_i) <= (site.config.attendease['cache_expiry'].nil? ? 30 : site.config.attendease['cache_expiry'])  # file is less than 30 seconds old
      end

      def generate(site)
        return if site.config.organization?

        if site.config.attendease['api_host'] && !site.config.attendease['api_host'].match(/^https/)
          raise "Is your Attendease api_host site properly in _config.yml? Needs to be something like https://myevent.attendease.com/"
        else
          # add a trailing slash if we are missing one.
          if site.config.attendease['api_host'][-1, 1] != '/'
            site.config.attendease['api_host'] += '/'
          end

          @attendease_data_path = File.join(site.source, '_attendease', 'data')

          FileUtils.mkdir_p(@attendease_data_path)

          if site.config.cms_theme?
            data_files = %w{ site event pages portal_pages site_settings organization_site_settings portal_published }.map { |m| "#{m}.json"} << 'lingo.yml'
          else
            data_files = %w{ site event sessions presenters rooms filters venues sponsors pages site_settings }.map { |m| "#{m}.json"} << 'lingo.yml'
          end

          # no more site in nextgen themes
          #data_files.shift if site.config.attendease['jekyll33']

          data_files.each do |filename|
            update_data = true
            data = nil

            file = File.join(@attendease_data_path, filename)
            if File.exists?(file) && use_cache?(site, file)
              update_data = false

              if filename.match(/json$/)
                begin
                  data = JSON.parse(File.read(file))
                rescue => e
                  raise "Error parsing #{file}: #{e.inspect}"
                end
              else
                data = File.read(file)
              end
            end

            key = "has_#{filename.split('.')[0]}"

            # don't bother making a request for resources that don't exist in the event
            if !site.config.attendease[key].nil? && !site.config.attendease[key]
              update_data = false
              data = []
            end

            if update_data
              options = {}
              options.merge!(:headers => {'X-Event-Token' => site.config.attendease['access_token']}) if site.config.attendease['access_token']

              request_filename = filename.gsub(/yml$/, 'yaml')
              response = get("#{site.config.attendease['api_host']}api/#{request_filename}?meta=true", options)

              #if (filename.match(/yaml$/) || data.is_a?(Hash) && !data['error']) || data.is_a?(Array)
              if (!response.nil? && response.response.is_a?(Net::HTTPOK))
                Jekyll.logger.info "[Attendease] Saving #{filename} data..."

                if filename.match(/json$/)
                  data = response.parsed_response
                  File.open(file, 'w') { |f| f.write(data.to_json) }
                else # yaml
                  File.open(file, 'w') { |f| f.write(response.body) }
                end
              else
                raise "Request failed for #{site.config.attendease['api_host']}api/#{request_filename}. Is your Attendease api_host site properly in _config.yml?"
              end
            end

            # make this data available to anything that wants it
            site.config['attendease'][File.basename(filename, '.*')] = data
            site.data[File.basename(filename, '.*')] = data

            if data.is_a?(Hash)
              # DEPRECATED
              if filename == 'site.json'
                # Adding to site config so we can access these variables globally without using a Liquid Tag so we can use if/else
                site.config['attendease']['data'] = {}

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
                    site.config['attendease']['data'][tag.gsub(/^attendease_/, '')] = data[tag]
                  end
                end
              end
            end
          end

          # provide a structure of session instances (timeslots) grouped
          # by day (suitable for displaying a schedule)
          unless site.config.cms_theme?
            site.config['attendease']['days'] = []
            schedule_data = ScheduleDataParser.new(site)
            site.config['attendease']['event']['dates'].each do |day|
              instances = []
              schedule_data.sessions.each do |s|
                s['instances'].each do |instance|
                  if instance['date'] == day['date']
                    instance['session'] = s
                    instances << instance
                  end
                end
              end

              day['instances'] = instances.sort {|x,y| [x['time'], x['session']['name']] <=> [y['time'], y['session']['name']]}
              site.config['attendease']['days'] << day
            end
          end

          # make the event available to anyone
          event = JSON.parse(File.read("#{@attendease_data_path}/event.json"))
          site.config['attendease']['event'] = event

          if site.config.attendease['copy_data']
            data_dir = File.join(site.source, 'attendease_data')
            FileUtils.mkdir(data_dir) unless File.exists?(data_dir)
            site.config['attendease']['data_files'] = {}

            Dir.chdir(@attendease_data_path) do
              extension = '.json'
              Dir.glob('*.json').each do |f|
                base_name = File.basename(f, extension)
                digest = Digest::SHA2.file(f).hexdigest
                digest_file = "#{base_name}-#{digest}.json"
                FileUtils.cp(f, File.join(data_dir, digest_file))
                site.config['attendease']['data_files'][base_name] = digest_file
              end
            end

            # tell Jekyll about these new static files to publish
            site.reader.read_directories 'attendease_data'
          end
        end
      end
    end
  end
end
