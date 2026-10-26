# Show my vehicle

Finding the car is actually easy. Unlike other mods, this one puts a pin on the vehicle and takes it down by itself: the pin appears when you ask for it, stays on screen while you travel, and disappears when you get in or when you arrive. You do not mark anything, and you do not clean anything up. Ask for the vehicle, go to it, and keep playing.

Each player has their own pin. Another player arriving at a vehicle, or getting into it, does not remove yours.

## How to use

Press **Shift + V**, or click **Show my vehicle** (the car icon) on the shortcut bar. The key can be changed in Settings → Controls.

A short confirmation sound plays when a vehicle is pinned. Pressing the shortcut again pins the current target once more and starts the timer over.

## How the vehicle is shown

The pin stays visible on screen the whole time, not only while the map is open. It follows the vehicle if the vehicle moves, including when the vehicle changes surface.

The pin is removed on its own in these cases:

- Immediately, when you enter that vehicle.
- After at least 10 seconds, once you are on the same surface and within 10 tiles of the vehicle. During those first 10 seconds the pin stays up, even if you are already standing next to the vehicle.
- When the vehicle no longer exists.
- When you turn off that vehicle's type.

Entering a different vehicle does not remove the pin. When that vehicle's type is enabled, it is remembered and becomes the target the next time you press the shortcut.

## Which vehicle

Choose which vehicles count in **Settings → Mod settings → Per player**. Each player has their own selection. Every type can be turned on or off on its own:

- **Cars** — the vanilla car.
- **Tanks** — the vanilla tank.
- **Spidertrons** — the spidertron and other spider vehicles.
- **Trains** — locomotives and wagons.
- **Other vehicles** — vehicles added by mods, and any driven vehicle that is not one of the types above.

All five are on by default. A modded vehicle keeps its own name, so it uses **Other vehicles** even when it looks like a car or a tank.

The game chooses the target in this order:

1. The last enabled vehicle you entered, if it still exists.
2. The nearest enabled vehicle on the surface you are currently on.

Driving a vehicle whose type is turned off does not replace the last vehicle. The nearest-vehicle search only looks at your current surface, and only at the types you enabled. If nothing enabled is there, the current pin is removed, the invalid-action sound plays, and the message *There is no matching vehicle on this surface.* appears.

## Notes

- The mod is built for Factorio 2.1. A release only loads on the major version declared in `info.json` (send me a GitHub issue if it is outdated).
- The pin is per player. In multiplayer, each person tracks their own vehicle.
- The nearest-vehicle search never looks on other surfaces. It only considers the vehicle types enabled for that player.
