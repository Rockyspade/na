module Ayadn
	class Workers
		def init_table(target)
			table = Terminal::Table.new do |t|
				t.style = { :width => MyConfig.options[:formats][:table][:width] }
			end
			table
		end

		def build_reposted_list(list, target) #not the same format as wollowings/etc: taks an array of hashes
			table = init_table(target)
			table.title = "List of users who reposted post ".color(:cyan) + "#{target}".color(:red) + "".color(:white)
			users_list = []
			list.each do |obj|
				obj['name'].nil? ? name = "" : name = obj['name']
				users_list << {:username => obj['username'], :name => name, :you_follow => obj['you_follow'], :follows_you => obj['follows_you']}
			end
			return users_list, table
		end

		def build_starred_list(list, target)
			table = init_table(target)
			table.title = "List of users who starred post ".color(:cyan) + "#{target}".color(:red) + "".color(:white)
			users_list = []
			list.each do |obj|
				obj['name'].nil? ? name = "" : name = obj['name']
				users_list << {:username => obj['username'], :name => name, :you_follow => obj['you_follow'], :follows_you => obj['follows_you']}
			end
			return users_list, table
		end

		def build_followings_list(list, target) #takes a hash of users with ayadn format
			table = init_table(target)
			if target == "me"
				table.title = "List of users you're following".color(:cyan) + "".color(:white)
			else
				table.title = "List of users ".color(:cyan) + "#{target}".color(:red) + " is following ".color(:cyan) + "".color(:white)
			end
			users_list = build_users_array(list)
			build_users_list(users_list, table)
		end

		def build_followers_list(list, target)
			table = init_table(target)
			if target == "me"
				table.title = "List of your followers".color(:cyan) + "".color(:white)
			else
				table.title = "List of users following ".color(:cyan) + "#{target}".color(:red) + "".color(:white)
			end
			users_list = build_users_array(list)
			build_users_list(users_list, table)
		end

		def build_muted_list(list)
			table = Terminal::Table.new do |t|
				t.style = { :width => MyConfig.options[:formats][:table][:width] }
				t.title = "List of users you muted".color(:cyan) + "".color(:white)
			end
			users_list = build_users_array(list)
			build_users_list(users_list, table)
		end

		def build_blocked_list(list)
			table = Terminal::Table.new do |t|
				t.style = { :width => MyConfig.options[:formats][:table][:width] }
				t.title = "List of users you blocked".color(:cyan) + "".color(:white)
			end
			users_list = build_users_array(list)
			build_users_list(users_list, table)
		end

		def build_users_array(list)
			users_list = []
			list.each do |key, value|
				users_list << {:username => value[0], :name => value[1], :you_follow => value[2], :follows_you => value[3]}
			end
			users_list
		end



		#private

		def build_users_list(list, table)
			list.each_with_index do |obj, index|
				unless obj[:name].nil?
					table << [ "@#{obj[:username]} ".color(MyConfig.options[:colors][:username]), "#{obj[:name]}" ]
				else
					table << [ "@#{obj[:username]} ".color(MyConfig.options[:colors][:username]), "" ]
				end
				table << :separator unless index + 1 == list.length
			end
			table
		end

		def build_posts(data)
			# builds a hash of hashes, each hash is a normalized post with post id as a key
			posts = {}

			data.each.with_index(1) do |post, index|

				values = {
					count: index,
					id: post['id'].to_i,
					name: post['user']['name'] || "(no name)",
					thread_id: post['thread_id'],
					username: post['user']['username'],
					handle: "@" + post['user']['username'],
					type: post['user']['type'],
					date: parsed_time(post['created_at']),
					you_starred: post['you_starred'],
					source_name: post['source']['name'],
					source_link: post['source']['link'],
					canonical_url: post['canonical_url']
				}

				unless post['text'].nil?
					values[:raw_text] = post['text']
					values[:text] = colorize_text(post['text'])
				else
					values[:raw_text] = ""
					values[:text] = "(no text)"
				end

				unless post['num_stars'].nil? || post['num_stars'] == 0
					values[:is_starred] = true
					values[:num_stars] = post['num_stars']
				else
					values[:is_starred] = false
					values[:num_stars] = 0
				end
				if post['repost_of']
					values[:is_repost] = true
					values[:repost_of] = post['repost_of']['id']
					values[:num_reposts] = post['repost_of']['num_reposts']
				else
					values[:is_repost] = false
					values[:repost_of] = nil
					values[:num_reposts] = 0
				end
				if post['reply_to']
					values[:is_reply] = true
					values[:reply_to] = post['reply_to']
					values[:num_replies] = post['num_replies']
				else
					values[:is_reply] = false
					values[:reply_to] = nil
					values[:num_replies] = 0
				end

				mentions, tags, links = [], [], []

				post['entities']['mentions'].each { |m| mentions << m['name'] }
				values[:mentions] = mentions
				values[:directed_to] = mentions.first || false

				post['entities']['hashtags'].each { |h| tags << h['name'] }
				values[:tags] = tags

				post['entities']['links'].each { |l| links << l['url'] }
				values[:links] = links

				values[:checkins], values[:has_checkins] = extract_checkins(post)

				posts[post['id'].to_i] = values

			end
			posts
		end

		def extract_checkins(post)
			has_checkins = false
			checkins = {}
			unless post['annotations'].nil?
				post['annotations'].each do |obj|
					case obj['type']
					when "net.app.core.checkin", "net.app.ohai.location"
						has_checkins = true
						checkins = {
							name: obj['value']['name'],
							address: obj['value']['address'],
							address_extended: obj['value']['address_extended'],
							locality: obj['value']['locality'],
							postcode: obj['value']['postcode'],
							country_code: obj['value']['country_code'],
							website: obj['value']['website'],
							telephone: obj['value']['telephone']
						}
						unless obj['value']['categories'].nil?
							unless obj['value']['categories'][0].nil?
					 			checkins[:categories] = obj['value']['categories'][0]['labels'].join(", ")
					 		end
						end
						unless obj['value']['factual_id'].nil?
					 			checkins[:factual_id] = obj['value']['factual_id']
						end
						unless obj['value']['longitude'].nil?
					 			checkins[:longitude] = obj['value']['longitude']
					 			checkins[:latitude] = obj['value']['latitude']
						end
					when "net.app.core.oembed"
						has_checkins = true
					 			checkins[:embeddable_url] = obj['value']['embeddable_url']
			 		end
				end
			end
			return checkins, has_checkins
		end


		def parsed_time(string)
			"#{string[0...10]} #{string[11...19]}"
		end

		def colorize_text(text)
			content = Array.new
			hashtag_color = MyConfig.options[:colors][:hashtags]
			mention_color = MyConfig.options[:colors][:mentions]
			text.scan(/^.+[\r\n]*/) do |word|
				if word =~ /#\w+/
          content << word.gsub(/#([A-Za-z0-9_]{1,255})(?![\w+])/, '#\1'.color(hashtag_color))
				elsif word =~ /@\w+/
          content << word.gsub(/@([A-Za-z0-9_]{1,20})(?![\w+])/, '@\1'.color(mention_color))
				else
					content << word
				end
			end
			content.join()
		end

	end
end
