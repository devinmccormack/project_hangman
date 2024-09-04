require 'yaml'

class Game
  attr_accessor :secret_word, :correct_guesses, :incorrect_guesses, :remaining_attempts

  # Initializes the game. Creates the secret word, creates the container for the correct guesses and a container for the
  # incorrect guesses, along with the remaining attempts counting down from 6
  def initialize
    @secret_word = select_random_word
    @correct_guesses = Array.new(@secret_word.length, "_")
    @incorrect_guesses = []
    @remaining_attempts = 6
  end

  # Uses the word list to select a word to be used in the game
  def select_random_word
    words = File.readlines("google-10000-english-no-swears.txt").map(&:chomp)
    words.select { |word| word.length.between?(5, 12) }.sample.downcase
  end

  # Displays the current status of the game, getting and printing information about the current turn in the round using the
  # previously initialized variables
  def display
    puts "\nSecret Word: #{correct_guesses.join(' ')}"
    puts "Incorrect Guesses: #{incorrect_guesses.join(', ')}"
    puts "Remaining Attempts: #{remaining_attempts}"
  end

  # Accepts input from the user. Verifies if the input is a letter and whether or not it counts as a letter that has not been guessed yet.
  # If it receives different input, it will save if requested to save, or start over when play_turn is called again
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

  # Checks whether or not the input is a letter that has not been guessed yet by checking the containers for both kinds of guesses
  def valid_guess?(input)
    input.match?(/^[a-z]$/) && !(@correct_guesses.include?(input) || @incorrect_guesses.include?(input))
  end

  # Adds the letter to the correct guesses if it is found within the secret_word, or adds the letter to the 
  # incorrect guesses and deducts an attempt
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

  # Checks if the user has used all of their attempts already, then checks if the correct guesses spell out the secret word. If either
  # conditions ar met, returns true, otherwise returns false
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

  # Called when player inputs "save" mid-round. Creates a saved game file that can be loaded again in a new instance
  def save_game
    File.open("saved_game.yaml", "w") { |file| file.write(YAML.dump(self)) }
    puts "\nGame saved!"
  end

  # Called when player requests to load the game, taking the saved game file and applying the initialization details to the new round
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
