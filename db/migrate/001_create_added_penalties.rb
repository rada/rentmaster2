class CreateAddedPenalties < ActiveRecord::Migration
  def self.up
    create_table :added_penalties do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :added_penalties
  end
end
