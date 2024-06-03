defmodule Acx.Persist.EctoAdapterTest do
  use ExUnit.Case, async: true
  alias Acx.Persist.PersistAdapter
  alias Acx.Persist.EctoAdapter.CasbinRule
  doctest Acx.Persist.EctoAdapter
  doctest Acx.Persist.PersistAdapter.Acx.Persist.EctoAdapter
  doctest Acx.Persist.EctoAdapter.CasbinRule

  defmodule MockTestRepo do
    use Acx.Persist.MockRepo, pfile: "../data/acl.csv" |> Path.expand(__DIR__)
  end

  describe "using the mock repo" do
    @repo MockTestRepo

    test "loads policies from the database" do
      expected =
        {:ok,
         [
           ["p", "alice", "blog_post", "create"],
           ["p", "alice", "blog_post", "delete"],
           ["p", "alice", "blog_post", "modify"],
           ["p", "alice", "blog_post", "read"],
           ["p", "bob", "blog_post", "read"],
           ["p", "peter", "blog_post", "create"],
           ["p", "peter", "blog_post", "modify"],
           ["p", "peter", "blog_post", "read"]
         ]}

      loaded =
        Acx.Persist.EctoAdapter.new(@repo)
        |> Acx.Persist.PersistAdapter.load_policies()

      assert loaded === expected
    end

    test "updates policy" do
      expected = %CasbinRule{id: 5, ptype: "p", v0: "bob", v1: "blog_post", v2: "create"}

      assert {:ok, ^expected} =
               with(
                 adapter <- Acx.Persist.EctoAdapter.new(@repo),
                 do:
                   Acx.Persist.PersistAdapter.update_policy(
                     adapter,
                     {:p, ["bob", "blog_post", "read"]},
                     {:p, ["bob", "blog_post", "create"]}
                   )
               )
    end
  end
end
