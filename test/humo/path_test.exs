defmodule Humo.PathTest do
  use ExUnit.Case, async: true

  test "ignores ./ in relative path" do
    assert "foo/bar" = Humo.Path.normalize(["./foo/", "./bar/"])
  end

  test "ignores ./ in absolute path" do
    assert "/foo/bar" = Humo.Path.normalize(["/foo/", "./bar/"])
  end

  test "eliminates parent folder when succeeded with ../" do
    assert "/foo/a/d" = Humo.Path.normalize(["/foo/bar/..", "a/b/c", "../../d/"])
  end
end
