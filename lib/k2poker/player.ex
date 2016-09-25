defmodule K2poker.Player do

  #status

  #new => cards dealt awaiting response
  #ready => has taken his turn and is now ready

  #TODO consider cards as list of tuples [{card1: "As"}, {card2: "Ad"}] ?
  # or make sure the list does not mutate (swap places)

  defstruct [:id, cards: [], status: :ready]

end

