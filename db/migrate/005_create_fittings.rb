class CreateFittings < ActiveRecord::Migration
  def self.up
    create_table :fittings do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :fittings
  end
end
