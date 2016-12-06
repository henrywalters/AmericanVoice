require 'mysql2'

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
