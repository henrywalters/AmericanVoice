require './utils/posts'
require './utils/mysql'
running = true
post_count = 0
while running
	begin
		new_post("test","test","

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis egestas turpis mi, vel sollicitudin nisi tincidunt ut. Integer tristique, est euismod feugiat dignissim, metus turpis tristique eros, tristique lacinia mauris risus a nunc. Quisque ac elementum lacus, vel porttitor neque. Nunc rhoncus faucibus ante at vulputate. Nulla pretium eget nulla hendrerit ornare. Etiam nibh risus, interdum sed finibus ac, commodo sed ante. Proin porttitor congue lorem ac ultricies.

Vestibulum fringilla ullamcorper velit, efficitur tristique enim sagittis non. Maecenas felis leo, blandit accumsan vestibulum non, pulvinar quis mauris. Ut viverra porta molestie. Nullam sagittis sem porta, vestibulum felis eget, tempus nibh. Duis varius sagittis massa et euismod. Curabitur sagittis odio et suscipit laoreet. Vestibulum vel ultrices augue, quis hendrerit enim. Pellentesque arcu quam, dapibus ut scelerisque quis, vehicula hendrerit lacus. Morbi porttitor turpis a mi dapibus dapibus. Vivamus pharetra augue at volutpat euismod. Integer fringilla nisl et imperdiet pretium. Aenean in lobortis purus, ut cursus libero.

Curabitur auctor nisi a sapien ornare, vel vehicula nulla ultricies. Nam in iaculis erat. Interdum et malesuada fames ac ante ipsum primis in faucibus. Duis aliquam ante auctor, dignissim arcu eget, gravida ante. Sed elementum justo et convallis suscipit. Aenean pellentesque sagittis mi, nec pretium arcu faucibus sed. Nulla pretium tempus urna tincidunt vulputate. Maecenas vitae nisl dictum, fermentum nunc non, blandit erat.

Vivamus pulvinar dapibus leo et commodo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque imperdiet fermentum rutrum. Vestibulum in justo a tortor ullamcorper euismod. Donec mattis ligula ac dolor ornare blandit. Nulla vel elit nulla. Nunc pellentesque ligula vel ipsum sagittis, in fermentum arcu mollis. Sed rhoncus diam ante.

Nullam quis ligula eu dolor venenatis eleifend. Phasellus facilisis, sapien non dictum interdum, mi diam semper dui, quis auctor odio lacus vitae turpis. Maecenas orci orci, cursus eu consequat sed, aliquam eget ante. Morbi dapibus odio eu risus malesuada finibus. Nam posuere sit amet augue tincidunt vehicula. Donec quis velit laoreet, auctor ligula eget, auctor augue. Quisque dui erat, hendrerit in feugiat vel, placerat ut odio. Vestibulum mi tellus, congue a nunc nec, consequat dignissim nisi. Praesent efficitur eros leo, ac posuere lectus pellentesque auctor. Proin non ipsum eu lorem vestibulum mattis. Maecenas non dolor nunc. Curabitur justo eros, pretium at posuere ut, scelerisque consequat sapien. Vestibulum quis mattis purus, sit amet sodales tellus. Mauris sem dolor, feugiat quis ipsum et, tristique rutrum odio. Nunc gravida, velit nec viverra hendrerit, tellus ex ultricies urna, eget efficitur sapien nulla id ex. ","test","text")
	rescue
		puts "Failed"
		break
	end
	post_count += 1
	puts "Posts made: #{post_count.to_i}"
end