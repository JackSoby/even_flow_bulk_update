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

  def evenflow_import do
    body =
      File.stream!("./data/evenflow-google-data.csv")
      |> CSV.decode!(headers: true)
      |> Stream.chunk_every(10)
      |> Stream.map(fn attributes ->
        encode_and_send(attributes)
      end)
      |> Stream.run()
  end

  def encode_and_send(attributes) do
    body =
      attributes
      |> create_encoded_body

    token = "api_url"

    headers = [Authorization: "Bearer #{token}", "Content-Type": "application/json"]

    response =
      HTTPoison.put!(
        "https://app.salsify.com/api/v1/orgs/org_id/products",
        body,
        headers
      )
  end

  def create_encoded_body(attributes) do
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
end
