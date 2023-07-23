-- TODO: Give some indication of loading for long running commands
-- TODO: Unmap keymaps when navigating away from each command
local utils = require("utils")
local config = require("config")
local buffer = require("buffer")
local navigation = require("navigation")

local M = {}

local highlight_group = "Visual"
local keymap = vim.keymap.set

local highlight_selected_item = function()
	local line = vim.fn.line(".")
	vim.api.nvim_buf_clear_namespace(buffer.number, -1, 0, -1)
	vim.api.nvim_buf_add_highlight(buffer.number, -1, highlight_group, line - 1, 0, -1)
end

local select_stream = function(items, group)
	local line = vim.fn.line(".")
	local selected_item = items[line]
	navigation.push(function()
		M.tail(group, selected_item)
	end)
end

local select_group = function(items, action)
	local line = vim.fn.line(".")
	local selected_item = items[line]
	if action == "tail" then
		navigation.push(function()
			M.tail(selected_item, nil)
		end)
	else
		navigation.push(function()
			M.list_streams(selected_item)
		end)
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
	keymap("n", "<CR>", function()
		vim.api.nvim_del_autocmd(setup.highlight_autocmd_id)
		select_group(setup.selections, "tail")
	end, {
		buffer = buffer.number,
	})
	keymap("n", "q", navigation.pop, { silent = true, buffer = buffer.number })
	keymap("n", "s", function()
		select_group(setup.selections)
	end, {
		buffer = buffer.number,
		silent = true,
	})
	keymap("n", "r", m.list_groups, {
		silent = true,
		buffer = buffer.number,
	})
end

function M.list_streams(group)
	buffer.clear()
	local command = string.format("cw ls streams %s --profile %s", group, config.values.profile)
	local str = vim.fn.system(command)

	local setup = setup_selections(str, { reverse = true })

	keymap("n", "<CR>", function()
		vim.api.nvim_del_autocmd(setup.highlight_autocmd_id)
		select_stream(setup.selections, group)
	end, {
		buffer = buffer.number,
	})
	keymap("n", "q", navigation.pop, { silent = true })
	keymap(buffer.number, "n", "r", function()
		M.list_streams(group)
	end, {
		silent = true,
	})
end

function M.tail(group, stream)
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
		on_exit = function(_, _)
			navigation.pop()
		end,
	})

	keymap(
		"n",
		"q",
		":lua vim.api.nvim_call_function('jobstop', {" .. job_id .. "})<cr>",
		{ buffer = buffer.number, silent = true }
	)
end

return M
