class CreateAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :answers do |t|
      t.references :room, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.string :answer
      t.float :time_taken
      t.boolean :correct

      t.timestamps
    end
  end
end
