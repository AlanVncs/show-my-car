local rules = require("vehicle_rules")

local failures = 0
local checks = 0

local function check(condition, message)
  checks = checks + 1
  if not condition then
    failures = failures + 1
    io.stderr:write("FAIL: " .. message .. "\n")
  end
end

local function eq(actual, expected, message)
  check(
    actual == expected,
    message .. " (expected " .. tostring(expected) .. ", got " .. tostring(actual) .. ")"
  )
end

local function list_eq(actual, expected, message)
  eq(table.concat(actual, ","), table.concat(expected, ","), message)
end

local function enabled_only(allowed)
  return function(category)
    return allowed[category] == true
  end
end

eq(rules.distance_squared({x = 0, y = 0}, {x = 3, y = 4}), 25, "3-4-5 distance")
eq(rules.distance_squared({x = 2, y = 2}, {x = 2, y = 2}), 0, "same position")

eq(rules.vehicle_category({name = "car", type = "car"}), "car", "vanilla car")
eq(rules.vehicle_category({name = "tank", type = "car"}), "tank", "tank keeps its own category")
eq(rules.vehicle_category({name = "spidertron", type = "spider-vehicle"}), "spidertron", "spidertron")
eq(rules.vehicle_category({name = "locomotive", type = "locomotive"}), "train", "locomotive")
eq(rules.vehicle_category({name = "cargo-wagon", type = "cargo-wagon"}), "train", "cargo wagon")
eq(rules.vehicle_category({name = "fluid-wagon", type = "fluid-wagon"}), "train", "fluid wagon")
eq(rules.vehicle_category({name = "artillery-wagon", type = "artillery-wagon"}), "train", "artillery wagon")
eq(rules.vehicle_category({name = "modded-car", type = "car"}), "other", "modded car is other")
eq(rules.vehicle_category({name = "unknown", type = "unit"}), "other", "unknown entity is other")

check(not rules.grace_elapsed(0, 0), "grace has not elapsed at the pin tick")
check(not rules.grace_elapsed(rules.PIN_GRACE_TICKS - 1, 0), "grace has not elapsed one tick early")
check(rules.grace_elapsed(rules.PIN_GRACE_TICKS, 0), "grace elapses after 10 seconds")
check(rules.grace_elapsed(1000, nil), "missing pin tick is treated as zero")

local surface = {}
local other_surface = {}
check(
  rules.has_arrived(surface, {x = 0, y = 0}, surface, {x = 10, y = 0}),
  "arrival includes the 10 tile boundary"
)
check(
  not rules.has_arrived(surface, {x = 0, y = 0}, surface, {x = 10, y = 1}),
  "arrival stops beyond 10 tiles"
)
check(
  not rules.has_arrived(surface, {x = 0, y = 0}, other_surface, {x = 0, y = 0}),
  "arrival requires the same surface"
)

list_eq(
  rules.entity_types_for(enabled_only({car = true})),
  {"car"},
  "cars search the car entity type"
)
list_eq(
  rules.entity_types_for(enabled_only({car = true, tank = true, other = true})),
  {"car"},
  "car, tank, and other share one search type"
)
list_eq(
  rules.entity_types_for(enabled_only({spidertron = true, train = true})),
  {"spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"},
  "spidertron and train search their own types"
)
list_eq(rules.entity_types_for(enabled_only({})), {}, "no enabled category searches nothing")

local far = {name = "car", position = {x = 30, y = 0}}
local near = {name = "car", position = {x = 4, y = 0}}
local disabled = {name = "tank", position = {x = 1, y = 0}}
local origin = {x = 0, y = 0}

eq(
  rules.nearest_vehicle(origin, {far, disabled, near}, function(entity)
    return entity.name == "car"
  end),
  near,
  "nearest enabled vehicle wins"
)
eq(
  rules.nearest_vehicle(origin, {disabled}, function()
    return false
  end),
  nil,
  "no enabled vehicle returns nil"
)
eq(
  rules.nearest_vehicle(origin, {far, near}, function()
    return true
  end),
  near,
  "a later closer vehicle replaces the current nearest"
)

local tied_first = {name = "car", position = {x = 5, y = 0}}
local tied_second = {name = "car", position = {x = 0, y = 5}}
eq(
  rules.nearest_vehicle(origin, {tied_first, tied_second}, function()
    return true
  end),
  tied_first,
  "an equal distance keeps the first vehicle"
)

for _, category in ipairs({"car", "tank", "spidertron", "train", "other"}) do
  check(rules.SETTING_BY_CATEGORY[category] ~= nil, "setting exists for " .. category)
end

return {failures = failures, checks = checks}
