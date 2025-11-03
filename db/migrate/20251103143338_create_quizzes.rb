class CreateQuizzes < ActiveRecord::Migration[7.1]
  def change
    create_table :quizzes do |t|
      t.string :name
      t.integer :questions_count
      t.integer :created_by_id

      t.timestamps
    end
  end
end
