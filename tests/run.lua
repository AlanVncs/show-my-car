local source = debug.getinfo(1, "S").source:sub(2)
local root = source:gsub("/?tests/run%.lua$", "")
if root == "" then
  root = "."
end

package.path = root .. "/?.lua;" .. package.path

local files = {
  "tests/release_files_test.lua",
  "tests/vehicle_rules_test.lua",
}

local checks = 0
local failures = 0
for _, file in ipairs(files) do
  local result = dofile(root .. "/" .. file)
  checks = checks + result.checks
  failures = failures + result.failures
end

if failures > 0 then
  io.stderr:write(string.format("%d of %d checks failed\n", failures, checks))
  os.exit(1)
end

print(string.format("%d checks passed", checks))
