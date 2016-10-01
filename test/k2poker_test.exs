defmodule K2pokerTest do
  use ExUnit.Case
  doctest K2poker

  # The base module has helper methods to the only required methods
  # in K2poker.GamePlay, so as a convenience we can start and play
  # a game with game = K2poker.new("bob", "stu") etc

  test "K2poker.new/2 starts a new game" do
    game = K2poker.new("bob", "stu")
    assert game.status == :deal
  end

  test "K2poker.play/2 continues play" do
    game = K2poker.new("bob", "stu")
    game = K2poker.play(game, "stu")
    assert List.last(game.players).status == :ready
  end

  test "K2poker.discard/3 discards the given card" do
    game = K2poker.new("bob", "stu")
    old_card = List.first(List.last(game.players).cards)
    game = K2poker.discard(game, "stu", 0)
    new_card = List.first(List.last(game.players).cards)
    refute old_card == new_card
    assert Enum.count(game.deck) == 46
  end

  test "K2poker.fold/2 finished the game with player folded" do
    game = K2poker.new("bob", "stu")
    game = K2poker.fold(game, "stu")
    assert List.last(game.players).status == :folded
    assert game.status == :finished
  end

end
