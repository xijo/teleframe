class ImageUploader < Shrine
  plugin :remote_url, max_size: 20*1024*1024
  # plugins and uploading logic
end
