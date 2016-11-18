def search(check, posts)
	matches = []
	posts.each do |post|
		tags = post["tags"].delete!','.split(' ')
		title = post["title"].delete','.split(' ')

	end
end