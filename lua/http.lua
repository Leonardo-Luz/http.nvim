local M = {}

local state = {
	print_curl = false,
	print_response = false,
	curl_max_time = 60,
}

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

---@param url string
---@param opts { method: string|nil, headers: table|nil, body: table|nil }|nil
---@return { data: any, err: string|nil }
local http_request = function(url, opts)
	local method = " -X GET"
	local headers = ""
	local body = ""

	if opts then
		method = opts.method and " -X " .. opts.method or " -X GET"
		headers = opts.headers and parse_headers(opts.headers) or ""
		body = opts.body and " --data '" .. vim.json.encode(opts.body, { escape_slash = true }) .. "'" or ""
	end

	local baseCurl = "curl -s --max-time " .. state.curl_max_time .. " "

	if state.print_curl then
		baseCurl = "curl --max-time " .. state.curl_max_time .. " "
	end

	local request = baseCurl .. url .. method .. headers .. body

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

	return { data = data }
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
M.fetch_json = function(url, opts)
	local request = http_request(url, opts)

	if request.err then
		return { err = request.err }
	end

	local success, decoded_data = pcall(vim.json.decode, request.data)

	if not success then
		print("Error decoding JSON: " .. decoded_data)
		return { err = "JSON decoding failed" }
	end

	if not decoded_data then
		print("Error decoding JSON response. " .. "\nResponse: " .. request.data)
		return { err = "JSON decoding failed" }
	end

	if state.print_response then
		vim.print(decoded_data)
	end

	return { response = decoded_data }
end

M.fetch_html = function(url, opts)
	opts = opts or {}

	local headers = {}

	table.insert(headers, "Accept: text/html")

	if opts.headers then
		for i = 1, #opts.headers do
			table.insert(headers, opts.headers[i])
		end
	end

	local request = http_request(url, {
		headers = headers,
		body = opts.body or nil,
	})

	if request.err then
		return { err = request.err }
	end

	return { response = request.data }
end

---setup http plugin
---@param opts { print_curl:boolean, print_response:boolean, curl_max_time: number }
M.setup = function(opts)
	state.print_curl = opts.print_curl
	state.print_response = opts.print_response
	state.curl_max_time = opts.curl_max_time and opts.curl_max_time or 60
end

return M
