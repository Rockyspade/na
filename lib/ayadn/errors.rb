# encoding: utf-8
module Ayadn
  class Errors
    def self.global_error(args)
      Logs.rec.error "--BEGIN--"
      Logs.rec.error "#{args[:error]}"
      Logs.rec.debug "DATA: #{args[:data]}"
      stack = args[:caller].map do |path|
        splitted = path.split('/')
        file = splitted.pop
        dir = splitted.pop
        "#{dir}/#{file}"
      end
      Logs.rec.debug "STACK: #{stack}"
      #Logs.rec.debug "STACK: #{args[:caller]}"
      Logs.rec.error "--END--"
      puts "\nError logged in #{Settings.config[:paths][:log]}/ayadn.log\n".color(:blue)
      Debug.err args[:error]
      exit
    end
    def self.error(status)
      Logs.rec.error status
    end
    def self.warn(warning)
      Logs.rec.warn warning
    end
    def self.info(msg)
      Logs.rec.info msg
    end
    def self.repost(repost, original)
      Logs.rec.info "Post #{repost} is a repost. Using original: #{original}."
    end
    def self.nr msg
      Logs.nr.warn msg
    end
  end
end
