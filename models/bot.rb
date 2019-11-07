class Bot < ActiveRecord::Base
  has_many :photos

  def renew_webhook
    Excon.get("https://api.telegram.org/bot#{telegram_token}/deleteWebhook")
    Excon.get("https://api.telegram.org/bot#{telegram_token}/setWebhook?url=https://#{ENV['TELEFRAME_DOMAIN']}/bots/#{token}/webhook")
  end

  def get_file_url(file_id)
    response = Excon.get("https://api.telegram.org/bot#{telegram_token}/getFile?file_id=#{file_id}")
    data = JSON.parse(response.body, object_class: JSON::GenericObject)
    "https://api.telegram.org/file/bot#{telegram_token}/#{data.result.file_path}"
  end
end
