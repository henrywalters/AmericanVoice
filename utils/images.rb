def new_image(user,title,image_link,tags)
	sql = MySql.new()
	sql.query(%Q{
		INSERT INTO image_posts(
			`user`,
			`title`,
			`image_link`,
			`tags`,
			`views`,
			`time_posted`,
			`type`
		)
		VALUES (
			"#{user}",
			"#{title}",
			"#{image_link}",
			"#{tags}",
			0,
			NOW(),
			"image"
		);
	})
	sql.close
end

def viewed_image(title)
	post = sel_image_posts_where(title)[0]
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

def delete_image_post(title)
	sql = MySql.new()
	sql.query(%Q{
		DELETE FROM image_posts
		WHERE `title`="#{title}";
		})
	sql.close
end