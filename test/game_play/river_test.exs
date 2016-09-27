defmodule GamePlay.RiverTest do
  use ExUnit.Case
  doctest K2poker.GamePlay

  test "#next_turn should not goto to river when players are not ready" do
    game_play = K2poker.GamePlay.new("thelazycamel", "bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")
    assert(game_play.status == :turn)
    assert Enum.count(game_play.deck) == 42
    assert game_play.status == :turn
  end

  setup do
    game_play = K2poker.GamePlay.new("thelazycamel", "bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    [game_play: game_play, player1: player1, player2: player2]
  end

  test "game should move onto the river when players are ready", context do
    assert context.game_play.status == :river
  end

  test "there should be 5 table cards on the river", context do
    assert Enum.count(context.game_play.table_cards) == 5
  end

  test "there should be 40 cards left in the deck (with no discards)", context do
    assert Enum.count(context.game_play.deck) == 40
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
