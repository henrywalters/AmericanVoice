require './utils/posts'

def new_post(user,title,body,tags)
	sql = MySql.new()
	sql.query(%Q{
		INSERT INTO posts(
			`user`,
			`title`,
			`body`,
			`tags`,
			`views`
		)
		VALUES (
			"#{user}",
			"#{title}",
			"#{body}",
			"#{tags}",
			0
		);
	})
end

