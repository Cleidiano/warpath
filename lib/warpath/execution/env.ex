defmodule Warpath.Execution.Env do
  @moduledoc false

  @type t :: %__MODULE__{instruction: any()}

  defstruct operator: nil, instruction: nil, previous_operator: nil

  def new(instruction, previous_operator \\ nil) do
    %__MODULE__{
      operator: operator_for(instruction),
      instruction: instruction,
      previous_operator: previous_operator
    }
  end

  defp operator_for({:root, _}), do: RootOperator
  defp operator_for({:dot, _}), do: IdentifierOperator
  defp operator_for({:wildcard, _}), do: WildcardOperator
  defp operator_for({:scan, _}), do: DescendantOperator
  defp operator_for({:array_indexes, _}), do: ArrayIndexOperator
  defp operator_for({:filter, _}), do: FilterOperator
  defp operator_for({:array_slice, _}), do: SliceOperator
  defp operator_for({:union, _}), do: UnionOperator
end