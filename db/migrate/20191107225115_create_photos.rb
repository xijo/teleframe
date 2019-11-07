class CreatePhotos < ActiveRecord::Migration[6.0]
  def change
    create_table :photos do |t|
      t.integer :bot_id, null: false
      t.integer :message_id
      t.jsonb :image_data
      t.string :from_first_name
      t.string :caption
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
