defmodule Models.CardTest do
  use ExUnit.Case
  doctest K2poker.Card

  test "creating a card with a struct" do
    card = %K2poker.Card{suit: :spades, rank: 13}
    assert card.rank == 13
    assert card.suit == :spades
  end

  test "#from_string -> Ace of Spades" do
    card = K2poker.Card.from_string("As")
    assert card.rank == 14
    assert card.suit == :spades
  end

  test "#from_string -> King of Clubs" do
    card = K2poker.Card.from_string("Kc")
    assert card.rank == 13
    assert card.suit == :clubs
  end

  test "#from_string -> Queen of Hearts" do
    card = K2poker.Card.from_string("Qh")
    assert card.rank == 12
    assert card.suit == :hearts
  end

  test "#from_string -> Jack of Diamonds" do
    card = K2poker.Card.from_string("Jd")
    assert card.rank == 11
    assert card.suit == :diamonds
  end

  test "#from_string -> 10 of Spades" do
    card = K2poker.Card.from_string("Ts")
    assert card.rank == 10
    assert card.suit == :spades
  end

  test "#from_string -> 2 of Hearts" do
    card = K2poker.Card.from_string("2h")
    assert card.rank == 2
    assert card.suit == :hearts
  end

  test "#to_string" do

  end

end
