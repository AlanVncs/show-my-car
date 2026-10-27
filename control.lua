local rules = require("vehicle_rules")

local SHORTCUT_NAME = "show-my-vehicle"
local MARKER_NAME = "show-my-vehicle-marker"

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

local function category_enabled(player, category)
  local setting = settings.get_player_settings(player)[rules.SETTING_BY_CATEGORY[category]]
  return setting and setting.value
end

local function vehicle_enabled(player, vehicle)
  return category_enabled(player, rules.vehicle_category(vehicle))
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
  return rules.entity_types_for(function(category)
    return category_enabled(player, category)
  end)
end

local function find_nearest_vehicle(player)
  local types = search_types(player)
  if #types == 0 then
    return nil
  end

  local entities = player.physical_surface.find_entities_filtered{type = types}
  return rules.nearest_vehicle(player.physical_position, entities, function(entity)
    return vehicle_enabled(player, entity)
  end)
end

local function player_has_arrived(player, vehicle)
  return rules.has_arrived(
    player.physical_surface,
    player.physical_position,
    vehicle.surface,
    vehicle.position
  )
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
    if rules.distance_squared(marker.position, vehicle.position) > 0.01 then
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

  local grace_elapsed = rules.grace_elapsed(game.tick, storage.pinned_tick[player_index])
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
