local commands = require("commands")
local utils = require("utils")

local M = {}

local function with_defaults(options)
	if options == nil then
		options = {}
	end

	return {
		profile = options.profile or "default",
	}
end

function M.setup(options)
	M.bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(M.bufnr, "buftype", "nofile")
	vim.api.nvim_buf_set_option(M.bufnr, "bufhidden", "hide")

	M.options = with_defaults(options)
	M.initialized = false

	vim.api.nvim_create_user_command("CWToggle", M.toggle, {})
end

function M.is_configured()
	return M.options ~= nil
end

function M.toggle()
	if not M.initialized then
		M.initialized = true
		commands.list_groups(M.bufnr, M.options)
	end

	if not M.is_configured() then
		return
	end

	local ui = vim.api.nvim_list_uis()[1]

	local buf_hidden = 0
	local buf_info = vim.api.nvim_call_function("getbufinfo", { M.bufnr })[1]

	if buf_info then
		buf_hidden = buf_info.hidden
	end
	local current_bufnr = vim.api.nvim_win_get_buf(0)

	if current_bufnr == M.bufnr then
		utils.hide_cw()
	elseif buf_hidden == 0 and buf_info.windows[1] then
		vim.api.nvim_set_current_win(buf_info.windows[1])
	else
		utils.show_cw(M.bufnr, ui)
	end
end

M.options = nil
return M
