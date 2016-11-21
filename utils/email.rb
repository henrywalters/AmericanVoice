require 'net/smtp'

@server = "gmail.com"
@username = "AmericanVoice0.1"
@password = "lunalove123!"

@website_url = "https://american-voice.herokuapp.com/"


def send_write_auth(to, auth_key)

	@server = "gmail.com"
	@username = "AmericanVoice0.1"
	@password = "lunalove123!"
	#@website_url = "localhost:9393/"
	@website_url = "https://american-voice.herokuapp.com/"
	smtp = Net::SMTP.new 'smtp.gmail.com', 587
	smtp.enable_starttls
	smtp.start(@server,@username,@password, :login)

	message = 
	"SUBJECT: Contribution authorization
You have been selected to contribute at 
#{@website_url}. 

Please follow the link below and you're ready to start posting.

#{@website_url}grant/write/access/#{auth_key}

The team at the American Voice appreciates your support!"

	smtp.send_message(message, @username+'@'+@server, to)
end

def send_registration_email(to,auth_key)
	@server = "gmail.com"
	@username = "AmericanVoice0.1"
	@password = "lunalove123!"
	#@website_url = "localhost:9393/"
	@website_url = "https://american-voice.herokuapp.com/"
	smtp = Net::SMTP.new 'smtp.gmail.com', 587
	smtp.enable_starttls
	smtp.start(@server,@username,@password, :login)

	message =
	"SUBJECT: Register your account
Thanks for creating an account at the American Voice.

To complete your registration please click on the link below

#{@website_url}register/user/#{auth_key}

Thanks again, we hope you enjoy our site."

	smtp.send_message(message, @username+'@'+@server, to)
end

