defmodule GamePlay.DealTest do
  use ExUnit.Case
  doctest K2poker.GamePlay

  setup do
    game_play = K2poker.GamePlay.new("thelazycamel", "bob")
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    [game_play: game_play, player1: player1, player2: player2]
  end

  test "#next_turn should deal when current game status is :start", context do
    assert context.game_play.status == :deal
  end

  test "the deck should have 48 cards", context do
    assert Enum.count(context.game_play.deck) == 48
  end

  test "the players cards should not still be in the deck", context do
    assert Enum.any?(context.game_play.deck, fn x -> x == List.first(context.player1.cards) end) == false
    assert Enum.any?(context.game_play.deck, fn x -> x == List.last(context.player1.cards) end) == false
    assert Enum.any?(context.game_play.deck, fn x -> x == List.first(context.player2.cards) end) == false
    assert Enum.any?(context.game_play.deck, fn x -> x == List.last(context.player2.cards) end) == false
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

