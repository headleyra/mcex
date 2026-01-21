defmodule Mcex.Modifier.RoundTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.Round

  describe "Mcex.Modifier.Round.modify/3" do
    test "rounds a float to a given decimal precision" do
      assert Round.modify("1.28", "1", %{}) == {:ok, "1.3"}
      assert Round.modify("3.142", "2", %{}) == {:ok, "3.14"}
      assert Round.modify("17.5001", "0", %{}) == {:ok, "18.0"}
      assert Round.modify("17.4887", "0", %{}) == {:ok, "17.0"}
      assert Round.modify("0.0008", "0", %{}) == {:ok, "0.0"}
      assert Round.modify("0.00", "1", %{}) == {:ok, "0.0"}
      assert Round.modify("-1.28", "1", %{}) == {:ok, "-1.3"}
      assert Round.modify("-3.142", "2", %{}) == {:ok, "-3.14"}
      assert Round.modify("-17.5001", "0", %{}) == {:ok, "-18.0"}
      assert Round.modify("-17.4887", "0", %{}) == {:ok, "-17.0"}
      assert Round.modify("-0.0008", "0", %{}) == {:ok, "-0.0"}
      assert Round.modify("2.123", "5", %{}) == {:ok, "2.123"}
    end

    test "handles integers (ignores precision)" do
      assert Round.modify("11", "1", %{}) == {:ok, "11.0"}
      assert Round.modify("-21", "3", %{}) == {:ok, "-21.0"}
      assert Round.modify("85", "0", %{}) == {:ok, "85.0"}
    end

    test "ignores whitespace" do
      assert Round.modify(" 1.88  ", "1", %{}) == {:ok, "1.9"}
      assert Round.modify("\t -1.88 \n ", "1", %{}) == {:ok, "-1.9"}
    end

    @parse_error "Mcex.Modifier.Round: parse error"

    test "errors when a number isn't given" do
      assert Round.modify("", "7", %{}) == {:error, @parse_error}
      assert Round.modify("\t", "5", %{}) == {:error, @parse_error}
      assert Round.modify("one point seven", "1", %{}) == {:error, @parse_error}
    end

    test "errors when precision is outside of 0..15 or is not an integer" do
      assert Round.modify("1.23", "-1", %{}) == {:error, @parse_error}
      assert Round.modify("1.23", "16", %{}) == {:error, @parse_error}
      assert Round.modify("1.23", "1.2", %{}) == {:error, @parse_error}
    end
  end
end
