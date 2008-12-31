class CreatePrecepts < ActiveRecord::Migration
  def self.up
    create_table :precepts do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :precepts
  end
end
