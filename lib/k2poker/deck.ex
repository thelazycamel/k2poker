defmodule K2poker.Deck do

  @spec new() :: [K2poker.Card.t]

  @max_shuffles 5000

  def new do
    for rank <- ranks, suit <- suits do
      %K2poker.Card{rank: rank, suit: suit}
    end
  end

  def shuffled do
    new |> super_shuffle(number_of_shuffles)
  end

  def number_of_shuffles do
    :rand.uniform(@max_shuffles) + 1
  end

  def to_strings(deck) do
    Enum.map(deck, fn card -> K2poker.Card.to_string(card) end)
  end

  def from_strings(deck) do
    Enum.map(deck, fn card -> K2poker.Card.from_string(card) end)
  end

  defp super_shuffle(deck, n) when n <= 1 do
    Enum.shuffle(deck)
  end

  defp super_shuffle(deck, n) do
    Enum.shuffle(deck)
    super_shuffle(deck, n-1)
  end

  defp ranks, do: Enum.to_list(2..14)
  defp suits, do: [:spades, :clubs, :hearts, :diamonds]
end

