# K2poker on Elixir

  Head-to-head Texas Holdem style poker game where players can discard,
  play or fold at any time during the game, creates a game api for
  handling all the actions and returns the winning result at the end.

#TODO
  This is a first version, written whilst learning Elixir, and although it
  works and has lots of test, some of the code could do with a good refactor to use the Elixir
  language more expressively, the API should remain the same though, I
  especially need to consider moving the players List to a Map, which
  should cut down all the finding and indexing needed to update the player
  on every action. 

#TODO
  Consider adding in the actions for updating players current scores
  within a tournament, not sure if it belongs here, but dont want to
  keep it within the main phoenix app, the game should be separated from
  the tournament, so we can simply add a new game into the app and just
  pass back and forth win/lose/draw results to the tournament so it can
  decide what to do with the player

#API:

Available methods that can be passed to K2Poker

#new

  This intializes a new game
  |> requires 2 ids (names) as Strings
  |> returns a Game (object) which holds a shuffled deck of cards
  |> 2 cards dealt to each player, setting the status to :deal
  |> player status' to :new
  |> information is held in a %K2poker.Game{} struct
  |> use the return value to play / discard or fold:

  eg.
  game = K2poker.new("bob", "stu")

#play
  This will update the players status to :ready
  |> requires the current K2poker.Game Struct and the player_id (String)
  |> if both players status' are set to ready,
  |> it will automatically move to the next stage of the game
  |> and set the status' accordingly
  |> returns the updated K2poker.Game Struct

  eg.
  game = K2poker.play(game, "bob")

#discard
  This will discard the given card and deal the given player a new card
  |> requires the current K2poker.Game Struct, the player_id and the index of the card to be exchanged
  |> will block the move unless the players status is :new
  |> will only exchange card during correct stage of game, i.e, deal, flop and turn
  |> if the game status is at the :river, it will discard (burn) both cards
  |> returns the updated K2poker.Game Struct

  eg.
  game = K2poker.discard(game, "stu", 0)

#fold
  This will finish the game, setting the players status to :folded
  |> requires the current K2poker.Game Struct and the player_id
  |> returns an updated K2poker.Game Stuct with the status's and result updated

  eg.
  game = K2poker.fold(game, "stu")

Once the game has reached the final turn (i.e. both players have played
on the :river) the cards are checked and winning result calculated, this result
is placed in the :result atom of the K2poker.Game Struct

  eg.
  game = K2poker.fold(game, "stu")

#player_data

  This will return a map of only the given players information, that can
  be passed down the line to the given player, so he/she does not
  receive the other players info or the deck
  |> requires the current K2poker.Game Struct and the player_id
  |> returns a map of key/values

  eg.
  player_data = K2poker.player_data(game, "stu")

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `k2poker` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:k2poker, "~> 0.1.0"}]
    end
    ```

  2. Ensure `k2poker` is started before your application:

    ```elixir
    def application do
      [applications: [:k2poker]]
    end
    ```

