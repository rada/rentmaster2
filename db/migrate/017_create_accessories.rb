class CreateAccessories < ActiveRecord::Migration
  def self.up
    create_table :accessories do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :accessories
  end
end
