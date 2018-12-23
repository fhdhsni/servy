defmodule Servy.Parser do
  require IEx
  alias Servy.Conv

  def parse(request) do
    [top, param_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _] = String.split(request_line)

    headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], param_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  @doc """
  Parses the given param string of the form `key1=value1&key2=value2`
  into a map with corresponding keys and values.

  ## Examples
      iex> params_string = "name=Baloo&type=Brown"
      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
      %{"name" => "Baloo", "type" => "Brown"}
      iex> Servy.Parser.parse_params("multipart/form-data", params_string)
      %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params(_, _) do
    %{}
  end

  def parse_headers(header_lines, headers \\ %{})
  def parse_headers([], headers), do: headers

  def parse_headers([car | cdr], headers) do
    [key, value] = Regex.split(~r/:/, car, parts: 2)

    parse_headers(cdr, Map.merge(headers, %{key => String.trim(value)}))
  end
end
