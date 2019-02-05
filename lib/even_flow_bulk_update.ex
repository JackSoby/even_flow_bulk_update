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
    result =
      File.stream!("./data/evenflow-google-data.csv")
      |> CSV.decode!(headers: true)
      |> Stream.map(fn attribute ->
        case attribute["brand"] do
          "Evenflo" ->
            %{
              id: attribute["id"],
              link: attribute["link"]
            }

          _ ->
            nil
        end
      end)
      |> Enum.to_list()
      |> Enum.filter(fn prod -> prod end)
      |> Poison.encode!()

    token = "api_key"

    headers = [Authorization: "Bearer #{token}", "Content-Type": "application/json"]

    test_body =
      [
        %{
          ID: "15311935",
          "Product Page URL": "http://www.evenflo.com/strollers/cambridge/15311935.html"
        }
      ]
      |> Poison.encode!()

    response =
      HTTPoison.put!(
        "https://app.salsify.com/api/v1/orgs/org_id/products",
        test_body,
        headers
      )

    IO.inspect(response)
  end
end
