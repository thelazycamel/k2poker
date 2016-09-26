defmodule FlopTest do
  use ExUnit.Case
  doctest K2poker.GamePlay

  setup do
    game_play = K2poker.GamePlay.initialize("thelazycamel", "bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    [game_play: game_play, player1: player1, player2: player2]
  end

  test "game_play should move onto the flop when players are ready", context do
    assert context.game_play.status == :flop
  end

  test "there should be 44 cards left in the deck", context do
    assert Enum.count(context.game_play.deck) == 44
  end

  test "there should be 3 table cards", context do
    assert Enum.count(context.game_play.table_cards) == 3
  end

  test "player 1 status should be set to new, and they should have 2 cards", context do
    assert context.player1.id == "thelazycamel"
    assert context.player1.status == :new
    assert Enum.count(context.player1.cards) == 2
  end

  test "player 2 status should be set to new, and they should have 2 cards", context do
    assert context.player2.status == :new
    assert context.player2.id == "bob"
    assert Enum.count(context.player2.cards) == 2
  end

end
