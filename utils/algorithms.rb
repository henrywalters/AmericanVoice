require 'base64'
require 'nokogiri'


def parse_date(date)
	date = date.split()[0].split('-')
	y = date[0]
	m = (date[1]).to_i - 1
	d = date[2]

	months = [
		'Jan',
		'Feb',
		'Mar',
		'Apr',
		'may',
		'June',
		'July',
		'Aug',
		'Sep',
		'Oct',
		'Nov',
		'Dec'
	]

	return "#{months[m]} #{d}, #{y}"
end

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
	if words.include?(']')
		words.gsub!(']','{right_bracket}')
	end
	if words.include?('[')
		words.gsub!('[','{left_bracket}')
	end
	if words.include?('#')
		words.gsub!('#','{hash_tag}')
	end
	if words.include?('%')
		words.gsub!('%','{percent}')
	end
	if words.include?('"')
		words.gsub!('"','{quote}')
	end
	if words.include?('<')
		words.gsub!('<','{less_than}')
	end
	if words.include?('>')
		words.gsub!('>','{greater_than}')
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
	if words.include?('{left_bracket}')
		words.gsub!('{left_bracket}','[')
	end
	if words.include?('{right_bracket}')
		words.gsub!('{right_bracket}',']')
	end
	if words.include?('{hash_tag}')
		words.gsub!('{hash_tag}','#')
	end
	if words.include?('{percent}')
		words.gsub!('{percent}','%')
	end
	if words.include?('{quote}')
		words.gsub!('{quote}','"')
	end
	if words.include?('{less_than}')
		words.gsub!('{less_than}','<')
	end
	if words.include?('{greater_than}')
		words.gsub!('{greater_than}','>')
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

def noko(html, length_limit=260)
	doc = Nokogiri::HTML(html)
	doc = doc.css("body").text or doc.css("image")
	if doc.size <= length_limit
		return doc.slice(0...length_limit)
	else
		return doc.slice(0...length_limit) + '...'
	end
end



#noko("<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>I want to take this opportunity to thank everyone who takes the time to join us here. Following the election of Donald Trump, I saw great pain among friends of mine who were women, who were minorities, who were part of the LGBTQ community and I felt great pain myself at the loss of what I saw as a safer future for America and a disregard of the lives of some Americans or their autonomy in favor of personal gain. There have been efforts to force a recount in some battleground states but I am not holding out hope that the recount will change the results, nor am I holding out hope for faithless electors. In such a case, Donald Trump will be our president. And to that end, I feel my duty is to be a watchdog on this administration and to do all that I can to ensure that the rights of Americans are not trampled upon. It’s part of the Trump team’s platform to make the world less safe for any marginalized group in our nation and this cannot be denied or ignored. So it’s time to be vigilant. The Republican Party holds the House, the Senate and the Executive Branch and in the past two weeks, there has already been much to be vigilant of. The Republican Party cannot be allowed to:</span></p>\r\n<div dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}> </div>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>-Repeal Roe v. Wade</span></p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>-Overturn marriage equality</span></p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>-Further destroy the environment</span></p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>-Further proliferate nuclear weapons across the globe</span></p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>-Start another war</span></p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>-Let a rapist hold public office</span></p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>-Destroy birth control health care provisions</span></p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>-Degrade the American education system</span></p>\r\n<div dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}> </div>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>These are just my beginning thoughts and anything you see as a pressing matter, I’ll add to this list in the next iteration and I’ll do everything in my power to advocate for it. For some of these problems, they’re more abstract and I look to all of you for any guidance you might have on achieving our goals to maintain this as an America for us all. For others, I know of some resources right now to start taking action. This is a petition to stop Myron Ebell, a climate change denier, from becoming head of the EPA: </span><a style={quote}text-decoration: none;{quote} href={quote}http://petitions.moveon.org/sign/keep-myron-ebell-from{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; color: #1155cc; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; text-decoration: underline; vertical-align: baseline; white-space: pre-wrap;{quote}>http://petitions.moveon.org/sign/keep-myron-ebell-from</span></a></p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}> </p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>here is the donation page for the Standing Rock Sioux Tribe: </span><a style={quote}text-decoration: none;{quote} href={quote}http://standingrock.org/news/standing-rock-sioux-tribe--dakota-access-pipeline-donation-fund/{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; color: #1155cc; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; text-decoration: underline; vertical-align: baseline; white-space: pre-wrap;{quote}>http://standingrock.org/news/standing-rock-sioux-tribe--dakota-access-pipeline-donation-fund/</span></a></p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}> </p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>as well as a supply list for Sacred Stone Camp: </span><a style={quote}text-decoration: none;{quote} href={quote}http://sacredstonecamp.org/supply-list/{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; color: #1155cc; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; text-decoration: underline; vertical-align: baseline; white-space: pre-wrap;{quote}>http://sacredstonecamp.org/supply-list/</span></a><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}> and an Amazon wishlist: </span><span style={quote}text-decoration: underline; font-size: 14.6667px; font-family: Arial; color: #1155cc; background-color: transparent; font-variant-ligatures: normal; vertical-align: baseline; white-space: pre-wrap;{quote}><a href={quote}https://www.amazon.com/gp/registry/wishlist/18FR1AGDPWZLC/{quote}>https://www.amazon.com/gp/registry/wishlist/18FR1AGDPWZLC/</a></span></p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}> </p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>here is a </span><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>petition to stop the appointment of Betsy DeVos, someone who would gut funding for public schools and funnel it to charter schools, to Secretary of Education: </span><a style={quote}text-decoration: none;{quote} href={quote}https://www.change.org/p/donald-trump-say-no-to-the-appointment-of-charter-school-lobbyist-betsy-devos-for-education-secretary{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; color: #1155cc; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; text-decoration: underline; vertical-align: baseline; white-space: pre-wrap;{quote}>https://www.change.org/p/donald-trump-say-no-to-the-appointment-of-charter-school-lobbyist-betsy-devos-for-education-secretary</span></a><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>. If you can lend your voice or support to any of these causes I know it would help. </span></p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}> </p>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>I’ve stated that I see my duty as being a watchdog on this administration and anyone who wants to join in that task, I welcome the watchful eyes. But we are all so talented and passionate in different ways and that diversity is the true beauty in our nation. This is a place, first and foremost, for political and civic action and it’s a place where all forms of expression are welcomed and celebrated. </span></p>\r\n<div dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}> </div>\r\n<p dir={quote}ltr{quote} style={quote}font-family: -webkit-standard; -webkit-text-size-adjust: auto; line-height: 1.38; margin-top: 0pt; margin-bottom: 0pt;{quote}><span style={quote}font-size: 14.666666666666666px; font-family: Arial; background-color: transparent; font-variant-ligatures: normal; font-variant-position: normal; font-variant-numeric: normal; font-variant-alternates: normal; font-variant-east-asian: normal; vertical-align: baseline; white-space: pre-wrap;{quote}>Over the past few weeks, I’ve been involved in front end development but the person to be commended on the great functionality of this site is my tireless and passionate partner, Henry Walters. If you have news to report, essays to express, stories to tell, poems to share, we have text posts. If you have art to show, we have image and album posts and we are working on allowing videos to be embedded. Anything that you feel could improve the site, we have a space for feedback and we would love to hear your thoughts. Under an administration that would see your voice silenced, let your voice be heard at The American Voice.</span></p>")
#noko("<p>Last night I went and saw the new <em>Star Wars</em>. I personally was quite amused but my friend said that there were many things he liked, and some things, not so much. He later went on to say that this is a large problem that we are facing in our current social situation; the requirement to make a binary statement on everything. </p>\r\n<p><img style={quote}display: block; margin-left: auto; margin-right: auto;{quote} src={quote}https://cruxnow.com/wp-content/uploads/2016/07/BBC.jpg{quote} alt={quote}{quote} width={quote}300{quote} height={quote}169{quote} /></p>\r\n<p>This election has been a very melodramatic one. If you side with Trump, you're alt right. If you side with Hillary, you must be an extreme liberal. This mode of thought is detrimental to compromise, a necessary component of a functioning system.</p>\r\n<p>{quote}Only siths deal in absolutes,{quote} so why should we ourselves fall into that type of behavior. We do it because it's the simplest of generalizations. What every human strives to do. It's an anchored social structure belief that one must fall into one of two categories. Break the cycle.</p>\r\n<p>I could sit and hypothesize the the reasons why this happens, but that's not so important. What's important that we criticize both sides of the story and realize the solution is somewhere in the middle.</p>\r\n<p>Just some thoughts of the day.</p>")