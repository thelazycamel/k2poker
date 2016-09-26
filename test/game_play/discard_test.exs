defmodule DiscardTest do
  use ExUnit.Case
  doctest K2poker.GamePlay

  setup do
    game_play = K2poker.GamePlay.initialize("thelazycamel", "bob")
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    [game_play: game_play, player1: player1, player2: player2]
  end

  test "players should be able to discard on the :deal", context do
    assert context.game_play.status == :deal
    old_card1 = List.first(context.player1.cards)
    old_card2 = List.last(context.player1.cards)
    game_play = K2poker.GamePlay.discard(context.game_play, "thelazycamel", 0)
    player1 = List.first(game_play.players)
    assert player1.status == :discarded
    assert Enum.any?(player1.cards, fn (x)-> x == old_card1 end) == false
    assert Enum.any?(player1.cards, fn (x)-> x == old_card2 end) == true
    assert Enum.any?(game_play.deck, fn (x)-> x == List.first(player1.cards) end) == false
    assert Enum.count(game_play.deck) == 46
  end

  test "players should be able to discard on the :flop", context do
    game_play = K2poker.GamePlay.play(context.game_play, "thelazycamel")
    |> K2poker.GamePlay.play("bob")
    assert game_play.status == :flop
    old_card1 = List.first(context.player1.cards)
    old_card2 = List.last(context.player1.cards)
    game_play = K2poker.GamePlay.discard(game_play, "thelazycamel", 1)
    player1 = List.first(game_play.players)
    assert player1.status == :discarded
    assert Enum.any?(player1.cards, fn (x)-> x == old_card1 end) == true
    assert Enum.any?(player1.cards, fn (x)-> x == old_card2 end) == false
    assert Enum.any?(game_play.deck, fn (x)-> x == List.last(player1.cards) end) == false
    assert Enum.count(game_play.deck) == 42
  end

  test "players should be able to discard on the :turn", context do
    game_play = K2poker.GamePlay.play(context.game_play, "thelazycamel")
    |> K2poker.GamePlay.play("bob")
    |> K2poker.GamePlay.play("bob")
    |> K2poker.GamePlay.play("thelazycamel")
    assert game_play.status == :turn
    old_card1 = List.first(context.player1.cards)
    old_card2 = List.last(context.player1.cards)
    game_play = K2poker.GamePlay.discard(game_play, "thelazycamel", 1)
    player1 = List.first(game_play.players)
    assert player1.status == :discarded
    assert Enum.any?(player1.cards, fn (x)-> x == old_card1 end) == true
    assert Enum.any?(player1.cards, fn (x)-> x == old_card2 end) == false
    assert Enum.any?(game_play.deck, fn (x)-> x == List.last(player1.cards) end) == false
    assert Enum.count(game_play.deck) == 40
  end

  test "players should be able to only burn on the :river", context do
    game_play = K2poker.GamePlay.play(context.game_play, "thelazycamel")
    |> K2poker.GamePlay.play("bob")
    |> K2poker.GamePlay.play("bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")
    |> K2poker.GamePlay.play("thelazycamel")
    assert game_play.status == :river
    old_card1 = List.first(context.player2.cards)
    old_card2 = List.last(context.player2.cards)
    game_play = K2poker.GamePlay.discard(game_play, "bob", 1)
    player2 = List.last(game_play.players)
    assert player2.status == :discarded
    assert Enum.any?(player2.cards, fn (x)-> x == old_card1 end) == false
    assert Enum.any?(player2.cards, fn (x)-> x == old_card2 end) == false
    assert Enum.any?(game_play.deck, fn (x)-> x == List.last(player2.cards) end) == false
    assert Enum.any?(game_play.deck, fn (x)-> x == List.first(player2.cards) end) == false
    assert Enum.count(game_play.deck) == 37
  end

  test "#discard should only be allowed when players status is new", context do
    game_play = K2poker.GamePlay.play(context.game_play, "thelazycamel")
    |> K2poker.GamePlay.play("bob")
    game_play = K2poker.GamePlay.discard(game_play, "bob", 1)
    player2 = List.last(game_play.players)
    assert player2.status == :discarded
    assert Enum.count(game_play.deck) == 42
    old_card1 = List.first(player2.cards)
    old_card2 = List.last(player2.cards)
    game_play = K2poker.GamePlay.discard(game_play, "bob", 1)
    player2 = List.last(game_play.players)
    assert player2.status == :discarded
    assert old_card1 == List.first(player2.cards)
    assert old_card2 == List.last(player2.cards)
    assert Enum.count(game_play.deck) == 42
  end

  test "should not allow discard at :start" do
    game_play = K2poker.GamePlay.initialize("thelazycamel", "bob")
    game_play = %{game_play | status: :start} #contrived
    assert game_play.status == :start
    game_play = K2poker.GamePlay.discard(game_play, "bob", 0)
    player2 = List.last(game_play.players)
    assert player2.status == :new
  end

end
