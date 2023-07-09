local M = {}

local function round(float)
	return math.floor(float + 0.5)
end

function M.hide_cw()
	vim.api.nvim_command("hide")
end

function M.show_cw(bufnr)
	local width = round(UI.width * 0.5)
	local height = round(UI.height * 0.5)

	vim.api.nvim_open_win(bufnr, true, M.window_config(width, height))
end

function M.window_config(width, height)
	local border = vim.g.workbench_border or "double"

	return {
		relative = "editor",
		width = width,
		height = height,
		col = (UI.width - width) / 2,
		row = (UI.height - height) / 2,
		style = "minimal",
		focusable = false,
		border = border,
	}
end

function M.clear_buffer()
	vim.api.nvim_buf_set_lines(CW_BUFNR, 0, -1, false, {})
end

return M
