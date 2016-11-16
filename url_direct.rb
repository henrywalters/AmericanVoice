#!/usr/bin/env ruby
#require 'rest-client'
require 'sinatra'
require 'encrypted_strings'
require './utils/auth'
require './utils/userbase'
require './utils/posts'
require './utils/images'
require './utils/text_edit'

set :bind, '0.0.0.0'
set :port, 9393

enable :sessions

get '/' do 
	posts = sel_posts().reverse
	images = sel_image_posts().reverse
	all_posts = posts + images
	all_posts = all_posts.sort_by { |post| post["time_posted"]}
	@titles = []
	post_limit = 10
	post_count = 0
	@links = []
	@types = []

	all_posts.each do | post |
		@titles.push(post["title"])
		if post["type"] == "text"
			@links.push('posts/' + post["title"].split().join('-'))
		end
		if post["type"] == "image"
			@links.push('image/post/' + post["title"].split().join('-'))
		end
		@types.push(post["type"])
		post_count = post_count + 1
		if post_count == post_limit
			break
		end
	end

	if defined?(session[:user]) && logged_in?(session[:user])
		@privilege = privilege(session[:user])
		erb :user_home	
	else
		erb :home
	end
end

post '/' do 
	if params[:login]
		redirect '/login' 
	end
	if params[:register]
		redirect '/register'
	end
	if params[:logout]
		logout(session[:user])
		redirect '/'
	end
	if params[:settings]
		redirect '/settings'
	end
	if params[:post]
		redirect '/post'
	end
	if params[:post_image]
		redirect '/post/image'
	end
end

get '/login' do 
	if defined?(session[:user]) && logged_in?(session[:user])
		redirect '/'
	else
		if defined?(params[:error]) && params[:error]
			@error_message = "Username/Password match not found"
		else
			@error_message = ""
		end
		erb :login
	end
end

post '/login' do 
	u = params[:username]
	p = params[:password].encrypt

	if good_login?(u,p)
		session[:user] = u
		session[:privilege] = privilege(u) 
		login(u)
		redirect '/'
	else
		redirect '/login?error=true'
	end
end

get '/register' do
	if defined?(session[:user]) && logged_in?(session[:user])
		redirect '/'
	else	
		if defined?(params[:error]) && params[:error]
			@error_message = "Something went wrong. Either username, email, or display name is already chosen, or password is too short or does not match"
		else
			@error_message = ""
		end
		erb :register
	end
end

post '/register' do 
	u = params[:username]
	dn = params[:display_name]
	e = params[:email]
	p1 = params[:password1]
	p2 = params[:password2]

	test = user_conflict?(u,e,dn)

	error = false

	if p1 != p2 || p1.length < 6
		error = true
	end

	if test[:user_conflict] || u.length == 0
		error = true
	end

	if test[:email_conflict] || e.length < 4
		error = true
	end

	if test[:display_name_conflict] || dn.length == 0
		error = true
	end
	
	if error
		redirect "/register?error=true"
	else
		new_user(u,e,dn,p1.encrypt,"0")
		redirect "/welcome/new/user"
	end
end

get "/welcome/new/user" do 
	erb :new_user
end

post "/welcome/new/user" do 
	redirect "/"
end

get '/settings' do 
	if defined?(session[:user]) && logged_in?(session[:user])
		@key_error = params[:key_error]
		erb :settings
	else
		redirect '/'
	end
end

post '/settings' do 
	if params[:enter_key]
		if register_key(params[:key]) && session[:privilege] == 0
			grant_write_access(session[:user])
			redirect '/'
		else
			redirect '/settings?key_error=true'
		end
	end
end

get '/generate/key' do 
	if defined?(session[:privilege]) && session[:privilege] == 2
		@key = generate_key()
		erb :generate_key
	else
		redirect '/'
	end
end

get '/post' do 
	if defined?(session[:user]) && logged_in?(session[:user]) && privilege(session[:user]) > 0
		if defined?(params[:post_error]) && params[:post_error]
			@post_error = true
		else
			@post_error = false
		end
		erb :post
	else
		redirect '/'
	end
end	

post '/post' do
	title = params[:post_title]
	body = params[:post_body]
	tags = params[:post_tags]

	post_count = sel_posts_where(title)

	if post_count.length != 0 || title.delete(' ') == '' || body.delete(' ') == '' || tags.delete(' ') == ''
		redirect '/post?post_error=true'
	else
		new_post(session[:user],title,body,tags)
		redirect '/'
	end
end

get '/posts/*' do 
	title = params[:splat].first.split('-').join(' ')
	post = sel_posts_where(title)[0]
	@title = post["title"]
	@body = post["body"]
	@tags = post["tags"]
	@dn = get_display_name(post["user"])
	if post["user"] == session["user"] && logged_in?(post["user"])
		@editable = true
	else
		@editable = false
	end
	viewed_post(@title)
	erb :view_post
end

post '/posts/*' do 
	title = params[:splat].first.split('-').join(' ')
	if params[:delete]
		redirect "/delete/post/#{title.split(' ').join('-')}"
	elsif params[:edit]
		redirect "/edit/post/#{title.split(' ').join('-')}"
	else
		redirect '/'
	end
end

get '/edit/post/*' do 
	title = params[:splat].first.split('-').join(' ')
	posts = sel_posts_where(title)
	if posts.length == 0
		redirect '/'
	else
		@body = posts[0]["body"]
		@title = posts[0]["title"]
		@tags = posts[0]["tags"]
		erb :post
	end
end

get '/post/image' do 
	if defined?(session[:user]) && logged_in?(session[:user]) && privilege(session[:user]) > 0
		if params[:error] == "true"
			@error = true
		else
			@error = false
		end		

		erb :image_upload
	else
		redirect '/'
	end
end

post '/post/image' do 
	link = params[:imgur_link]
	title = params[:image_title]
	tags = params[:tags]
	post_count = sel_image_posts_where(title)

	if post_count.length != 0 || title == '' || tags == '' || link.include?('http://imgur.com/a/') == false
		redirect '/post/image?error=true'
	else
		link = link.split('/')[4]
		new_image(session[:user],title,link,tags)
		redirect '/'
	end
end

get '/image/post/*' do 
	title = params[:splat].first.split('-').join(' ')
	img = sel_image_posts_where(title)
	if img.length == 0
		redirect '/'
	else
		link = img[0]["image_link"].split('/')
		link = link[link.length-1]
	end
	@data = "a/#{link}"
	@link = "//imgur.com/#{link}"
	@title = img[0]["title"]
	@tags = img[0]["tags"]
	@dn = get_display_name(img[0]["user"])

	erb :view_image_post
end

post '/image/post/*' do
	redirect '/'
end