# Show my vehicle

Finding the car is actually easy. Unlike other mods, this one puts a pin on the vehicle and takes it down by itself: the pin appears when you ask for it, stays on screen while you travel, and disappears when you get in or when you arrive. You do not mark anything, and you do not clean anything up. Ask for the vehicle, go to it, and keep playing.

Each player has their own pin. Another player arriving at a vehicle, or getting into it, does not remove yours.

## How to use

Press **Shift + V**, or click **Show my vehicle** (the car icon) on the shortcut bar. The key can be changed in Settings → Controls.

A short confirmation sound plays when a vehicle is pinned. Pressing the shortcut again pins the current target once more and starts the timer over.

## How the vehicle is shown

The pin stays visible on screen the whole time, not only while the map is open. It follows the vehicle if the vehicle moves, including when the vehicle changes surface.

The pin is removed on its own in three cases:

- Immediately, when you enter that vehicle.
- After at least 10 seconds, once you are on the same surface and within 10 tiles of the vehicle. During those first 10 seconds the pin stays up, even if you are already standing next to the vehicle.
- When the vehicle no longer exists.

Entering a different vehicle does not remove the pin. That other vehicle is remembered, and it becomes the target the next time you press the shortcut.

## Which vehicle

The game chooses the target in this order:

1. The last vehicle you entered, if it still exists.
2. The nearest car on the surface you are currently on.

Anything you have driven counts as the last vehicle. That includes a car, a tank, a spidertron, a locomotive, and a vehicle added by another mod. The next pin targets that vehicle, whatever its internal name is.

The search for the nearest vehicle only looks at entities named `car`, and only on your current surface. A tank, a spidertron, a locomotive, or a modded vehicle with a different name is pinned only when you have already driven it. If that last vehicle was destroyed, or if you have not driven one yet, the search falls back to the nearest car.

If there is no car on that surface, the current pin is removed, the invalid-action sound plays, and the message *There is no car on this surface.* appears.

## Notes

- The mod is built for Factorio 2.1. A release only loads on the major version declared in `info.json` (send me a GitHub issue if it is outdated).
- The pin is per player. In multiplayer, each person tracks their own vehicle.
- The nearest-car fallback never searches other surfaces, and it never searches entity names other than `car`.
