local utils = require("utils")

M = {}

M.number = nil

function M.hide()
	vim.api.nvim_command("hide")
end

function M.show(ui)
	local width = utils.round(ui.width * 0.5)
	local height = utils.round(ui.height * 0.5)

	vim.api.nvim_open_win(M.number, true, utils.window_config(width, height, ui))
end

function M.create()
	M.number = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = M.number,
		callback = function()
			M.hide()
		end,
	})
end

function M.set_lines(lines)
	vim.api.nvim_buf_set_option(M.number, "modifiable", true)
	vim.api.nvim_buf_set_lines(M.number, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(M.number, "modifiable", false)
end

function M.append_lines(lines)
	vim.api.nvim_buf_set_option(M.number, "modifiable", true)
	vim.api.nvim_buf_set_lines(M.number, -1, -1, false, lines)
	vim.api.nvim_buf_set_option(M.number, "modifiable", false)
end

function M.clear()
	M.set_lines({})
end

return M
