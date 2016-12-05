def new_post(user,title,body,tags,type)
	sql = MySql.new()
	if body.include?('"')
		body.gsub!('"','{quote}')
	end
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
			"#{type}"
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
			"#{body}"
			"#{tags}",
			0,
			NOW(),
			"text_draft"
		);
	})
	sql.close
end

def post_comment(user, root, body)
	sql = MySql.new()
	sql.query(%Q{
		INSERT INTO comments(
			`user`,
			`root`,
			`comment`
		) 
		VALUES
		(
			"#{user}",
			"#{root}",
			"#{body}"
		);
		})
	sql.close
end

def viewed_post(title)
	post = sel_all_posts_where_title(title)[0]
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

def user_page(user,post_limit, page_number)
	offset = (page_number*post_limit).to_s
	limit = (post_limit).to_s
	sql = MySql.new()
	sql.query(%Q{SELECT * FROM posts LIMIT #{limit} OFFSET #{offset} WHERE user="#{user}";})
	sql.close
	return sql.iter_query()
end	
