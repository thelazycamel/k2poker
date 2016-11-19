defmodule SinglePlayerDataTest do
  use ExUnit.Case
  doctest K2poker.SinglePlayerData

  setup do
    game_play = K2poker.GamePlay.new("thelazycamel", "bob")
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    player1_data = K2poker.player_data(game_play, player1.id)
    player2_data = K2poker.player_data(game_play, player2.id)
    [game_play: game_play, player1: player1, player2: player2, player1_data: player1_data, player2_data: player2_data]
  end

  test "#player1 player_data returns player1 cards", context do
    assert(context.player1_data.cards == context.player1.cards)
  end

  test "both players player_status should be 'new'", context do
    assert(context.player1_data.player_status == "new")
    assert(context.player2_data.player_status == "new")

  end

  test "both players game_status should be 'deal'", context do
    assert(context.player1_data.status == "deal")
    assert(context.player2_data.status == "deal")
  end

  test "both players table_cards should be empty'", context do
    assert(Enum.empty?(context.player1_data.table_cards))
    assert(Enum.empty?(context.player2_data.table_cards))
  end

  test "both players game_result should be 'in_play'", context do
    assert(context.player1_data.result.status == "in_play")
    assert(context.player2_data.result.status == "in_play")
  end

  test "both players have the same table_cards after the flop", context do
    new_game_play = K2poker.play(context.game_play, context.player1.id)
      |> K2poker.play(context.player2.id)
    player1_data = K2poker.player_data(new_game_play, context.player1.id)
    player2_data = K2poker.player_data(new_game_play, context.player2.id)
    assert(player1_data.table_cards == player2_data.table_cards)
    assert(Enum.count(player1_data.table_cards) == 3)
  end


end
