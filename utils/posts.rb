require './utils/posts'

def new_post(user,title,body,tags)
	sql = MySql.new()
	sql.query(%Q{
		INSERT INTO posts(
			`user`,
			`title`,
			`body`,
			`tags`,
			`views`,
			`time_posted`,
			`type`
		)
		VALUES (
			"#{user}",
			"#{title}",
			"#{body}",
			"#{tags}",
			0,
			NOW(),
			"text"
		);
	})
	sql.close
end

def viewed_post(title)
	post = sel_posts_where(title)[0]
	views = post["views"] + 1

	sql=MySql.new()
	sql.query(
		%Q{
			UPDATE posts
			SET views=#{views};
		}
		)
	sql.close
end
