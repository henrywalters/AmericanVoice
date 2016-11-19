
def search(checks, posts)
	matches = []
	posts.each do |post|
		matches.push({
			:post => post,
			:ranking => 0
			})
	end
	checks = checks.split(' ')
	posts.each do |post|
		tags = post["tags"].split(' ')
		title = post["title"].split(' ')
		checks.each do |check|
			if tags.include?(check) || title.include?(check)
				matches.each do |match|
					if match[:post] == post
						match[:ranking] = match[:ranking] + 1
					end
				end
			end
		end
	end
	matches.delete_if{|i| i[:ranking] == 0}
	matches.sort_by {|i| i[:ranking]}
	
	return matches
end