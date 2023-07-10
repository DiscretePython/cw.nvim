local M = {}

local function round(float)
	return math.floor(float + 0.5)
end

function M.hide_cw()
	vim.api.nvim_command("hide")
end

function M.show_cw(bufnr, ui)
	local width = round(ui.width * 0.5)
	local height = round(ui.height * 0.5)

	vim.api.nvim_open_win(bufnr, true, M.window_config(width, height, ui))
end

function M.window_config(width, height, ui)
	local border = vim.g.workbench_border or "double"

	return {
		relative = "editor",
		width = width,
		height = height,
		col = (ui.width - width) / 2,
		row = (ui.height - height) / 2,
		style = "minimal",
		focusable = false,
		border = border,
	}
end

function M.clear_buffer(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
end

return M
