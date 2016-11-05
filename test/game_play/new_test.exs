defmodule GamePlay.NewTest do
  use ExUnit.Case
  doctest K2poker.GamePlay

  setup do
    game_play = K2poker.GamePlay.new("thelazycamel", "bob")
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    [game_play: game_play, player1: player1, player2: player2]
  end

  test "should initialize a new game with a deck of 52 (dealing 2 cards to each player)", context do
    assert( (
        Enum.count(context.game_play.deck) +
        Enum.count(context.player1.cards) +
        Enum.count(context.player2.cards)
      )  == 52 )
  end

  test "there should be no table cards yet", context do
    assert Enum.count(context.game_play.table_cards) == 0
  end

  test "the game status should be set to :deal", context do
    assert context.game_play.status == "deal"
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
