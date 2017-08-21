Project Status: Complete | Maintaining
# zshconf
A barebones zsh configuration tool

# Installation
To install zshconf clone this repository into `$HOME/.config/zshconf` and source the `zshconf.zsh` file in your `.zshrc`.

# Configuration
Zshconf looks for a `zshconf` file. When the `zshconf.zsh` file is sourced in your `.zshrc` it will load all the files specified in this `zshconf` file.

Giving you the plugin functionality of many alternatives, but with only a ~120 line zsh file. 

## zshconf file
By default zshconf looks for a `zshconf` file in `$HOME/.config/zshconf/zshconf`. Set the `ZSHCONF_FILE` and `ZSHCONF_DIR` environment variables to customize this location.  

The `zshconf` file follows the scheme:

```
<Git Repository URI>
	<file>
	<file>
	<file>
	<file>
... repeat ...
```

It will clone down any Git repository and source each file listed.

## Other paramteres
Zshconf reads certain environment variables for settings.

- ZSHCONF_DIR (string): Absolute path to directory zshconf uses for all general work
- ZSHCONF_REPO_DIR (string): Absolute path directory zshconf uses to save external Git repositories listed in `zshconf` file
- ZSHCONF_FILE (string): Abolute path to `zshconf` file
- ZSHCONF_REPO_UPDATE_INTERVAL (integer, seconds): How often zshconf checks for updates to external repositories listed in `zshconf`
- ZSHCONF_SELF_UPDATE_INTERVAL (integer, seconds): How often zshconf checks for updates to itself

# Updating
Zshconf checks for updates every day. It pulls down updates using Git. 
