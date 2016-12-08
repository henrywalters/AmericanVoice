require 'base64'

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


def is_offensive?(text,acceptable_ratio)
	slurs = [
		'nig',
		'nigger',
		'niggers',
		'nigga',
		'ni66a',
		'jew',
		'negro',
		'fag',
		'faggot',
		'f4g',
		'spick',
		'niglet',
		'negress',
	]
	swears = [
		'fuck',
		'bitch',
		'cunt',
		'shit',
		'asshole',
		'ass'
	]
	text = text.split()
	bad_words = []
	for word in text
		if slurs.include?(word)
			bad_words.push(word)
		end
	end
	print bad_words
end


def compress(image)
	return Base64.encode64(image)
end
def decompress(encoded_image)
	File.open('new_image.png') do |f|
		f.write(Base64.decode(encoded_image))
	end
end

