require './lib/cards.rb'
require './lib/hands.rb'
# класс для симуляции игры(одной раздачи)
class Game
  ROUNDS = { flop: 3, turn: 1, river: 1 }

  attr_reader :board, :state

  def initialize(players_count, type = :holdem)
    @deck = Cards.shuffle
    @board = Struct::Board.new([])
    @state = []
    @type = type
    @players_count = players_count
  end

  # раздача карманных карт
  def dealt
    Hands::GAMETYPES[@type].times do |round|
      @players_count.times do |player|
        @state[player] = Struct::Hand.new([]) if round == 0
        @state[player].cards << @deck.pop
      end
    end
    @state
  end

  # методы для флопа/терна/ривера
  ROUNDS.each do |name, card_size|
    define_method(name) do
      new_cards = @deck.pop(card_size)
      @board.cards << new_cards
      @board.cards.flatten!
      new_cards.map { |c| c.view }
    end
  end

  # определяем победителя по вскрытию
  def showdown
    max_rank = @state.map do |player|
      Hands.rank(player, @board, @type)[:rank]
    end.max
    s = @state.select do |player|
      Hands.rank(player, @board, @type)[:rank] == max_rank
    end.sort do |a, b|
      Hands.rank(a, @board, @type)[:weight] <=> Hands.rank(b, @board, @type)[:weight]
    end.last
    { hands: @state.map{|h| h.cards.map { |c| c.view }},
      board: @board.cards_view,
      winner: @state.index(s) + 1,
      handname: Hands.rank(s, @board, @type)[:handname] }
  end
end


# симуляция раздачи
def simulation_game(cnt, type)
  g = Game.new(cnt, type)
  g.dealt
  g.flop
  g.turn
  g.river
  puts g.showdown
end

simulation_game(6, :holdem)

