
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
		tags = post["tags"]
		title = post["title"]
		checks.each do |check|
			if tags.downcase.include?(check.downcase) || title.downcase.include?(check.downcase)
				matches.each do |match|
					if match[:post] == post
						puts "Match"
						match[:ranking] = match[:ranking] + 1
					end
				end
			end
		end
	end
	matches.delete_if{|i| i[:ranking] == 0}
	matches.sort_by {|i| i[:ranking]}

	return matches.reverse
end