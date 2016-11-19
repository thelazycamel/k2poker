defmodule SinglePlayerResultTest do
  use ExUnit.Case
  doctest K2poker.SinglePlayerData

  setup do
    game_play = K2poker.GamePlay.new("thelazycamel", "bob")
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    player1_cards = ["Ad", "As"]
    player2_cards = ["Kd", "Ks"]
    table_cards = ["Ah", "Ac", "Kh","Qc", "Js"]
    player1 = %{player1 | cards: player1_cards, status: :new}
    player2 = %{player2 | cards: player2_cards, status: :new}
    game_play = %{game_play | status: "river", players: [player1, player2], table_cards: table_cards}
    game_play = K2poker.play(game_play, player1.id) |> K2poker.play(player2.id)
    player1_data = K2poker.player_data(game_play, player1.id)
    player2_data = K2poker.player_data(game_play, player2.id)
    [game_play: game_play, player1: player1, player2: player2, player1_data: player1_data, player2_data: player2_data]
  end

  test "#status (player1)", context do
    assert(context.player1_data.result.status == "win")
  end

  test "#status (player2)", context do
    assert(context.player2_data.result.status == "lose")
  end

  test "#winning_cards", context do
    assert(context.player1_data.result.winning_cards == ["As", "Ad", "Kh", "Ac", "Ah"])
    assert(context.player2_data.result.winning_cards == ["As", "Ad", "Kh", "Ac", "Ah"])
  end

  test "#win_description", context do
    assert(context.player1_data.result.win_description == "four_of_a_kind")
    assert(context.player2_data.result.win_description == "four_of_a_kind")
  end

  test "#lose_description", context do
    assert(context.player1_data.result.lose_description == "full_house")
    assert(context.player2_data.result.lose_description == "full_house")
  end

  test "#other_player_cards (player1)", context do
    assert(context.player1_data.result.other_player_cards == context.player2.cards)
  end

  test "#other_player_cards (player2)", context do
    assert(context.player2_data.result.other_player_cards == context.player1.cards)
  end


end
