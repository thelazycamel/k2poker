defmodule K2poker.GamePlay do

  # This module deals with the whole game process of creating a game
  # and taking players turns, dealing out the flop turn, river and
  # returning the winner (at the appropriate times)

  # TODO possibly, enable game to be initialized with a game,
  # though it might not need it!
  #
  # TODO perhaps this can call next_turn in order to deal the cards
  # for the first hand, otherwise the players status should be set to
  # :new awaiting for them to acknowledge the start of the game

  def initialize(player1, player2) do
    %K2poker.Game{
      players: [
        %K2poker.Player{id: player1},
        %K2poker.Player{id: player2}
      ],
      deck: K2poker.Deck.shuffled_strings
    }
  end

  @spec next_turn(K2poker.Game.t) :: K2poker.Game.t

  # TODO this could probably be a private method and
  # only called from play
  def next_turn(game) do
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

  @spec discard(K2poker.Game.t, String.t, String.t) :: K2poker.Game.t

  def discard(game, player_id, card) do
    #check if the player (status) to see if they can discard the given card
    #check the game status, if :river then burn both cards
    #update the players status to :ready
    {game, player_id, card} #just stopping warning for now
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

  defp calc_winner(game) do
    # run the cards through the rankings ->
    # return the winner and cards, perhaps in another atom on the game struct?
    %{game | status: :finish}
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

end
