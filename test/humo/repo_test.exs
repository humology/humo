defmodule Humo.RepoTest do
  use Humo.DataCase, async: true
  alias Humo.Repo

  defmodule User do
    use Ecto.Schema

    @primary_key false
    schema "users" do
      field :name, :string
    end
  end

  setup do
    Repo.query!("CREATE TABLE users(name TEXT);")

    :ok
  end

  describe "none/1" do
    test "returns no records" do
      Repo.insert!(%User{name: "Miguel"})

      assert Repo.none(User) |> Repo.all() == []
    end
  end
end
