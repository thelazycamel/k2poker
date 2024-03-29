defmodule GamePlay.PlayerDataTest do
  use ExUnit.Case
  doctest K2poker.GamePlay

  setup do
    game_play = K2poker.new("thelazycamel", "bob")
    |> K2poker.play("thelazycamel")
    |> K2poker.play("bob")
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    player_data = K2poker.player_data(game_play, player1.id)
    [game_play: game_play, player1: player1, player2: player2, player_data: player_data]
  end

  test "player_data returns the players cards", context do
    assert List.first(context.player_data.cards) == List.first(context.player1.cards)
    assert List.last(context.player_data.cards) == List.last(context.player1.cards)
    assert Enum.count(context.player_data.cards) == 2
  end

  test "player_data returns the table cards", context do
    assert Enum.count(context.player_data.table_cards) == 3
    assert Enum.at(context.player_data.table_cards, 0) == Enum.at(context.game_play.table_cards, 0)
    assert Enum.at(context.player_data.table_cards, 1) == Enum.at(context.game_play.table_cards, 1)
    assert Enum.at(context.player_data.table_cards, 2) == Enum.at(context.game_play.table_cards, 2)
  end

  test "player_data returns the game status", context do
    assert context.player_data.status == "flop"
  end

  test "player_data returns the player status", context do
    assert context.player_data.player_status == "new"
  end

  test "player_data returns the other players status", context do
    assert context.player_data.other_player_status == "new"
    game_play = K2poker.discard(context.game_play, context.player2.id, 0)
    player_data = K2poker.player_data(game_play, context.player1.id)
    assert player_data.other_player_status == "discarded"
    game_play = K2poker.play(game_play, context.player2.id)
    player_data = K2poker.player_data(game_play, context.player1.id)
    assert player_data.other_player_status == "ready"
  end

  test "player_data returns game_result if the game is complete", context do
    player1 = context.player1.id
    player2 = context.player2.id
    game_play = K2poker.play(context.game_play, player1)
    |> K2poker.play(player2)
    |> K2poker.play(player1)
    |> K2poker.play(player2)
    |> K2poker.play(player1)
    |> K2poker.play(player2)
    result = game_play.result
    player_data = K2poker.player_data(game_play, player1)
    assert(player_data.status == "finished")
    assert(player_data.result.winning_cards == result.cards)
    assert(player_data.result.win_description == result.win_description)
    assert(player_data.result.lose_description == result.lose_description)
  end

  test "player_data returns the players current best hand and cards", context do
    player1 = context.player1
    player2 = context.player2
    game_play = context.game_play
    table_cards = ["Ks", "Kh", "As", "Tc", "4d"]
    player_cards = ["Ad", "Ah"]
    player1 = %{player1 | cards: player_cards}
    players = [player1, player2]
    game_play = %{game_play | table_cards: table_cards, players: players}
    game_play = K2poker.play(game_play, player1.id)
    player_data = K2poker.player_data(game_play, player1.id)
    assert(player_data.best_cards == ["Ah", "Ad", "As", "Kh", "Ks"])
    assert(player_data.hand_description == "full_house")
  end

  test "player_data returns folded info if the player has folded", context do
    player1_id = context.player1.id
    game_play = K2poker.fold(context.game_play, player1_id)
    player_data =  K2poker.player_data(game_play, player1_id)
    assert(player_data.result.status == "folded")
  end

  test "player_data returns folded info if the other player has folded", context do
    player1_id = context.player1.id
    player2_id = context.player2.id
    game_play = K2poker.fold(context.game_play, player2_id)
    player_data =  K2poker.player_data(game_play, player1_id)
    assert(player_data.result.status == "other_player_folded")
  end

end
