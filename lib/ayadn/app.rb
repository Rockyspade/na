module Ayadn
	class App < Thor
		package_name "ayadn"

		%w{stream api descriptions endpoints cnx view workers myconfig status}.each { |r| require_relative "#{r}" }
		
		desc "unified", "Shows your Unified Stream."
		map "-U" => :unified
		map "uni" => :unified
		map "stream" => :unified
		long_desc Descriptions.unified
		option :count, aliases: "-c"
		option :index, aliases: "-i"
		def unified
			init
			Stream.new.unified(options)
		end

		private

		def init
			$config = MyConfig.new
		end

	end
end