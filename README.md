Project Status: Complete | Maintaining
# zshconf
A barebones zsh configuration tool

# Installation
To install zshconf clone this repository into `$HOME/.config/zshconf` and source the `zshconf.zsh` file in your `.zshrc`.

# zshconf file
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
