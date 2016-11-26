# AmericanVoice #

#Table of Contents#

### Utils ###
      
      mysql.rb

      auth.rb
      
      userbase.rb
      
      posts.rb
      
      images.rb
      
      text_edit.rb
      
      algorithms.rb

      email.rb

### url_direct.rb ###

# Utils #

### mysql.rb ###

The MySql class is the first abstraction from the mysql database.

One may initialize the class by calling:

sql_instance = MySql.new()

You can call any mysql query using the module: 

sql_instance.query(sql_query) 

To return an array of results call:

sql_instace.iter_query()

To close the connection, simply call

sql_instance.close