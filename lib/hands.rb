#require 'cards.rb'
module Hands
  GAMETYPES = { holdem: 2, omaha: 4 }

  COMBINATIONSIZE = 5

  # веса комбинаций
  HANDRANKS = { straight_flush: 522,
                four_of_a_kind: 410,
                full_house: 320,
                flush: 318,
                straight: 315,
                three_of_a_kind: 311,
                two_pair: 221,
                one_pair: 211,
                high_card: 111 }

  # структура руки
  Struct.new('Hand', :cards) do
    # в виде ['As', 'Kh']
    def cards_view
      cards.map { |card| card.view }
    end
  end

  # доска
  Struct.new('Board', :cards) do
    # в виде ['As', 'Kh', 'Qs', 'Jh', 'Ts']
    def cards_view
      cards.map { |card| card.view }
    end
  end

  # структура комбинации
  Struct.new('Combination', :cards) do
    # в виде ['As', 'Kh', 'Qs', 'Jh', 'Ts']
    def cards_view
      cards.map { |card| card.view }
    end

    # сортировка карт комбинации по достоинству или масти
    def cards_sort!(type = :suit)
      consts = Cards.const_get("#{type.to_s.upcase}S")
      cards.sort! { |a, b| consts.index(a[type]) <=> consts.index(b[type]) }
    end

    # методы для получения хэша вида масть(достоинство) => кол-во
    %w(suits symbols).each do |action|
      define_method(action + '_hash') do
        hash = Hash.new(0)
        cards.each { |c| hash[c[action[0..-2]]] += 1 }
        hash
      end
    end

    # "вес" комбинации по достоинству
    # чтобы определить старшую при совпадении комбинации по типу
    # например, флэш от туза должна быть старше
    # флэша от короля
    def symbols_sum
      cards_sort!(:symbol).each.with_index.reduce(0) do |sum, (card, index)|
        weight = (Cards::SYMBOLS.size**(COMBINATIONSIZE - index - 1))
        sum += weight * Cards::SYMBOLS.reverse.index(card.symbol)
      end
    end

    # вычислении типа комбинации
    def weight
      weight = (symbols_hash.values + [0]).sort.reverse[0..2].join('').to_i
      if weight == 111
        array = cards_sort!(:symbol).map{|c| Cards::SYMBOLS.index(c.symbol)}
        # проверка на стрит
        weight += 204 if (array.each_cons(2).map {|x,y| y - x == 1}.all? || array == [0, 9, 10, 11, 12])
        # проверка на флэш
        weight += 207 if suits_hash.keys.size == 1
      end
      weight
    end
  end

  # вычислении старшой комбинации
  def self.rank(hand, board, game = :holdem)
    combinations = case game
    when :holdem
      (hand.cards + board.cards).combination(COMBINATIONSIZE).to_a.map do |c|
        Struct::Combination.new(c)
      end
    when :omaha
      combinations = hand.cards.combination(2).to_a.map do |hand_card|
        board.cards.combination(3).to_a.map do |board_card|
          Struct::Combination.new([hand_card, board_card].flatten)
        end
      end.flatten(1)
    end
    max_weight = combinations.map{|comb| comb.weight}.max
    win_comb = combinations.select{|comb| comb.weight == max_weight}.sort{|c1,c2| c1.symbols_sum<=>c2.symbols_sum}.last
    {rank: max_weight, weight: win_comb.symbols_sum, combination: win_comb.cards_sort!(:symbol), handname: HANDRANKS.invert[max_weight]}
  end
end
