def new_image(user,title,image_link,tags)
	sql = MySql.new()
	title = title.tr('?','')
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

def new_image_gallery(user,title,image_link,tags)
	sql = MySql.new()
	title = title.tr('?','')
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
			"image_gallery"
		);
	})
	sql.close
end

def imgur_type(link)
	if link.include?("/a/")
		return "image"
	end
	if link.include?("/gallery/")
		return "image_gallery"
	end
end

def viewed_image(title)
	post = sel_image_posts_where_id(title)
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

def delete_image_post(id)
	sql = MySql.new()
	sql.query(%Q{
		DELETE FROM image_posts
		WHERE `id`=#{id};
		})
	sql.close
end