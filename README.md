Project Status: Complete | Maintaining

# zshconf
A barebones Zsh plugin loader tool.

# Table Of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Updating](#updating)

# Overview
Zshconf is a lightweight plugin loader utility. It allows you to source 
individual Zsh files from Git repositories.  

This gives you the ability to incorporate features other's have made into your 
own Zsh profile.

# Installation
To install Zshconf clone this repository into `$HOME/.config/zshconf`:

```
git clone git@github.com:Noah-Huppert/zshconf.git ~/.config/zshconf
```

Then source the `zshconf.zsh` file in your Zsh profile:  

```
# ~/.zshrc
source $HOME/.config/zshconf/zshconf.zsh
```

# Usage
Zshconf determines which files to source by reading a `zshconf` file.

By default Zshconf looks for a `zshconf` file in 
`$HOME/.config/zshconf/zshconf`.  

Set the `ZSHCONF_FILE` and `ZSHCONF_DIR` environment variables to customize 
the location.  

The `zshconf` file follows the format:

```
<Git Repository URI>
	<file>
	<file>
	<file>
	<file>
... repeat ...
```

It will clone down the listed Git repository and source the files listed for 
that Git repository.

## Example Zshconf File
This example `zshconf` file loads a theme from the 
[Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh.git) repository:

```
# oh my zsh
https://github.com/robbyrussell/oh-my-zsh.git
	# lib
	lib/git.zsh
	lib/theme-and-appearance.zsh
	# Theme
	themes/sorin.zsh-theme	
```

This will only load the files necessary to use the "Sorin" Zsh theme.  

All the other unwanted files in the Oh My Zsh repository will not be included 
in you Zsh profile.

## Configuration
Zshconf can be configured with the following environment variables:

- `ZSHCONF_DIR` (string): Absolute path to directory Zshconf uses for all 
                          general work
- `ZSHCONF_REPO_DIR` (string): Absolute path to directory Zshconf uses to save 
                               external Git repositories listed in the 
			       `zshconf` file
- `ZSHCONF_FILE` (string): Absolute path to `zshconf` file
- `ZSHCONF_REPO_UPDATE_INTERVAL` (integer, seconds): How often Zshconf checks 
                                                     for updates to external 
						     repositories listed in 
						     the `zshconf`
- `ZSHCONF_SELF_UPDATE_INTERVAL` (integer, seconds): How often Zshconf checks 
                                                     for updates to itself

# Updating
Zshconf checks for updates every day. It pulls down updates using Git. 
