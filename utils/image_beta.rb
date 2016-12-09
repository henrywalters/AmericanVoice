require 'imgurapi'


class Imgur
	def initialize()
		id = 'dbc53b818ba730b'
		secret = '5990b179700e6b42c869adbe154bf77bfaf41322'
		refresh = '29b359d1fcddaba3b9f7da5cdff38b441a6525ee'
		@session = Imgurapi::Session.new(client_id: id, client_secret: secret, refresh_token: refresh)
	end

	def upload(image_location)
		image = @session.image.image_upload(image_location)
		return image
	end
end

i = Imgur.new()

i.upload('avhead-min.png')

