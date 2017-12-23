require 'net/https'
require 'uri'
require './mysql'


class AVIP
	def initialize(ip = '127.0.0.1', content = [])
		@ip = ip
		@content = content
		@params = [
			:format,
			:ip,
			:content
		]

		@contents = [
			:ip,
			:hostname,
			:city,
			:region,
			:country,
			:loc,
			:org,
			:postal
		]
	end

	# Input options in hash form ie {:format => :json, :ip => '127.0.0.1'}
	def update(param_hash)
		param_hash.each do |key,value|
			if @params.include?(key)
				if key == :ip
					@ip = value
					puts "Ip changed to #{value}."
				elsif key == :content
					if value.length == 0
						puts "Invalid Input, using all outputs"
					else
						content = []
						value.each do |val|
							if @contents.include?(val)
								@content.push(val)
								puts "Including: #{val}"
							else
								puts "#{val} is not a valid option."
							end
						end
					end
				end
			else
				puts "Paramater: #{key} is not a valid option."
				puts "Warning: No change has been made."  
			end
		end
	end

	def search(ip = nil)
		if ip == nil
			p_ip = @ip
		else
			p_ip = ip
		end
		uri = URI("http://ipinfo.io/#{p_ip}/#{@format}")
		Net::HTTP.start(uri.host, uri.port) do |http|
			request = Net::HTTP::Get.new uri
			response = http.request request
			res = eval(response.body )
			if @content == []
				return res
			else
				new_res = {}
				res.each do |key,value|
					@content.each do |con|
						if key == con
							new_res[key] = value
						end
					end
				end
				return new_res
			end
		end
	end
end

def get_locations
	anal = sel_analytics
	ip = AVIP.new()
	ip.update({:content => [:city, :region, :loc]})
	logged = []
	out = []
	anal.each do |a|
		if logged.include?(a["ip"]) == false && a["ip"].include?('.')
			logged.push(a["ip"])
			out.push(ip.search(a["ip"]))
		end
	end
	return out
end

print get_locations