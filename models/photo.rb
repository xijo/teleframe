require './models/image_uploader'

class Photo < ActiveRecord::Base
  include ImageUploader::Attachment(:image)
end
