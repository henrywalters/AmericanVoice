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
			`type`,
		)
		VALUES (
			"#{user}",
			"#{title}",
			REPLACE("#{body}",'"','\"'),
			"#{tags}",
			0,
			NOW(),
			"text"
		);
	})
	sql.close
end
def save_draft(user,title,body,tags)
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
			REPLACE("#{body}",'"','\"'),
			"#{tags}",
			0,
			NOW(),
			"text_draft"
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

def delete_post(title)
	sql = MySql.new()
	sql.query(%Q{
		DELETE FROM posts
		WHERE `title`="#{title}";
		})
	sql.close
end

def page(post_limit, page_number)
	offset = (page_number*post_limit).to_s
	limit = (post_limit).to_s
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM posts LIMIT #{limit} OFFSET #{offset};})
	sql.close
	return sql.iter_query()
end


