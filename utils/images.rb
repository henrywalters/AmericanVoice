def new_image(user,title,image_link,tags)
	sql = MySql.new()
	sql.query(%Q{
		INSERT INTO image_posts(
			`user`,
			`title`,
			`image_link`,
			`tags`,
			`views`,
			`time_posted`
		)
		VALUES (
			"#{user}",
			"#{title}",
			"#{image_link}",
			"#{tags}",
			0,
			NOW()
		);
	})
	sql.close
end

def viewed_image(title)
	post = sel_posts_where(title)[0]
	views = post["views"] += 1

	sql=MySql.new()
	sql.query(
		%Q{
			UPDATE image_posts
			SET views=#{views};
		}
		)
	sql.close
end
