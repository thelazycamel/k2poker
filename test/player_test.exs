defmodule PlayerTest do
  use ExUnit.Case
  doctest K2poker.Player

  test "it should hold an id, position and list of cards" do
    player = %K2poker.Player{id: "abc123", cards: ["Ks", "2h"]}
    assert player.id == "abc123"
    assert player.cards == ["Ks", "2h"]
  end

end
