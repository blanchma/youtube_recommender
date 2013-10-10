#get = CGIMethods.parse_query_paremeters(@request.query_string)
#post = CGIMethods.parse_query_parameters(@request.raw_post) 
# you'd think you could use @request.query_parameters and
# @request.request_parameters, but they're update()d by route vars
#route = @request.path_parameters

puts "success"
