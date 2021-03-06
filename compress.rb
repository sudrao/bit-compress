require 'rubygems'
require 'sinatra'
require 'sixchars'
require 'erb'
require 'redis'
require 'json'

configure do
    if vcap = ENV['VCAP_SERVICES']
      services = JSON.parse(vcap)
      redis_key = services.keys.select { |svc| svc =~ /redis/i }.first
      redis = services[redis_key].first['credentials']
      redis_conf = {:host => redis['hostname'], :port => redis['port'], :password => redis['password']}
      @@redis = Redis.new redis_conf
    else
      @@redis = Redis.new
    end
end

get '/hi' do
  "Hi! This is the web address compressor."
end

get '/set' do
  process_set
end

get '/set.js' do
  process_set(true)
end

get '/customset' do
  erb :custom
end

get '/customset.js' do
  process_customset(true)
end

get '/:key' do
  redir = nil;
  if (params[:key])
    r = @@redis
    redir = r[params[:key]]
    unless (redir.nil?)
      redirect redir;
    else
      status 404
      "Not Found"
    end
  end
end

get '/' do
  erb :index
end

get '*' do
  "Got a wierd path = '" + params[:path] + "'"
end

def process_set(short=false)
  if params['urlin'] && params['urlin'].include?('http')
    r = @@redis
    key = rand_url;
    10.times do |index|
      break unless r[key]
      key = rand_url
    end
    unless r[key]
      r.set(key, params['urlin'])
      @url = "http://short.cloudfoundry.com/#{key}"
      if short
        '<a href="' + @url + '">' + "#{@url}</a>"
      else
        erb :index
      end
    else
      "<h3>Error: Report to admin@cloudfoundry.com</h3>"
    end
  else
    redirect '/'
  end
end

post '/set' do
  process_set
end

post '/set.js' do
  process_set(true)
end

def process_customset(short = false)
  @urlin = params['urlin']
  @password = params['password']
  @customname = params['customname']
  unless @urlin and @urlin.include?('http') and
     @password and @customname
    @errmsg = "Invalid or Missing input. Please try again."
    erb :custom
  else
    if @password == @customname
      @errmsg = "Password and short URL cannot be the same. Please try another password."
      erb :custom
    else
      r = @@redis
      existing_key = r[@password]
      if existing_key and (@customname != existing_key)
        @errmsg = "Sorry password does not match or is duplicate. Please try another password."
        erb :custom
      else 
        if !existing_key and r[@customname]
          @errmsg = "Sorry custom URL is already in use. Try another."
          erb :custom
        else
          r.set(@password, @customname)
          r.set(@customname, @urlin)
          @url = "http://short.cloudfoundry.com/#{@customname}"
          @password=nil
          @urlin=nil
          @customname=nil
          if short
            '<a href="' + @url + '">' + "#{@url}</a>"
          else
            erb :custom
          end
        end
      end
    end
  end
end

post '/customset' do
  process_customset
end

post '/customset.js' do
  process_customset(true)
end
