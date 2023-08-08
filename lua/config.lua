local M = {}

M.values = nil

function M.set_with_defaults(options)
	if options == nil then
		options = {}
	end

	M.values = {
		profile = options.profile or "default",
		wrap = options.wrap or false,
		tail_begin = options.tail_begin or "1h",
		show_timestamp = options.show_timestamp or false,
	}
end

function M.is_configured()
	return M.values ~= nil
end

return M
