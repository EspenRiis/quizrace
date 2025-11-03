class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms do |t|
      t.string :room_code
      t.references :quiz, null: false, foreign_key: true
      t.integer :host_user_id
      t.integer :status
      t.integer :current_question_index
      t.datetime :started_at
      t.integer :max_players

      t.timestamps
    end
  end
end
