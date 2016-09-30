defmodule GamePlay.FoldTest do
  use ExUnit.Case
  doctest K2poker.GamePlay

  setup do
    [game_play: K2poker.GamePlay.new("thelazycamel", "bob")]
  end

  test "#fold should update GamePlay status to :finish", context do
    game_play = K2poker.GamePlay.fold(context.game_play, "thelazycamel")
    assert game_play.status == :finished
  end

  test "#fold should update players status to :folded", context do
    game_play = K2poker.GamePlay.fold(context.game_play, "thelazycamel")
    assert List.first(game_play.players).status == :folded
  end

  test "#fold should update result status to :folded", context do
    game_play = K2poker.GamePlay.fold(context.game_play, "thelazycamel")
    assert game_play.result.status == :folded
  end

  test "#fold should update result id to the folded player id", context do
    game_play = K2poker.GamePlay.fold(context.game_play, "thelazycamel")
    assert game_play.result.player_id == "thelazycamel"
  end

  test "#fold should update result descriptions to :folded", context do
    game_play = K2poker.GamePlay.fold(context.game_play, "thelazycamel")
    assert game_play.result.win_description == :folded
    assert game_play.result.lose_description == :folded
  end

end
