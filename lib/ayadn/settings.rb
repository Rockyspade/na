module Ayadn
  class Settings

    AYADN_CLIENT_ID = "hFsCGArAjgJkYBHTHbZnUvzTmL4vaLHL"

    class << self
      attr_accessor :options, :config
      attr_reader :user_token
    end

    def self.load_config
      @options = self.defaults # overridden later in the method by the loaded file
      home = Dir.home + "/ayadn2/data" #temp, will be /ayadn in v1
      @user_token = File.read(File.expand_path("../../../token", __FILE__)).chomp #temp
      @config = {
        paths: {
          home: home,
          log: "#{home}/log",
          db: "#{home}/db",
          pagination: "#{home}/pagination",
          config: "#{home}/config",
          auth: "#{home}/auth",
          downloads: "#{home}/downloads",
          backup: "#{home}/backup",
          posts: "#{home}/backup/posts",
          messages: "#{home}/backup/messages",
          lists: "#{home}/backup/lists"
        },
        version: VERSION,
        platform: RbConfig::CONFIG['host_os']
      }

      self.create_config_folders
      self.create_config_file
      self.create_version_file
      self.create_api_file

      self.set_identity
    end

    def self.save_config
      File.write(@config[:paths][:config] + "/config.yml", @options.to_yaml)
    end

    private

    def self.set_identity
      unless File.exist?(@config[:paths][:config] + "/identity.yml")
        resp = API.new.get_user("me")
        username = resp['data']['username']
        self.create_identity_file(username)
        @config[:identity] = username
      else
        @config[:identity] = self.read_identity_file
      end
      @config[:handle] = "@" + @config[:identity]
    end

    def self.create_api_file
      api_file = @config[:paths][:config] + "/api.json"
      time_now = Time.now
      if File.exist?(api_file)
        if ( File.ctime(api_file) < (time_now - 172800) ) #48h in secs
          self.new_api_file(api_file)
        end
      else
        self.new_api_file(api_file)
      end
      self.read_api(api_file)
    end

    def self.new_api_file(api_file)
      api = API.new
      resp = api.get_config
      api.check_response_meta_code(resp)
      File.write(api_file, resp['data'].to_json)
    end

    def self.read_api(api_file)
      content = JSON.parse(File.read(api_file))
      @config[:post_max_length] = content['post']['text_max_length']
      @config[:message_max_length] = content['message']['text_max_length']
    end

    def self.create_identity_file(username)
      File.write(@config[:paths][:config] + "/identity.yml", {identity: username}.to_yaml)
    end

    def self.read_identity_file
      content = YAML.load(File.read(@config[:paths][:config] + "/identity.yml"))
      content[:identity]
    end

    def self.create_version_file
      File.write(@config[:paths][:config] + "/version.yml", {version: @config[:version]}.to_yaml)
    end

    def self.create_config_file
      config_file = @config[:paths][:config] + "/config.yml"
      if File.exists?(config_file)
        # TODO: system to merge existing config file when future category are added
        begin
          @options = YAML.load(File.read(config_file))
        rescue => e
          Errors.global_error("myconfig/load config.yml", nil, e)
        end
      else
        begin
          self.write_config_file(config_file, @options)
        rescue => e
          Errors.global_error("myconfig/create config.yml from defaults", nil, e)
        end
      end
    end

    def self.create_config_folders
      #todo: unless version file exists + more checks
      begin
        FileUtils.mkdir_p(@config[:paths][:home]) unless Dir.exists?(@config[:paths][:home])
        %w{log db pagination config auth downloads backup posts messages lists}.each do |target|
          Dir.mkdir(@config[:paths][target.to_sym]) unless Dir.exists?(@config[:paths][target.to_sym])
        end
      rescue => e
        Errors.global_error("myconfig/create ayadn folders", nil, e)
      end
    end

    def self.write_config_file(config_file, options)
      File.write(config_file, options.to_yaml)
    end

    def self.defaults
      {
        timeline: {
          directed: 1,
          deleted: 0,
          html: 0,
          annotations: 1,
          show_source: true,
          show_symbols: true,
          show_real_name: true,
          show_date: true
        },
        counts: {
          default: 50,
          unified: 50,
          global: 50,
          checkins: 50,
          conversations: 50,
          photos: 50,
          trending: 50,
          mentions: 50,
          convo: 50,
          posts: 50,
          messages: 50,
          search: 100,
          whoreposted: 50,
          whostarred: 50,
          whatstarred: 100,
          files: 66
        },
        formats: {
          table: {
            width: 75
          }
        },
        colors: {
          id: :red,
          index: :red,
          username: :green,
          name: :magenta,
          date: :cyan,
          link: :yellow,
          dots: :blue,
          hashtags: :cyan,
          mentions: :red,
          source: :blue,
          symbols: :green
        },
        backup: {
          auto_save_sent_posts: false,
          auto_save_sent_messages: false,
          auto_save_lists: false
        }
      }
    end

  end
end
