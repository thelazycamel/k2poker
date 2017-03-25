defmodule K2poker.SinglePlayerData do

  def extract(game, player_id) do
    {:ok, player, index} = get_player(game.players, player_id)
    {{player_result, _}, best_cards} = get_best_possible_hand(game, player)
    response_map(game, player)
      |> Map.put(:other_player_status, get_other_player_status(game, index))
      |> Map.put(:hand_description, K2poker.ResultCalculator.result_description(player_result))
      |> Map.put(:best_cards, K2poker.Deck.to_strings(best_cards))
      |> Map.put(:result, get_final_result_for_player(game, player, index))
  end

  defp response_map(game, player) do
    %{
      cards: player.cards,
      player_status: player.status,
      status: game.status,
      table_cards: game.table_cards
      }
  end

  defp get_other_player_status(game, index) do
    other_player = get_other_player(game, index)
    other_player.status
  end

  defp get_best_possible_hand(game, player) do
    cond do
      Enum.empty?(game.table_cards) -> {{0,""}, []}
      true ->
        table_cards = K2poker.Deck.from_strings(game.table_cards)
        K2poker.Ranking.best_possible_hand(table_cards, K2poker.Deck.from_strings(player.cards))
    end
  end

  defp get_other_player(game, index) do
    case index do
      0 -> Enum.at(game.players, 1)
      1 -> Enum.at(game.players, 0)
    end
  end

  # this is a duplicate of game_play version, look at merging
  #
  defp get_player(players, player_id) do
    find_player = fn(player) -> player.id == player_id end
    player = Enum.find(players, nil, find_player)
    index = Enum.find_index(players, find_player)
    {:ok, player, index}
  end

  defp get_final_result_for_player(game, player, index) do
    result = game.result
    status = cond do
      result.status == "in_play" -> "in_play"
      result.status == "folded" -> if (player.id == result.player_id), do: "folded", else: "other_player_folded"
      result.status == "draw" -> "draw"
      (result.status == "win") && (result.player_id == player.id) -> "win"
      true -> "lose"
    end
    %{
      status: status,
      winning_cards: result.cards,
      win_description: result.win_description,
      lose_description: result.lose_description,
      player_cards: player.cards,
      table_cards: game.table_cards,
      other_player_cards: get_other_players_cards(game, index)
    }
  end

  #TODO think about not return other players cards if they have folded
  #
  defp get_other_players_cards(game, index) do
    if game.status == "finished" do
      other_player = get_other_player(game, index)
      other_player.cards
    else
      []
    end
  end

end
