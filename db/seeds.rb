# Clear existing data
puts "Clearing existing data..."
Answer.destroy_all
Player.destroy_all
Room.destroy_all
Question.destroy_all
Quiz.destroy_all

puts "Creating sample quizzes..."

# Sample Quiz 1: General Knowledge
quiz1 = Quiz.create!(
  name: "General Knowledge Challenge",
  created_by_id: 1
)

Question.create!([
  {
    quiz: quiz1,
    sentence: "The Earth is flat.",
    question_type: :true_false,
    time_limit: 10,
    points: 100,
    question_number: 1,
    correct_answer: "false",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz1,
    sentence: "What is the capital of France?",
    question_type: :multiple_choice,
    time_limit: 15,
    points: 150,
    question_number: 2,
    correct_answer: "Paris",
    possible_answers: ["London", "Paris", "Berlin", "Madrid"]
  },
  {
    quiz: quiz1,
    sentence: "How many continents are there?",
    question_type: :multiple_choice,
    time_limit: 12,
    points: 120,
    question_number: 3,
    correct_answer: "7",
    possible_answers: ["5", "6", "7", "8"]
  },
  {
    quiz: quiz1,
    sentence: "The Great Wall of China is visible from space.",
    question_type: :true_false,
    time_limit: 10,
    points: 100,
    question_number: 4,
    correct_answer: "false",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz1,
    sentence: "What is the largest ocean on Earth?",
    question_type: :multiple_choice,
    time_limit: 15,
    points: 150,
    question_number: 5,
    correct_answer: "Pacific Ocean",
    possible_answers: ["Atlantic Ocean", "Pacific Ocean", "Indian Ocean", "Arctic Ocean"]
  }
])

quiz1.update!(questions_count: quiz1.questions.count)
puts "Created quiz: #{quiz1.name} with #{quiz1.questions_count} questions"

# Sample Quiz 2: Technology
quiz2 = Quiz.create!(
  name: "Tech Trivia",
  created_by_id: 1
)

Question.create!([
  {
    quiz: quiz2,
    sentence: "HTML stands for HyperText Markup Language.",
    question_type: :true_false,
    time_limit: 8,
    points: 100,
    question_number: 1,
    correct_answer: "true",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz2,
    sentence: "Who founded Apple Inc.?",
    question_type: :multiple_choice,
    time_limit: 15,
    points: 150,
    question_number: 2,
    correct_answer: "Steve Jobs",
    possible_answers: ["Bill Gates", "Steve Jobs", "Elon Musk", "Mark Zuckerberg"]
  },
  {
    quiz: quiz2,
    sentence: "What year was the first iPhone released?",
    question_type: :multiple_choice,
    time_limit: 15,
    points: 150,
    question_number: 3,
    correct_answer: "2007",
    possible_answers: ["2005", "2006", "2007", "2008"]
  },
  {
    quiz: quiz2,
    sentence: "JavaScript and Java are the same programming language.",
    question_type: :true_false,
    time_limit: 10,
    points: 100,
    question_number: 4,
    correct_answer: "false",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz2,
    sentence: "What does CPU stand for?",
    question_type: :multiple_choice,
    time_limit: 12,
    points: 120,
    question_number: 5,
    correct_answer: "Central Processing Unit",
    possible_answers: [
      "Central Processing Unit",
      "Computer Personal Unit",
      "Central Program Utility",
      "Computer Processing Unit"
    ]
  },
  {
    quiz: quiz2,
    sentence: "Which company developed the Android operating system?",
    question_type: :multiple_choice,
    time_limit: 15,
    points: 150,
    question_number: 6,
    correct_answer: "Google",
    possible_answers: ["Apple", "Google", "Microsoft", "Samsung"]
  }
])

quiz2.update!(questions_count: quiz2.questions.count)
puts "Created quiz: #{quiz2.name} with #{quiz2.questions_count} questions"

# Sample Quiz 3: Quick Fire Round
quiz3 = Quiz.create!(
  name: "Quick Fire Round",
  created_by_id: 1
)

Question.create!([
  {
    quiz: quiz3,
    sentence: "2 + 2 = 5",
    question_type: :true_false,
    time_limit: 5,
    points: 50,
    question_number: 1,
    correct_answer: "false",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz3,
    sentence: "Water boils at 100°C at sea level.",
    question_type: :true_false,
    time_limit: 5,
    points: 50,
    question_number: 2,
    correct_answer: "true",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz3,
    sentence: "The sun rises in the west.",
    question_type: :true_false,
    time_limit: 5,
    points: 50,
    question_number: 3,
    correct_answer: "false",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz3,
    sentence: "Cats are mammals.",
    question_type: :true_false,
    time_limit: 5,
    points: 50,
    question_number: 4,
    correct_answer: "true",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz3,
    sentence: "A triangle has four sides.",
    question_type: :true_false,
    time_limit: 5,
    points: 50,
    question_number: 5,
    correct_answer: "false",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz3,
    sentence: "The moon orbits the Earth.",
    question_type: :true_false,
    time_limit: 5,
    points: 50,
    question_number: 6,
    correct_answer: "true",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz3,
    sentence: "Fire is cold.",
    question_type: :true_false,
    time_limit: 5,
    points: 50,
    question_number: 7,
    correct_answer: "false",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz3,
    sentence: "Birds can fly.",
    question_type: :true_false,
    time_limit: 5,
    points: 50,
    question_number: 8,
    correct_answer: "true",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz3,
    sentence: "Ice is hot.",
    question_type: :true_false,
    time_limit: 5,
    points: 50,
    question_number: 9,
    correct_answer: "false",
    possible_answers: ["true", "false"]
  },
  {
    quiz: quiz3,
    sentence: "Humans need oxygen to breathe.",
    question_type: :true_false,
    time_limit: 5,
    points: 50,
    question_number: 10,
    correct_answer: "true",
    possible_answers: ["true", "false"]
  }
])

quiz3.update!(questions_count: quiz3.questions.count)
puts "Created quiz: #{quiz3.name} with #{quiz3.questions_count} questions"

puts "\nSeed data created successfully!"
puts "Total quizzes: #{Quiz.count}"
puts "Total questions: #{Question.count}"
puts "\nYou can now create a room and start playing!"
