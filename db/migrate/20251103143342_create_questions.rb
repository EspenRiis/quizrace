class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.text :sentence
      t.integer :question_type
      t.integer :time_limit
      t.integer :points
      t.integer :question_number
      t.string :correct_answer
      t.json :possible_answers

      t.timestamps
    end
  end
end
