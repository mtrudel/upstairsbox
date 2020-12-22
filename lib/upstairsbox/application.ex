defmodule Upstairsbox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Upstairsbox.Supervisor]

    hap_server_config = %HAP.AccessoryServer{
      name: "Upstairs Hallway HAP Gateway",
      identifier: "11:22:33:44:55:66",
      accessory_type: 2,
      accessories: [
        %HAP.Accessory{
          name: "Skylight Blinds",
          services: [
            %HAP.Services.WindowCovering{
              current_position: {Upstairsbox.WindowCovering, :current_position},
              target_position: {Upstairsbox.WindowCovering, :target_position},
              position_state: {Upstairsbox.WindowCovering, :position_state},
              hold_position: {Upstairsbox.WindowCovering, :hold_position}
            }
          ]
        }
      ]
    }

    children =
      [
        Upstairsbox.WindowCovering,
        {HAP, hap_server_config}
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Upstairsbox.Worker.start_link(arg)
      # {Upstairsbox.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: Upstairsbox.Worker.start_link(arg)
      # {Upstairsbox.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:upstairsbox, :target)
  end
end
