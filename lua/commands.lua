-- TODO: Give some indication of loading for long running commands
local utils = require("utils")
local config = require("config")
local buffer = require("buffer")

local M = {}

local highlight_group = "Visual"

local highlight_selected_item = function()
	local line = vim.fn.line(".")
	vim.api.nvim_buf_clear_namespace(buffer.number, -1, 0, -1)
	vim.api.nvim_buf_add_highlight(buffer.number, -1, highlight_group, line - 1, 0, -1)
end

local select_stream = function(items, group, options)
	local line = vim.fn.line(".")
	local selected_item = items[line]
	M.tail(group, selected_item, options.on_exit)
end

local select_group = function(items, options)
	local line = vim.fn.line(".")
	local selected_item = items[line]
	if options.action == "tail" then
		M.tail(selected_item, nil, options.on_exit)
	else
		M.list_streams(selected_item)
	end
end

local setup_selections = function(selections, options)
	local selections_table = {}
	for s in selections:gmatch("[^\r\n]+") do
		table.insert(selections_table, s)
	end

	if options.reverse then
		utils.reverse_table(selections_table)
	end

	buffer.set_lines(selections_table)

	vim.api.nvim_buf_add_highlight(buffer.number, -1, highlight_group, 0, 0, -1)

	local highlight_autocmd_id = vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = buffer.number,
		callback = function()
			highlight_selected_item()
		end,
	})

	return { highlight_autocmd_id = highlight_autocmd_id, selections = selections_table }
end

function M.list_groups()
	buffer.clear()
	local command = string.format("cw ls groups --profile %s", config.values.profile)
	local str = vim.fn.system(command)

	local setup = setup_selections(str, {})
	vim.api.nvim_buf_set_keymap(buffer.number, "n", "<CR>", "", {
		callback = function()
			vim.api.nvim_del_autocmd(setup.highlight_autocmd_id)
			select_group(setup.selections, { on_exit = M.list_groups, action = "tail" })
		end,
	})
	vim.api.nvim_buf_set_keymap(buffer.number, "n", "q", ":CWToggle<cr>", { silent = true })
	vim.api.nvim_buf_set_keymap(buffer.number, "n", "s", "", {
		callback = function()
			select_group(setup.selections, { on_exit = M.list_groups })
		end,
		silent = true,
	})
	vim.api.nvim_buf_set_keymap(buffer.number, "n", "r", "", {
		silent = true,
		callback = M.list_groups,
	})
end

function M.list_streams(group)
	buffer.clear()
	local command = string.format("cw ls streams %s --profile %s", group, config.values.profile)
	local str = vim.fn.system(command)

	local setup = setup_selections(str, { reverse = true })

	vim.api.nvim_buf_set_keymap(buffer.number, "n", "<CR>", "", {
		callback = function()
			vim.api.nvim_del_autocmd(setup.highlight_autocmd_id)
			select_stream(setup.selections, group, {
				on_exit = function()
					M.list_streams(group)
				end,
			})
		end,
	})
	vim.api.nvim_buf_set_keymap(buffer.number, "n", "q", "", {
		callback = M.list_groups,
		silent = true,
	})
	vim.api.nvim_buf_set_keymap(buffer.number, "n", "r", "", {
		silent = true,
		callback = function()
			M.list_streams(group)
		end,
	})
end

function M.tail(group, stream, on_exit)
	buffer.clear()

	local winnr = vim.fn.bufwinid(buffer.number)

	local command = string.format("cw tail -f '%s", group)
	if stream ~= nil then
		command = command .. string.format(":%s", stream)
	end
	command = command .. string.format("' --profile %s", config.values.profile)

	local job_id = vim.fn.jobstart(command, {
		on_stdout = function(_, data, _)
			buffer.append_lines(data)
			local line_count = vim.api.nvim_buf_line_count(buffer.number)
			vim.api.nvim_win_set_cursor(winnr, { line_count, 1 })
		end,
		on_stderr = function(_, data, _)
			buffer.append_lines(data)
			local line_count = vim.api.nvim_buf_line_count(buffer.number)
			vim.api.nvim_win_set_cursor(winnr, { line_count, 1 })
		end,
		on_exit = function(_, _)
			on_exit()
		end,
	})

	vim.api.nvim_buf_set_keymap(
		buffer.number,
		"n",
		"q",
		":lua vim.api.nvim_call_function('jobstop', {" .. job_id .. "})<cr>",
		{ silent = true }
	)
end

return M
