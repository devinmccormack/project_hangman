require 'yaml'

class Game
  attr_accessor :secret_word, :correct_guesses, :incorrect_guesses, :remaining_attempts

  def initialize
    @secret_word = select_random_word
    @correct_guesses = Array.new(@secret_word.length, "_")
    @incorrect_guesses = []
    @remaining_attempts = 6
  end

  def select_random_word
    words = File.readlines("google-10000-english-no-swears.txt").map(&:chomp)
    words.select { |word| word.length.between?(5, 12) }.sample.downcase
  end

  def display
    puts "\nSecret Word: #{correct_guesses.join(' ')}"
    puts "Incorrect Guesses: #{incorrect_guesses.join(', ')}"
    puts "Remaining Attempts: #{remaining_attempts}"
  end

  def play_turn
    puts "\nEnter a letter to guess or type 'save' to save the game:"
    input = gets.chomp.downcase
    if input == 'save'
      save_game
    elsif valid_guess?(input)
      process_guess(input)
    else
      puts "Invalid input, please guess a single letter."
    end
  end

  def valid_guess?(input)
    input.match?(/^[a-z]$/) && !(@correct_guesses.include?(input) || @incorrect_guesses.include?(input))
  end

  def process_guess(letter)
    if secret_word.include?(letter)
      secret_word.chars.each_with_index do |char, index|
        correct_guesses[index] = letter if char == letter
      end
    else
      @incorrect_guesses << letter
      @remaining_attempts -= 1
    end
  end

  def game_over?
    if @remaining_attempts <= 0
      puts "\nYou lost! The secret word was: #{secret_word}"
      true
    elsif @correct_guesses.join == @secret_word
      puts "\nCongratulations! You've guessed the word: #{secret_word}"
      true
    else
      false
    end
  end

  def save_game
    File.open("saved_game.yaml", "w") { |file| file.write(YAML.dump(self)) }
    puts "\nGame saved!"
  end

  def self.load_game
    if File.exist?("saved_game.yaml")
      YAML.safe_load(File.read("saved_game.yaml"), permitted_classes: [Game], aliases: true)
    else
      puts "No saved game found."
      nil
    end
  end
end

# Main Game Loop
puts "Welcome to Hangman!"
puts "Type 'new' to start a new game or 'load' to load an existing game."
choice = gets.chomp.downcase

game = if choice == 'load'
         Game.load_game || Game.new
       else
         Game.new
       end

until game.game_over?
  game.display
  game.play_turn
end
