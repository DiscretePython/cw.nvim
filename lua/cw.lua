local commands = require("commands")
local utils = require("utils")

local M = {}

local function with_defaults(options)
	if options == nil then
		return nil
	end

	return {}
end

local function initialize()
	commands.list_groups()
	INITIALIZED = true
end

function M.setup(options)
	UI = vim.api.nvim_list_uis()[1]
	CW_BUFNR = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(CW_BUFNR, "buftype", "nofile")
	vim.api.nvim_buf_set_option(CW_BUFNR, "bufhidden", "hide")
	INITIALIZED = false

	M.options = with_defaults(options)
end

function M.is_configured()
	return M.options ~= nil
end

function M.toggle()
	UI = vim.api.nvim_list_uis()[1]

	local buf_hidden = 0
	local buf_info = vim.api.nvim_call_function("getbufinfo", { CW_BUFNR })[1]

	if buf_info then
		buf_hidden = buf_info.hidden
	end
	local current_bufnr = vim.api.nvim_win_get_buf(0)

	if current_bufnr == CW_BUFNR then
		utils.hide_cw()
	elseif buf_hidden == 0 and buf_info.windows[1] then
		vim.api.nvim_set_current_win(buf_info.windows[1])
	else
		utils.show_cw(CW_BUFNR)
	end

	if not INITIALIZED then
		initialize()
	end
end

M.options = nil
return M
