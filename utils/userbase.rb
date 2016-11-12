require './utils/mysql'

def user_conflict?(username,email,display_name)
	sql=MySql.new()
	sql.query("SELECT 
    `userbase`.`username`,
    `userbase`.`email`,
    `userbase`.`display_name`
	FROM `userbase`;")
	errors = {
		:user_conflict => false,
		:email_conflict => false,
		:display_name_conflict => false
	}
	sql.iter_query().each do |user|
		if user["username"].upcase == username.upcase
			errors[:user_conflict] = true
		end
		if user["email"].upcase == email.upcase
			errors[:email_conflict] = true
		end
		if user["display_name"].upcase == display_name.upcase
			errors[:display_name_conflict] = true
		end
	end
	sql.close
	return errors

end

def new_user(username,email,display_name,password,privilege)
	sql=MySql.new()
	query = %Q{INSERT INTO `userbase`
				(`username`,
				 `password`,
				 `email`,
				 `privilege`,
				 `posts`,
				 `comments`,
				 `reputation`,
				 `display_name`,
				 `logged_in`)
				Values (
					"#{username}",
					"#{password}",
					"#{email}",
					"#{privilege}",
					0,0,0,
					"#{display_name}",
					0
				);}

	sql.query(query)
	sql.close
end

def login(username)
	sql=MySql.new()
	sql.query("SELECT 
    `userbase`.`username`,
	FROM `users`;")
	sql.iter_query().each do |user|
		if user["username"] == username
			sql.query(
			%Q{
				UPDATE userbase
				SET logged_in=1
				WHERE `username`="#{username}"
			}
			)
		end
	end
end

def logout(username)
	sql=MySql.new()
	sql.query("SELECT 
    `userbase`.`username`,
	FROM `users`;")
	sql.iter_query().each do |user|
		if user["username"] == username
			sql.query(
			%Q{
				UPDATE userbase
				SET logged_in=0
				WHERE `username`="#{username}"
			}
			)
		end
	end
end