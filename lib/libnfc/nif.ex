# SPDX-License-Identifier: Apache-2.0

defmodule LibNFC.NIF do
  @moduledoc false

  @on_load :on_load

  # The Makefile installs the shared object to the application's priv dir.
  app = Mix.Project.config()[:app]

  def on_load do
    path =
      unquote(app)
      |> :code.priv_dir()
      |> :filename.join(~c"libnfc_nif")

    case :erlang.load_nif(path, 0) do
      :ok ->
        :ok

      {:error, reason} ->
        # The NIF only builds and loads on Linux. On other platforms (e.g.
        # macOS development hosts, including when a crosscompiled .so for a
        # Nerves target is present in priv), allow the module to load anyway
        # so that LibNFC.Mock can be used; calling any NIF function will
        # raise :not_loaded.
        case :os.type() do
          {:unix, :linux} -> {:error, reason}
          _ -> :ok
        end
    end
  end

  def list_devices, do: not_loaded()
  def open, do: not_loaded()
  def open(_device), do: not_loaded()
  def version, do: not_loaded()
  def initiator_select_passive_target(_open_device, _modulation), do: not_loaded()
  def initiator_target_is_present(_open_device), do: not_loaded()

  defp not_loaded, do: :erlang.nif_error(:not_loaded)
end
