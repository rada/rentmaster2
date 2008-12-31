class CreatePenaltyHistories < ActiveRecord::Migration
  def self.up
    create_table :penalty_histories do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :penalty_histories
  end
end
