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
	erb :register
end