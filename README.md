# Kakoune Configuration

This is my configuration for [Kakoune](http://kakoune.org/) editor.

## Dependencies

- Rust

On Ubuntu, install dependencies with:

```bash
sudo apt install rustc
```

## Setup

Clone this repository to `~/.config/kak`:

```bash
git clone git@github.com:strika/config-kak.git ~/.config/kak
```

Install [plug.kak](https://github.com/andreyorst/plug.kak):

```bash
mkdir -p $HOME/.config/kak/plugins
git clone https://github.com/andreyorst/plug.kak.git $HOME/.config/kak/plugins/plug.kak
```

Start Kakoune and run `plug-install` command.
