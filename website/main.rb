require 'sinatra'
require 'uri'
require 'mongo'
require 'date'
require 'time'
require File.expand_path('../../src/language-detector', __FILE__)

use Rack::MethodOverride

# Tweets come from a MongoDB collection.
uri = URI.parse(ENV['MONGOHQ_URL'])
conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
db = conn.db(uri.path.gsub(/^\//, ''))
coll = db["tweets"]

DETECTOR = LanguageDetector.load_yaml("detector2.yaml")

helpers do
  def partial(page, locals = {})
    haml page, :layout => false, :locals => locals
  end  
end

layout 'layout'
  
get '/' do  
  haml :index
end

post '/' do
  @sentence = nil
  if params[:sentence]
    @sentence = params[:sentence]
    @language = DETECTOR.classify(@sentence) == "majority" ? "English" : "Not English"
  end
  
  haml :index
end

get '/tweet' do
  @tweet = coll.find().limit(-1).skip(rand(coll.count())).first()['text']
  @language = DETECTOR.classify(@tweet) == "majority" ? "English" : "Not English"
  @language = "Not English" if @tweet.split.select{ |c| c =~ /[^\x00-\x80]/ }.size > 1 # Use this if you want to check for non-Roman characters. Not necessary, but sometimes there are tweets consisting solely of non-Roman characters, in which case the classifier fails (since it currently removes all non-ASCII characters).

  haml :tweet, :layout => false
end