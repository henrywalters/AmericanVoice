#!/usr/bin/env ruby
#require 'rest-client'
require 'sinatra'
require 'encrypted_strings'
require 'mail'
require 'pony'
require './utils/auth'
require './utils/userbase'
require './utils/posts'
require './utils/images'
require './utils/text_edit'
require './utils/algorithms'
require './utils/email'

set :bind, '0.0.0.0'
set :port, 9393

enable :sessions


get '/' do 
	if  session["search"] != nil && session["search"] != []
		all_matches = session["search"]
		all_posts = []
		all_matches.each do |match|
			all_posts.push(match[:post])
		end
	else
		session["search"] = []
		posts = sel_posts()
		images = sel_image_posts()
		all_posts = posts + images
		all_posts = all_posts.sort_by { |post| post["time_posted"]}.reverse
	end
	@titles = []
	post_limit = 3
	@pages = 0
	post_count = 0
	@links = []
	@types = []
	@titles_on_page = []
	@links_on_page = []
	@types_on_page = []

	@page = params[:page] || 0

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
		if post_count % post_limit == 0
			@pages += 1
			@types = @types
			@titles = @titles
			@links = @links
			@titles_on_page.push(@titles)
			@titles = []
			@links_on_page.push(@links)
			@links = []
			@types_on_page.push(@types)
			@types = []
		end
	end
	if post_count < post_limit
		@types_on_page.push(@types)
		@titles_on_page.push(@titles)
		@links_on_page.push(@links)
		@pages = 1
	end
	if post_count > post_limit && post_count % post_limit != 0
		@types_on_page.push(@types)
		@titles_on_page.push(@titles)
		@links_on_page.push(@links)
		@pages += 1
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
		session["search"] = []
		redirect '/login' 
	end
	if params[:register]
		redirect '/register'
	end
	if params[:logout]
		logout(session[:user])
		session[:user] = ""
		session["search"] = []
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
	if params[:search]
		redirect "/search/#{params[:search_query]}"
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

	if good_login?(u,p) && registered?(u)
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
		@user_conflict = true if params[:user_conflict]
		@bad_user = true if params[:bad_user]
		@pass_conflict =true if params[:pass_conflict]
		@bad_pass = true if params[:bad_pass]
		@email_conflict = true if params[:email_conflict]
		@bad_email = true if params[:bad_email]
		@dn_conflict = true if params[:dn_conflict]
		@bad_dn = true if params[:bad_dn]
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

	errors = []

	special_chars = ['!','@','#','$','%','^','&','*','(',')','_','-','+','=','1','2','3','4','5','6','7','8','9','0']

	if p1 != p2
		errors.push("pass_conflict=true")
	end
	if p1.length < 6 || special_chars.any? {|char| p1.include?(char)} == false
		errors.push("bad_pass=true")
	end
	if test[:user_conflict]
		errors.push("user_conflict=true")
	end
	if u.length == 0
		errors.push("bad_user=true")
	end
	if test[:email_conflict]
		errors.push("email_conflict=true")
	end
	if e.length < 5 || (e.include?("@") == false && e.include?(".edu") == false && e.include?(".com") == false && e.include?(".net") == false)
		errors.push("bad_email=true")
	end
	if test[:display_name_conflict]
		errors.push("dn_conflict=true")
	end
	if test.length == 0
		errors.push("bad_dn=true")
	end
	if errors.length != 0
		error = errors.join('&')
		redirect "/register?#{error}"
	else
		new_user(u,e,dn,p1.encrypt,"0")
		session[:user] = u
		send_registration_email(e,generate_key())
		redirect "/welcome/new/user"
	end
end

get "/welcome/new/user" do 
	erb :new_user
end

post "/welcome/new/user" do 
	redirect "/"
end

get '/register/user/*' do 
	auth_key = params[:splat].first
	if register_key(auth_key)
		register_user(session[:user])
		redirect '/'
	else
		redirect '/'
	end
end

get 'grant/write/access/*' do 
	auth_key = params[:splat].first
	if register_key(params[:key]) && session[:privilege] == 0
		grant_write_access(session[:user])
		redirect '/'
	else
		redirect '/'
	end
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


get '/post' do 
	if defined?(session[:user]) && logged_in?(session[:user]) && privilege(session[:user]) > 0
			if params[:title_conflict]
				@title_conflict = true
			end
			if params[:empty_title]
				@empty_title = true 
			end
			if params[:empty_body]
				@empty_body = true 
			end
			if params[:empty_tag]
				@empty_tag = true 
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
	errors = []

	if post_count.length != 0
		errors.push('title_conflict=true')
	end
	if title.delete(' ') == ''
		errors.push('empty_title=true')
	end
	if body.delete(' ') == ''
		errors.push('empty_body=true')
	end
	if tags.delete(' ') == ''
		errors.push('empty_tag=true')
	end

	if errors.length != 0
		error = "?"+errors.join('&')
		redirect "/post#{error}"
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
	session["edit_title"] = title
	if posts.length == 0 || logged_in?(session["user"]) == false
		redirect '/'
	else
		if params[:title_conflict]
			@title_conflict = true
		end
		if params[:empty_title]
			@empty_title = true 
		end
		if params[:empty_body]
			@empty_body = true 
		end
		if params[:empty_tag]
			@empty_tag = true 
		end

		@body = posts[0]["body"]
		@title = posts[0]["title"]
		@tags = posts[0]["tags"]
		erb :post
	end
end

post '/edit/post/*' do
	title = params[:post_title]
	body = params[:post_body]
	tags = params[:post_tags]

	post_count = sel_posts_where(title)
	errors = []

	if post_count.length != 0 && session["edit_title"] != title
		errors.push('title_conflict=true')
	end
	if title.delete(' ') == ''
		errors.push('empty_title=true')
	end
	if body.delete(' ') == ''
		errors.push('empty_body=true')
	end
	if tags.delete(' ') == ''
		errors.push('empty_tag=true')
	end
	session["edit_title"] = nil
	if errors.length != 0
		error = "?"+errors.join('&')
		redirect "/post#{error}"
	else
		delete_post(title)
		new_post(session[:user],title,body,tags)
		redirect '/'
	end
end


get '/delete/post/*' do
	title = params[:splat].first.split('-').join(' ')
	posts = sel_posts_where(title)
	if posts.length == 0 || logged_in?(session["user"]) == false
		redirect '/'
	else
		delete_post(title)
		redirect '/'
	end
end

get '/post/image' do 
	if defined?(session[:user]) && logged_in?(session[:user]) && privilege(session[:user]) > 0
		if params[:title_conflict]
			@title_conflict = true
		end
		if params[:empty_title]
			@empty_title = true
		end
		if params[:empty_tag]
			@empty_tag = true
		end
		if params[:bad_link]
			@bad_link = true
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

	errors = []

	if post_count.length != 0
		errors.push('title_conflict=true')
	end
	if title.delete(' ') == ''
		errors.push('empty_title=true')
	end
	if link.include?('http://imgur.com/a/') == false
		errors.push('bad_link=true')
	end
	if tags.delete(' ') == ''
		errors.push('empty_tag=true')
	end

	if errors.length != 0
		error = "?"+errors.join('&')
		redirect "/post/image#{error}"
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
	viewed_image(title)
	if session["user"] == img[0]["user"] && logged_in?(session["user"])
		@editable = true
	else
		@editable = false
	end
	erb :view_image_post
end

post '/image/post/*' do
	title = params[:splat].first.split('-').join(' ')
	if params[:delete]
		redirect "/delete/image/post/#{title.split(' ').join('-')}"
	else
		redirect '/'
	end
end

get '/delete/image/post/*' do 
	title = params[:splat].first.split('-').join(' ')
	posts = sel_image_posts_where(title)
	if posts.length == 0 || logged_in?(session["user"]) == false
		redirect '/'
	else
		delete_image_post(title)
		redirect '/'
	end
end

get '/search/*' do 
	query = params[:splat].first
	matches = search(query, sel_posts + sel_image_posts)
	session["search"] = matches
	redirect '/'
end

get '/admin' do 
	if defined?(session["user"]) && privilege(session["user"]) == 2
		erb :admin_page
	else
		redirect '/'
	end
end

post '/admin' do 
	if params[:submit_auth]
		user = sel_userbase_where(params[:authorize_user])
		if user != []
			send_write_auth_key(user[0]["email"],generate_key())
			redirect '/admin'
		end
	end
	redirect '/admin'
end