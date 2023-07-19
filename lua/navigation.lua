local M = {}

local stack = {}

function M.push(item)
	item()
	stack[#stack + 1] = item
end

function M.pop()
	if #stack < 1 then
		return nil
	end

	local top = table.remove(stack, #stack)
	if #stack > 0 then
		stack[#stack]()
	else
		vim.cmd("CWToggle")
	end
	return top
end

function M.initialized()
	return #stack > 0
end

function M.clear()
	stack = {}
end

return M
