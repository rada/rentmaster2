class CreateAutoPays < ActiveRecord::Migration
  def self.up
    create_table :auto_pays do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :auto_pays
  end
end
