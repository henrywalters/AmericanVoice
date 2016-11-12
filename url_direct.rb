#!/usr/bin/env ruby
#require 'rest-client'
require 'sinatra'
require './utils/auth'
require './utils/userbase'

set :bind, '0.0.0.0'
set :port, 9393

get '/' do 
	erb :home
end

post '/' do 
	if params[:login] == nil
		redirect '/register' 
	else
		redirect 'login'
	end
end

get '/login' do 
	erb :login
end

post '/login' do 
	user = params[:username]
	pass = params[:password]
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
		new_user(u,e,dn,p1,"0")
		redirect "/welcome/new/user"
	end
end

get "/welcome/new/user" do 
	erb :new_user
end

post "/welcome/new/user" do 
	redirect "/"
end