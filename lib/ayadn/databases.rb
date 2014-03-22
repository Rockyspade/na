# encoding: utf-8
module Ayadn

  class Databases

    class << self
      attr_accessor :users, :index, :pagination, :aliases, :blacklist
    end

    def self.open_databases
      @users = Daybreak::DB.new "#{Settings.config[:paths][:db]}/users.db"
      @index = Daybreak::DB.new "#{Settings.config[:paths][:pagination]}/index.db"
      @pagination = Daybreak::DB.new "#{Settings.config[:paths][:pagination]}/pagination.db"
      @aliases = Daybreak::DB.new "#{Settings.config[:paths][:db]}/aliases.db"
      @blacklist = Daybreak::DB.new "#{Settings.config[:paths][:db]}/blacklist.db"
    end

    def self.close_all
      [@users, @index, @pagination, @aliases, @blacklist].each do |db|
        db.flush
        db.close
      end
    end

    def self.add_mention_to_blacklist(target)
      @blacklist[target] = :mention
    end
    def self.add_client_to_blacklist(target)
      @blacklist[target] = :client
    end
    def self.add_hashtag_to_blacklist(target)
      @blacklist[target] = :hashtag
    end
    def self.remove_from_blacklist(target)
      @blacklist.delete(target)
    end

    def self.save_max_id(stream)
      @pagination[stream['meta']['marker']['name']] = stream['meta']['max_id']
    end

    def self.create_alias(channel_id, channel_alias)
      @aliases[channel_alias] = channel_id
    end

    def self.delete_alias(channel_alias)
      @aliases.delete(channel_alias)
    end

    def self.get_channel_id(channel_alias)
      @aliases[channel_alias]
    end

    def self.get_alias_from_id(channel_id)
      @aliases.each do |al, id|
        return al if id == channel_id
      end
      nil
    end

    def self.save_indexed_posts(posts)
      @index.clear
      posts.each do |id, hash|
        @index[id] = hash
      end
    end

    def self.get_index_length
      @index.length
    end

    def self.get_post_from_index(number)
      unless number > @index.length || number <= 0
        @index.to_h.each do |id, values|
          return values if values[:count] == number
        end
      else
        puts "\nNumber must be in the range of the indexed posts.\n".color(:red)
        Errors.global_error("databases/get_post_from_index", number, "out of range")
      end
    end

    def self.add_to_users_db_from_list(list)
      list.each do |id, content_array|
        @users[id] = {content_array[0] => content_array[1]}
      end
    end

    def self.add_to_users_db(id, username, name)
      @users[id] = {username => name}
    end

    def self.has_new?(stream, title)
      stream['meta']['max_id'].to_i > @pagination[title].to_i
    end

  end

end
