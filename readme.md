# NixOS configuration

An ever-evolving work in progress, my NixOS configuration allows me to share an identical system
configuration on many different machines while also providing a historical record of the tools
and workflows that I've used for my personal productivity over time.

## Can I use this?

In theory, this configuration should work for others, though portability beyond myself isn't
necessarily a goal of mine. There isn't anything specific to me here other than the username
set for home-manager and  potentially the `hardware-configuration`, but this is usually
auto-generated for you anyway, so replacing it should be trivial.

If you are planning on using this configuration as a starting point, you may wish to remove
the references to my development environment flake, unless you want to try using the same
tools that I use with my customized configurations. These are highly tailored to my personal
preference, so you may not find them suitable. Of course, I would argue that they're great :)

## Configuration structure

The configuration is structured as a Flake and relies on other personal customizations that I
maintain for myself, particularly my [development environment](https://github.com/jkaye2012/devenv).
The configuration is built for x86-64, and currently hasn't been tested on other systems (though
I suspect that it would work without issue).

Flakes used by the configuration are loaded as NixOS modules, all of which are provided a consistent
set of `specialArgs`:

* `inputs`: all inputs to the configuration (e.g. `devenv`, `home-manager`, etc.)
* `outputs`: the final Flake output, useful for e.g. overlays
* `system`: the system type used for the configuration, currently hard-coded to `x86-64`

## Modules

There are currently only a few different modules in use for the configuration. Each has its own
conventions which should be readily apparentl from reading the module source. The modules
in use are:

* `configuration.nix`: system-wide configuration. Almost all core NixOS configuration goes here
* `system-packages.nix`: isolated definition of system-wide packages. This allows other flakes
  to be easily injected into the module via the `inputs` and `system` arguments
* `home-manager/home.nix`: home-manager configuration. Some programs and settings are configured
  in the module directly, while others are broken out into their own individual files
