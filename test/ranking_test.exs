defmodule RankingTest do
  use ExUnit.Case
  doctest K2poker.Ranking

  # Hand ranks
  @royal_flush     10
  @straight_flush  9
  @four_of_a_kind  8
  @full_house      7
  @flush           6
  @straight        5
  @three_of_a_kind 4
  @two_pair        3
  @one_pair        2
  @high_card       1

  # NOTE user #best_possible_hand to evaluate cards not evaluate, with that you can throw
  # in all 7 cards and it will check all combinations

  test "Royal Flush" do
    cards = K2poker.Deck.from_strings(["As", "Js", "Ts", "Qs", "Ks"])
    {evaluated_hand, _ } =  K2poker.Ranking.evaluate(cards)
    assert evaluated_hand == @royal_flush
  end

  test "Straight Flush" do
    cards = K2poker.Deck.from_strings(["8s", "9s", "Ts", "Qs", "Js"])
    {evaluated_hand, card_rank} = K2poker.Ranking.evaluate(cards)
    assert card_rank == 12
    assert evaluated_hand == @straight_flush
  end

  test "Four of a Kind" do
    cards = K2poker.Deck.from_strings(["8s", "8h", "8d", "8c", "Js"])
    {evaluated_hand, card_rank} =  K2poker.Ranking.evaluate(cards)
    assert card_rank == {8, 11}
    assert evaluated_hand == @four_of_a_kind
  end

  test "Full House" do
    cards = K2poker.Deck.from_strings(["8s", "8h", "3d", "3c", "3s"])
    {evaluated_hand, card_rank} = K2poker.Ranking.evaluate(cards)
    assert card_rank == {3, 8}
    assert evaluated_hand == @full_house
  end

  test "Flush" do
    cards = K2poker.Deck.from_strings(["8s", "3s", "Ks", "2s", "5s"])
    {evaluated_hand, card_rank} =  K2poker.Ranking.evaluate(cards)
    assert card_rank == {13, 8, 5, 3, 2}
    assert evaluated_hand == @flush
  end

  test "Straight" do
    cards = K2poker.Deck.from_strings(["8s", "7s", "6d", "9h", "Tc"])
    {evaluated_hand, card_rank} =  K2poker.Ranking.evaluate(cards)
    assert card_rank == 10
    assert evaluated_hand == @straight
  end

  test "Three of a Kind" do
    cards = K2poker.Deck.from_strings(["8s", "8d", "8c", "9h", "Tc"])
    {evaluated_hand, card_rank} = K2poker.Ranking.evaluate(cards)
    assert card_rank == {8, 10, 9}
    assert evaluated_hand == @three_of_a_kind
  end

  test "Two Pair" do
    cards = K2poker.Deck.from_strings(["8s", "8d", "9c", "9h", "Tc"])
    {evaluated_hand, card_rank} =  K2poker.Ranking.evaluate(cards)
    assert card_rank == {9, 8, 10}
    assert evaluated_hand == @two_pair
  end

  test "One Pair" do
    cards = K2poker.Deck.from_strings(["8s", "8d", "2c", "9h", "Tc"])
    {evaluated_hand, card_rank} = K2poker.Ranking.evaluate(cards)
    assert card_rank == {8, 10, 9, 2}
    assert evaluated_hand == @one_pair
  end

  test "High Card" do
    cards = K2poker.Deck.from_strings(["8s", "Ad", "2c", "9h", "Tc"])
    {evaluated_hand, card_rank} = K2poker.Ranking.evaluate(cards)
    assert card_rank == {14, 10, 9, 8, 2}
    assert evaluated_hand == @high_card
  end

  test "#best_possible_hand (royal flush)" do
    player_cards = K2poker.Deck.from_strings(["Ad", "Td"])
    table_cards = K2poker.Deck.from_strings(["Kd", "Qd", "Jd", "Qc", "Kc"])
    {{hand_rank, card_ranks}, winning_cards}  = K2poker.Ranking.best_possible_hand(table_cards, player_cards)
    assert hand_rank == @royal_flush
    assert card_ranks == nil #return nil as no other cards necessary
    assert Enum.reverse(Enum.sort(K2poker.Deck.to_strings(winning_cards))) == ["Td", "Qd", "Kd", "Jd", "Ad"]
  end

  test "#best_possible_hand (straight flush)" do
    player_cards = K2poker.Deck.from_strings(["7d", "6d"])
    table_cards = K2poker.Deck.from_strings(["5d", "8d", "9d", "Ac", "Kc"])
    {{hand_rank, card_ranks}, winning_cards}  = K2poker.Ranking.best_possible_hand(table_cards, player_cards)
    assert hand_rank == @straight_flush
    assert card_ranks == 9
    assert Enum.reverse(Enum.sort(K2poker.Deck.to_strings(winning_cards))) == ["9d", "8d", "7d", "6d", "5d"]
  end

  test "#best_possible_hand (four of a kind)" do
    player_cards = K2poker.Deck.from_strings(["Ad", "Ac"])
    table_cards = K2poker.Deck.from_strings(["2d", "As", "Ah", "3c", "4c"])
    {{hand_rank, card_ranks}, winning_cards}  = K2poker.Ranking.best_possible_hand(table_cards, player_cards)
    assert hand_rank == @four_of_a_kind
    assert card_ranks == {14, 4} # Aces with a 4
    assert Enum.reverse(Enum.sort(K2poker.Deck.to_strings(winning_cards))) == ["As", "Ah", "Ad", "Ac", "4c"]
  end

  test "#best_possible_hand (full house)" do
    player_cards = K2poker.Deck.from_strings(["3d", "2c"])
    table_cards = K2poker.Deck.from_strings(["3h", "3s", "Ah", "Ac", "2d"])
    {{hand_rank, card_ranks}, winning_cards}  = K2poker.Ranking.best_possible_hand(table_cards, player_cards)
    assert hand_rank == @full_house
    assert card_ranks == {3, 14}
    assert Enum.reverse(Enum.sort(K2poker.Deck.to_strings(winning_cards))) == ["Ah", "Ac", "3s", "3h", "3d"]
  end

  test "#best_possible_hand (flush)" do
    player_cards = K2poker.Deck.from_strings(["3d", "2d"])
    table_cards = K2poker.Deck.from_strings(["4d", "5d", "8d", "Kd", "9d"])
    {{hand_rank, card_ranks}, winning_cards}  = K2poker.Ranking.best_possible_hand(table_cards, player_cards)
    assert hand_rank == @flush
    assert card_ranks == {13, 9, 8, 5, 4}
    assert Enum.reverse(Enum.sort(K2poker.Deck.to_strings(winning_cards))) == ["Kd", "9d", "8d", "5d", "4d"]
  end

  test "#best_possible_hand (straight)" do
    player_cards = K2poker.Deck.from_strings(["8s", "2c"])
    table_cards = K2poker.Deck.from_strings(["4d", "5d", "6c", "7s", "3h"])
    {{hand_rank, card_ranks}, winning_cards}  = K2poker.Ranking.best_possible_hand(table_cards, player_cards)
    assert hand_rank == @straight
    assert card_ranks == 8 #{just 8 needed for straight
    assert Enum.reverse(Enum.sort(K2poker.Deck.to_strings(winning_cards))) == ["8s", "7s", "6c", "5d", "4d"]
  end

  test "#best_possible_hand (three of a kind)" do
    player_cards = K2poker.Deck.from_strings(["8s", "2c"])
    table_cards = K2poker.Deck.from_strings(["8d", "5d", "Ac", "7s", "8h"])
    {{hand_rank, card_ranks}, winning_cards}  = K2poker.Ranking.best_possible_hand(table_cards, player_cards)
    assert hand_rank == @three_of_a_kind
    assert card_ranks == {8, 14, 7}
    assert Enum.reverse(Enum.sort(K2poker.Deck.to_strings(winning_cards))) == ["Ac", "8s", "8h", "8d", "7s"]
  end

  test "#best_possible_hand (two pair)" do
    player_cards = K2poker.Deck.from_strings(["8s", "2c"])
    table_cards = K2poker.Deck.from_strings(["8d", "5d", "Ac", "5s", "Ah"])
    {{hand_rank, card_ranks}, winning_cards}  = K2poker.Ranking.best_possible_hand(table_cards, player_cards)
    assert hand_rank == @two_pair
    assert card_ranks == {14, 8, 5}
    assert Enum.reverse(Enum.sort(K2poker.Deck.to_strings(winning_cards))) == ["Ah", "Ac", "8s", "8d", "5d"]
  end

  test "#best_possible_hand (one pair)" do
    player_cards = K2poker.Deck.from_strings(["8s", "2c"])
    table_cards = K2poker.Deck.from_strings(["8d", "3d", "Ac", "5s", "6h"])
    {{hand_rank, card_ranks}, winning_cards}  = K2poker.Ranking.best_possible_hand(table_cards, player_cards)
    assert hand_rank == @one_pair
    assert card_ranks == {8, 14, 6, 5}
    assert Enum.reverse(Enum.sort(K2poker.Deck.to_strings(winning_cards))) == ["Ac", "8s", "8d", "6h", "5s"]
  end

  test "#best_possible_hand (high card)" do
    player_cards = K2poker.Deck.from_strings(["7s", "2c"])
    table_cards = K2poker.Deck.from_strings(["8d", "3d", "Ac", "5s", "6h"])
    {{hand_rank, card_ranks}, winning_cards}  = K2poker.Ranking.best_possible_hand(table_cards, player_cards)
    assert hand_rank == @high_card
    assert card_ranks == {14, 8, 7, 6, 5}
    assert Enum.reverse(Enum.sort(K2poker.Deck.to_strings(winning_cards))) == ["Ac", "8d", "7s", "6h", "5s"]
  end

  # Tests on rank winner

  test "Royal flush beats straight flush" do
    player1 = K2poker.Deck.from_strings(["As", "Ks"])
    player2 = K2poker.Deck.from_strings(["9s", "8s"])
    table_cards = K2poker.Deck.from_strings(["Qs", "Js", "Ts", "3d", "5d"])
    {player_1_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "Higher Four-of-a-Kind wins" do
    player1 = K2poker.Deck.from_strings(["As", "Ad"])
    player2 = K2poker.Deck.from_strings(["Ks", "Kc"])
    table_cards = K2poker.Deck.from_strings(["Ac", "Ah", "Kh", "Kd", "5d"])
    {player_1_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "Higher Four-of-a-Kind wins on the high card" do
    player1 = K2poker.Deck.from_strings(["As", "3c"])
    player2 = K2poker.Deck.from_strings(["Qs", "Js"])
    table_cards = K2poker.Deck.from_strings(["Kd", "Ks", "Kh", "Kd", "5d"])
    {player_1_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "Higher Full House wins 3s and Aces" do
    player1 = K2poker.Deck.from_strings(["As", "3c"])
    player2 = K2poker.Deck.from_strings(["Qs", "3s"])
    table_cards = K2poker.Deck.from_strings(["Ad", "Qc", "3d", "3h", "5d"])
    {player_1_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "Higher Full House wins Aces and 3s" do
    player1 = K2poker.Deck.from_strings(["As", "3c"])
    player2 = K2poker.Deck.from_strings(["Qs", "3s"])
    table_cards = K2poker.Deck.from_strings(["Ad", "Qc", "Ad", "3h", "3d"])
    {player_1_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "Higher Flush wins" do
    player1 = K2poker.Deck.from_strings(["As", "8s"])
    player2 = K2poker.Deck.from_strings(["Ks", "Qs"])
    table_cards = K2poker.Deck.from_strings(["2s", "4s", "Ts", "3h", "5d"])
    {player_1_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "Higher Straight wins" do
    player1 = K2poker.Deck.from_strings(["Td", "8s"])
    player2 = K2poker.Deck.from_strings(["9c", "4s"])
    table_cards = K2poker.Deck.from_strings(["9s", "7h", "6d", "3h", "5d"])
    {player_1_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand,_} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "Higher Three of a kind wins" do
    player1 = K2poker.Deck.from_strings(["Td", "Ts"])
    player2 = K2poker.Deck.from_strings(["9c", "9s"])
    table_cards = K2poker.Deck.from_strings(["9s", "Th", "6d", "3h", "5d"])
    {player_1_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "Higher Three of a kind wins with high card" do
    player1 = K2poker.Deck.from_strings(["Td", "Js"])
    player2 = K2poker.Deck.from_strings(["Tc", "9s"])
    table_cards = K2poker.Deck.from_strings(["Ts", "Th", "6d", "3h", "5d"])
    {player_1_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "Three of a kind draws with same ranked hand" do
    player1 = K2poker.Deck.from_strings(["Td", "9c"])
    player2 = K2poker.Deck.from_strings(["Tc", "9s"])
    table_cards = K2poker.Deck.from_strings(["Ts", "Th", "6d", "3h", "5d"])
    {player_1_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    refute player_1_hand > player_2_hand
    refute player_1_hand < player_2_hand
    assert player_1_hand == player_2_hand
  end

  test "Two Pair with higher pair wins" do
    player1 = K2poker.Deck.from_strings(["Td", "Ts"])
    player2 = K2poker.Deck.from_strings(["9c", "9s"])
    table_cards = K2poker.Deck.from_strings(["3s", "7h", "6d", "3h", "5d"])
    {player_1_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "One Pair with higher pair wins" do
    player1 = K2poker.Deck.from_strings(["Td", "Ts"])
    player2 = K2poker.Deck.from_strings(["9c", "9s"])
    table_cards = K2poker.Deck.from_strings(["2s", "7h", "6d", "3h", "5d"])
    {player_1_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "Higher Card wins" do
    player1 = K2poker.Deck.from_strings(["Td", "8d"])
    player2 = K2poker.Deck.from_strings(["9c", "8s"])
    table_cards = K2poker.Deck.from_strings(["2s", "7h", "4d", "3h", "5d"])
    {player_1_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    assert player_1_hand > player_2_hand
  end

  test "Higher Card draws when same" do
    player1 = K2poker.Deck.from_strings(["Td", "8d"])
    player2 = K2poker.Deck.from_strings(["Tc", "8s"])
    table_cards = K2poker.Deck.from_strings(["2s", "7h", "4d", "3h", "5d"])
    {player_1_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player1)
    {player_2_hand, _} = K2poker.Ranking.best_possible_hand(table_cards, player2)
    refute player_1_hand > player_2_hand
    refute player_1_hand < player_2_hand
    assert player_1_hand == player_2_hand
  end
end

