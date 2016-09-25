defmodule K2poker.Game do

  #status types:
  # :start
  # :deal
  # :flop
  # :turn
  # :river
  # :finish

  defstruct [
    players: [],
    table_cards: [],
    deck: [],
    status: :start
  ]

end
