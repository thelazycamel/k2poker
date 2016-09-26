defmodule TurnTest do
  use ExUnit.Case
  doctest K2poker.GamePlay

  test "#next_turn should not turn when players are not ready" do
    game_play = K2poker.GamePlay.initialize("thelazycamel", "bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")
    assert(game_play.status == :flop)
    assert Enum.count(game_play.deck) == 44
    assert game_play.status == :flop
  end

  setup do
    game_play = K2poker.GamePlay.initialize("thelazycamel", "bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    [game_play: game_play, player1: player1, player2: player2]
  end

  test "game should move onto the turn when players are ready", context do
    assert context.game_play.status == :turn
  end

  test "the deck should have 42 cards (without discards)", context do
    assert Enum.count(context.game_play.deck) == 42

  end

  test "the table cards should have 4 cards", context do
    assert Enum.count(context.game_play.table_cards) == 4
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

