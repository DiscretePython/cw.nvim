local M = {}

function M.round(float)
	return math.floor(float + 0.5)
end

function M.reverse_table(x)
	local n, m = #x, #x / 2
	for i = 1, m do
		x[i], x[n - i + 1] = x[n - i + 1], x[i]
	end
	return x
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

return M
