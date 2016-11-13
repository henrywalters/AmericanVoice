#!/usr/bin/env ruby
#require 'rest-client'
require 'sinatra'
require 'encrypted_strings'
require './utils/auth'
require './utils/userbase'

set :bind, '0.0.0.0'
set :port, 9393

enable :sessions


get '/' do 
	if defined?(session[:user]) && session[:user] != ""
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
		session[:user] = ""
		redirect '/'
	end
	if params[:settings]
		redirect '/settings'
	end
end

get '/login' do 
	if defined?(params[:error]) && params[:error]
		@error_message = "Username/Password match not found"
	else
		@error_message = ""
	end
	erb :login
end

post '/login' do 
	u = params[:username]
	p = params[:password].encrypt

	if good_login?(u,p)
		session[:user] = u
		redirect '/'
	else
		redirect '/login?error=true'
	end
end

get '/register' do
	if defined?(params[:error]) && params[:error]
		@error_message = "Something went wrong. Either username, email, or display name is already chosen, or password is too short or does not match"
	else
		@error_message = ""
	end
	erb :register
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