require './utils/mysql'

def generate_key(target_user)
	letters = 'abcdefghijklmnopqrstuvwxyz'
	key = ''
	sql=MySql.new()
	unique = false
	while not unique
		for i in 0...30
			if rand(2) == 0
				key = key + (rand(9)+1).to_s
			else
				key = key + letters[rand(26)]
			end
		end
		sql.query("select * from auth_keys")
		matches = []
		sql.iter_query().each do |keys|
			if keys[key]==key
				matches.append(keys)
			end
		end
		if matches.length == 0
			unique = true
		end
	end
	## Change when deployed
	sql=MySql.new()
	sql.query(%Q{INSERT INTO auth_keys (`key`,`registered`,`target_user`) VALUES ("#{key}",0,"#{target_user}");})
	sql.close
	return key
end

def register_key(key)
	errors = {
		:key_exists => false,
		:key_used => false
	}
	sql=MySql.new()
	sql.query("select * from auth_keys")
	sql.iter_query().each do |keys|
		if key == keys["key"]
			errors[:key_exists] = true
			if keys["registered"] == "1"
				errors[:key_used] = true
				sql.close
				return false
			end
		end
	end
	if errors[:key_exists] == true && errors[:key_used] == false
		sql.query(
			%Q{
				UPDATE auth_keys
				SET registered="1"
				WHERE `key`="#{key}"
			}
			)
		sql.close
		return true
	end
	sql.close
	return false
end

def grant_write_access(username)
	sql=MySql.new()
	sql.query("SELECT 
    username
	FROM `userbase`;")
	sql.iter_query().each do |user|
		if user["username"] == username
			sql.query(
			%Q{
				UPDATE userbase
				SET privilege=1
				WHERE `username`="#{username}";
			}
			)
		end
	end
	sql.close
end

def register_user(username)
	sql=MySql.new()
	sql.query("SELECT 
    username
	FROM `userbase`;")
	sql.iter_query().each do |user|
		if user["username"] == username
			sql.query(
			%Q{
				UPDATE userbase
				SET registered=1
				WHERE `username`="#{username}";
			}
			)
		end
	end
	sql.close
end	

def privilege(user)
	sql = MySql.new()
	sql.query(%Q{SELECT privilege FROM `userbase` WHERE `username`="#{user}";})
	sql.close
	return sql.iter_query()[0]["privilege"]
end	
