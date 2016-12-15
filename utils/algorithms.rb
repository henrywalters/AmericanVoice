require 'base64'

def search(checks, posts)
	matches = []
	posts.each do |post|
		matches.push({
			:post => post["title"],
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
					if match[:post] == post["title"]
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

def parse_title(words)
	if words.include?('-')
		words.gsub!('-','{hypen}')
	end
	if words.include?('?')
		words.gsub!('?','{question}')
	end
	if words.include?('&')
		words.gsub!('&', '{ampersand}')
	end
	if words.include?('/')
		words.gsub!('/','{slash}')
	end
	return words.split(' ').join('-')
end

def deparse_title(words)
	words = words.split('-').join(' ')
	if words.include?('{hypen}')
		words.gsub!('{hypen}','-')
	end
	if words.include?('{question}')
		words.gsub!('{question}','?')
	end
	if words.include?('{ampersand}')
		words.gsub!('{ampersand}','&')
	end
	if words.include?('{slash}')
		words.gsub!('{slash}','/')
	end
	return words
end

def parse_body(words)
	if words.include?('"')
		words.gsub!('"','{quote}')
	end
	return words
end

def deparse_body(words)
	if words.include?('{quote}')
		words.gsub!('{quote}','"')
	end
	return words
end

