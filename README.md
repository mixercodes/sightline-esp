# Visuals

ESP for players, NPCs, items and anything else in the world, built to one house look.

## Loading

Put `visuals.luau` in the executor's workspace folder (on umbra that is `~/.local/share/umbra/shared/`), then:

```luau
local Visuals = loadstring(readfile("visuals.luau"), "visuals")()
```

`test.luau` spawns dummies and a crate in front of you and shows every layout. Stop it with `getgenv().VisualsTest.stop()`.

## API

```luau
local esp = Visuals.start(themeOverrides?)

local players = esp:players(settings?, accessors?)
local loot = esp:group(settings?, accessors?)

local handle = loot:add(target, accessors?)
local watcher = loot:watch(container, { filter = fn, ...accessors })
handle.remove()
watcher.remove()
loot:remove()

loot.settings.name.enabled = false
esp.theme.textSize = 14
esp:unload()
```

`start` replaces any session that is already running. Settings are read every frame, so writes take effect immediately. Every settings table rejects unknown keys.

## Settings

| Key | Default (group / players) |
|---|---|
| `enabled` | `true` |
| `layout` | `"classic"` |
| `maxDistance` | `5000` |
| `box.enabled` | off / on |
| `healthBar.enabled` | off / on |
| `name.enabled` | on / on |
| `distance.enabled` | off / off |
| `theme` | partial theme overrides for this group |
| `variants` | `{ [name] = partial settings }`, picked per target by the `variant` accessor |

The players group picks the `teammate` variant for players on your team.

## Layouts

- `classic`: thin health bar left of the box, name above, distance below.
- `card`: dark rounded panel above the target with name, distance and a slim health bar.

## Accessors

Each takes `(target, model)` and falls back to a default when left out.

| Accessor | Default |
|---|---|
| `model(target)` | `Player.Character`, otherwise the target itself |
| `health` | Humanoid `Health, MaxHealth`; no health bar when it returns nil |
| `name` | `DisplayName` for players, otherwise `Name` |
| `variant` | nil (players: `"teammate"` on your team) |
| `parts` | body parts for rigs, every visible part for other models, the part itself for a part |

Targets with no parts (attachments, empty models) get name and distance at their position and no box.

## Theme

`font`, `textSize`, `smallTextSize`, `textColor`, `mutedTextColor`, `shadowColor`, `shadowTransparency`, `shadowOffset`, `boxColor`, `outlineColor`, `healthyHue`, `healthSmoothing`, `barWidth`, `barGap`, `textGap`, `panelColor`, `panelTransparency`, `panelCornerRadius`, `panelPadding`, `panelSpacing`, `panelMinWidth`, `panelBarHeight`, `panelBarColor`.

A theme value resolves from the target's variant, then its group, then `esp.theme`.
