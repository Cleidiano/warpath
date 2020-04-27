defmodule Warpath.Expression do
  @moduledoc false
  alias Warpath.ExpressionError
  alias Warpath.Parser
  alias Warpath.Tokenizer

  @type root :: {:root, String.t()}
  @type property :: {:property, String.t()}
  @type has_property :: {:has_property?, property}
  @type dot_access :: {:dot, property}
  @type index_access :: {:index_access, integer}
  @type array_indexes :: {:array_indexes, [index_access, ...]}
  @type wildcard :: {:wildcard, :*}
  @type operator :: :< | :> | :<= | :>= | :== | :!= | :=== | :!== | :and | :or | :in
  @type fun ::
          :is_atom
          | :is_binary
          | :is_boolean
          | :is_float
          | :is_integer
          | :is_list
          | :is_map
          | :is_nil
          | :is_number
          | :is_tuple

  @type filter :: {:filter, has_property | {operator | fun, term}}
  @type scan :: {:scan, property | wildcard | filter | array_indexes}
  @type token :: root | dot_access | wildcard | array_indexes | filter | scan
  @type t :: list(token)

  @spec compile(String.t()) :: {:ok, [token, ...]} | {:error, ExpressionError.t()}
  def compile(expression) when is_binary(expression) do
    with {:ok, tokens} <- Tokenizer.tokenize(expression),
         {:ok, _} = expression_tokens <- Parser.parse(tokens) do
      expression_tokens
    else
      {:error, error} ->
        message = Exception.message(error)
        {:error, ExpressionError.exception(message)}
    end
  end
end
