---
name: Config
---

Castro uses a configuration file to handle all systems. The file `config.toml` is generated at the installation process.

- [Mode](#mode)
- [CheckUpdates](#checkupdates)
- [Port](#port)
- [URL](#url)
- [Datapack](#datapack)

# Mode

Sets the castro running mode. Possible values are

- `prod`
- `dev`

While on `dev` mode Castro will reload all pages, widgets and config file on each request. This mode is expensive. Dont expose this mode to the public.

# CheckUpdates

If `true` checks how many commits behind you are running Castro at start-up.

# Port

Determines the port where the HTTP server should listen to.

# URL

Sets the URL for all links.

# Datapack

Path of your server datapack. Where `config.lua` is located. This path is set at installation.
