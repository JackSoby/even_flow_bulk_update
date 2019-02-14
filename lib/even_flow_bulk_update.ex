defmodule EvenFlowBulkUpdate do
  @moduledoc """
  Documentation for EvenFlowBulkUpdate.
  """

  @doc """
  Hello world.

  ## Examples

      iex> EvenFlowBulkUpdate.hello
      :world

  """
  require IEx

  def evenflow_google_import do
    body =
      File.stream!("./data/evenflow-google-data.csv")
      |> CSV.decode!(headers: true)
      |> Stream.chunk_every(10)
      |> Stream.map(fn attributes ->
        encode_and_send(attributes, :google)
      end)
      |> Stream.run()
  end

  def encode_and_send(attributes, :google) do
    body =
      attributes
      |> create_encoded_body_google

    token = "api_url"

    headers = [Authorization: "Bearer #{token}", "Content-Type": "application/json"]

    response =
      HTTPoison.put!(
        "https://app.salsify.com/api/v1/orgs/org_id/products",
        body,
        headers
      )
  end

  def create_encoded_body_google(attributes) do
    attributes
    |> Enum.map(fn attribute ->
      case attribute["brand"] do
        "Evenflo" ->
          %{
            ID: attribute["id"],
            "Product Page URL": attribute["link"]
          }

        "Evenflo Gold" ->
          %{
            ID: attribute["id"],
            "Product Page URL": attribute["link"]
          }

        _ ->
          nil
      end
    end)
    |> Enum.filter(fn prod -> prod end)
    |> Poison.encode!()
  end

  def evenflow_open_line_usa_import do
    body =
      File.stream!("./data/2019-open-line-usa.csv")
      |> CSV.decode!(headers: true)
      |> Stream.chunk_every(10)
      |> Stream.map(fn attributes ->
        encode_and_send(
          attributes,
          :open_line
        )
      end)
      |> Stream.run()
  end

  def create_encoded_body_open_line(attributes) do
    attributes
    |> Enum.map(fn attribute ->
      case attribute[" Standard  "] do
        "" ->
          %{
            ID: attribute["Model "],
            SalePrice: price(attribute[" Sale Price "])
          }

        _ ->
          %{
            ID: attribute["Model "],
            SalePrice: price(attribute[" Sale Price "])
            # msrp: price(attribute[" Standard  "])
          }
      end
    end)
    |> Enum.filter(fn prod -> prod end)
    |> Poison.encode!()
  end

  def price(price) do
    String.replace(price, "$", "")
    |> String.trim()
    |> String.to_float()
  end

  def encode_and_send(attributes, :open_line) do
    body =
      attributes
      |> create_encoded_body_open_line

    token = "api_key"

    headers = [Authorization: "Bearer #{token}", "Content-Type": "application/json"]

    response =
      HTTPoison.put!(
        "https://app.salsify.com/api/v1/orgs/org_id/products",
        body,
        headers
      )

    IO.puts("---DONE UPDATING---")

    # IO.inspect(response)
  end

  def evenflow_gold_open_line_import do
    body =
      File.stream!("./data/gold-open-even-flow.csv")
      |> CSV.decode!(headers: true)
      |> Stream.chunk_every(10)
      |> Stream.map(fn attributes ->
        encode_and_send(
          attributes,
          :gold_open
        )
      end)
      |> Stream.run()
  end

  def create_encoded_body_gold_open_line(attributes) do
    attributes
    |> Enum.map(fn attribute ->
      case attribute["Model "] do
        "63012312" ->
          nil

        "63012311" ->
          nil

        _ ->
          check_for_id(attribute)
      end
    end)
    |> Enum.filter(fn prod -> prod end)
    |> Poison.encode!()
  end

  def check_for_id(attribute) do
    case String.length(attribute["Model "]) do
      0 ->
        nil

      1 ->
        nil

      2 ->
        nil

      3 ->
        nil

      _ ->
        %{
          ID: attribute["Model "],
          usd: price(attribute[" MSRP "])
        }
    end
  end

  def encode_and_send(attributes, :gold_open) do
    body =
      attributes
      |> create_encoded_body_gold_open_line

    token = "api_token"

    headers = [Authorization: "Bearer #{token}", "Content-Type": "application/json"]

    response =
      HTTPoison.put!(
        "https://app.salsify.com/api/v1/orgs/org_id/products",
        body,
        headers
      )

    IO.puts("---DONE UPDATING---")

    IO.inspect(response)
  end
end
