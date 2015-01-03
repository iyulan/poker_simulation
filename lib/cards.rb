module Cards
  # масти
  SUITS = [:s, :h, :c, :d]
  # достоинства
  SYMBOLS = [:A, :K, :Q, :J, :T, 9, 8, 7, 6, 5, 4, 3, 2]

  # структура карты
  Struct.new('Card', :symbol, :suit) do
    # в виде 'As'
    def view
      symbol.to_s << suit.to_s
    end
  end

  # колода
  DECK = Cards::SUITS.map do |suit|
    Cards::SYMBOLS.map do |symbol|
      Struct::Card.new(symbol, suit)
    end
  end.flatten

  # размешивание колоды
  def self.shuffle
    DECK.shuffle
  end
end

