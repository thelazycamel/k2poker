defmodule Models.GameTest do
  use ExUnit.Case
  doctest K2poker.Game

  setup do
    [ players: [
        %K2poker.Player{id: "thelazycamel"},
        %K2poker.Player{id: "bob"}
      ],
      deck: K2poker.Deck.shuffled_strings
      ]
  end

  test "it should create a game with 2 players", context do
    game = %K2poker.Game{players: context[:players]}
    assert List.first(game.players) == List.first(context[:players])
    assert List.last(game.players) == List.last(context[:players])
  end

  test "it should hold a deck of cards", context do
    game = %K2poker.Game{deck: context.deck}
    assert List.first(game.deck) == List.first(context.deck)
  end

  test "it should set the status to :start", context do
    game = %K2poker.Game{deck: context.deck, players: context[:players]}
    assert game.status == "start"
  end

end
