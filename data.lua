local empty_sprite = {
  filename = "__core__/graphics/empty.png",
  priority = "extra-high",
  width = 1,
  height = 1
}

data:extend({
  {
    type = "custom-input",
    name = "show-my-vehicle",
    key_sequence = "SHIFT + V",
    action = "lua",
    consuming = "game-only"
  },
  {
    type = "shortcut",
    name = "show-my-vehicle",
    order = "z[show-my-vehicle]",
    action = "lua",
    associated_control_input = "show-my-vehicle",
    localised_name = {"shortcut.show-my-vehicle"},
    icon = "__base__/graphics/icons/car.png",
    icon_size = 64,
    small_icon = "__base__/graphics/icons/car.png",
    small_icon_size = 64
  },
  {
    type = "simple-entity",
    name = "show-my-vehicle-marker",
    flags = {
      "not-on-map",
      "not-blueprintable",
      "not-deconstructable",
      "placeable-off-grid",
      "not-selectable-in-game",
      "not-flammable",
      "no-copy-paste"
    },
    icon = "__base__/graphics/icons/car.png",
    icon_size = 64,
    localised_name = {"entity-name.show-my-vehicle-marker"},
    picture = empty_sprite,
    collision_mask = {layers = {}},
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selectable_in_game = false,
    hidden = true
  }
})
