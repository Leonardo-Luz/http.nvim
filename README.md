# http.nvim

*A Neovim plugin providing a simple function for making HTTP requests using curl.*

## Features

* **`fetch_json` function:**  Performs HTTP requests and returns the response data as a Lua table.
* **Methods:** Supports all HTTP methods, including `GET`, `POST`, `PUT`, `DELETE`, and `PATCH` requests.

## Dependencies

* `curl` (must be installed on your system)

## Installation

Add `leonardo-luz/http.nvim` to your Neovim plugin manager.  For example, in your `init.lua` (or equivalent):

```lua
{
  'leonardo-luz/http.nvim',
  opts = {
      print_curl = false,  -- Prints the curl request, (not recommended, can cause issues), default: false
      print_response = false, -- Prints the raw response data, default: false
      curl_max_time = 60,     -- Maximum time for the curl operation, default: 60 seconds
  }
}
```

## Usage

Require the plugin using either:

* `local http = require('http')`
* `local fetch_json = require('http').fetch_json`

## Example

```lua
local http = require('http')

local function example()
  local url = "https://example.com/users"
  local opts = {
    method = "POST", -- default: GET
    headers = {
		"Content-Type: application/json",
    },
    body = {
		username = "test",
    },
  }
  local response = http.fetch_json(url, opts)

  -- Process the response (response is a table)
  print(response)
end

example()
```

## License

This project is licensed under the [MIT License](LICENSE.md).
