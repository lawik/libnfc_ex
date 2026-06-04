# SPDX-License-Identifier: Apache-2.0

defmodule LibNFC.MixProject do
  use Mix.Project

  @source_url "https://github.com/maltoe/libnfc_ex"
  @version "0.1.0"

  def project do
    [
      name: "LibNFC",
      version: @version,
      source_url: @source_url,
      homepage_url: @source_url,
      app: :libnfc_ex,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      compilers: compilers(),
      make_targets: ["all"],
      make_clean: ["clean"],
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      lint: [
        "format --check-formatted",
        "cmd make check"
      ]
    ]
  end

  defp compilers do
    [:elixir_make] ++ Mix.compilers()
  end

  defp deps do
    [
      {:elixir_make, "~> 0.9", runtime: false},
      {:ex_doc, "> 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "LibNFC",
      extras: [
        "README.md": [title: "README"],
        "CHANGELOG.md": [title: "Changelog"],
        LICENSE: [title: "License"]
      ],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      formatters: ["html"]
    ]
  end

  defp package do
    [
      description: "libnfc native wrapper",
      maintainers: ["@maltoe"],
      licenses: ["Apache-2.0"],
      links: %{
        Changelog: "https://hexdocs.pm/libnfc_ex/changelog.html",
        GitHub: @source_url
      }
    ]
  end
end
