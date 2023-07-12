local utils = require("utils")

local M = {}

local highlight_group = "Visual"

local highlight_selected_item = function(bufnr)
	local line = vim.fn.line(".")
	vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)
	vim.api.nvim_buf_add_highlight(bufnr, -1, highlight_group, line - 1, 0, -1)
end

local select_item = function(bufnr, options, items)
	local line = vim.fn.line(".")
	local selected_item = items[line]
	M.tail_group(selected_item, bufnr, options)
end

function M.list_groups(bufnr, options)
	utils.clear_buffer(bufnr)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", ":CWToggle<cr>", { silent = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "r", "", {
		silent = true,
		callback = function()
			M.list_groups(bufnr, options)
		end,
	})
	local command = string.format("cw ls groups --profile %s", options.profile)
	local str = vim.fn.system(command)

	local groups = {}
	for s in str:gmatch("[^\r\n]+") do
		table.insert(groups, s)
	end

	utils.set_buffer_lines(bufnr, groups)

	vim.api.nvim_buf_add_highlight(bufnr, -1, highlight_group, 0, 0, -1)

	local highlight_autocmd_id = vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = bufnr,
		callback = function()
			highlight_selected_item(bufnr)
		end,
	})
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "", {
		callback = function()
			vim.api.nvim_del_autocmd(highlight_autocmd_id)
			select_item(bufnr, options, groups)
		end,
	})
end

function M.tail_group(group_name, bufnr, options)
	utils.clear_buffer(bufnr)

	local winnr = vim.fn.bufwinid(bufnr)
	local command = string.format("cw tail -f %s --profile %s", group_name, options.profile)

	local job_id = vim.fn.jobstart(command, {
		on_stdout = function(_, data, _)
			utils.append_buffer_lines(bufnr, data)
			local line_count = vim.api.nvim_buf_line_count(bufnr)
			vim.api.nvim_win_set_cursor(winnr, { line_count, 1 })
		end,
		on_exit = function(_, _)
			M.list_groups(bufnr, options)
		end,
	})

	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"q",
		":lua vim.api.nvim_call_function('jobstop', {" .. job_id .. "})<cr>",
		{ silent = true }
	)
end

return M
