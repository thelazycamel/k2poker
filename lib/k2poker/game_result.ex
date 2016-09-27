defmodule K2poker.GameResult do

  defstruct [
    id: "",
    status: :in_play,
    cards: [],
    win_description: "",
    lose_description: ""
  ]

end
