std = {
	read_globals = {
		"assert",
		"debug",
		"error",
		"getmetatable",
		"ipairs",
		"math",
		"mw",
		"os",
		"pairs",
		"pcall",
		"require",
		"select",
		"string",
		"table",
		"tonumber",
		"tostring",
		"type",
		"unpack",
		"xpcall",
	}
}
exclude_files = {
	".install", -- package files
	".luarocks" -- package manager files
}

-- https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
ignore = {
	"212" -- unused argument
}
