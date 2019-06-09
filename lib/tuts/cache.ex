defmodule Tuts.Cache do
  @moduledoc """
  Wrapper around `ConCache` that only enables caching in the `prod` environment.
  """

  def get_or_store(key, callback) do
    run_get_or_store(Mix.env, key, callback)
  end

  defp run_get_or_store(:dev, key, callback) do
    callback.()
  end

  defp run_get_or_store(:test, key, callback) do
    callback.()
  end


  defp run_get_or_store(:prod, key, callback) do
    ConCache.get_or_store(:cache, key, fn ->
      callback.()
    end)
  end
end