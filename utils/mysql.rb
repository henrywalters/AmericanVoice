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
	print sql.iter_query()
	sql.close
end

def sel_keys
	sql = MySql.new()
	sql.query("SELECT * FROM auth_keys;")
	print sql.iter_query()
	sql.close
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

sel_keys