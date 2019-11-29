require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require 'excon'

require 'shrine'
require 'shrine/storage/s3'

s3_options = {
  bucket:             ENV['S3_BUCKET'],
  access_key_id:      ENV['S3_ACCESS_KEY_ID'],
  secret_access_key:  ENV['S3_SECRET_ACCESS_KEY'],
  region:             'eu-west-1',
}

Shrine.storages = {
  cache: Shrine::Storage::S3.new(prefix: "cache", **s3_options),
  store: Shrine::Storage::S3.new(public: true, **s3_options),
}

Shrine.plugin :activerecord
Shrine.plugin :restore_cached_data
Shrine.plugin :rack_file

require './models/bot'
require './models/photo'

get '/bots/:token', provides: 'html' do
  @bot = Bot.find_by token: params[:token]
  @photos = @bot.photos.order(:created_at).last(10)
  erb :index
end

get '/bots/:token/current' do
  @bot = Bot.find_by token: params[:token]
  @photo = @bot.photos.order(:created_at).last
  @photo.id.to_s
end

post '/bots/:token/webhook' do
  bot = Bot.find_by(token: params['token'])
  request.body.rewind  # in case someone already read it
  data = JSON.parse(request.body.read, object_class: JSON::GenericObject)

  if file_id = Array(data.message.photo).last&.file_id
    Photo.create(bot_id: bot.id, image_remote_url: bot.get_file_url(file_id))
  end
end


# {
#   "update_id"=>505038626,
#   "message"=>{
#     "message_id"=>65,
#     "from"=>{
#       "id"=>11748780,
#       "is_bot"=>false,
#       "first_name"=>"Johannes",
#       "last_name"=>"Opper",
#       "language_code"=>"en"
#     },
#     "chat"=>{
#       "id"=>11748780,
#       "first_name"=>"Johannes",
#       "last_name"=>"Opper",
#       "type"=>"private"
#     },
#     "date"=>1573168157,
#     "photo"=>[
#       {
#         "file_id"=>"AgADBAADpLExG3eBKVJTS7nGiV3WBn5hqBsABAEAAwIAA20AA2kTBAABFgQ",
#         "file_size"=>20835,
#         "width"=>240,
#         "height"=>320
#       },
#       {
#         "file_id"=>"AgADBAADpLExG3eBKVJTS7nGiV3WBn5hqBsABAEAAwIAA3gAA2oTBAABFgQ",
#         "file_size"=>88882,
#         "width"=>600,
#         "height"=>800
#       },
#       {
#         "file_id"=>"AgADBAADpLExG3eBKVJTS7nGiV3WBn5hqBsABAEAAwIAA3kAA2sTBAABFgQ",
#         "file_size"=>192520,
#         "width"=>960,
#         "height"=>1280
#       }
#     ]
#   }
# }


# {
#   "update_id"=>505038627,
#   "message"=>{
#     "message_id"=>66,
#     "from"=>{
#       "id"=>11748780,
#       "is_bot"=>false,
#       "first_name"=>"Johannes",
#       "last_name"=>"Opper",
#       "language_code"=>"en"
#     },
#     "chat"=>{
#       "id"=>11748780,
#       "first_name"=>"Johannes",
#       "last_name"=>"Opper",
#       "type"=>"private"
#     },
#     "date"=>1573168448,
#     "photo"=>[
#       {
#         "file_id"=>"AgADBAADp7ExG3eBKVKiDCym-grzDLyOuBoABAEAAwIAA20AA8RwAgABFgQ",
#         "file_size"=>21598,
#         "width"=>240,
#         "height"=>320
#       },
#       {
#         "file_id"=>"AgADBAADp7ExG3eBKVKiDCym-grzDLyOuBoABAEAAwIAA3gAA8VwAgABFgQ",
#         "file_size"=>100807,
#         "width"=>600,
#         "height"=>800
#       },
#       {
#         "file_id"=>"AgADBAADp7ExG3eBKVKiDCym-grzDLyOuBoABAEAAwIAA3kAA8ZwAgABFgQ",
#         "file_size"=>218132,
#         "width"=>960,
#         "height"=>1280
#       }
#     ],
#     "caption"=>"dingdong"
#   }
# }



# {"update_id"=>505038634, "message"=>{"message_id"=>73, "from"=>{"id"=>11748780, "is_bot"=>false, "first_name"=>"Johannes", "last_name"=>"Opper", "language_code"=>"en"}, "chat"=>{"id"=>11748780, "first_name"=>"Johannes", "last_name"=>"Opper", "type"=>"private"}, "date"=>1573168606, "media_group_id"=>"12585348853349556", "photo"=>[{"file_id"=>"AgADBAADqrExG3eBKVLi-nwnb0YkQi-toBoABAEAAwIAA20AA9hqAgABFgQ", "file_size"=>21419, "width"=>240, "height"=>320}, {"file_id"=>"AgADBAADqrExG3eBKVLi-nwnb0YkQi-toBoABAEAAwIAA3gAA9pqAgABFgQ", "file_size"=>96399, "width"=>600, "height"=>800}, {"file_id"=>"AgADBAADqrExG3eBKVLi-nwnb0YkQi-toBoABAEAAwIAA3kAA9tqAgABFgQ", "file_size"=>207841, "width"=>960, "height"=>1280}]}
