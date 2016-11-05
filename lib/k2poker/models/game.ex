defmodule K2poker.Game do

  # status types:
  # start
  # deal
  # flop
  # turn
  # river
  # finished

  defstruct [
    players: [%K2poker.Player{}, %K2poker.Player{}],
    table_cards: [],
    deck: [],
    status: "start",
    result: %K2poker.GameResult{}
  ]

end
