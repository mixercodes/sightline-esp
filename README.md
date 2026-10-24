# Sightline

ESP for players, NPCs, items and anything else in the world, built to one house look.

## Loading

Load a pinned commit so an update never changes a script under you:

```luau
local Sightline = loadstring(game:HttpGet("https://raw.githubusercontent.com/mixercodes/sightline-esp/de958a795a2e35b4da7445aac47559765775f9ce/sightline.luau"), "sightline")()
```

Swap the hash for a newer commit when you want to update. For local development, put `sightline.luau` in the executor's workspace folder and load it with `readfile("sightline.luau")` instead.

Needs the standard executor functions `Drawing`, `getgenv` and `loadstring` (plus `game:HttpGet` for the pinned loader). `cloneref` and `gethui` are used when present.

`test.luau` spawns six dummies (one per layout) and a crate in front of you and turns on every feature for players. Run it with `sightline.luau` in the workspace folder, and stop it with `getgenv().SightlineTest.stop()`.

## API

```luau
local esp = Sightline.start(themeOverrides?)

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
| `maxDistance` | `5000` | studs, measured from your HumanoidRootPart (the camera when you have no character) |
| `maxTargets` | `0` | keep only the nearest N, 0 for all |
| `useTeamColor` | `false` | box, tracer, skeleton, head dot, arrow and chams take the team colour |
| `visibilityCheck` | `false` | raycasts every 0.1s and applies the `occluded` overlay when blocked |
| `fade` | off, `start 300`, `finish 1500`, `minOpacity 0.25` | fades everything with distance |
| `focus` | off, `radius 150` | the target nearest the mouse gets the `focused` overlay |
| `box` | off, `style "full"`, `filled false` | styles: `full`, `corners`, `3d` |
| `health` | off, `style "bar"`, `format "value"`, `gradient true`, `side "left"` | `bar`, `number`, or `both` for the bar and the number together; formats: `value`, `percent`, `fraction`; side: `left`, `right` |
| `name` | on, `style "display"` | `display`, `username`, `both` |
| `avatar` | off | headshot next to the name |
| `distance` | off, `unit "studs"` | `studs`, `meters` |
| `weapon`, `team`, `tags` | off | extra lines (classic) or a details row (card) |
| `tracer` | off, `origin "bottom"`, `target "bottom"` | origin: `bottom`, `center`, `top`, `mouse`; target: `bottom`, `center`, `top` (box top), `head` (the head itself, or the box top when there is none) |
| `skeleton` | off | R6 and R15 draw a head line, spine, shoulder and hip bars and straight limbs; other rigs fall back to their Motor6D chain |
| `headDot` | off | |
| `look` | off, `length 6` | line along the head's look direction |
| `arrow` | off, `radius 160`, `size 12` | points at targets that are off screen or behind you |
| `chams` | off, `throughWalls true` | Highlight fill and outline, shared pool of 31 for the nearest targets |
| `shrink` | on, `badgeBelow 60`, `minimalBelow 32`, `numberBelow 24` | box heights in pixels: cards become badges, panels become minimal, and classic drops its health number as targets get small |

`esp:players` also turns on box and health.

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

The players group puts teammates in the `teammate` variant. Overlays can be added or replaced while running:

```luau
players.settings.variants.boss = { theme = { nameColor = Color3.fromRGB(255, 200, 60) } }
players.settings.occluded = { theme = { boxColor = Color3.fromRGB(90, 90, 90) } }
```

## Layouts

- `classic`: health bar and/or number left of the box, avatar and name above, distance and details below.
- `card`: dark rounded panel with an avatar beside two lines: the name, then health, distance and details.
- `badge`: compact pill with a round avatar, name, health number and distance.
- `minimal`: one line of shadowed text.

Panels never draw a bar inside themselves: the health number goes in the panel and, with `health.style` set to `bar` or `both` and the box on, the bar sits left of the box as in `classic`. Without a box the panel shows the number instead. The nearest target's panel draws on top.

The health bar is a fixed gradient from `theme.healthColors` (0 is empty, 1 is full, any number of stops): as health drops, the top empties and the fill shows more of the low end. The same colours tint the health number. Set `health.gradient = false` for a solid bar that changes colour instead.

```luau
esp.theme.healthColors = ColorSequence.new(Color3.fromRGB(80, 0, 255), Color3.fromRGB(0, 220, 255))
```

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

Every line-type element (`box`, `tracer`, `skeleton`, `headDot`, `look`, `arrow`) has the same four keys: `<element>Color`, `<element>Thickness`, `<element>Outline` and `<element>Transparency`. Outlines are on by default except for the skeleton.

| Group | Keys |
|---|---|
| Text | `font`, `textSize`, `smallTextSize`, `nameColor`, `distanceColor`, `weaponColor`, `tagColor`, `textShadow`, `shadowColor`, `shadowTransparency`, `shadowOffset` |
| Outlines | `outlineColor`, `lineOutlineWidth` (black edge width on each side of lines, rings and arrows; fractional values work) |
| Box | `boxColor`, `boxThickness`, `boxOutline`, `boxTransparency`, `boxFillColor`, `boxFillTransparency`, `cornerLength` |
| Lines | `tracer…`, `skeleton…`, `look…`, `arrow…` (Color, Thickness, Outline, Transparency) |
| Head dot | `headDotColor`, `headDotThickness`, `headDotOutline`, `headDotTransparency`, `headDotFilled` |
| Chams | `chamsFillColor`, `chamsFillTransparency`, `chamsOutlineColor`, `chamsOutlineTransparency` |
| Health | `healthColors`, `healthSmoothing`, `barWidth`, `barGap`, `barOutline`, `barBackgroundColor`, `barBackgroundTransparency` |
| Spacing | `textGap`, `lineSpacing` |
| Avatar | `avatarSize`, `avatarCornerRadius`, `avatarBackgroundColor`, `avatarBackgroundTransparency` |
| Panels | `panelColor`, `panelTransparency`, `panelCornerRadius`, `panelPadding`, `panelSpacing`, `panelMinWidth`, `panelStrokeColor`, `panelStrokeTransparency`, `panelStrokeThickness` |

A theme value resolves from the overlays, then the team colour (with `useTeamColor`), then the group, then `esp.theme`. Values are type-checked, so `boxColor = "red"` errors.

A target whose accessor errors is hidden and warned about once; the other targets keep drawing.
