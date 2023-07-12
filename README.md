# cw.nvim

A plugin to tail AWS CloudWatch Logs using [cw](https://github.com/lucagrulla/cw).

## Requirements

[neovim >= 0.7.0](https://github.com/neovim/neovim/wiki/Installing-Neovim)

[cw](https://github.com/lucagrulla/cw) installed and on your path

## Installation

Install using your preferred plugin manager

For example, using Packer

`use({
	"DiscretePython/cw.nvim",
	config = function()
		require("cw").setup({})
	end,
})`

## Configuration

An options table can be passed to the setup function. Valid options are below:

- `profile` string - Changes which AWS profile is used by default. Default: default

## Commands

- `:CWToggle` Toggle the cw overlay
- `:CWSwitchProfile profile` Switches AWS profile to the passed string

## Using

The cw overlay can be opened and closed using the :CWToggle command. You may wish
to set this to a keymapping of your choice. For example, mapping to `gw` in normal mode:

`vim.api.nvim_set_keymap("n", "gw", ":CWToggle<CR>", { silent = true, noremap = true })`

After opening the CW overlay, your default profile's log groups will be listed. Highlight
the group you wish to tail and follow and press `<CR>`. The log groups output will be tailed
and followed in the overlay.

Press `q` to return to a list of groups. Pressing `q` again will close the overlay.

Pressing `r` will refresh the list of groups.

## Features

- [x] List Log Groups
- [x] Tail and Follow Log Group
- [x] Switch AWS Profiles
- [ ] Tail Log Group
- [ ] Switch AWS Regions
- [ ] Configure Date and Time Preferences
- [ ] Multi-group Tails
