require './utils/mysql'

def generate_key()
	letters = 'abcdefghijklmnopqrstuvwxyz'
	key = ''
	sql=MySql.new('root','Merry123!')
	unique = false
	while not unique
		for i in 0...30
			if rand(2) == 0
				key = key + (rand(9)+1).to_s
			else
				key = key + letters[rand(26)]
			end
		end
		sql.query("select * from AmericanVoice.auth_keys")
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
	sql=MySql.new('root','Merry123!')
	sql.query("INSERT INTO AmericanVoice.auth_keys (`key`,`registered`) VALUES ('"+ key +"',0);")
	sql.close
	return key
end

def register_key(key)
	errors = {
		:key_exists => false,
		:key_used => false
	}
	sql=MySql.new('root','Merry123!')
	sql.query("select * from AmericanVoice.auth_keys")
	sql.iter_query().each do |keys|
		if key == keys["key"]
			errors[:key_exists] = true
			if keys["registered"] == 1
				errors[:key_used] = true
			end
		end
	end
	if errors[:key_exists] == true && errors[:key_used] == false
		sql.query(
			%Q{
				UPDATE AmericanVoice.auth_keys
				SET registered=1
				WHERE `key`="#{key}"
			}
			)
		sql.close
	else
		sql.close
		return errors
	end
end
