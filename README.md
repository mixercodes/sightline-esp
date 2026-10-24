# Visuals

ESP for players, NPCs, items and anything else in the world, built to one house look.

## Loading

Put `visuals.luau` in the executor's workspace folder (on umbra that is `~/.local/share/umbra/shared/`), then:

```luau
local Visuals = loadstring(readfile("visuals.luau"), "visuals")()
```

`test.luau` spawns six dummies (one per layout) and a crate in front of you and turns on every feature for players. Stop it with `getgenv().VisualsTest.stop()`.

## API

```luau
local esp = Visuals.start(themeOverrides?)

local players = esp:players(settings?, accessors?)
local loot = esp:group(settings?, accessors?)

local handle = loot:add(target, accessors?)
local watcher = loot:watch(container, { filter = fn, recursive = bool, ...accessors })
handle.remove()
watcher.remove()
loot:remove()

loot.settings.name.enabled = false
esp.theme.textSize = 14
esp.enabled = false
players:focusedTarget()
esp:unload()
```

`start` replaces any session that is already running. Settings are read every frame, so writes take effect immediately. Settings tables reject unknown keys and invalid choices on write.

## Settings

| Key | Default | Notes |
|---|---|---|
| `enabled` | `true` | |
| `layout` | `"classic"` | `classic`, `card`, `badge`, `minimal` |
| `maxDistance` | `5000` | studs |
| `maxTargets` | `0` | keep only the nearest N, 0 for all |
| `useTeamColor` | `false` | box, tracer, skeleton, head dot, arrow and chams take the team colour |
| `visibilityCheck` | `false` | raycasts every 0.1s and applies the `occluded` overlay when blocked |
| `fade` | off, `start 300`, `finish 1500`, `minOpacity 0.25` | fades everything with distance |
| `focus` | off, `radius 150` | the target nearest the mouse gets the `focused` overlay |
| `box` | off, `style "full"`, `filled false` | styles: `full`, `corners`, `3d` |
| `health` | off, `style "bar"`, `format "value"`, `gradient true` | styles: `bar`, `number`, `both`; formats: `value`, `percent`, `fraction` |
| `name` | on, `style "display"` | `display`, `username`, `both` |
| `avatar` | off | headshot next to the name |
| `distance` | off, `unit "studs"` | `studs`, `meters` |
| `weapon`, `team`, `tags` | off | extra lines (classic) or a details row (card) |
| `tracer` | off, `origin "bottom"` | `bottom`, `center`, `top`, `mouse` |
| `skeleton` | off | built from the rig's Motor6Ds, works for R6, R15 and custom rigs |
| `headDot` | off | |
| `look` | off, `length 6` | line along the head's look direction |
| `arrow` | off, `radius 160`, `size 12` | points at targets that are off screen or behind you |
| `chams` | off, `throughWalls true` | Highlight fill and outline, shared pool of 31 for the nearest targets |

`esp:players` turns on box, health and name. `esp:group` turns on name.

### Overlays

Partial settings layered on top of the group's own, highest first: `focused`, `occluded`, then the target's variant.

```luau
esp:players({
	variants = { teammate = { theme = { boxColor = Color3.fromRGB(80, 160, 255) } } },
	occluded = { theme = { boxColor = Color3.fromRGB(120, 120, 120) } },
	focused = { theme = { boxColor = Color3.fromRGB(255, 80, 80) }, tracer = { enabled = true } },
	visibilityCheck = true,
	focus = { enabled = true },
})
```

The players group puts teammates in the `teammate` variant.

## Layouts

- `classic`: health bar and/or number left of the box, avatar and name above, distance and details below.
- `card`: dark rounded panel with avatar, name, health number, distance, a details row and a slim bar.
- `badge`: compact pill with a round avatar, name, health number, distance and bar.
- `minimal`: one line of shadowed text.

The health bar is a fixed green-to-red gradient: as health drops, the top empties and the fill shows more red. Set `health.gradient = false` for a solid bar that changes colour instead.

## Accessors

Each takes `(target, model)` and falls back to a default when left out.

| Accessor | Default |
|---|---|
| `model(target)` | `Player.Character`, otherwise the target itself |
| `health` | Humanoid `Health, MaxHealth`; nothing when it returns nil |
| `name` | `DisplayName` for players, otherwise `Name` |
| `avatar` | player headshot (`rbxthumb://`), nil otherwise |
| `weapon` | name of the held Tool |
| `team` | team name and colour |
| `tags` | `{ "Friend" }` for friends |
| `variant` | nil (players: `"teammate"` on your team) |
| `parts` | body parts for rigs, every visible part for other models, the part itself for a part |

Targets with no parts (attachments, empty models) get text at their position and no box.

## Theme

`font`, `textSize`, `smallTextSize`, `textColor`, `mutedTextColor`, `tagColor`, `shadowColor`, `shadowTransparency`, `shadowOffset`, `outlineColor`, `lineThickness`, `lineOutline`, `boxColor`, `boxFillColor`, `boxFillTransparency`, `cornerLength`, `tracerColor`, `skeletonColor`, `headDotColor`, `lookColor`, `arrowColor`, `chamsFillColor`, `chamsFillTransparency`, `chamsOutlineColor`, `chamsOutlineTransparency`, `healthyHue`, `healthSmoothing`, `barWidth`, `barGap`, `textGap`, `lineSpacing`, `avatarSize`, `avatarCornerRadius`, `panelColor`, `panelTransparency`, `panelCornerRadius`, `panelPadding`, `panelSpacing`, `panelMinWidth`, `panelBarHeight`, `panelBarColor`.

A theme value resolves from the overlays, then the group, then `esp.theme`.
