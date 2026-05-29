class ChangeCustomDataToJsonb < ActiveRecord::Migration[8.0]
  def up
    change_column :users, :custom_data, :jsonb, using: "custom_data::jsonb"
  end

  def down
    change_column :users, :custom_data, :json
  end
end
