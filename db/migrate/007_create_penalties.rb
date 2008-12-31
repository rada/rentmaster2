class CreatePenalties < ActiveRecord::Migration
  def self.up
    create_table :penalties do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :penalties
  end
end
