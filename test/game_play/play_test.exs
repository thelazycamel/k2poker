defmodule GamePlay.PlayTest do
  use ExUnit.Case
  doctest K2poker.GamePlay

  test "#play should update player 1s status to :ready" do
    game_play = K2poker.GamePlay.new("thelazycamel", "bob")
    game_play = K2poker.GamePlay.play(game_play, "thelazycamel")
    assert List.first(game_play.players).status == "ready"
    assert List.last(game_play.players).status == "new"
  end

  test "#play should update player 2s status to :ready" do
    game_play = K2poker.GamePlay.new("thelazycamel", "bob")
    game_play = K2poker.GamePlay.play(game_play, "bob")
    assert List.first(game_play.players).status == "new"
    assert List.last(game_play.players).status == "ready"
  end

  setup do
    game_play = K2poker.GamePlay.new("thelazycamel", "bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    [game_play: game_play, player1: player1, player2: player2]
  end

  test "#play should automatically action the next turn (flop) if both players are ready", context do
    assert context.game_play.status == "flop"
    assert Enum.count(context.game_play.table_cards) == 3
    assert Enum.count(context.game_play.deck) == 44
  end

  test "player 1 status should be set to new, and they should have 2 cards", context do
    assert context.player1.id == "thelazycamel"
    assert context.player1.status == "new"
    assert Enum.count(context.player1.cards) == 2
  end

  test "player 2 status should be set to new, and they should have 2 cards", context do
    assert context.player2.status == "new"
    assert context.player2.id == "bob"
    assert Enum.count(context.player2.cards) == 2
  end

end
