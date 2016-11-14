defmodule K2poker.GamePlay do

  # This module deals with the whole game process of creating a game
  # and taking players turns, dealing out the flop turn, river and
  # returning the winner (at the appropriate times)

  # new
  #
  # Call this method with 2 player ids to create a new game and deal the first hand
  # returns a K2poker.Game with the players, deck and status setup

  @spec new(String.t, String.t) :: K2poker.Game.t

  def new(player1, player2) do
    game = %K2poker.Game{
      players: [
        %K2poker.Player{id: player1},
        %K2poker.Player{id: player2}
      ],
      deck: K2poker.Deck.shuffled_strings
    }
    next_turn(game)
  end

  # play
  #
  # Call this method simply passing in the game and the player id,
  # to set the players status to ready, if both players status' are set
  # to ready then call the next_turn function, will will automatically
  # play the next stage of the game
  # returns a K2poker.Game with the new player status (and game status if next_turn has been called)

  @spec play(K2poker.Game.t, K2poker.Player.t) :: K2poker.Game.t

  def play(game, player_id) do
    {:ok, player, index} = get_player(game.players, player_id)
    player = %{player | status: "ready"}
    players = List.replace_at(game.players, index, player)
    game = %{game | players: players}
    if both_players_ready?(players), do: next_turn(game), else: game
  end

  # discard
  #
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
    if player.status == "new" && allowed_to_discard_at_stage?(game.status) do
      deck = List.delete_at(game.deck, 0) #discard the first card
      player = case game.status do
        "deal" -> replace_one_card(deck, player, card_index)
        "flop" -> replace_one_card(deck, player, card_index)
        "turn" -> replace_one_card(deck, player, card_index)
        "river" -> replace_both_cards(deck, player)
      end
      players = List.replace_at(game.players, player_index, player)
      deck = deck -- player.cards
      %{game | deck: deck, players: players}
    else
      game
    end
  end

  # fold
  # call this method to finish the game with the player given
  # their status will be set to folded and the games status to finish
  # a GameResult will be returned in the Game Struct with the
  # player_id and status set to folded
  #
  @spec fold(K2poker.Game.t, String.t) :: K2poker.Game.t

  def fold(game, player_id) do
    {:ok, player, index} = get_player(game.players, player_id)
    player = %{player | status: "folded"}
    players = List.replace_at(game.players, index, player)
    game_result = %K2poker.GameResult{player_id: player_id, status: "folded", cards: [], win_description: "folded", lose_description: "folded"}
    %{game | players: players, result: game_result, status: "finished"}
  end

  #TODO break down this long method

  @spec player_data(K2poker.Game.t, String.t) :: Map.t

  def player_data(game, player_id) do
    {:ok, player, index} = get_player(game.players, player_id)
    other_player = case index do
      0 -> Enum.at(game.players, 1)
      1 -> Enum.at(game.players, 0)
    end
    best_possible_hand = cond do
      Enum.empty?(game.table_cards) -> {{0,""}, []}
      true ->
        table_cards = K2poker.Deck.from_strings(game.table_cards)
        K2poker.Ranking.best_possible_hand(table_cards, K2poker.Deck.from_strings(player.cards))
    end
    {{player_result, _}, best_cards} = best_possible_hand
    player_result = K2poker.ResultCalculator.result_description(player_result)
    best_cards = K2poker.Deck.to_strings(best_cards)

    #only return ready or new for the other_player status, not discard!
    other_player_status = if (other_player.status == "ready"), do: "ready", else: "new"
    %{
      cards: player.cards,
      player_status: player.status,
      other_player_status: other_player_status,
      table_cards: game.table_cards,
      status: game.status,
      hand_description: player_result,
      best_cards: best_cards,
      result: game.result
    }
  end

  # PRIVATE

  defp next_turn(game) do
    case game.status do
        "start" -> deal(game)
        "deal" -> flop(game)
        "flop" -> turn(game)
        "turn" -> river(game)
        "river" -> calc_winner(game)
        _ -> game
    end
  end

  # TODO im sure this method could be much smaller
  # and cycle the dealing of the cards to players!
  #
  defp deal(game) do
    deck = game.deck
    player1 = List.first(game.players)
    player2 = List.last(game.players)
    {:ok, deck, player1_cards} = deal_card(deck, player1.cards)
    {:ok, deck, player2_cards} = deal_card(deck, player2.cards)
    {:ok, deck, player1_cards} = deal_card(deck, player1_cards)
    {:ok, deck, player2_cards} = deal_card(deck, player2_cards)
    players = [ %{player1 | cards: player1_cards}, %{player2 | cards: player2_cards} ]
    players = set_all_players_status(players, "new")
    %{game | status: "deal", deck: deck, players: players}
  end

  defp flop(game) do
    deck = List.delete_at(game.deck, 0) #discard the first card
    {:ok, deck, table_cards} = deal_card(deck, game.table_cards)
    {:ok, deck, table_cards} = deal_card(deck, table_cards)
    {:ok, deck, table_cards} = deal_card(deck, table_cards)
    players = set_all_players_status(game.players, "new")
    %{game | status: "flop", table_cards: table_cards, deck: deck, players: players}
  end

  defp turn(game) do
    deck = List.delete_at(game.deck, 0) #discard the first
    {:ok, deck, table_cards} = deal_card(deck, game.table_cards)
    players = set_all_players_status(game.players, "new")
    %{game | status: "turn", table_cards: table_cards, deck: deck, players: players}
  end

  defp river(game) do
    deck = List.delete_at(game.deck, 0) #discard the first
    {:ok, deck, table_cards} = deal_card(deck, game.table_cards)
    players = set_all_players_status(game.players, "new")
    %{game | status: "river", table_cards: table_cards, deck: deck, players: players}
  end

  defp calc_winner(game) do
    game = K2poker.ResultCalculator.calculate(game)
    player1 = List.first(game.players)
    player2 = List.last(game.players)
    players = cond do
      game.result.player_id == player1.id ->
        [ set_player_status(player1, "win"), set_player_status(player2, "lose") ]
      game.result.player_id == player2.id ->
        [ set_player_status(player1, "lose"), set_player_status(player2, "win") ]
      true ->
        set_all_players_status(game.players, "draw")
    end
    %{game | status: "finished", players: players}
  end

  defp get_player(players, player_id) do
    find_player = fn(player) -> player.id == player_id end
    player = Enum.find(players, nil, find_player)
    index = Enum.find_index(players, find_player)
    {:ok, player, index}
  end

  defp both_players_ready?(players) do
    Enum.all?(players, fn(player) -> player.status == "ready" end)
  end

  defp set_player_status(player, status) do
    %{player | status: status}
  end

  defp set_all_players_status(players, status) do
    Enum.map(players, fn(player) -> %{player | status: status} end)
  end

  defp deal_card(deck, card_array) do
    {:ok, new_card} = Enum.fetch(deck, 0)
    cards = List.insert_at(card_array, -1, new_card)
    deck = deck -- [new_card]
    {:ok, deck, cards}
  end

  defp replace_one_card(deck, player, card_index) do
    {:ok, new_card} = Enum.fetch(deck, 0)
    cards = List.replace_at(player.cards, card_index, new_card)
    %{player | cards: cards, status: "discarded"}
  end

  defp replace_both_cards(deck, player) do
    {:ok, card1} = Enum.fetch(deck, 0)
    {:ok, card2} = Enum.fetch(deck, 1)
    cards = List.replace_at(player.cards, 0, card1)
    |> List.replace_at(1, card2)
    %{player | cards: cards, status: "discarded"}
  end

  defp allowed_to_discard_at_stage?(status) do
    Enum.any?(["deal", "flop", "turn", "river"], fn(x) -> x == status end)
  end

end
