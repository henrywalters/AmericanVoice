require 'mail'

def send_email(t,f,s,b)
	mail = Mail.new do
		from f
		to t
		subject s
		body b
	end
	mail.to_s
end

send_email("henrywalters20@gmail.com","henrywalters20@gmail.com","test","hello dude")