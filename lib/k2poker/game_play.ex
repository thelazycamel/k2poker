defmodule K2poker.GamePlay do

  # This module deals with the whole game process of creating a game
  # and taking players turns, dealing out the flop turn, river and
  # returning the winner (at the appropriate times)

  # TODO possibly, enable game to be initialized with a game,
  # though it might not need it!
  #

  # initialize
  # Call this method with 2 player ids to create a new game and deal the first hand
  # returns a K2poker.Game with the players, deck and status setup

  @spec initialize(String.t, String.t) :: K2poker.Game.t

  def initialize(player1, player2) do
    if player1 && player2 do
      game = %K2poker.Game{
        players: [
          %K2poker.Player{id: player1},
          %K2poker.Player{id: player2}
        ],
        deck: K2poker.Deck.shuffled_strings
      }
      next_turn(game)
    else
      {:error, "Game needs 2 players to begin"}
    end
  end

  # *** play ***
  # Call this method simply passing in the game and the player id,
  # to set the players status to ready, if both players status' are set
  # to ready then call the next_turn function, will will automatically
  # play the next stage of the game
  # returns a K2poker.Game with the new player status (and game status if next_turn has been called)

  @spec play(K2poker.Game.t, K2poker.Player.t) :: K2poker.Game.t

  def play(game, player_id) do
    {:ok, player, index} = get_player(game.players, player_id)
    player = %{player | status: :ready}
    players = List.replace_at(game.players, index, player)
    game = %{game | players: players}
    if both_players_ready?(players) do
      next_turn(game)
    else
      game
    end
  end

  # *** discard ***
  # Call this method to discard one (or both) of the players cards and
  # take a new one from the deck
  # Pass in the game, the player_id and the index of the card that is to be
  # discarded, the action will only be applied if the player status is set to new,
  # and they are in the correct stage of play, also if the game status is on the river
  # it will automatically "burn" both cards, no matter which card is requested to discard
  # returns a K2poker.Game with the players cards and status updated

  @spec discard(K2poker.Game.t, String.t, Integer.t) :: K2poker.Game.t

  def discard(game, player_id, card_index) do
    {:ok, player, player_index} = get_player(game.players, player_id)
    if player.status == :new && allowed_to_discard_at_stage?(game.status) do
      deck = List.delete_at(game.deck, 0) #discard the first card
      player = case game.status do
        :deal -> replace_one_card(deck, player, card_index)
        :flop -> replace_one_card(deck, player, card_index)
        :turn -> replace_one_card(deck, player, card_index)
        :river -> replace_both_cards(deck, player)
      end
      players = List.replace_at(game.players, player_index, player)
      deck = deck -- player.cards
      %{game | deck: deck, players: players}
    else
      game
    end
  end

  # initialize, play and discard should be the only public functions,
  # all others (below) should be private

  # PRIVATE

  defp next_turn(game) do
    if both_players_ready?(game.players) do
      case game.status do
        :start -> deal(game)
        :deal -> flop(game)
        :flop -> turn(game)
        :turn -> river(game)
        :river -> calc_winner(game)
        _ -> game
      end
    else
      game
    end
  end

  # TODO im sure this method could be much smaller
  # and cycle the dealing of the cards to players!
  #
  defp deal(game) do
    deck = game.deck
    player1 = List.first(game.players)
    player2 = List.last(game.players)
    #fetch the 4 cards
    {:ok, card1} = Enum.fetch(deck, 0)
    {:ok, card2} = Enum.fetch(deck, 1)
    {:ok, card3} = Enum.fetch(deck, 2)
    {:ok, card4} = Enum.fetch(deck, 3)
    #add the cards and new status to the players
    player1 = %{player1 | cards: [card1, card3], status: :new}
    player2 = %{player2 | cards: [card2, card4], status: :new}
    #remove the cards from the deck
    deck = deck -- [card1, card2, card3, card4]
    #update and return the game
    %{game | status: :deal, deck: deck, players: [player1, player2]}
  end

  defp flop(game) do
    deck = List.delete_at(game.deck, 0) #discard the first card
    {:ok, card1} = Enum.fetch(deck, 0)
    {:ok, card2} = Enum.fetch(deck, 1)
    {:ok, card3} = Enum.fetch(deck, 2)
    table_cards = [card1, card2, card3]
    deck = deck -- [card1, card2, card3]
    players = set_all_players_status(game.players, :new)
    %{game | status: :flop, table_cards: table_cards, deck: deck, players: players}
  end

  defp turn(game) do
    deck = List.delete_at(game.deck, 0) #discard the first
    {:ok, card} = Enum.fetch(deck, 0)
    table_cards = List.insert_at(game.table_cards, -1, card)
    deck = deck -- [card]
    players = set_all_players_status(game.players, :new)
    %{game | status: :turn, table_cards: table_cards, deck: deck, players: players}
  end

  defp river(game) do
    deck = List.delete_at(game.deck, 0) #discard the first
    {:ok, card} = Enum.fetch(deck, 0)
    table_cards = List.insert_at(game.table_cards, -1, card)
    deck = deck -- [card]
    players = set_all_players_status(game.players, :new)
    %{game | status: :river, table_cards: table_cards, deck: deck, players: players}
  end

  # TODO: run the cards through the rankings ->
  # return the winner and cards, perhaps in another atom on the game struct?
  #
  defp calc_winner(game) do
    player1 = List.first(game.players)
    player2 = List.last(game.players)
    table_cards = K2poker.Deck.from_strings(game.table_cards)
    {player1_result, player1_hand} = K2poker.Ranking.best_possible_hand(table_cards, K2poker.Deck.from_strings(player1.cards))
    {player2_result, player2_hand} = K2poker.Ranking.best_possible_hand(table_cards, K2poker.Deck.from_strings(player2.cards))

    {player1_hand_value, _} = player1_result
    {player2_hand_value, _} = player2_result
    player1_hand_description = result_description(player1_hand_value)
    player2_hand_description = result_description(player2_hand_value)

    #TODO return the description as an atom (it can then used as a translation)
    result = cond do
      player1_result > player2_result ->
        %K2poker.GameResult{id: player1.id, is_draw: false, cards: K2poker.Deck.to_strings(player1_hand), win_description: player1_hand_description, lose_description: player2_hand_description}
      player1_result < player2_result ->
        %K2poker.GameResult{id: player2.id, is_draw: false, cards: K2poker.Deck.to_strings(player2_hand), win_description: player2_hand_description, lose_description: player1_hand_description}
      player1_result == player2_result ->
        %K2poker.GameResult{id: :draw, is_draw: true, cards: Enum.uniq(K2poker.Deck.to_strings(player1_hand ++ player2_hand)), win_description: player1_hand_description, lose_description: ""}
    end
    %{game | status: :finish, result: result}
  end

  defp get_player(players, player_id) do
    find_player = fn(player) -> player.id == player_id end
    player = Enum.find(players, nil, find_player)
    index = Enum.find_index(players, find_player)
    {:ok, player, index}
  end

  defp both_players_ready?(players) do
    Enum.all?(players, fn(player) -> player.status == :ready end)
  end

  defp set_all_players_status(players, status) do
    Enum.map(players, fn(player) -> %{player | status: status} end)
  end

  defp replace_one_card(deck, player, card_index) do
    {:ok, new_card} = Enum.fetch(deck, 0)
    cards = List.replace_at(player.cards, card_index, new_card)
    %{player | cards: cards, status: :discarded}
  end

  defp replace_both_cards(deck, player) do
    {:ok, card1} = Enum.fetch(deck, 0)
    {:ok, card2} = Enum.fetch(deck, 1)
    cards = List.replace_at(player.cards, 0, card1)
    |> List.replace_at(1, card2)
    %{player | cards: cards, status: :discarded}
  end

  defp allowed_to_discard_at_stage?(status) do
    Enum.any?([:deal, :flop, :turn, :river], fn(x) -> x == status end)
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
