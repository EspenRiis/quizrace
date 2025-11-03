class CreatePlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :players do |t|
      t.references :room, null: false, foreign_key: true
      t.string :username
      t.string :avatar
      t.integer :score
      t.integer :position
      t.string :uuid
      t.string :player_secret

      t.timestamps
    end
  end
end
