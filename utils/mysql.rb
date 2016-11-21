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
	return sql.iter_query()
	sql.close
end

def sel_userbase_where(username)
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM userbase WHERE username="#{username}";})
	return sql.iter_query()
	sql.close
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
	sql.query("SELECT * FROM posts;")
	sql.close
	return sql.iter_query()
end

def sel_posts_where(name)
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM posts WHERE title="#{name}";})
	sql.close
	return sql.iter_query()
	
end

def sel_image_posts_where(name)
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM image_posts WHERE title="#{name}";})
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

sql = MySql.new()
print sel_userbase