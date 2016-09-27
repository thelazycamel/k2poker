defmodule GameResultTest do
  use ExUnit.Case

  doctest K2poker.GameResult

  setup do
    [ game_result: %K2poker.GameResult{
        id: "player_1",
        status: :win,
        cards: ["Ac", "Kc", "Qc", "Jc", "Tc"],
        win_description: :royal_flush,
        lose_description: :high_card
      }
    ]
  end

  test "it should hold the :id (player_id)", context do
    assert context.game_result.id == "player_1"
  end

  test "it should hold status as an atom", context do
    assert context.game_result.status == :win
  end

  test "it should hold an array of cards", context do
    assert context.game_result.cards == ["Ac", "Kc", "Qc", "Jc", "Tc"]
  end

  test "it should hold the win description", context do
    assert context.game_result.win_description == :royal_flush
  end

  test "it should hold the lose description", context do
    assert context.game_result.lose_description == :high_card
  end

end
