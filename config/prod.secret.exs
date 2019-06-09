# In this file, we load production configuration and
# secrets from environment variables. You can also
# hardcode secrets, although such is generally not
# recommended and you have to remember to add this
# file to your .gitignore.
use Mix.Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :tuts, TutsWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  force_ssl: [hsts: true],
  https: [
    port: 443,
    opt_app: :tuts,
    keyfile: "/etc/letsencrypt/live/functuts.com/privkey.pem",
    cacertfile: "/etc/letsencrypt/live/functuts.com/chain.pem",
    certfile: "/etc/letsencrypt/live/functuts.com/cert.pem"
  ],
  secret_key_base: secret_key_base
