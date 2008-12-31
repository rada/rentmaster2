class CreateRenters < ActiveRecord::Migration
  def self.up
    create_table :renters do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :renters
  end
end
