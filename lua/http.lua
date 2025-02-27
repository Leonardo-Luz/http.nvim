local M = {}

---Parse headers
---@param headers table
---@return string
local parse_headers = function(headers)
	local parsed = ""
	for _, value in ipairs(headers) do
		parsed = parsed .. " -H '" .. value .. "'"
	end

	return parsed
end

---HTTP request
---
---Usage example:
---local http = require('http')
---local response = http.fetch("https://example.com/users", {
---	method = "POST",
---	headers = {
---		"Content-Type: application/json",
---	},
---	body = {
---		username = "test",
---	},
---})
---@param url string
---@param opts { method: string|nil, headers: table|nil, body: table|nil }|nil
---@return { response: table|nil, err: string|nil }
M.fetch = function(url, opts)
	local method = " -X GET"
	local headers = ""
	local body = ""

	if opts then
		method = opts.method and " -X " .. opts.method or " -X GET"
		headers = opts.headers and parse_headers(opts.headers) or ""
		body = opts.body and " --data '" .. vim.json.encode(opts.body, { escape_slash = true }) .. "'" or ""
	end

	local request = "curl -s --max-time 60 " .. url .. method .. headers .. body

	local handle = io.popen(request)
	if handle == nil then
		print("Error: Could not execute http request.")
		return { err = "http request failed" }
	end

	local data, err = handle:read("*a")
	handle:close()

	if err then
		print("Error reading http response: " .. err)
		return { err = "response read failed" }
	end

	local success, decoded_data = pcall(vim.json.decode, data)

	if not success then
		print("Error decoding JSON: " .. decoded_data)
		return { err = "JSON decoding failed" }
	end

	if not decoded_data then
		print("Error decoding JSON response. " .. "\nResponse: " .. data)
		return { err = "JSON decoding failed" }
	end

	return { response = decoded_data }
end

M.setup = function(opts) end

return M
