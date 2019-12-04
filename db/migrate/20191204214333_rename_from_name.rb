class RenameFromName < ActiveRecord::Migration[6.0]
  def change
    rename_column :photos, :from_first_name, :from_name
  end
end
