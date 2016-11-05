defmodule K2poker.Player do

  #status

  # new       => cards dealt awaiting response
  # discarded => player has discarded
  # ready     => has taken his turn and is now ready

  defstruct [:id, cards: [], status: "ready"]

end

