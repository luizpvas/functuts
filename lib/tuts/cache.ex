defmodule Tuts.Cache do
  @moduledoc """
  Wrapper around `ConCache` that only enables caching in the `prod` environment.
  """

  def get_or_store(key, callback) do
    get_or_store_by_env(Mix.env, key, callback)
  end

  defp get_or_store_by_env(:dev, key, callback) do
    callback.()
  end

  defp get_or_store_by_env(:test, key, callback) do
    callback.()
  end


  defp get_or_store_by_env(:prod, key, callback) do
    ConCache.get_or_store(:cache, key, fn ->
      callback.()
    end)
  end
end