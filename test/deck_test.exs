defmodule DeckTest do
  use ExUnit.Case
  doctest K2poker.Deck

  test "creating a new deck of (unshuffled) cards" do
    deck = K2poker.Deck.unshuffled_deck
    assert Enum.count(deck) == 52
  end

  test "an unshuffled deck should start with the 2 of spades and 2 of clubs" do
    deck = K2poker.Deck.unshuffled_deck
    first_card = Enum.at(deck, 0)
    second_card = Enum.at(deck, 1)
    assert %K2poker.Card{:suit => :spades, :rank => 2} == first_card
    assert %K2poker.Card{:suit => :clubs, :rank => 2} == second_card
  end

  test "#number_of_shuffles should be an integer between 5 and 500" do
    assert is_integer(K2poker.Deck.number_of_shuffles)
    assert K2poker.Deck.number_of_shuffles >= 1
    assert K2poker.Deck.number_of_shuffles <= 5001
  end

  test "#number_of_shuffles should be a random number" do
    # will fail approx once every 5000 times ;)
    refute K2poker.Deck.number_of_shuffles == K2poker.Deck.number_of_shuffles
  end

  test "#shuffled_deck should return a full deck" do
    deck = K2poker.Deck.shuffled
    assert Enum.count(deck) == 52
  end

  test "#shuffled_deck should return a shuffled deck" do
    deck = K2poker.Deck.shuffled
    first_match = %K2poker.Card{:suit => :spades, rank: 2} == Enum.at(deck, 0)
    second_match = %K2poker.Card{:suit => :clubs, rank: 2} == Enum.at(deck, 1)
    refute first_match and second_match
  end

  test "#to_strings should convert the K2Poker.Card structs to strings" do
    deck = K2poker.Deck.unshuffled_deck
    string_deck = K2poker.Deck.to_strings(deck)
    first_card = Enum.at(string_deck, 0)
    last_card = Enum.at(string_deck, 51)
    assert Enum.count(string_deck) == 52
    assert first_card == "2s"
    assert last_card == "Ad"
    assert K2poker.Card.from_string(last_card) == %K2poker.Card{suit: :diamonds, rank: 14}
  end

  test "#from_strings should convert a deck of strings to %K2poker.Card structs" do
    deck = K2poker.Deck.from_strings(["Ad", "2h", "3s","Jc"])
    assert Enum.at(deck, 0) == %K2poker.Card{suit: :diamonds, rank: 14}
    assert Enum.at(deck, 1) == %K2poker.Card{suit: :hearts, rank: 2}
    assert Enum.at(deck, 2) == %K2poker.Card{suit: :spades, rank: 3}
    assert Enum.at(deck, 3) == %K2poker.Card{suit: :clubs, rank: 11}
  end



end
