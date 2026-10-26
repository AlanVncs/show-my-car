local SHORTCUT_NAME = "show-my-vehicle"
local MARKER_NAME = "show-my-vehicle-marker"
local ARRIVAL_DISTANCE = 10
local ARRIVAL_DISTANCE_SQUARED = ARRIVAL_DISTANCE * ARRIVAL_DISTANCE
local PIN_GRACE_TICKS = 60 * 10

local SETTING_BY_CATEGORY = {
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

local function distance_squared(origin, position)
  local dx = origin.x - position.x
  local dy = origin.y - position.y
  return dx * dx + dy * dy
end

local function init_storage()
  storage.pins = storage.pins or {}
  storage.markers = storage.markers or {}
  storage.vehicles = storage.vehicles or storage.cars or {}
  storage.last_vehicles = storage.last_vehicles or storage.last_cars or {}
  storage.pinned_tick = storage.pinned_tick or {}
end

local function clear_pin(player_index)
  local pin = storage.pins[player_index]
  if pin and pin.valid then
    pin.destroy()
  end
  storage.pins[player_index] = nil

  local marker = storage.markers[player_index]
  if marker and marker.valid then
    marker.destroy()
  end
  storage.markers[player_index] = nil
  storage.vehicles[player_index] = nil
  storage.pinned_tick[player_index] = nil
end

local function vehicle_category(vehicle)
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

local function category_enabled(player, category)
  local setting = settings.get_player_settings(player)[SETTING_BY_CATEGORY[category]]
  return setting and setting.value
end

local function vehicle_enabled(player, vehicle)
  return category_enabled(player, vehicle_category(vehicle))
end

local function remember_driven_vehicle(player)
  local vehicle = player.vehicle
  if vehicle and vehicle.valid and vehicle_enabled(player, vehicle) then
    storage.last_vehicles[player.index] = vehicle
  end
end

local function last_used_vehicle(player)
  local vehicle = storage.last_vehicles[player.index]
  if not vehicle or not vehicle.valid then
    storage.last_vehicles[player.index] = nil
    return nil
  end
  if not vehicle_enabled(player, vehicle) then
    return nil
  end
  return vehicle
end

local function search_types(player)
  local types = {}
  local seen = {}
  local function add(entity_type)
    if not seen[entity_type] then
      seen[entity_type] = true
      types[#types + 1] = entity_type
    end
  end

  if category_enabled(player, "car") or category_enabled(player, "tank") or category_enabled(player, "other") then
    add("car")
  end
  if category_enabled(player, "spidertron") then
    add("spider-vehicle")
  end
  if category_enabled(player, "train") then
    add("locomotive")
    add("cargo-wagon")
    add("fluid-wagon")
    add("artillery-wagon")
  end
  return types
end

local function find_nearest_vehicle(player)
  local types = search_types(player)
  if #types == 0 then
    return nil
  end

  local origin = player.physical_position
  local nearest = nil
  local nearest_distance = nil
  local entities = player.physical_surface.find_entities_filtered{type = types}
  for _, entity in pairs(entities) do
    if vehicle_enabled(player, entity) then
      local distance = distance_squared(origin, entity.position)
      if nearest_distance == nil or distance < nearest_distance then
        nearest = entity
        nearest_distance = distance
      end
    end
  end

  return nearest
end

local function player_has_arrived(player, vehicle)
  return player.physical_surface == vehicle.surface
    and distance_squared(player.physical_position, vehicle.position) <= ARRIVAL_DISTANCE_SQUARED
end

local function create_marker(surface, position, force)
  local marker = surface.create_entity{
    name = MARKER_NAME,
    position = position,
    force = force,
    create_build_effect_smoke = false
  }
  if marker then
    marker.destructible = false
  end
  return marker
end

local function attach_pin(player, marker)
  local pin = player.add_pin{
    entity = marker,
    always_visible = true
  }
  storage.markers[player.index] = marker
  if pin then
    storage.pins[player.index] = pin
  end
  return pin
end

local function pin_vehicle(player, vehicle)
  clear_pin(player.index)

  local marker = create_marker(vehicle.surface, vehicle.position, player.force)
  if not marker then
    return false
  end

  storage.vehicles[player.index] = vehicle
  storage.pinned_tick[player.index] = game.tick
  attach_pin(player, marker)
  return true
end

local function move_marker(player, marker, vehicle)
  if marker.surface == vehicle.surface then
    if distance_squared(marker.position, vehicle.position) > 0.01 then
      -- Passing a surface makes Factorio treat this as a cross-surface teleport,
      -- which a simple-entity cannot do even when the surface is unchanged.
      marker.teleport(vehicle.position)
    end
    return marker
  end

  local moved = create_marker(vehicle.surface, vehicle.position, player.force)
  if not moved then
    return nil
  end

  local pin = storage.pins[player.index]
  if pin and pin.valid then
    pin.destroy()
  end
  storage.pins[player.index] = nil
  marker.destroy()
  attach_pin(player, moved)
  return moved
end

local function update_pin(player_index)
  local vehicle = storage.vehicles[player_index]
  local marker = storage.markers[player_index]
  local player = game.get_player(player_index)
  if not player or not vehicle or not vehicle.valid or not marker or not marker.valid or not vehicle_enabled(player, vehicle) then
    clear_pin(player_index)
    return
  end

  local pinned_tick = storage.pinned_tick[player_index] or 0
  local grace_elapsed = game.tick >= pinned_tick + PIN_GRACE_TICKS
  if grace_elapsed and player_has_arrived(player, vehicle) then
    clear_pin(player_index)
    return
  end

  if not move_marker(player, marker, vehicle) then
    clear_pin(player_index)
  end
end

script.on_init(init_storage)
script.on_configuration_changed(init_storage)

script.on_nth_tick(10, function()
  if not storage.vehicles then
    return
  end
  for player_index, _ in pairs(storage.vehicles) do
    update_pin(player_index)
  end
end)

script.on_event(defines.events.on_player_driving_changed_state, function(event)
  local player = game.get_player(event.player_index)
  if not player then
    return
  end
  init_storage()
  remember_driven_vehicle(player)

  local pinned = storage.vehicles[player.index]
  local current = player.vehicle
  if pinned and pinned.valid and current and current.valid and current == pinned then
    clear_pin(player.index)
  end
end)

local function show_vehicle(player_index)
  local player = game.get_player(player_index)
  if not player then
    return
  end
  init_storage()
  remember_driven_vehicle(player)

  local vehicle = last_used_vehicle(player) or find_nearest_vehicle(player)
  if not vehicle then
    clear_pin(player.index)
    player.play_sound{path = "utility/cannot_build", volume_modifier = 1}
    player.print({"show-my-vehicle.no-vehicle"})
    return
  end

  if pin_vehicle(player, vehicle) then
    player.play_sound{path = "utility/new_objective", volume_modifier = 1}
  end
end

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name ~= SHORTCUT_NAME then
    return
  end
  show_vehicle(event.player_index)
end)

script.on_event(SHORTCUT_NAME, function(event)
  show_vehicle(event.player_index)
end)
