defmodule Warpath.Query.FilterOperatorTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Warpath.Element
  alias Warpath.Execution.Env
  alias Warpath.Expression
  alias Warpath.Query.FilterOperator

  @relative_path [{:root, "$"}]

  defp env_for_filter(filter) do
    {:ok, %Expression{tokens: [_root, {:filter, expression} | _]}} =
      Expression.compile("$[?( #{filter} )]")

    Env.new({:filter, expression})
  end

  defp quoted_key(key) do
    case key do
      atom when is_atom(atom) ->
        ":'#{Atom.to_string(atom)}'"

      _ ->
        "['#{key}']"
    end
  end

  defp key_generator do
    gen all key <- one_of([string(:alphanumeric), atom(:alphanumeric)]),
            is_atom(key) or key != "" do
      key
    end
  end

  test "evaluate a filter on data type other then map or list result in an empty list " do
    env = env_for_filter("@['a property']")

    assert FilterOperator.evaluate(1, @relative_path, env) == []
    assert FilterOperator.evaluate(1.0, @relative_path, env) == []
    assert FilterOperator.evaluate(true, @relative_path, env) == []
    assert FilterOperator.evaluate(:atom, @relative_path, env) == []
    assert FilterOperator.evaluate("string", @relative_path, env) == []
    assert FilterOperator.evaluate(make_ref(), @relative_path, env) == []
    assert FilterOperator.evaluate({:tuple, 2}, @relative_path, env) == []
  end

  property "apply a filter that is truth on map always include it on result" do
    check all map <- map_of(key_generator(), term(), min_length: 1),
              {key, _value} = Enum.random(map) do
      env = env_for_filter("@.#{quoted_key(key)}")

      assert FilterOperator.evaluate(map, @relative_path, env) == [
               Element.new(map, @relative_path)
             ]
    end
  end

  property "apply a filter that is not truth on map result in a empty list" do
    unique = make_ref()
    env = env_for_filter("@['#{inspect(unique)}']")

    check all map <- map_of(term(), term(), min_length: 1) do
      assert FilterOperator.evaluate(map, @relative_path, env) == []
    end
  end

  property "keep only item that is accepted by filter applied in na list" do
    env = env_for_filter("is_integer(@)")

    check all list <- list_of(term()) do
      result = FilterOperator.evaluate(list, @relative_path, env)
      terms = Enum.map(result, &Element.value/1)

      assert Enum.all?(terms, &is_integer/1)
    end
  end

  property "empty list when there isn' any titem that is accepted by filter" do
    env = env_for_filter("is_float(@)")

    check all map <- list_of(integer()) do
      assert FilterOperator.evaluate(map, @relative_path, env) == []
    end
  end

  property "can collect elements that match filter criteria" do
    map_generator = map_of(key_generator(), term(), length: 1..3)
    element = map(map_generator, &Element.new(&1, @relative_path))

    check all elements <- list_of(element, length: 1..10),
              %Element{value: value} = Enum.random(elements),
              {key, _} = Enum.random(value) do
      result =
        FilterOperator.evaluate(
          elements,
          [],
          env_for_filter("@.#{quoted_key(key)}")
        )

      assert Enum.all?(result, &Map.has_key?(Element.value(&1), key))
    end
  end

  test "evaluate/3 is nil safe" do
    env = env_for_filter("@.any")

    assert FilterOperator.evaluate(nil, @relative_path, env) == []
  end
end
