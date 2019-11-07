class CreateBots < ActiveRecord::Migration[6.0]
  def change
    create_table :bots do |t|
      t.string :name
      t.string :telegram_token
      t.string :token
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
