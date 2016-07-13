require 'minitest/autorun'
require 'rack/test'
require_relative "../app/app.rb"
class TestLogin < MiniTest::Unit::TestCase
include Rack::Test::Methods
	def app
    	Sinatra::Application
  	end


	def setup
		@user=User.new
	end
#Test rutas del login
	def test_root
		get "/"
		assert_equal 200, last_response.status
    	assert last_response.ok?
	end
	def test_get_singup
		get "/signup"
		assert_equal 200, last_response.status
		assert last_response.ok?
	end
	#def test_post_signup
	#	post "/signup"
	#	assert_equal 200, last_response.status
	#	assert last_response.ok?
	#end
	def test_post_login
		post "/login"
		assert_equal 200, last_response.status
	end
	
	def test_get_signoff
		get "/singoff"
		#302 Redirection code
		assert_equal 302, last_response.status 
	end

#Test login
	#Registro
	def test_singup
        post '/players', "userid"=> "test9", "name" => "testname9", 'last_name' => "testlastname9", 'password' => "1234"
      #  assert_equal 302, last_response.status
        #assert_includes(last_response.body , "test6") 
        usdb=User.find_by(userid: "test9")
        assert_equal("testname9" , usdb.name)
	end

	def test_login
		post '/login' ,"userid"=> "test9", 'password' => "1234" 
		assert_equal "test9", last_request.env['rack.session']['userid']
	end
	def test_signoff
		get "/singoff"
		assert_nil(last_request.env['rack.session']['userid'])
	end
	#
	def test_invalid_login
		post '/login' ,"userid"=> "test10", 'password' => "1234" 
		assert_nil(last_request.env['rack.session']['userid'])
		assert last_response.body.include?('Incorrect username and password')
	end

	def test_invalid_singup
		post '/players', "userid"=> "test9", "name" => "testname9", 'last_name' => "testlastname9", 'password' => "1234"
        assert last_response.body.include?('el usuario existe ya existe')
        assert_equal 409, last_response.status 
	end

end