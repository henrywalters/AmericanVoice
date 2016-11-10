require './mysql'

def user_conflict?(username,email,display_name)
	sql=MySql.new('root','Merry123!')
	sql.query("SELECT 
    `users`.`username`,
    `users`.`email`,
    `users`.`display_name`
	FROM `AmericanVoice`.`users`;")
	errors = {
		:user_conflict => false,
		:email_conflict => false,
		:display_name_conflict => false
	}
	sql.iter_query().each do |user|
		if user["username"] = user
			errors[:user_conflict] = true
		end
		if user["email"] = email
			errors[:email_conflict] = true
		end
		if user["display_name"] = display_name
			errors[:display_name_conflict] = true
		end
	end
	sql.close
	return errors

end

def new_user(username,email,display_name,password,privilege)
	sql=MySql.new('root','Merry123!')
	query = %Q{INSERT INTO `AmericanVoice`.`users`
				(`username`,
				 `password`,
				 `email`,
				 `privilege`,
				 `posts`,
				 `comments`,
				 `reputation`,
				 `display_name`)
				Values (
					"#{username}",
					"#{password}",
					"#{email}",
					"#{privilege}",
					0,0,0,
					"#{display_name}",0
				);}

	sql.query(query)
	sql.close
end
