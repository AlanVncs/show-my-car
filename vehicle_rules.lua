local rules = {}

rules.ARRIVAL_DISTANCE = 10
rules.ARRIVAL_DISTANCE_SQUARED = rules.ARRIVAL_DISTANCE * rules.ARRIVAL_DISTANCE
rules.PIN_GRACE_TICKS = 60 * 10

rules.SETTING_BY_CATEGORY = {
  car = "show-my-vehicle-include-car",
  tank = "show-my-vehicle-include-tank",
  spidertron = "show-my-vehicle-include-spidertron",
  train = "show-my-vehicle-include-train",
  other = "show-my-vehicle-include-other"
}

local TRAIN_TYPES = {
  locomotive = true,
  ["cargo-wagon"] = true,
  ["fluid-wagon"] = true,
  ["artillery-wagon"] = true
}

function rules.distance_squared(origin, position)
  local dx = origin.x - position.x
  local dy = origin.y - position.y
  return dx * dx + dy * dy
end

function rules.vehicle_category(vehicle)
  local name = vehicle.name
  if name == "car" then
    return "car"
  end
  if name == "tank" then
    return "tank"
  end

  local entity_type = vehicle.type
  if entity_type == "spider-vehicle" then
    return "spidertron"
  end
  if TRAIN_TYPES[entity_type] then
    return "train"
  end
  return "other"
end

function rules.grace_elapsed(current_tick, pinned_tick)
  return current_tick >= (pinned_tick or 0) + rules.PIN_GRACE_TICKS
end

function rules.has_arrived(player_surface, player_position, vehicle_surface, vehicle_position)
  return player_surface == vehicle_surface
    and rules.distance_squared(player_position, vehicle_position) <= rules.ARRIVAL_DISTANCE_SQUARED
end

function rules.entity_types_for(category_enabled)
  local types = {}
  local seen = {}
  local function add(entity_type)
    if not seen[entity_type] then
      seen[entity_type] = true
      types[#types + 1] = entity_type
    end
  end

  if category_enabled("car") or category_enabled("tank") or category_enabled("other") then
    add("car")
  end
  if category_enabled("spidertron") then
    add("spider-vehicle")
  end
  if category_enabled("train") then
    add("locomotive")
    add("cargo-wagon")
    add("fluid-wagon")
    add("artillery-wagon")
  end
  return types
end

function rules.nearest_vehicle(origin, entities, is_enabled)
  local nearest = nil
  local nearest_distance = nil
  for _, entity in pairs(entities) do
    if is_enabled(entity) then
      local distance = rules.distance_squared(origin, entity.position)
      if nearest_distance == nil or distance < nearest_distance then
        nearest = entity
        nearest_distance = distance
      end
    end
  end
  return nearest
end

return rules
