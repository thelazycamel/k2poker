defmodule K2poker.Game do

  #status types:
  # :start
  # :deal
  # :flop
  # :turn
  # :river
  # :finish

  # TODO could players be a map, would be easier to find them by id, however need to check
  # positioning for dealing out the cards
  #
  defstruct [
    players: [],
    table_cards: [],
    deck: [],
    status: :start,
    result: %K2poker.GameResult{}
  ]

end
