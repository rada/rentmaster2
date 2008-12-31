class CreateAccommodationHistories < ActiveRecord::Migration
  def self.up
    create_table :accommodation_histories do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :accommodation_histories
  end
end
