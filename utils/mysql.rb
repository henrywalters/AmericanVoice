require 'mysql2'
require 'av-ip'

class MySql
	def initialize(user='b84b5e214f662b',pass='3d58b94e',host='us-cdbr-iron-east-04.cleardb.net')
		@client = Mysql2::Client.new(:host => host, :username => user, :password => pass)
		@results = nil	
		@client.query("USE heroku_9c255df9d99a625")
	end
	def query(query)
		@results = @client.query(query)
	end
	def iter_query()
		if @results == nil
			puts "There are no results"
		else
			rows = []
			@results.each do |row|
				rows.push(row)
			end
			return rows
		end
	end

	def close
		@client.close
	end
end

def correct_id(id)
	return (id/10.0).to_i + 1
end

def deparse_post(title)
	sql = MySql.new()
	sql.query(%Q{
		UPDATE posts WHERE `title` ="#{title}"
		SET `title` = REPLACE(`title`,'{hypen}','-')
		SET `title` = REPLACE(`title`, '{question}','?')
		SET `title` = REPLACE(`title`, '{ampersand}','&');
		})
	sql.close
end

def sel_userbase
	sql = MySql.new()
	sql.query("SELECT * FROM userbase;")
	sql.close
	return sql.iter_query()
end

def sel_comments
	sql = MySql.new()
	sql.query("SELECT * FROM comments;")
	sql.close
	return sql.iter_query()
end

def sel_post_comments(post_title)
	comments = sel_comments
	post_comments = []
	comments.each do |comment|
		if comment["root"].split('/')[0] == post_title
			post_comments.push(comment)
		end
	end
	return post_comments
end


def sel_userbase_where(username)
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM userbase WHERE username="#{username}";})
	sql.close
	return sql.iter_query()

end

def get_display_name(username)
	sql = MySql.new()
	sql.query(%Q{SELECT display_name FROM userbase WHERE username="#{username}";})
	sql.close
	return sql.iter_query()[0]["display_name"]
end

def sel_keys
	sql = MySql.new()
	sql.query("SELECT * FROM auth_keys;")
	sql.close
	return sql.iter_query()
end

def sel_keys_where(key)
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM auth_keys WHERE `key`="#{key}";})
	sql.close
	return sql.iter_query()[0]
end

def sel_posts
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM posts WHERE `type`="text";})
	sql.close
	return sql.iter_query()
end

def sel_drafts
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM posts WHERE `type`="text_draft";})
	sql.close
	return sql.iter_query()
end

def sel_posts_where(name)
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM posts WHERE title="#{name}" and `type`="text";})
	sql.close
	return sql.iter_query()	
end

def sel_all_posts_where_title(title)
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM posts WHERE title="#{title}";})
	sql.close
	return sql.iter_query()	
end

def sel_all_posts_where_id(id)
	sql = sel_posts
	sql.each do |post|
		if post['id'].to_i == id.to_i
			return post
		end
	end
	return "nil"
end

def sel_all_posts_where(name)
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM posts WHERE user="#{name}";})
	sql.close
	return sql.iter_query()	
end

def sel_image_posts_where(name)
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM image_posts WHERE title="#{name}";})
	sql.close
	return sql.iter_query()
end

def sel_all_image_posts_where(username)
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM image_posts WHERE user="#{username}";})
	sql.close
	return sql.iter_query()
end

def sel_image_posts
	sql = MySql.new()
	sql.query("SELECT * FROM image_posts;")
	sql.close
	return sql.iter_query()
end

def sel_image_posts_where_id(id)
	sql = sel_image_posts
	sql.each do |post|
		if post['id'].to_i == id.to_i
			return post
		end
	end
	return "nil"
end	


def grant_admin_access(username)
	sql=MySql.new()
	sql.query("SELECT 
    username
	FROM `userbase`;")
	sql.iter_query().each do |user|
		if user["username"] == username
			sql.query(
			%Q{
				UPDATE userbase
				SET privilege=2
				WHERE `username`="#{username}";
			}
			) 
		end
	end
	sql.close
end

def delete_user(username)
	sql = MySql.new()
	sql.query(%Q{DELETE FROM userbase WHERE `username`="#{username}";})
	sql.close
end

def sel_analytics()
	sql = MySql.new()
	sql.query("SELECT * FROM analytics;")
	sql.close
	return sql.iter_query
end

def log_analytics(ip)
	comp = 0
	comps = []
	ips = sel_analytics()

	ips.each do |sql_ip|
		if comps.include?(sql_ip["ip"]) == false
			comps.push(sql_ip["ip"])
			comp += 1
		end
	end

	for i in 0...comps.length
		if comps[i] == ip
			log_comp = i
			break
		end
	end
	if comps.include?(ip) == false
		log_comp = comp
	end


	sql = MySql.new()
	sql.query(%{INSERT INTO analytics 
		(
			`ip`,
			`computer`,
			`date`
		)
		VALUES
		(
			"#{ip}",
			"#{log_comp}",
			NOW()
		);
		})
	sql.close
end


def analytic_data
	views = []
	analytics = sel_analytics()
	current_day = analytics[0]["date"].to_s.split()[0]
	days = [current_day]
	day_views = 0
	analytics.each do |view|
		if view["date"].to_s.split()[0] != current_day
			current_day = view["date"].to_s.split()[0]
			views.push(day_views)
			days.push(current_day)
		end
		if view["computer"] > 3 && current_day == view["date"].to_s.split()[0]
			day_views += 1
		end
	end
	if views.length != days.length
		views.push(day_views)
	end
	return {:days => days, :views => views}
end

def geolocate
	analytics = sel_analytics()
	unique = []
	analytics.each do |view|
		if not unique.include? view['ip']
			unique.push(view['ip'])
		end
	end
	avip = AVIP.new()

	unique.each do |ip|
		puts ip
		puts avip.search(ip)
	end

end

geolocate