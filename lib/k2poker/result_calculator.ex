defmodule K2poker.ResultCalculator do

  @spec calculate(K2poker.Game) :: K2poker.Game.t

  def calculate(game) do
    player1 = List.first(game.players)
    player2 = List.last(game.players)
    table_cards = K2poker.Deck.from_strings(game.table_cards)

    # Get the results from the Rankings
    #
    {{player1_hand_value, _},_} = {player1_result, player1_cards} = K2poker.Ranking.best_possible_hand(table_cards, K2poker.Deck.from_strings(player1.cards))
    {{player2_hand_value, _},_} = {player2_result, player2_cards} = K2poker.Ranking.best_possible_hand(table_cards, K2poker.Deck.from_strings(player2.cards))

    # Tidy up the results into a map of human readable cards and descriptions, ready to be passed on
    # TODO: I dont really like this creating a map just so it can be passed into the create_result method neatly, smells,
    # think of a better solution!
    #
    player1_result_map = %{id: player1.id, result: player1_result, hand: K2poker.Deck.to_strings(player1_cards), description: result_description(player1_hand_value)}
    player2_result_map = %{id: player2.id, result: player2_result, hand: K2poker.Deck.to_strings(player2_cards), description: result_description(player2_hand_value)}

    %{game | result: create_result(player1_result_map, player2_result_map)}
  end

  # check the results from the player rankings and build a K2poker.GameResult that is added to the :result key of the Game
  #
  defp create_result(p1, p2) do
    result = cond do
      p1.result > p2.result ->
        %K2poker.GameResult{player_id: p1.id, status: :win, cards: p1.hand, win_description: p1.description, lose_description: p2.description}
      p1.result < p2.result ->
        %K2poker.GameResult{player_id: p2.id, status: :win, cards: p2.hand, win_description: p2.description, lose_description: p1.description}
      p1.result == p2.result ->
        %K2poker.GameResult{player_id: "", status: :draw, cards: Enum.uniq(p1.hand ++ p2.hand), win_description: p1.description, lose_description: ""}
    end
    result
  end

  defp result_description(value) do
    case value do
      10 -> :royal_flush
      9 -> :straight_flush
      8 -> :four_of_a_kind
      7 -> :full_house
      6 -> :flush
      5 -> :straight
      4 -> :three_of_a_kind
      3 -> :two_pair
      2 -> :one_pair
      1 -> :high_card
    end
  end

end
