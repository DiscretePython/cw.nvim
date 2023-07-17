local config = require("config")
local buffer = require("buffer")
local utils = require("utils")
local commands = require("commands")

local M = {}

M.initialized = false

function M.setup(options)
	config.set_with_defaults(options)

	buffer.create()
	vim.api.nvim_buf_set_option(buffer.number, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buffer.number, "bufhidden", "hide")

	vim.api.nvim_create_user_command("CWToggle", M.toggle, {})
	vim.api.nvim_create_user_command("CWSwitchProfile", M.switch_profile, { nargs = 1 })
end

function M.toggle()
	if not M.initialized then
		M.initialized = true
		commands.list_groups()
	end

	if not config.is_configured() then
		return
	end

	local ui = vim.api.nvim_list_uis()[1]

	local buf_hidden = 0
	local buf_info = vim.api.nvim_call_function("getbufinfo", { buffer.number })[1]

	if buf_info then
		buf_hidden = buf_info.hidden
	end
	local current_bufnr = vim.api.nvim_win_get_buf(0)

	if current_bufnr == buffer.number then
		buffer.hide()
	elseif buf_hidden == 0 and buf_info.windows[1] then
		vim.api.nvim_set_current_win(buf_info.windows[1])
	else
		buffer.show(ui)
	end

	local winnr = vim.fn.bufwinid(buffer.number)
	if winnr ~= -1 then
		vim.api.nvim_win_set_option(winnr, "wrap", config.values.wrap)
	end
end

function M.switch_profile(inp)
	local current_bufnr = vim.api.nvim_win_get_buf(0)
	if current_bufnr == buffer.number then
		utils.hide_cw()
	end

	config.values.profile = inp.fargs[1]
	M.initialized = false
end

return M
