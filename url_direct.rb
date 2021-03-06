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
	
	log_analytics(request.ip)

	if  session["search"] != nil && session["search"] != []
		all_matches = session["search"]
		all_posts = []
		all_matches.each do |match|
			all_posts += (sel_image_posts_where(match[:post]) + sel_posts_where(match[:post]))
		end
		
		session["search"] = nil
	else
		session["search"] = []
		posts = sel_posts
		images = sel_image_posts
		all_posts = posts + images

		all_posts = all_posts.sort_by { |post| post["time_posted"]}.reverse
	end
	@titles = []
	post_limit = 10
	@pages = 0
	post_count = 0
	@links = []
	@types = []
	@content = []
	@titles_on_page = []
	@links_on_page = []
	@types_on_page = []
	@contents_on_page = []
	@dn = []

	@page = params[:page] || 0
	all_posts.each do | post |
		@titles.push(deparse_title(post["title"]))
		if post["type"] == "text"
			if post["body"].include? "{quote}"
				body = post["body"].gsub("{quote}",'"')
			else
				body = post["body"]
			end
			@links.push('posts/' + post["id"].to_s)
			body = noko(body)

			@content.push(body)

			@dn.push(get_display_name(post["user"]))
		end
		if post["type"] == "image"
			print post["id"]
			@links.push('image/post/' + post["id"].to_s)
			@content.push(["a/#{post["image_link"]}","//imgur.com/#{post["link"]}"])
			@dn.push(get_display_name(post["user"]))
		end
		if post["type"] == "image_gallery"
			print post["id"]
			@links.push('image/post/' + post["id"].to_s)
			@content.push(["a/#{post["image_link"]}","//imgur.com/#{post["link"]}"])
			@dn.push(get_display_name(post["user"]))
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
			@contents_on_page.push(@content)
			@content = []
		end
	end
	if post_count < post_limit
		@types_on_page.push(@types)
		@titles_on_page.push(@titles)
		@links_on_page.push(@links)
		@contents_on_page.push(@content)
		@pages = 1
	end
	if post_count > post_limit && post_count % post_limit != 0
		@types_on_page.push(@types)
		@titles_on_page.push(@titles)
		@links_on_page.push(@links)
		@contents_on_page.push(@content)
		@pages += 1
	end
	pages = @pages
	if @page != 0
		@page = @page.to_i - 1
	else
		@page = 0
	end

	if pages < 5 
		@pages = []
		for i in 0...pages
			@pages.push(i)
		end
	else
		if @page > 1 && @page < pages - 2
			@pages = [0,@page-1,@page,@page+1,pages-1]
		elsif @page <= 1
			@pages = [0,1,2,3,pages-1]
		else
			@pages = [0,pages-4,pages-3,pages-2,pages-1]
		end
	end

	erb :home
end

post '/' do 
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:register]
		redirect '/register'
	end
	if params[:feedback]
		redirect '/feedback'
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
	if params[:profile]
		redirect '/profile'
	end
	if params[:search]
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
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
	if params[:submit]
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
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:feedback]
		redirect '/feedback'
	end
	if params[:register]
		redirect '/register'
	end
	if params[:profile]
		redirect '/profile'
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
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
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
	if params[:submit]
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
			send_registration_email(e,generate_key(u))
			redirect "/welcome/new/user"
		end
	end
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:feedback]
		redirect '/feedback'
	end
	if params[:register]
		redirect '/register'
	end
	if params[:profile]
		redirect '/profile'
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
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
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
	key = sel_keys_where(auth_key)
	beta_users = 25
	user_count = sel_userbase.length
	if register_key(auth_key)
		register_user(key["target_user"])
		if user_count < beta_users
			grant_write_access(key["target_user"])
		end
		redirect '/'
	else
		redirect '/'
	end
end

get '/grant/write/access/*' do 
	auth_key = params[:splat].first
	key = sel_keys_where(auth_key)
	if register_key(params[:key]) && session[:privilege] == 0
		grant_write_access(key["target_user"])
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
	if params[:change_username]
		redirect '/change/username'
	end
	if params[:change_display_name]
		redirect '/change/display/name'
	end
	if params[:change_password]
		redirect '/change/password'
	end
	if params[:change_display_name]
		redirect '/change/display/name'
	end
	if params[:change_password]
		redirect '/change/password'
	end
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:profile]
		redirect '/profile'
	end
	if params[:feedback]
		redirect '/feedback'
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
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
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

	if params[:submit_post]

		post_count = sel_posts_where(parse_title(title))
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
		end
		if defined?(session[:user]) == false || logged_in?(session[:user]) == false
			redirect '/'
		else
			new_post(session[:user],title,body,tags,"text")
			made_post(session[:user])
			redirect '/'
		end
	elsif params[:submit_draft]

		post_count = sel_posts_where(title)
		errors = []

		if post_count.length != 0
			errors.push('title_conflict=true')
		end
		if title.delete(' ') == ''
			errors.push('empty_title=true')
		end

		if errors.length != 0
			error = "?"+errors.join('&')
			redirect "/post#{error}"
		end
		if defined?(session[:user]) == false || logged_in?(session[:user]) == false
			redirect '/'
		else
			new_post(session[:user],title,body,tags,"text_draft")
			
			redirect '/'
		end
	else
		if params[:login]
			session["search"] = []
			
			redirect '/login' 
		end
		if params[:register]
			
			redirect '/register'
		end
		if params[:feedback]
			
			redirect '/feedback'
		end
		if params[:profile]
			
			redirect '/profile'
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
			
			redirect "/search/#{params[:search_query].split(' ').join('-')}"
		end
	end
end

get '/posts/*' do 
	id = params[:splat].first
	post = sel_all_posts_where_id(id)
	@display_names = []	

	@title = post["title"]
	if post["body"].include?("{quote}")
		@body = post["body"].gsub!("{quote}",'"')
	else
		@body = post["body"]
	end
	@tags = post["tags"]
	@date = parse_date(post["time_posted"].to_s)
	@dn = get_display_name(post["user"])
	if defined?(session["user"]) && logged_in?(session["user"])
		if privilege(session["user"]) > 0
			@commentable = true
		else
			@commentable = false
		end
		if post["user"].upcase == session["user"].upcase && logged_in?(post["user"])
			@editable = true
		else
			@editable = false
		end
	end
	viewed_post(@title)
	@title = deparse_title(@title)

	erb :view_post
end

post '/posts/*' do 
	redirect_title = params[:splat].first

	title = params[:splat].first

	comment_length = sel_post_comments(title).length
	comments = sel_post_comments(title)
	for i in 0...comment_length
		if params["delete_comment-" + i.to_s]
			delete_comment(session["delete_comment-"+i.to_s])
			session[:delete_comment] = nil
			redirect("posts/" + redirect_title)
		end
	end
	if params[:delete]
		redirect "/delete/post/#{URI.escape(title.split(' ').join('-'))}"
	elsif params[:edit]
		redirect "/edit/post/#{URI.escape(title.split(' ').join('-'))}"
	end
	if params[:comment]
		post_comment(session[:user],title + '/' + comment_length.to_s,params[:comment_field])
		redirect("posts/" + redirect_title)
	end

	if params[:home]
		redirect '/'
	end
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:feedback]
		redirect '/feedback'
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
	if params[:profile]
		redirect '/profile'
	end
	if params[:search]
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
	end
end

get '/edit/post/*' do 
	title = params[:splat].first
	posts = sel_all_posts_where_id(title)
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
		@body = posts["body"]
		if @body.include?("{quote}")
			@body.gsub!("{quote}",'"')
		end
		@title = deparse_title(posts["title"])
		@tags = posts["tags"]
		erb :post
	end
end

post '/edit/post/*' do
	if params[:submit_post]
		title = params[:post_title]
		body = params[:post_body]
		tags = params[:post_tags]

		post_count = sel_posts_where(title)
		errors = []

		if post_count.length != 0 && session["edit_title"] != parse_title(title)
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
			delete_post(params[:splat].first)
			new_post(session[:user],title,body,tags,"text")
			redirect '/'
		end
	elsif params[:submit_draft]
		title = params[:post_title]
		body = params[:post_body]
		tags = params[:post_tags]

		post_count = sel_posts_where(session["edit_title"])
		errors = []

		if post_count.length != 0 && session["edit_title"] != parse_title(title)
			errors.push('title_conflict=true')
		end
		if title.delete(' ') == ''
			errors.push('empty_title=true')
		end
		session["edit_title"] = nil
		if errors.length != 0
			error = "?"+errors.join('&')
			redirect "/post#{error}"
		else
			delete_post(params[:splat].first)
			new_post(session[:user],title,body,tags,"text_draft")
			redirect '/'
		end
	else
		title = params[:post_title]
		body = params[:post_body]
		tags = params[:post_tags]
		
		if params[:login]
			session["search"] = []
			redirect '/login' 
		end
		if params[:register]
			redirect '/register'
		end
		if params[:feedback]
			redirect '/feedback'
		end
		if params[:profile]
			redirect '/profile'
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
			redirect "/search/#{params[:search_query].split(' ').join('-')}"
		end
	end
end


get '/delete/post/*' do
	title = params[:splat].first
	posts = sel_all_posts_where_id(title)
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
	if params[:submit]
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
		if link.include?('http://imgur.com/') == false
			errors.push('bad_link=true')
		end
		if tags.delete(' ') == ''
			errors.push('empty_tag=true')
		end

		if errors.length != 0
			error = "?"+errors.join('&')
			redirect "/post/image#{error}"
		else
			if imgur_type(link) == "image"
				link = link.split('/')[4]
				new_image(session[:user],title,link,tags)
				made_post(session[:user])
				redirect '/'
			end
			if imgur_type(link) == "image_gallery"
				link = link.split('/')[4]
				new_image_gallery(session[:user],title,link,tags)
				made_post(session[:user])
				redirect '/'
			end
		end
	end
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:register]
		redirect '/register'
	end
	if params[:profile]
		redirect '/profile'
	end
	if params[:feedback]
		redirect '/feedback'
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
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
	end
end

get '/image/post/*' do 
	title = params[:splat].first
	img = sel_image_posts_where_id(title.to_i)
	if img.length == 0
		redirect '/'
	else
		link = img["image_link"].split('/')
		link = link[link.length-1]
	end
	@data = "a/#{link}"
	@link = "//imgur.com/#{link}"
	@title = img["title"]
	@tags = img["tags"]
	@date = parse_date(img["time_posted"].to_s)
	@dn = get_display_name(img["user"])
	viewed_image(title)
	if defined?(session["user"]) && logged_in?(session["user"])
		if session["user"].upcase == img["user"].upcase && logged_in?(session["user"])
			@editable = true
		else
			@editable = false
		end
	end
	erb :view_image_post
end

post '/image/post/*' do
	title = params[:splat].first
	if params[:delete]
		redirect "/delete/image/post/#{title.split(' ').join('-')}"
	end
	if params[:home]
		redirect '/'
	end
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:register]
		redirect '/register'
	end
	if params[:feedback]
		redirect '/feedback'
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
	if params[:profile]
		redirect '/profile'
	end
	if params[:post_image]
		redirect '/post/image'
	end
	if params[:search]
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
	end
end

get '/delete/image/post/*' do 
	title = params[:splat].first
	posts = sel_image_posts_where_id(title)
	if posts.length == 0 || logged_in?(session["user"]) == false
		redirect '/'
	else
		delete_image_post(title)
		redirect '/'
	end
end

get '/search/*' do 
	query = params[:splat].first.split('-').join(' ')
	matches = search(query, sel_posts + sel_image_posts)
	session["search"] = matches
	redirect '/'
end


get '/change/username' do
	if defined?(session[:user]) && logged_in?(session[:user])
		@username_conflict = true if params[:username_conflict]
		erb :change_username
	else
		redirect '/'
	end
end

post '/change/username' do 
	if params[:submit_new_username]
		if username_conflict(params[:new_username])
			redirect '/change/username?username_conflict=true'
		else
			update_user(session[:user],params[:new_username])
			redirect '/'
		end
	end

	if params[:home]
		redirect '/'
	end
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:register]
		redirect '/register'
	end
	if params[:feedback]
		redirect '/feedback'
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
	if params[:profile]
		redirect '/profile'
	end
	if params[:post]
		redirect '/post'
	end
	if params[:post_image]
		redirect '/post/image'
	end
	if params[:search]
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
	end
end

get '/change/display/name' do 
	if defined?(session[:user]) && logged_in?(session[:user])
		@display_name_conflict = true if params[:display_name_conflict]
		erb :change_display_name
	else
		redirect '/'
	end
end

post '/change/display/name' do 
	if params[:submit_new_display_name]
		if display_name_conflict(params[:new_display_name])
			redirect '/change/display/name?display_name_conflict=true'
		else
			update_display_name(get_display_name(session[:user]),params[:new_display_name])
			redirect '/'
		end
	end
	if params[:home]
		redirect '/'
	end
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
	if params[:feedback]
		redirect '/feedback'
	end
	if params[:profile]
		redirect '/profile'
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
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
	end
end

get '/change/password' do 
	if defined?(session[:user]) && logged_in?(session[:user])
		@password_conflict = true if params[:password_conflict]
		@bad_password = true if params[:bad_password]
		erb :change_password
	else
		redirect '/'
	end
end

post '/change/password' do 
	if params[:submit_new_password]
		p0 = params[:p0]
		p1 = params[:p1]
		p2 = params[:p2]
		special_chars = ['!','@','#','$','%','^','&','*','(',')','_','-','+','=','1','2','3','4','5','6','7','8','9','0']
		if p1 != p2
			redirect '/change/password?bad_password=true'
		end
		if p1.length < 6 || special_chars.any? {|char| p1.include?(char)} == false
			redirect '/change/password?bad_password=true'
		end
		if not good_password(sel_userbase_where(session[:user])[0]["password"])
			redirect '/change/password?password_conflict=true'
		else
			update_password(sel_userbase_where(session[:user])[0]["password"],p1.encrypt)
			redirect '/'
		end
	end

	if params[:home]
		redirect '/'
	end
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:register]
		redirect '/register'
	end
	if params[:feedback]
		redirect '/feedback'
	end
	if params[:logout]
		logout(session[:user])
		session[:user] = ""
		session["search"] = []
		redirect '/'
	end
	if params[:profile]
		redirect '/profile'
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
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
	end
end

get '/feedback' do
	if defined?(session["user"]) && logged_in?(session["user"])
		erb :feedback
	else
		redirect '/'
	end
end

post '/feedback' do 
	if params[:home]
		redirect '/'
	end
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:register]
		redirect '/register'
	end
	if params[:feedback]
		redirect '/feedback'
	end
	if params[:logout]
		logout(session[:user])
		session[:user] = ""
		session["search"] = []
		redirect '/'
	end
	if params[:profile]
		redirect '/profile'
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
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
	end
	send_feedback(params[:subject],params[:message])
	redirect '/thanks'
end

get '/thanks' do 
	erb :thanks
end
post '/thanks' do 
	if params[:home]
		redirect '/'
	end
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:register]
		redirect '/register'
	end
	if params[:feedback]
		redirect '/feedback'
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
	if params[:profile]
		redirect '/profile'
	end
	if params[:post]
		redirect '/post'
	end
	if params[:post_image]
		redirect '/post/image'
	end
	if params[:search]
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
	end
end

get '/profile' do 
	if defined?(session[:user]) && logged_in?(session[:user])
		posts_on_page = 10

		@user = sel_userbase_where(session[:user])[0]
		text_posts = sel_all_posts_where(@user["username"])
		img_posts = sel_all_image_posts_where(@user["username"])
		all_posts = text_posts + img_posts
		@all_posts = all_posts.sort_by { |post| post["time_posted"]}.reverse

		@page = params[:page] || 0

		@posts_on_page = []
		@content = []
		for i in 0...@all_posts.length
			if (i+1)%posts_on_page == 0
				@posts_on_page.push(@content)
				@content = [@all_posts[i]]
			else
				@content.push(@all_posts[i])
			end
		end
		if @content != []
			@posts_on_page.push(@content)
		end
		if @page != 0
			@page = @page.to_i - 1
		else
			@page = 0
		end
		pages = @posts_on_page.length
		if pages < 5 
			@pages = []
			for i in 0...pages
				@pages.push(i)
			end
		else
			if @page > 1 && @page < pages - 2
				@pages = [0,@page-1,@page,@page+1,pages-1]
			elsif @page <= 1
				@pages = [0,1,2,3,pages-1]
			else
				@pages = [0,pages-4,pages-3,pages-2,pages-1]
			end
		end

		erb :profile
	else
		redirect '/'
	end
end

post '/profile' do 
	if params[:home]
		redirect '/'
	end
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:register]
		redirect '/register'
	end
	if params[:feedback]
		redirect '/feedback'
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
	if params[:profile]
		redirect '/profile'
	end
	if params[:post]
		redirect '/post'
	end
	if params[:post_image]
		redirect '/post/image'
	end
	if params[:search]
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
	end
end


class Admin
	def initialize()
		@results = ""
	end
	def update(results)
		@results = results
	end
	def results
		return @results
	end
end

a = Admin.new()

get '/admin' do
	if defined?(session[:user]) && logged_in?(session[:user]) && privilege(session[:user])==2
		@sql_results = a.results
		data = analytic_data
		@dates = data[:days]
		@views = data[:views]
		erb :admin_page
	else
		redirect '/'
	end
end

post '/admin' do
	if params[:home]
		redirect '/'
	end
	if params[:login]
		session["search"] = []
		redirect '/login' 
	end
	if params[:register]
		redirect '/register'
	end
	if params[:feedback]
		redirect '/feedback'
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
	if params[:profile]
		redirect '/profile'
	end
	if params[:post]
		redirect '/post'
	end
	if params[:post_image]
		redirect '/post/image'
	end
	if params[:search]
		redirect "/search/#{params[:search_query].split(' ').join('-')}"
	end
	if params["sql_query"]
		begin 
			sql = MySql.new()
			sql.query(params["query"])
			sql.close
			a.update(sql.iter_query())
		rescue
			a.update("Invalid SQL cmd")
		end	
	end
	redirect '/admin'
end
