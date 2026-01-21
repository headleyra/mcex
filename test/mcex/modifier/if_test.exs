defmodule Mcex.Modifier.IfTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.If

  setup do
    %{mappings: Mc.Mappings.s()}
  end

  describe "modify/3" do
    test "parses `args` as: <sep> <regex><sep> <true script><sep> <false script>", do: true
    test "runs <true script> if <regex> matches `buffer`, else runs <false script>", do: true

    test "works", %{mappings: mappings} do
      assert If.modify("foo", ", fo, b true dat, b nah!", mappings) == {:ok, "true dat"}
      assert If.modify("more stuff", ": ff$: b yep: b nah", mappings) == {:ok, "yep"}
      assert If.modify("howdy", ", h.wdi, date, range 3", mappings) == {:ok, "1\n2\n3"}
    end

    test "runs against the `buffer`", %{mappings: mappings} do
      assert If.modify("foo", ", no-match, b foo, append -bar", mappings) == {:ok, "foo-bar"}
    end

    @parse_err "Mcex.Modifier.If: parse error"

    test "detects parse errors" do
      assert If.modify("n/a", "", %{}) == {:error, @parse_err}
      assert If.modify("", ", regx-only", %{}) == {:error, @parse_err}
      assert If.modify("", ", regx, true-script-only", %{}) == {:error, @parse_err}
    end

    @regx_err "Mcex.Modifier.If: bad regex"

    test "errors when regex is bad" do
      assert If.modify("dosh", ", ?, b true, b false", %{}) == {:error, @regx_err}
    end

    test "works with ok tuples", %{mappings: mappings} do
      assert If.modify({:ok, "aaa"}, ", .aa, b t, b f", mappings) == {:ok, "t"}
      assert If.modify({:ok, "aaa"}, ", ba., b t, b f", mappings) == {:ok, "f"}
    end

    test "allows error tuples to pass through" do
      assert If.modify({:error, "reason"}, "", %{}) == {:error, "reason"}
    end
  end
end
