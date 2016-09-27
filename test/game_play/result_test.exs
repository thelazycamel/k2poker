defmodule GamePlay.ResultTest do
  use ExUnit.Case
  doctest K2poker.GamePlay

  setup do
    game_play = K2poker.GamePlay.new("thelazycamel", "bob")
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")          #flop
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")          #turn
    |> K2poker.GamePlay.play("thelazycamel")
    |> K2poker.GamePlay.play("bob")          #river
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    [game_play: game_play, player1: player1, player2: player2]
  end

  test "game status should be set to :finished", context do
    game_play = K2poker.GamePlay.play(context.game_play, "thelazycamel")
    |> K2poker.GamePlay.play("bob")
    assert game_play.status == :finished
  end

  test "should return a updated result struct", context do
    game_play = K2poker.GamePlay.play(context.game_play, "thelazycamel")
    |> K2poker.GamePlay.play("bob")
    refute game_play.result.win_description == ""
  end

  test "it should return the winner as player 1", context do
    player1_cards = ["Ad", "As"]
    player2_cards = ["Kd", "Ks"]
    table_cards = ["Ah", "Ac", "Kh","Qc", "Js"]
    player1 = %{context.player1 | cards: player1_cards, status: :new}
    player2 = %{context.player2 | cards: player2_cards, status: :ready}
    game_play = %{context.game_play | status: :river, players: [player1, player2], table_cards: table_cards}
    game_play = K2poker.GamePlay.play(game_play, player1.id)
    assert game_play.result.id == "thelazycamel"
    assert Enum.sort(game_play.result.cards) == Enum.sort(["Ad", "As", "Ah", "Ac", "Kh"])
    assert game_play.result.status == :win
    assert game_play.result.win_description == :four_of_a_kind
    assert game_play.result.lose_description == :full_house
    assert game_play.status == :finished
  end

  test "it should return the winner as player 2", context do
    player1_cards = ["Kd", "Ts"]
    player2_cards = ["Ad", "As"]
    table_cards = ["Ah", "Ac", "Kh","Qc", "Js"]
    player1 = %{context.player1 | cards: player1_cards, status: :new}
    player2 = %{context.player2 | cards: player2_cards, status: :ready}
    game_play = %{context.game_play | status: :river, players: [player1, player2], table_cards: table_cards}
    game_play = K2poker.GamePlay.play(game_play, player1.id)
    assert game_play.result.id == "bob"
    assert Enum.sort(game_play.result.cards) == Enum.sort(["Ad", "As", "Ah", "Ac", "Kh"])
    assert game_play.result.status == :win
    assert game_play.result.win_description == :four_of_a_kind
    assert game_play.result.lose_description == :straight
    assert game_play.status == :finished
  end

  test "it should return the result as a draw", context do
    player1_cards = ["Kd", "Ts"]
    player2_cards = ["Kc", "Th"]
    table_cards = ["Ah", "Ac", "Kh","Qc", "Js"]
    player1 = %{context.player1 | cards: player1_cards, status: :new}
    player2 = %{context.player2 | cards: player2_cards, status: :ready}
    game_play = %{context.game_play | status: :river, players: [player1, player2], table_cards: table_cards}
    game_play = K2poker.GamePlay.play(game_play, player1.id)
    assert game_play.result.id == ""
    assert Enum.sort(game_play.result.cards) == Enum.sort(["Ah", "Js", "Kc", "Kd", "Qc", "Th", "Ts"])
    assert game_play.result.status == :draw
    assert game_play.result.win_description == :straight
    assert game_play.result.lose_description == ""
    assert game_play.status == :finished
  end

end
