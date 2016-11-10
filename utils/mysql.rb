require 'mysql2'

class MySql
	def initialize(user,pass,host='localhost')
		@client = Mysql2::Client.new(:host => host, :username => user, :password => pass)
		@results = nil	
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
