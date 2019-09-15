# Commit 1 - Psuedocode

# psuedocode for initialize

# psuedocode for sides

# psuedocode for roll

# Commit 2 and 4 - Initial Solution

class Die
  attr_reader :sides

  def initialize(sides)
    @sides = sides
  end

  def roll
    rand(1..@sides)
  end

  def sides=(sides)
    unless sides.positive?
      raise ArgumentError.new('only positive number of sides allowed')
    end
  end
end

class DiceCup < Die
  attr_reader :dices, :test

  def initialize(game_type)
    @dice = []
    game_type = game_type.downcase
    init_dnd_dice if game_type == 'dnd'
  end

  def init_dnd_dice
    4.times { @dices << Die.new(6) }
    2.times { @dices << Die.new(8) }
    4.times { @dices << Die.new(4) }
    @dice << Die.new(20)
  end

  def init_yahtzee_dice
    30.times { @dice << Die.new(6) }
  end

  def roll
    @dice.each { |die| p die.roll }
  end
end

class Yahtzee < Die
  def initialize
    @roll_results = []
    @dice = []
    @upper_section = {}
    @lower_section = {}
    @game_state = 'rolling'
    @reroll_count = 0

    init_dice
    init_upper_section
    init_lower_section

    @grand_total = 0
  end

  def init_upper_section
    @upper_section = {
      aces: ' ',
      twos: ' ',
      threes: ' ',
      fours: ' ',
      fives: ' ',
      sixes: ' ',
      bonus: 0,
      total: 0
    }
  end

  def init_lower_section
    @lower_section = {
      three_of_a_kind: ' ',
      four_of_a_kind: ' ',
      full_house: ' ',
      sm_straight: ' ',
      lg_straight: ' ',
      yahtzee: ' ',
      chance: ' ',
      yahtzee_bonus: 0,
      total: 0
    }
  end

  def init_dice
    5.times { @dice << Die.new(6) }
  end

  def play
    roll('abcde')
    loop do
      clear_screen
      display_game
      break if game_over?
      case @game_state
      when 'rolling' then rolling
      when 'rerolling' then rerolling
      when 'scoring' then scoring
      when 'end of turn' then end_of_turn
      else
        puts "Invalid input #{@game_state}"
        break
      end
    end
    clear_screen
    update_totals
    display_game
    puts 'Thanks for playing!'
  end

  def roll(die_letters)
    die_letters.chars.each do |letter|
      case letter
      when 'a' then @roll_results[0] = rand(1..6)
      when 'b' then @roll_results[1] = rand(1..6)
      when 'c' then @roll_results[2] = rand(1..6)
      when 'd' then @roll_results[3] = rand(1..6)
      when 'e' then @roll_results[4] = rand(1..6)
      end
    end
  end

  def clear_screen
    50.times { puts }
  end

  def display_game
    aces = @upper_section[:aces]
    twos = @upper_section[:twos]
    threes = @upper_section[:threes]
    fours = @upper_section[:fours]
    fives = @upper_section[:fives]
    sixes = @upper_section[:sixes]
    upp_bonus = @upper_section[:bonus]
    upp_total = @upper_section[:total]

    three_of_a_kind = @lower_section[:three_of_a_kind]
    four_of_a_kind = @lower_section[:four_of_a_kind]
    full_house = @lower_section[:full_house]
    sm_straight = @lower_section[:sm_straight]
    lg_straight = @lower_section[:lg_straight]
    yahtzee = @lower_section[:yahtzee]
    chance = @lower_section[:chance]
    lower_bonus = @lower_section[:yahtzee_bonus]
    lower_total = @lower_section[:total]

    puts [
          ["--------------------------"],
          ["      -- COMMANDS --      "],
          ["--------------------------"],
          [''],
          ["rolls to change: \"abc\" changes dice a b and c"],
          ["  place a score: \"1\" picks Aces and \"a\" picks 3 of a kind"],
          [''],
          ["--------------------------\t--------------------------"],
          ["   -- UPPER SECTION --    \t   -- LOWER SECTION --    "],
          ["--------------------------\t--------------------------"],
          ["1 - Aces  \t\t#{aces}     \ta - 3 of a kind \t#{three_of_a_kind} "],
          ["2 - Twos  \t\t#{twos}     \tb - 4 of a kind \t#{four_of_a_kind} "],
          ["3 - Threes\t\t#{threes}   \tc - Full House  \t#{full_house} "],
          ["4 - Fours \t\t#{fours}    \td - Sm Straight \t#{sm_straight}"],
          ["5 - Fives \t\t#{fives}    \te - Lg. Straight\t#{lg_straight}"],
          ["6 - Sixes \t\t#{sixes}    \tf - Yahtzee     \t#{yahtzee} "],
          ["                          \tg - Chance      \t#{chance} "],
          ["--------------------------\t--------------------------"],
          ["BONUS     \t\t#{upp_bonus}\tYahtzee Bonus   \t#{lower_bonus}"],
          ["TOTAL     \t\t#{upp_total}\tTOTAL           \t#{lower_total}"],
          ["--------------------------\t--------------------------"],
          [''],
          ["GRAND TOTAL: #{@grand_total} "],
          [''],
          ['ROLL'],
          ["A - #{@roll_results[0]}"],
          ["B - #{@roll_results[1]}"],
          ["C - #{@roll_results[2]}"],
          ["D - #{@roll_results[3]}"],
          ["E - #{@roll_results[4]}"],
          ['']
        ]
  end

  def rolling
    return @game_state = 'scoring' if @reroll_count == 2

    print 'Reroll? (y)es (n)o: '
    person_input = gets.chomp.downcase
    person_input = person_input.downcase
    @game_state = if person_input == 'y'
                    'rerolling'
                  elsif person_input == 'n'
                    'scoring'
                  else
                    'rolling'
                  end
  end

  def rerolling
    print 'rolls to change: '
    selected_die = gets.chomp
    selected_die = selected_die.downcase
    selected_die = selected_die.delete('^a-e')
    selected_die = selected_die.split('')
    selected_die = selected_die.uniq
    selected_die = selected_die.join
    roll(selected_die)
    @reroll_count += 1
    @game_state = 'rolling'
  end

  def scoring
    @reroll_count = 0
    print 'Place your score: '
    person_input = gets.chomp.downcase
    if valid_input?(person_input)
      input_to_upper_section(person_input) if number?(person_input)
      input_to_lower_section(person_input) if letter?(person_input)
      @game_state = 'end of turn'
    end
  end

  def valid_input?(input)
    key = if number?(input)
            num_to_upper_section_key(input.to_i)
          elsif letter?(input)
            letter_to_lower_section_key(input)
          end
    input.match(/[a-i1-9]/) && input.length == 1 && (upper_score_empty?(key) || lower_score_empty?(key))
  end

  def upper_score_empty?(key)
    @upper_section[key] == ' '
  end

  def lower_score_empty?(key)
    @lower_section[key] == ' '
  end

  def number?(input)
    input.match(/\d/)
  end

  def letter?(input)
    input.match(/[a-z]/)
  end

  def input_to_upper_section(number)
    number = number.to_i
    number_occurence = @roll_results.count(number)
    score = number * number_occurence
    key = num_to_upper_section_key(number)
    @upper_section[key] = score
  end

  def num_to_upper_section_key(num)
    case num
    when 1 then :aces
    when 2 then :twos
    when 3 then :threes
    when 4 then :fours
    when 5 then :fives
    when 6 then :sixes
    else :invalid
    end
  end

  def letter_to_lower_section_key(letter)
    case letter
    when 'a' then :three_of_a_kind
    when 'b' then :four_of_a_kind
    when 'c' then :full_house
    when 'd' then :sm_straight
    when 'e' then :lg_straight
    when 'f' then :yahtzee
    when 'g' then :chance
    else :invalid
    end
  end

  def input_to_lower_section(letter)
    case letter
    when 'a' then num_of_a_kind(3, :three_of_a_kind) 
    when 'b' then num_of_a_kind(4, :four_of_a_kind)
    when 'c' then full_house
    when 'd' then sm_straight
    when 'e' then lg_straight
    when 'f' then yahtzee
    when 'g' then chance
    else invalid_input
    end
  end

  def num_of_a_kind(input_num, key)
    return @lower_section[key] = 0 if @roll_results.select { |roll| @roll_results.count(roll) == input_num }.empty?

    @lower_section[key] = @roll_results.sum
  end

  def full_house
    return @lower_section[:full_house] = 0 unless @roll_results.select { |roll| @roll_results.count(roll) == 3 || @roll_results.count(roll) == 2 }.length == 5

    @lower_section[:full_house] = 25
  end

  def sm_straight
    return @lower_section[:sm_straight] = 0 unless @roll_results.uniq.length >= 4

    @lower_section[:sm_straight] = 30
  end

  def lg_straight
    return @lower_section[:lg_straight] = 0 unless @roll_results.uniq.length == 5

    @lower_section[:lg_straight] = 40
  end

  def yahtzee
    return @lower_section[:yahtzee] = 0 unless same_values?(@roll_results)

    if @lower_section[:yahtzee] == ' '
      @lower_section[:yahtzee] = 50
    else
      @lower_section[:yahtzee_bonus] += 100

    end
  end

  def same_values?(arr)
    arr.uniq.length == 1
  end

  def chance
    @lower_section[:chance] = @roll_results.sum
  end

  def update_totals
    @upper_section[:total] = total(@upper_section)
    if @upper_section[:total] >= 65 && @upper_section[:bonus] == 0
      @upper_section[:bonus] = 35
      @upper_section[:total] += 35
    end
    @lower_section[:total] = total(@lower_section)
    @grand_total = @upper_section[:total] + @lower_section[:total]
  end

  def total(section)
    upper_total = 0
    section.each do |key, value|
      next if key == :total

      value = 0 if value == ' '
      upper_total += value
    end
    upper_total
  end

  def game_over?
    @upper_section.select { |key, value| value == ' ' }.empty? && @lower_section.select{ |key,value| value == ' ' }.empty?
  end

  def end_of_turn
    clear_screen
    update_totals
    display_game
    print 'Press any key to roll again '
    gets.chomp
    roll('abcde')
    @game_state = 'rolling'
  end
end
# create your Die class here

# Commit 3 - Write Runner Code / Tests

yahtzee = Yahtzee.new

yahtzee.play