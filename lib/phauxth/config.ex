defmodule Phauxth.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.

  The following are valid configuration items.


  | name               | type          | default          |
  | :----------------- | :-----------  | ---------------: |
  | log_level          | atom          | :info            |
  | drop_user_keys     | list of atoms | []               |
  | endpoint           | module        | N/A              |
  | token_salt         | string        | N/A              |

  ## Umbrella apps

  Due to how the configuration is handled in umbrella apps, you will
  need to override the `token_salt` and `endpoint` values when using
  them in the sub-apps.

  The example below shows how the token can be generated this way:

      Phauxth.Token.sign(conn, data, token_salt: "somesalt")

  And this example shows how the Confirm.verify function needs to be
  called:

      Phauxth.Confirm.verify(params, MyApp.Accounts,
        endpoint: MyAppWeb.Endpoint, token_salt: "somesalt")

  ## Examples

  Add a `phauxth` entry to the `config.exs` file in your project,
  as in the following example.

      config :phauxth,
        token_salt: "YkLmt7+f",
        endpoint: MyAppWeb.Endpoint,
        log_level: :warn,
        drop_user_keys: [:shoe_size]

  """

  @doc """
  The log level for Phauxth logs.

  This should either be an atom, :debug, :info, :warn or :error, or
  false.

  The default is :info, which means that :info, :warn and :error logs
  will be returned.
  """
  def log_level do
    Application.get_env(:phauxth, :log_level, :info)
  end

  @doc """
  The keys that are removed from the user struct before it is passed
  on to another function.

  This should be a list of atoms.

  By default, :password_hash, :password and :otp_secret are removed,
  and this option allows you to add to this list.
  """
  def drop_user_keys do
    Application.get_env(:phauxth, :drop_user_keys, []) ++
    [:password_hash, :password, :otp_secret]
  end

  @doc """
  The endpoint of your app.

  This is used by the Phauxth.Confirm module.
  """
  def endpoint do
    Application.get_env(:phauxth, :endpoint) || raise """
    You need to either set the `endpoint` value in the config/config.exs
    file or set it by using the `endpoint` keyword argument.
    """
  end

  @doc """
  The salt to be used when creating and verifying tokens.

  This is used by the Phauxth.Authenticate module, if you are using
  token authentication, and by the Phauxth.Confirm module.
  """
  def token_salt do
    Application.get_env(:phauxth, :token_salt) || raise """
    You need to either set the `token_salt` value in the config/config.exs
    file or set it by using the `token_salt` keyword argument.

    To generate a suitable random salt, use the `gen_token_salt` function
    in the Phauxth.Config module.
    """
  end

  @doc """
  Generate a random salt for use with token authentication.
  """
  def gen_token_salt(length \\ 8)
  def gen_token_salt(length) when length > 7 do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end
  def gen_token_salt(_) do
    raise ArgumentError, """
    The length is too short. The token_salt should be at least 8 characters long.
    """
  end
end
