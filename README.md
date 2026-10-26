# Show my vehicle

Ask for your vehicle and a pin appears on it. The pin stays on screen while you travel, follows the vehicle if it moves, and removes itself when you get in or when you arrive. You do not place a marker, and you do not clean anything up.

Each player has their own pin. Another player arriving at a vehicle, or getting into it, does not remove yours.

## How to use

Press **Shift + V**, or click **Show my vehicle** (the car icon) on the shortcut bar. The key can be changed in Settings → Controls.

A short confirmation sound plays when a vehicle is pinned. Press the shortcut again to pin the current target once more and start the timer over.

## Which vehicle

In **Settings → Mod settings → Per player**, turn each type on or off. Any combination works, and every player chooses for themselves:

- **Cars**
- **Tanks**
- **Spidertrons**, including other spider vehicles
- **Trains**, locomotives and wagons
- **Other vehicles**, including vehicles added by mods

All five are on by default. A modded vehicle uses **Other vehicles**, even when it looks like a car or a tank.

The pin targets, in this order:

1. The last vehicle you entered, if that type is still enabled and the vehicle still exists.
2. The nearest enabled vehicle on your current surface.

Driving a type you turned off does not replace the last vehicle. The search does not look on other surfaces. If nothing enabled is there, the pin is removed, an error sound plays, and the message *There is no matching vehicle on this surface.* appears.

## When the pin goes away

- Immediately, when you enter that vehicle.
- After at least 10 seconds, once you are on the same surface and within 10 tiles of it. During those first 10 seconds the pin stays up, even if you are already next to the vehicle.
- When the vehicle no longer exists.
- When you turn off that vehicle's type.

Entering a different vehicle does not remove the pin. If that type is enabled, it becomes the next target.

## Notes

Built for Factorio 2.1. In multiplayer, each person tracks their own vehicle.

Feedback is welcome on this page or in a [GitHub issue](https://github.com/AlanVncs/show-my-car/issues).
