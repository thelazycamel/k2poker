defmodule K2poker do

  # These are just helper methods, the only required
  # methods for the API in order to initialize and play
  # a game, they call the GamePlay methods of the same name

  alias K2poker.GamePlay, as: GamePlay

  def new(player1, player2) do
    GamePlay.new(player1, player2)
  end

  def play(game, player_id) do
    GamePlay.play(game, player_id)
  end

  def discard(game, player_id, card_index) do
    GamePlay.discard(game, player_id, card_index)
  end

  def fold(game, player_id) do
    GamePlay.fold(game, player_id)
  end

  def player_data(game, player_id) do
    GamePlay.player_data(game, player_id)
  end

end
