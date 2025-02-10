defmodule Mcex.Modifier.IfTest do
  use ExUnit.Case, async: true
  alias Mcex.Modifier.If

  setup do
    %{mappings: %Mc.Mappings{}}
  end

  describe "modify/3" do
    test "parses `args` as: r:<regex> t:<true script> f:<false script>", do: true
    test "runs <true script> if <regex> matches `buffer`, else runs <false script>", do: true

    test "works", %{mappings: mappings} do
      assert If.modify("foo", "r:fo t:b%20true%20dat f:b%20nah!", mappings) == {:ok, "true dat"}
      assert If.modify("more stuff", "t:b%20yep  r:ff$  f:b%20nah", mappings) == {:ok, "yep"}
      assert If.modify("howdy", "r:h.wdi  f:range%203  t:date", mappings) == {:ok, "1\n2\n3"}
    end

    @parse_err "Mcex.Modifier.If: parse error"
    @regex_err "Mcex.Modifier.If: bad regex"

    test "detects parse errors" do
      assert If.modify("n/a", "", %{}) == {:error, @parse_err}
      assert If.modify("", "r:regx", %{}) == {:error, @parse_err}
      assert If.modify("", "f:false  t:true", %{}) == {:error, @parse_err}
      assert If.modify("", "foo", %{}) == {:error, @parse_err}
    end

    test "errors when regex is bad" do
      assert If.modify("dosh", "r:? t:mod1 f:mod2", %{}) == {:error, @regex_err}
    end

    test "works with ok tuples", %{mappings: mappings} do
      assert If.modify({:ok, "aaa"}, "r:.aa  t:b%20t  f:b%20f", mappings) == {:ok, "t"}
      assert If.modify({:ok, "aaa"}, "r:ba.  t:b%20t  f:b%20f", mappings) == {:ok, "f"}
    end

    test "allows error tuples to pass through" do
      assert If.modify({:error, "reason"}, "", %{}) == {:error, "reason"}
    end
  end
end
