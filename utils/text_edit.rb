

def text_to_html(str)
	str.sub! '[b]', '<b>'
	str.sub! '[/b]', '</b>'
	str.sub! '[i]', '<i>'
	str.sub! '[/i]', '</i>'
	str.sub! '[sm]', '<small>'
	str.sub! '[/sm]', '</small>'
	str.sub! '[e]', '<em>'
	str.sub! '[/e]', '</em>'
	str.sub! '[s]', '<sub>'
	str.sub! '[/s]', '</sub>'
	str.sub! '[^]', '<sup>'
	str.sub! '[/^]', '</sup>'
	str.sub! '\n', '<br>'
	
	return str
end
