defmodule GamePlay.BotTest do
  use ExUnit.Case
  doctest K2poker.GamePlay

  setup do
    game_play = K2poker.GamePlay.new("thelazycamel", "BOT")
    player1 = List.first(game_play.players)
    player2 = List.last(game_play.players)
    [game_play: game_play, player1: player1, player2: player2]
  end

  test "#next_turn deal should set BOT to ready", context do
    assert(context.game_play.status == "deal")
    assert(context.player2.status == "ready")
  end

  test "#next_turn flop should set BOT to ready", context do
    game_play = K2poker.play(context.game_play, context.player1.id)
    assert(game_play.status == "flop")
    assert(K2poker.player_data(game_play, "BOT").player_status == "ready")
  end

  test "#next_turn turn should set BOT to ready", context do
    game_play = K2poker.play(context.game_play, context.player1.id)
    |> K2poker.play(context.player1.id)
    assert(game_play.status == "turn")
    assert(K2poker.player_data(game_play, "BOT").player_status == "ready")
  end

  test "#next_turn river should set BOT to ready", context do
    game_play = K2poker.play(context.game_play, context.player1.id)
    |> K2poker.play(context.player1.id)
    |> K2poker.play(context.player1.id)
    assert(game_play.status == "river")
    assert(K2poker.player_data(game_play, "BOT").player_status == "ready")
  end

  test "#next_turn finish should set BOT to ready", context do
    game_play = K2poker.play(context.game_play, context.player1.id)
    |> K2poker.play(context.player1.id)
    |> K2poker.play(context.player1.id)
    assert(game_play.status == "river")
    assert(K2poker.player_data(game_play, "BOT").player_status == "ready")
  end

  test "#next_turn end should not set BOT to ready", context do
    game_play = K2poker.play(context.game_play, context.player1.id)
    |> K2poker.play(context.player1.id)
    |> K2poker.play(context.player1.id)
    |> K2poker.play(context.player1.id)
    assert(game_play.status == "finished")
    refute(K2poker.player_data(game_play, "BOT").player_status == "ready")
  end

end

