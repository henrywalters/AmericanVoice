#!/usr/bin/env ruby
#require 'rest-client'
require 'sinatra'
require 'encrypted_strings'
require './utils/auth'
require './utils/userbase'
require './utils/posts'

set :bind, '0.0.0.0'
set :port, 9393

enable :sessions


get '/' do 
	posts = sel_posts()
	@titles = []
	post_limit = 10
	post_count = 0
	@links = []
	posts.each do | post |
		@titles.push(post["title"])
		@links.push('posts/' + post["title"].split().join('-'))
		post_count = post_count + 1
		if post_count == post_limit
			break
		end
	end

	if defined?(session[:user]) && logged_in?(session[:user])
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
	if defined?(session[:user]) && logged_in?(session[:user]) && defined?(session[:privilege]) && session[:privilege] > 0
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

	post_count = sel_posts_where(title).length

	if post_count != 0 || title.delete(' ') == '' || body.delete(' ') == '' || tags.delete(' ') == ''
		redirect '/post?post_error=true'
	else
		new_post(session[:user],title,body,tags)
		redirect '/'
	end
end

get '/posts/*' do 
	title = params[:splat].first.split('-').join(' ')
	post = sel_posts_where(title)
	@title = post["title"]
	@body = post["body"]
	@tags = post["tags"]
	viewed(@title)
	erb :view_post
end

post '/posts/*' do 
	redirect '/'
end