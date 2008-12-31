class CreateRoomAreas < ActiveRecord::Migration
  def self.up
    create_table :room_areas do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :room_areas
  end
end
