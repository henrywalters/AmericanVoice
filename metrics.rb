require './utils/mysql'

menu = [
	'View Users',
	'View Users detailed',
	'User Count',
	'Quit'
]

running = true
while running
	puts "American Voice Metrics"
	for i in 0...menu.length
		puts (i+1).to_s + '.) ' + menu[i]
	end
	print "Input: "
	input = gets().to_i 

	if input == 4
		running = false
	end
	if input == 1
		users = sel_userbase
		users.each do | user |
			puts user["username"]
		end
	end

end

