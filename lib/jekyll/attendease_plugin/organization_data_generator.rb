module Jekyll
  module AttendeasePlugin
    class OrganizationDataGenerator < EventDataGenerator
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

      def generate(site)
        return unless site.config.organization? && site.config.cms_theme?

        if site.config.attendease['api_host'] && !site.config.attendease['api_host'].match(/^https/)
          raise "Is your Attendease api_host site properly in _config.yml? Needs to be something like https://myorg.attendease.org/"
        else
          # add a trailing slash if we are missing one.
          if site.config.attendease['api_host'][-1, 1] != '/'
            site.config.attendease['api_host'] += '/'
          end

          @attendease_data_path = File.join(site.source, '_attendease', 'data')

          FileUtils.mkdir_p(@attendease_data_path) unless File.exists?(@attendease_data_path)

          data_files = %w{ pages site_settings }.map { |m| "#{m}.json"}

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

            if update_data
              options = {}
              options.merge!(:headers => {'X-Organization-Token' => site.config.attendease['access_token']}) if site.config.attendease['access_token']

              response = get("#{site.config.attendease['api_host']}api/v2/#{filename}", options)

              if (!response.nil? && response.response.is_a?(Net::HTTPOK))
                Jekyll.logger.info "[Attendease] Saving #{filename} data..."

                if filename.match(/json$/)
                  data = response.parsed_response
                  File.open(file, 'w') { |f| f.write(data.to_json) }
                else # yaml
                  File.open(file, 'w') { |f| f.write(response.body) }
                end
              else
                raise "Request failed for #{site.config.attendease['api_host']}api/v2/#{filename}. Is your Attendease api_host site properly in _config.yml?"
              end
            end

            site.data[File.basename(filename, '.*')] = data
          end
        end
      end
    end
  end
end


