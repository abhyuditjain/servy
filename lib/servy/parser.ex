defmodule Servy.Parser do
  # If we don't use "as", the alias will be the last part of the module name, in this case Conv
  alias Servy.Conv, as: Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      headers: headers,
      params: params
    }
  end

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}

  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn val, acc ->
      [key, value] = String.split(val, ": ")
      Map.put(acc, key, value)
    end)
  end

  defp parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")

    parse_headers(tail, Map.put(headers, key, value))
  end

  defp parse_headers([], headers), do: headers
end
