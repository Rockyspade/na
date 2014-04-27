# encoding: utf-8
module Ayadn
  class Scroll

    def initialize(api, view)
      @api = api
      @view = view
    end

    def method_missing(meth, options)
      case meth.to_s
      when 'trending', 'photos', 'checkins', 'replies', 'global', 'unified'
        scroll_it(meth.to_s, options)
      else
        super
      end
    end

    def scroll_it(target, options)
      options = check_raw(options)
      orig_target = target
      loop do
        begin
          stream = get(target, options)
          target = "explore:#{target}" if explore?(target)
          show_if_new(stream, options, target)
          target = orig_target if target =~ /explore/
          options = save_then_return(stream, options)
          pause
        rescue Interrupt
          canceled
        end
      end
    end

    def mentions(username, options)
      options = check_raw(options)
      user = @api.get_user(username)
      id = user['data']['id']
      loop do
        begin
          stream = @api.get_mentions(username, options)
          show_if_new(stream, options, "mentions:#{id}")
          options = save_then_return(stream, options)
          pause
        rescue Interrupt
          canceled
        end
      end
    end

    def posts(username, options)
      options = check_raw(options)
      user = @api.get_user(username)
      id = user['data']['id']
      loop do
        begin
          stream = @api.get_posts(username, options)
          show_if_new(stream, options, "posts:#{id}")
          options = save_then_return(stream, options)
          pause
        rescue Interrupt
          canceled
        end
      end
    end

    def convo(post_id, options)
      options = check_raw(options)
      loop do
        begin
          stream = @api.get_convo(post_id, options)
          show_if_new(stream, options, "replies:#{post_id}")
          options = save_then_return(stream, options)
          pause
        rescue Interrupt
          canceled
        end
      end
    end

    def messages(channel_id, options)
      options = check_raw(options)
      loop do
        begin
          stream = @api.get_messages(channel_id, options)
          show_if_new(stream, options, "channel:#{channel_id}")
          options = save_then_return(stream, options)
          pause
        rescue Interrupt
          canceled
        end
      end
    end

    private

    def get(target, options)
      case target
      when 'global'
        @api.get_global(options)
      when 'unified'
        @api.get_unified(options)
      when 'trending'
        @api.get_trending(options)
      when 'photos'
        @api.get_photos(options)
      when 'checkins'
        @api.get_checkins(options)
      when 'replies'
        @api.get_conversations(options)
      end
    end

    def explore?(target)
      case target
      when 'trending', 'photos', 'checkins', 'replies'
        true
      else
        false
      end
    end

    def pause
      sleep Settings.options[:scroll][:timer]
    end

    def show_if_new(stream, options, target)
      show(stream, options) if Databases.has_new?(stream, target)
    end

    def save_then_return(stream, options)
      unless stream['meta']['max_id'].nil?
        Databases.save_max_id(stream)
        return options_hash(stream)
      end
      options
    end

    def check_raw(options)
      if options[:raw]
        {count: 200, since_id: nil, raw: true, scroll: true}
      else
        {count: 200, since_id: nil, scroll: true}
      end
    end

    def options_hash(stream)
      {:count => 50, :since_id => stream['meta']['max_id'], scroll: true}
    end

    def show(stream, options)
      unless options[:raw]
        @view.show_posts(stream['data'], options)
      else
        jj stream
      end
    end

    def canceled
      puts Status.canceled
      exit
    end
  end
end
