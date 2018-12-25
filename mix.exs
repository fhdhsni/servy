defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      app: :servy,
      description: "A crappy HTTP server",
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      # give the callback module, the callback module can be any
      # module the uses the Application behaviour
      # OTP calls the module `start` function
      mod: {Servy, []},
      env: [port: 4445]
    ]
  end

  defp deps do
    [
      {:poison, "~> 4.0"}
    ]
  end
end
