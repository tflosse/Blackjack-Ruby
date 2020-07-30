## Console Blackjack

class String
    def black;          "\033[30m#{self}\033[0m" end
    def red;            "\033[31m#{self}\033[0m" end
    def green;          "\033[32m#{self}\033[0m" end
    def brown;          "\033[33m#{self}\033[0m" end
    def blue;           "\033[34m#{self}\033[0m" end
    def magenta;        "\033[35m#{self}\033[0m" end
    def cyan;           "\033[36m#{self}\033[0m" end
    def gray;           "\033[37m#{self}\033[0m" end
  end
  
  class Player 
  
      attr_accessor :name, :bankroll, :hand
  
      def initialize(name, bankroll=100, hand=[])
          @name = name
          @bankroll = bankroll
          @hand = hand
      end
  
  end
  
  class Deck 
  
    @@card_faces = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)
    @@card_suits = %w(Spades Hearts Diamonds Clubs)
  
    attr_accessor :cards
  
    def initialize(cards = [])
      @cards = cards
    end
  
    def create_set(suit)
      set = []
      @@card_faces.map {|x| 
      set << Card.new(x, suit)}
      @cards << set
    end
  
    def full_deck
      deck = []
      @@card_suits.map {|s|
      deck << create_set(s) }
      @cards.flatten!
      @cards.shuffle!
    end
  
  end
  
  class Card < Deck
  
    attr_accessor :face, :suit, :value
    # :value set a attr_accessor rahter than reader to address the value of Ace
  
    def initialize(face, suit="")
      @face = face
      if (2..10).include?(face.to_i)
        @value = face.to_i
      elsif ((face == "Jack")||(face== "Queen")||(face == "King"))
        @value = 10
      elsif (face == "Ace")
        @value = 11
      end
      @suit = suit
    end
  
  end

  
  class Game
  
    attr_accessor :deck, :player_name, :human, :house, :wager, :ace_value, :stand
    attr_reader :hand, :hand_value, :house_hand, :house_value, :house1
  
    def initialize
  
      # Shuffle new deck
      @deck = Deck.new
      @deck.full_deck.to_a
  
      # Get Name + Welcome message
      print "Player name: ".blue
      @player_name = gets.chomp
      puts "Welcome to console Blackjack #{player_name}!"
  
      # Create player and house
      @human = Player.new(@player_name, 100)
      @house = Player.new("House", 10000)
  
    end
  
    # Ask player to start a new Round
    def new_round
      print "New Round? Y/N ".gray
      start = gets.chomp
      if start.upcase == "Y"
        if deck.cards.length < 10
          puts "We'll need a new deck!".brown
          @deck.full_deck.to_a
        end
      get_wager
      end
    end
  
    # Ask player for their bet
    def get_wager
      print "\nYour bankroll: #{human.bankroll}".blue
      print " \nWager? $"
      @wager = gets.chomp.to_i
      if ((wager >= human.bankroll)or(wager<10))
        print "Please enter a number between 10 and #{human.bankroll}".blue
        print "\n$"
        wager = gets.chomp.to_i
        deal
      else deal
      end
    end
  
    def get_hit(stand = false)
      # Determine whether to continue
      print "Card? Y/N ".gray
      hit = gets.chomp
      if hit.upcase == "Y" 
        then house_choice
        deal_hit
      else end_round
        @stand = true
      end
    end
  
    # House's choice
    def house_choice
      if @house_value <= 16
        house_hand << deck.cards.shift()
        if house_hand.any? { |card| card.face == "Ace"}
          if house_value > 10
            @ace_value = 1
          elsif house_value <= 10
            @ace_value = 11
          end
          ace_index = house_hand.find_index { |card| card.face == "Ace"}
          house_hand[ace_index].value = ace_value
        end
        @house_value += @house_hand[-1].value
        puts "Computer hit.".magenta
      end
      if house_value > 21
      end_round
      elsif ((house_value == 21) && (@stand == false))
        get_hit
      end
    end
  
    def deal
  
      # Player's hand
      @hand = [] 
      @hand_value = 0
      hand << deck.cards.shift() << deck.cards.shift()
      hand.each {|card| @hand_value += card.value}
      print "\n"
      hand.each {|card| puts "#{card.face} of #{card.suit}"}
  
      # Deal house's hand
      @house1 = deck.cards.shift()
      @house_hand = [house1] 
      @house_value = 0
      house_hand << deck.cards.shift()
      house_hand.each {|card| @house_value += card.value}
  
      # Outcomes
      if hand_value < 21
        puts "Your hand: #{hand_value}".cyan
        puts "Computer's hand: #{house1.face} of #{house1.suit} + ...".magenta
        get_hit
      elsif hand_value == 21
        puts "That's 21.".green
        puts "Computer's hand: #{house1.face} of #{house1.suit} + ...".magenta
        end_round
      end
  
    end
  
    def deal_hit
  
      # Add new card to player's hand
      hand << deck.cards.shift()
      # Address the case of Ace
      if hand.any? { |card| card.face == "Ace"}
        if @hand_value <= 10
          print "1 or 11?".cyan
          @ace_value = gets.chomp.to_i
        elsif @hand_value > 10
          @ace_value = 1
        end
        ace_index = hand.find_index { |card| card.face == "Ace"}
        hand[ace_index].value = ace_value
      end
  
      @hand_value += hand[-1].value
      print "\n"
      hand.each {|card| puts "#{card.face} of #{card.suit}"}
  
      #Address scenarios
      if hand_value < 21
        puts "Your hand: #{hand_value}".cyan
        house_choice
        get_hit
      elsif hand_value == 21
        puts "That's 21.".green
        house_choice
        end_round
      elsif hand_value > 21
        puts "#{hand_value}. BUST!".red
        end_round
      else get_hit
      end
  
    end
  
    def end_round
  
      # House at 16
      if @house_value <= 16
        house_choice
      end
  
      # Outcomes
      if hand_value > 21
        human.bankroll -= wager
        puts "Your bankroll is now #{human.bankroll}".red
      elsif house_value > 21
        human.bankroll += wager
        puts "House Bust! Your bankroll is now #{human.bankroll}".green
      elsif hand_value == house_value
        puts "It's a tie."
      elsif hand_value > house_value
        puts "\nThe computer got: #{@house_value}"
        house_hand.each {|card| puts "#{card.face} of #{card.suit}"}
        human.bankroll += wager
        puts "\nYou beat the computer. Your bankroll is now #{human.bankroll}".green
        house.bankroll -= wager
      elsif hand_value < house_value
        puts "\nThe computer got: #{@house_value}"
        house_hand.each {|card| puts "#{card.face} of #{card.suit}"}
        human.bankroll -= wager
        puts "\nThe computer beat you. Your bankroll is now #{human.bankroll}".red
      end
  
      new_round
  
    end
  
  end
  
  new_game = Game.new
  new_game.new_round
    