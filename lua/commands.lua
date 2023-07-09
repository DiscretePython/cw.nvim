local utils = require("utils")

local M = {}

local highlight_group = "Visual"

local highlight_selected_item = function()
	local line = vim.fn.line(".")
	vim.api.nvim_buf_clear_namespace(CW_BUFNR, -1, 0, -1)
	vim.api.nvim_buf_add_highlight(CW_BUFNR, -1, highlight_group, line - 1, 0, -1)
end

local selected_item = function()
	local line = vim.fn.line(".")
	local selected_group = M.groups[line]
	M.tail_group(selected_group)
end

function M.list_groups()
	vim.api.nvim_buf_set_keymap(CW_BUFNR, "n", "q", ":CWToggle<cr>", { silent = true })
	local str = vim.fn.system("cw ls groups")

	M.groups = {}
	for s in str:gmatch("[^\r\n]+") do
		table.insert(M.groups, s)
	end

	vim.api.nvim_buf_set_lines(CW_BUFNR, 0, -1, false, M.groups)

	vim.api.nvim_buf_add_highlight(CW_BUFNR, -1, highlight_group, 0, 0, -1)

	vim.api.nvim_create_autocmd("CursorMoved", { buffer = CW_BUFNR, callback = highlight_selected_item })
	vim.api.nvim_buf_set_keymap(CW_BUFNR, "n", "<CR>", "", { callback = selected_item })
end

function M.tail_group(group_name)
	vim.api.nvim_command(string.format("autocmd! CursorMoved <buffer=%d>", CW_BUFNR))
	utils.clear_buffer()

	local winnr = vim.fn.bufwinid(CW_BUFNR)

	local job_id = vim.fn.jobstart("cw tail -f " .. group_name, {
		on_stdout = function(_, data, _)
			vim.api.nvim_buf_set_lines(CW_BUFNR, -1, -1, false, data)
			local line_count = vim.api.nvim_buf_line_count(CW_BUFNR)
			vim.api.nvim_win_set_cursor(winnr, { line_count, 1 })
		end,
		on_exit = function(_, _)
			M.list_groups()
		end,
	})

	vim.api.nvim_buf_set_keymap(
		CW_BUFNR,
		"n",
		"q",
		":lua vim.api.nvim_call_function('jobstop', {" .. job_id .. "})<cr>",
		{ silent = true }
	)
end

return M
