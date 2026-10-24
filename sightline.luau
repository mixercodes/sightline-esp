local THEME_DEFAULTS = {
	font = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
	textSize = 13,
	smallTextSize = 11,
	nameColor = Color3.new(1, 1, 1),
	distanceColor = Color3.fromRGB(200, 200, 210),
	weaponColor = Color3.fromRGB(200, 200, 210),
	tagColor = Color3.fromRGB(255, 200, 80),
	textShadow = true,
	shadowColor = Color3.new(0, 0, 0),
	shadowTransparency = 0,
	shadowOffset = Vector2.new(1, 1),
	outlineColor = Color3.new(0, 0, 0),
	lineOutlineWidth = 1,
	boxColor = Color3.new(1, 1, 1),
	boxFillColor = Color3.new(0, 0, 0),
	boxFillTransparency = 0.8,
	cornerLength = 0.25,
	tracerColor = Color3.new(1, 1, 1),
	skeletonColor = Color3.new(1, 1, 1),
	headDotColor = Color3.new(1, 1, 1),
	headDotFilled = false,
	lookColor = Color3.fromRGB(255, 90, 90),
	arrowColor = Color3.new(1, 1, 1),
	chamsFillColor = Color3.fromRGB(255, 70, 70),
	chamsFillTransparency = 0.5,
	chamsOutlineColor = Color3.new(1, 1, 1),
	chamsOutlineTransparency = 0,
	healthColors = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 84, 84)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 206, 72)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(92, 230, 120)),
	}),
	healthSmoothing = 10,
	barWidth = 1,
	barGap = 4,
	barOutline = true,
	barBackgroundColor = Color3.new(0, 0, 0),
	barBackgroundTransparency = 0,
	textGap = 3,
	lineSpacing = 1,
	avatarSize = 18,
	avatarCornerRadius = 4,
	avatarBackgroundColor = Color3.fromRGB(16, 16, 20),
	avatarBackgroundTransparency = 0.3,
	panelColor = Color3.fromRGB(16, 16, 20),
	panelTransparency = 0.15,
	panelCornerRadius = 9,
	panelPadding = 5,
	panelSpacing = 6,
	panelMinWidth = 48,
	panelStrokeColor = Color3.fromRGB(255, 255, 255),
	panelStrokeTransparency = 1,
	panelStrokeThickness = 1,
}
for feature, outlined in { box = true, tracer = true, skeleton = false, headDot = true, look = true, arrow = true, leader = false } do
	THEME_DEFAULTS[feature .. "Thickness"] = 1
	THEME_DEFAULTS[feature .. "Outline"] = outlined
	THEME_DEFAULTS[feature .. "Transparency"] = 0
end
THEME_DEFAULTS.leaderColor = Color3.fromRGB(200, 200, 210)
THEME_DEFAULTS.leaderTransparency = 0.4
for layer, order in { boxFill = 1, tracer = 2, look = 3, skeleton = 4, headDot = 5, box = 6, leader = 7, healthBar = 8, text = 9, arrow = 10 } do
	THEME_DEFAULTS[layer .. "Layer"] = order
end
local SETTINGS_DEFAULTS = {
	enabled = true,
	layout = "classic",
	maxDistance = 5000,
	maxTargets = 0,
	useTeamColor = false,
	visibilityCheck = false,
	fade = { enabled = false, start = 300, finish = 1500, minOpacity = 0.25 },
	focus = { enabled = false, radius = 150 },
	box = { enabled = false, style = "full", filled = false },
	health = { enabled = false, style = "bar", format = "value", gradient = true, side = "left", hideFull = false },
	name = { enabled = true, style = "display", maxLength = 0 },
	avatar = { enabled = false },
	distance = { enabled = false, unit = "studs" },
	weapon = { enabled = false },
	team = { enabled = false },
	tags = { enabled = false },
	tracer = { enabled = false, origin = "bottom", target = "bottom" },
	skeleton = { enabled = false },
	headDot = { enabled = false },
	look = { enabled = false, length = 6 },
	arrow = { enabled = false, placement = "circle", radius = 160, inset = 24, size = 12, maxDistance = 0, label = false },
	chams = { enabled = false, throughWalls = true },
	shrink = { enabled = true, badgeBeyond = 60, minimalBeyond = 120, numberBeyond = 160, detailBeyond = 200 },
	declutter = { enabled = false, maxLift = 150, spacing = 2, leaders = false },
}
local CHOICES = {
	layout = { classic = true, card = true, badge = true, minimal = true },
	["box.style"] = { full = true, corners = true, ["3d"] = true },
	["health.style"] = { bar = true, number = true, both = true },
	["health.format"] = { value = true, percent = true, fraction = true },
	["name.style"] = { display = true, username = true, both = true },
	["distance.unit"] = { studs = true, meters = true },
	["tracer.origin"] = { bottom = true, center = true, top = true, mouse = true },
	["tracer.target"] = { bottom = true, center = true, top = true, head = true },
	["health.side"] = { left = true, right = true },
	["arrow.placement"] = { circle = true, edge = true },
}
local OVERLAY_KEYS = { theme = true, variants = true, occluded = true, focused = true }
local TEAM_TINTED = {
	boxColor = true, tracerColor = true, skeletonColor = true, headDotColor = true,
	arrowColor = true, chamsFillColor = true, chamsOutlineColor = true,
}
local PLAYER_PRESET = { box = { enabled = true }, health = { enabled = true } }
local HEADSHOT = "rbxthumb://type=AvatarHeadShot&id=%d&w=60&h=60"
local FRIEND_TAGS = { "Friend" }
local STUDS_TO_METERS = 0.28
local MAX_HIGHLIGHTS = 31
local LIMB_TIP_INSET = 0.1
local ARROW_SPREAD = 0.6
local RIG_REFRESH = 2
local INFO_INTERVAL = 0.1
local LOCAL_BOUNDS_REFRESH = 0.1
local LOD_PIXELS = 70
local ORDER_MARGIN = 2
local Z_STEP = 4
local LAYER_STEP = 100000
local LAYER_KEYS = {}
for _, layer in { "boxFill", "tracer", "look", "skeleton", "headDot", "box", "leader", "healthBar", "text", "arrow" } do
	LAYER_KEYS[layer] = layer .. "Layer"
end
local PARTS_REFRESH = 0.5
local VISIBILITY_INTERVAL = 0.1
local SESSION_KEY = "SightlineSession"
local CORNERS = {
	Vector3.new(-1, -1, -1), Vector3.new(-1, -1, 1), Vector3.new(-1, 1, -1), Vector3.new(-1, 1, 1),
	Vector3.new(1, -1, -1), Vector3.new(1, -1, 1), Vector3.new(1, 1, -1), Vector3.new(1, 1, 1),
}
local ESCAPES = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;", ["'"] = "&apos;" }

local cloneref = cloneref or function(instance) return instance end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Workspace = cloneref(game:GetService("Workspace"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local LocalPlayer = Players.LocalPlayer

local function numberedKeys(prefix, count)
	local keys = {}
	for index = 1, count do
		keys[index] = prefix .. index
	end
	return keys
end
local BONE_KEYS = numberedKeys("bone", 64)
local EDGE_KEYS = numberedKeys("edge", 12)
local DETAIL_KEYS = numberedKeys("detail", 16)
local BOX_EDGES = {}
for corner = 0, 7 do
	for _, bit in { 1, 2, 4 } do
		if bit32.band(corner, bit) == 0 then
			table.insert(BOX_EDGES, { corner + 1, bit32.bor(corner, bit) + 1 })
		end
	end
end

local Sightline = {}
local Esp = {}
Esp.__index = Esp
local Group = {}
Group.__index = Group

local function unknown(kind, path, key)
	error(string.format("sightline: unknown %s '%s%s'", kind, path, tostring(key)), 0)
end

local function checkValue(path, key, value, default)
	if value == nil then
		return
	end
	if typeof(value) ~= typeof(default) then
		error(string.format("sightline: '%s%s' must be a %s, got %s", path, key, typeof(default), typeof(value)), 0)
	end
	local choices = CHOICES[path .. key]
	if choices and not choices[value] then
		error(string.format("sightline: '%s%s' cannot be '%s'", path, key, tostring(value)), 0)
	end
end

local RAW = setmetatable({}, { __mode = "k" })
local settingsVersion = 0

local function strict(defaults, given, path, partial, specials)
	given = given or {}
	specials = specials or {}
	if type(given) ~= "table" then
		error(string.format("sightline: '%s' must be a table", path), 0)
	end
	for key, value in given do
		local default = defaults[key]
		if default == nil then
			unknown("setting", path, key)
		elseif type(default) ~= "table" then
			checkValue(path, key, value, default)
		end
	end
	local store = {}
	for key, default in defaults do
		local value = given[key]
		if type(default) == "table" then
			store[key] = strict(default, value, path .. key .. ".", partial)
		elseif value ~= nil then
			store[key] = value
		elseif not partial then
			store[key] = default
		end
	end
	for key, special in specials do
		store[key] = special.value
	end
	local proxy = setmetatable({}, {
		__index = function(_, key)
			local special = specials[key]
			if special then
				return special.value
			end
			local value = store[key]
			if value == nil and defaults[key] == nil then
				unknown("setting", path, key)
			end
			return value
		end,
		__newindex = function(_, key, value)
			local special = specials[key]
			if special then
				if not special.replace then
					error(string.format("sightline: set the fields of '%s%s' instead of replacing it", path, key), 0)
				end
				special.value = special.replace(value)
				store[key] = special.value
				settingsVersion += 1
				return
			end
			local default = defaults[key]
			if default == nil then
				unknown("setting", path, key)
			elseif type(default) == "table" then
				error(string.format("sightline: set the fields of '%s%s' instead of replacing it", path, key), 0)
			end
			checkValue(path, key, value, default)
			store[key] = value
			settingsVersion += 1
		end,
		__iter = function()
			return next, store
		end,
	})
	RAW[proxy] = store
	return proxy
end

local buildSettings

local function partialSettings(given)
	return buildSettings(given, true)
end

function buildSettings(given, partial)
	local plain = table.clone(given or {})
	local overlays = {}
	for key in OVERLAY_KEYS do
		overlays[key] = plain[key]
		plain[key] = nil
	end
	local specials = { theme = { value = strict(THEME_DEFAULTS, overlays.theme, "theme.", true) } }
	if partial then
		if overlays.variants or overlays.occluded or overlays.focused then
			error("sightline: variants, occluded and focused only go at the top of a group's settings", 3)
		end
	else
		local built = {}
		local variants = setmetatable({}, {
			__index = built,
			__newindex = function(_, name, variant)
				built[name] = if variant then partialSettings(variant) else nil
				settingsVersion += 1
			end,
			__iter = function()
				return next, built
			end,
		})
		for name, variant in overlays.variants or {} do
			variants[name] = variant
		end
		specials.variants = { value = variants }
		specials.occluded = { value = partialSettings(overlays.occluded), replace = partialSettings }
		specials.focused = { value = partialSettings(overlays.focused), replace = partialSettings }
	end
	return strict(SETTINGS_DEFAULTS, plain, "", partial, specials)
end

local function overlay(base, top)
	local result = table.clone(base)
	for key, value in top or {} do
		if type(value) == "table" and type(result[key]) == "table" then
			result[key] = overlay(result[key], value)
		else
			result[key] = value
		end
	end
	return result
end

local friendCache = {}
local function isFriend(player)
	local known = friendCache[player.UserId]
	if known == nil then
		friendCache[player.UserId] = false
		task.spawn(function()
			local ok, result = pcall(LocalPlayer.IsFriendsWith, LocalPlayer, player.UserId)
			friendCache[player.UserId] = ok and result == true
		end)
		return false
	end
	return known
end

local function humanoidOf(model)
	return if model:IsA("Model") then model:FindFirstChildOfClass("Humanoid") else nil
end

local DEFAULT_ACCESSORS = {
	model = function(target)
		return if target:IsA("Player") then target.Character else target
	end,
	health = function(_, model)
		local humanoid = humanoidOf(model)
		if humanoid then
			return humanoid.Health, humanoid.MaxHealth
		end
		return nil
	end,
	name = function(target)
		return if target:IsA("Player") then target.DisplayName else target.Name
	end,
	avatar = function(target)
		return if target:IsA("Player") then string.format(HEADSHOT, target.UserId) else nil
	end,
	weapon = function(_, model)
		local tool = if model:IsA("Model") then model:FindFirstChildOfClass("Tool") else nil
		return tool and tool.Name
	end,
	team = function(target)
		if target:IsA("Player") and target.Team then
			return target.Team.Name, target.TeamColor.Color
		end
		return nil
	end,
	tags = function(target)
		return if target:IsA("Player") and target ~= LocalPlayer and isFriend(target) then FRIEND_TAGS else nil
	end,
	variant = function()
		return nil
	end,
	parts = function(_, model)
		if model:IsA("BasePart") then
			return { model }
		end
		local parts = {}
		local humanoid = humanoidOf(model)
		local root = humanoid and humanoid.RootPart
		local source = if humanoid then model:GetChildren() else model:GetDescendants()
		for _, part in source do
			if part:IsA("BasePart") and part ~= root and part.Transparency < 1 then
				table.insert(parts, part)
			end
		end
		return parts
	end,
}

local function playerVariant(player)
	return if player.Team ~= nil and player.Team == LocalPlayer.Team then "teammate" else nil
end

local function withAccessors(base, extra)
	local result = table.clone(base)
	for key, accessor in extra or {} do
		if DEFAULT_ACCESSORS[key] == nil then
			unknown("accessor", "", key)
		end
		result[key] = accessor
	end
	return result
end

local function setting(entry, key)
	for _, layer in entry.overlays do
		local value = RAW[layer][key]
		if value ~= nil then
			return value
		end
	end
	return RAW[entry.group.settings][key]
end

local function option(entry, feature, key)
	for _, layer in entry.overlays do
		local value = RAW[RAW[layer][feature]][key]
		if value ~= nil then
			return value
		end
	end
	return RAW[RAW[entry.group.settings][feature]][key]
end

local function theme(entry, key)
	for _, layer in entry.overlays do
		local value = RAW[RAW[layer].theme][key]
		if value ~= nil then
			return value
		end
	end
	if TEAM_TINTED[key] and entry.view.teamColor and setting(entry, "useTeamColor") then
		return entry.view.teamColor
	end
	local value = RAW[RAW[entry.group.settings].theme][key]
	if value == nil then
		value = RAW[entry.esp.theme][key]
	end
	return value
end

local function cached(object)
	return { object = object, cache = {} }
end

local function set(item, key, value)
	if item.cache[key] ~= value then
		item.cache[key] = value
		item.object[key] = value
	end
end

local function use(entry, key, create, ...)
	local item = entry.elements[key]
	if not item then
		item = create(...)
		entry.elements[key] = item
	end
	item.tick = entry.tick
	local recording = entry.recording
	if recording then
		table.insert(recording, item)
	end
	return item
end

local function guiAlpha(entry, transparency)
	return 1 - (1 - transparency) * entry.opacity
end

local function escape(value)
	return (string.gsub(value, "[&<>\"']", ESCAPES))
end

local function colored(value, color)
	return string.format('<font color="#%s">%s</font>', color:ToHex(), escape(value))
end

local keypointCache = setmetatable({}, { __mode = "k" })
local function sample(sequence, t)
	local points = keypointCache[sequence]
	if not points then
		points = sequence.Keypoints
		keypointCache[sequence] = points
	end
	for index = 2, #points do
		local upper = points[index]
		if t <= upper.Time then
			local lower = points[index - 1]
			local span = upper.Time - lower.Time
			return lower.Value:Lerp(upper.Value, if span > 0 then (t - lower.Time) / span else 0)
		end
	end
	return points[#points].Value
end

local function healthColor(entry, fraction)
	return sample(theme(entry, "healthColors"), fraction)
end


local function addCorner(parent)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new()
	corner.Parent = parent
	return cached(corner)
end

local function newLabel(parent)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.XY
	label.Size = UDim2.new()
	label.RichText = true
	label.Visible = false
	label.Parent = parent
	return cached(label)
end

local function newFrame(parent)
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = parent
	local item = cached(frame)
	item.corner = addCorner(frame)
	return item
end

local function newPanel(parent)
	local item = newFrame(parent)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = item.object
	item.stroke = cached(stroke)
	return item
end

local function newImage(parent)
	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency = 1
	image.BorderSizePixel = 0
	image.ScaleType = Enum.ScaleType.Crop
	image.Visible = false
	image.Parent = parent
	local item = cached(image)
	item.corner = addCorner(image)
	return item
end

local function newBar(parent)
	local item = newFrame(parent)
	local back = Instance.new("Frame")
	back.BorderSizePixel = 0
	back.Parent = item.object
	local clip = Instance.new("Frame")
	clip.BackgroundTransparency = 1
	clip.BorderSizePixel = 0
	clip.ClipsDescendants = true
	clip.Parent = back
	item.back = cached(back)
	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.Parent = clip
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 270
	gradient.Parent = fill
	item.clip = cached(clip)
	item.fill = cached(fill)
	item.gradient = cached(gradient)
	return item
end

local ARM_SHAPES = {
	{ true, 0, 0 }, { false, 0, 0 },
	{ true, 1, 0 }, { false, 1, 0 },
	{ true, 0, 1 }, { false, 0, 1 },
	{ true, 1, 1 }, { false, 1, 1 },
}

local function newBoxRoot(parent)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = parent
	local item = cached(frame)
	item.arms, item.borders = {}, {}
	for index = 1, #ARM_SHAPES do
		for _, list in { item.borders, item.arms } do
			local piece = Instance.new("Frame")
			piece.BorderSizePixel = 0
			piece.ZIndex = if list == item.arms then 2 else 1
			piece.Parent = frame
			list[index] = cached(piece)
		end
	end
	return item
end

local function layerZ(entry, layer, sub)
	return theme(entry, LAYER_KEYS[layer]) * LAYER_STEP + entry.zBase + sub
end

local function newSegment(parent)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = parent
	return cached(frame)
end

local function newRing(parent)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Parent = frame
	local item = cached(frame)
	item.stroke = cached(stroke)
	return item
end

local function square(entry, key, layer, sub, color, transparency, position, size)
	local item = use(entry, key, newFrame, entry.esp.gui)
	set(item, "ZIndex", layerZ(entry, layer, sub))
	set(item, "BackgroundColor3", color)
	set(item, "BackgroundTransparency", guiAlpha(entry, transparency))
	set(item, "Position", UDim2.fromOffset(position.X, position.Y))
	set(item, "Size", UDim2.fromOffset(size.X, size.Y))
	set(item, "Visible", true)
end

local STYLE_KEYS = {}
for _, feature in { "box", "tracer", "skeleton", "headDot", "look", "arrow", "leader" } do
	STYLE_KEYS[feature] = {
		color = feature .. "Color",
		thickness = feature .. "Thickness",
		outline = feature .. "Outline",
		transparency = feature .. "Transparency",
	}
end

local function styleOf(entry, feature)
	local style = entry.styles[feature]
	if not style then
		style = {}
		entry.styles[feature] = style
	end
	if style.tick ~= entry.tick then
		local keys = STYLE_KEYS[feature]
		style.tick = entry.tick
		style.color = theme(entry, keys.color)
		style.thickness = theme(entry, keys.thickness)
		style.outlined = theme(entry, keys.outline)
		style.transparency = theme(entry, keys.transparency)
		style.alpha = guiAlpha(entry, style.transparency)
		style.outlineColor = theme(entry, "outlineColor")
		style.outlineWidth = theme(entry, "lineOutlineWidth")
		style.z = if LAYER_KEYS[feature] then layerZ(entry, feature, 0) else 0
	end
	return style
end

local function segment(entry, key, center, length, thickness, rotation, color, alpha, zIndex)
	local item = use(entry, key, newSegment, entry.esp.gui)
	set(item, "Position", UDim2.fromOffset(center.X, center.Y))
	set(item, "Size", UDim2.fromOffset(length, thickness))
	set(item, "Rotation", rotation)
	set(item, "BackgroundColor3", color)
	set(item, "BackgroundTransparency", alpha)
	set(item, "ZIndex", zIndex)
	set(item, "Visible", true)
end

local function line(entry, key, from, to, feature)
	local style = styleOf(entry, feature)
	local thickness = math.max(style.thickness, 1)
	local delta = to - from
	local length = delta.Magnitude
	local rotation = math.deg(math.atan2(delta.Y, delta.X))
	local center = (from + to) / 2
	local z = style.z
	if style.outlined then
		local width = style.outlineWidth
		segment(entry, key .. "Border", center, length + thickness + width * 2, thickness + width * 2, rotation, style.outlineColor, style.alpha, z)
	end
	segment(entry, key, center, length + thickness, thickness, rotation, style.color, style.alpha, z + 1)
end

local function ring(entry, key, center, radius, color, thickness, alpha, zIndex, filled)
	local item = use(entry, key, newRing, entry.esp.gui)
	local diameter = math.max(radius, 0) * 2
	set(item, "Position", UDim2.fromOffset(center.X, center.Y))
	set(item, "Size", UDim2.fromOffset(diameter, diameter))
	set(item, "BackgroundColor3", color)
	set(item, "BackgroundTransparency", if filled then alpha else 1)
	set(item.stroke, "Color", color)
	set(item.stroke, "Thickness", thickness)
	set(item.stroke, "Transparency", alpha)
	set(item, "ZIndex", zIndex)
	set(item, "Visible", true)
end

local function circle(entry, key, center, radius, feature)
	local style = styleOf(entry, feature)
	local thickness = math.max(style.thickness, 1)
	local filled = theme(entry, feature .. "Filled") == true
	local z = style.z
	if style.outlined then
		local width = style.outlineWidth
		ring(entry, key .. "Outer", center, radius + thickness / 2, style.outlineColor, width, style.alpha, z, false)
		if not filled then
			ring(entry, key .. "Inner", center, math.max(radius - thickness / 2 - width, 0), style.outlineColor, width, style.alpha, z, false)
		end
	end
	ring(entry, key, center, radius - thickness / 2, style.color, thickness, style.alpha, z + 1, filled)
end

local function styleLabel(entry, item, value, size, color, transparency, zIndex)
	set(item, "Text", value)
	set(item, "FontFace", theme(entry, "font"))
	set(item, "TextSize", size)
	set(item, "TextColor3", color)
	set(item, "TextTransparency", guiAlpha(entry, transparency))
	set(item, "ZIndex", layerZ(entry, "text", zIndex))
	set(item, "Visible", true)
end

local function newMeasuredLabel(entry, parent)
	local item = newLabel(parent)
	table.insert(entry.labels, item)
	return item
end

local function text(entry, key, parent, size, color, plain, rich)
	local escaped = escape(plain)
	local shadow
	if theme(entry, "textShadow") then
		shadow = use(entry, key .. "Shadow", newLabel, parent)
		styleLabel(entry, shadow, escaped, size, theme(entry, "shadowColor"), theme(entry, "shadowTransparency"), 1)
	end
	local main = use(entry, key, newMeasuredLabel, entry, parent)
	styleLabel(entry, main, rich or escaped, size, color, 0, 2)
	local bounds = main.bounds
	if not bounds or main.boundsFor ~= main.cache.Text or main.boundsSize ~= size then
		bounds = main.measured or Vector2.new(#plain * size * 0.5, size)
		entry.staleBounds = true
	end
	return main, shadow, bounds
end

local function measureLabels(esp)
	for _, group in esp.groups do
		for _, entry in group.entries do
			for _, item in entry.labels do
				local cache = item.cache
				if cache.Visible and (item.boundsFor ~= cache.Text or item.boundsSize ~= cache.TextSize or item.boundsFont ~= cache.FontFace) then
					item.measured = item.object.TextBounds
					item.bounds, item.boundsFor, item.boundsSize, item.boundsFont = item.measured, cache.Text, cache.TextSize, cache.FontFace
				end
			end
		end
	end
end

local function join(parts, separator)
	local rich, plain = "", ""
	for index = 1, #parts, 2 do
		local value, color = parts[index], parts[index + 1]
		local gap = if index > 1 then separator else ""
		rich ..= gap .. (if color then colored(value, color) else escape(value))
		plain ..= gap .. value
	end
	return rich, plain
end

local function pin(item, xScale, x, yScale, y, anchorX, anchorY)
	set(item, "AnchorPoint", Vector2.new(anchorX or 0, anchorY or 0))
	set(item, "Position", UDim2.new(xScale, x, yScale, y))
end

local function pinText(entry, main, shadow, xScale, x, yScale, y, anchorX, anchorY)
	pin(main, xScale, x, yScale, y, anchorX, anchorY)
	if shadow then
		local offset = theme(entry, "shadowOffset")
		pin(shadow, xScale, x + offset.X, yScale, y + offset.Y, anchorX, anchorY)
	end
end

local function place(entry, main, shadow, x, y)
	x, y = x - entry.originX, y - entry.originY
	set(main, "Position", UDim2.fromOffset(x, y))
	if shadow then
		local offset = theme(entry, "shadowOffset")
		set(shadow, "Position", UDim2.fromOffset(x + offset.X, y + offset.Y))
	end
end

local function avatarImage(entry, key, parent, image, xScale, x, yScale, y, size, radius)
	local item = use(entry, key, newImage, parent)
	set(item, "Image", image)
	set(item, "ImageTransparency", guiAlpha(entry, 0))
	set(item, "BackgroundColor3", theme(entry, "avatarBackgroundColor"))
	set(item, "BackgroundTransparency", guiAlpha(entry, theme(entry, "avatarBackgroundTransparency")))
	set(item, "Position", UDim2.new(xScale, x, yScale, y))
	set(item, "Size", UDim2.fromOffset(size, size))
	set(item, "ZIndex", layerZ(entry, "text", 2))
	set(item, "Visible", true)
	set(item.corner, "CornerRadius", UDim.new(0, radius))
end

local function shorten(value, length)
	if length <= 0 or (utf8.len(value) or #value) <= length then
		return value
	end
	local cut = utf8.offset(value, length + 1)
	return if cut then value:sub(1, cut - 1) .. "…" else value
end

local function displayName(entry)
	local view = entry.view
	local style = option(entry, "name", "style")
	local length = option(entry, "name", "maxLength")
	if view.username then
		if style == "username" then
			return shorten(view.username, length)
		elseif style == "both" and view.username ~= view.name then
			return shorten(view.name, length) .. " @" .. shorten(view.username, length)
		end
	end
	return shorten(view.name, length)
end

local function healthText(entry)
	local view = entry.view
	local format = option(entry, "health", "format")
	if format == "percent" then
		return string.format("%d%%", math.round(math.clamp(view.health / math.max(view.maxHealth, 1), 0, 1) * 100))
	elseif format == "fraction" then
		return string.format("%d/%d", math.round(view.health), math.round(view.maxHealth))
	end
	return tostring(math.round(view.health))
end

local function distanceText(entry)
	if option(entry, "distance", "unit") == "meters" then
		return string.format("%dm", entry.view.distance * STUDS_TO_METERS)
	end
	return string.format("%d studs", entry.view.distance)
end

local function addPart(parts, value, color)
	table.insert(parts, value)
	table.insert(parts, color or false)
end

local function addDetails(entry, parts)
	local view = entry.view
	if option(entry, "weapon", "enabled") and view.weapon then
		addPart(parts, view.weapon, theme(entry, "weaponColor"))
	end
	if option(entry, "team", "enabled") and view.teamName then
		addPart(parts, view.teamName, view.teamColor or theme(entry, "weaponColor"))
	end
	if option(entry, "tags", "enabled") and view.tags then
		local color = theme(entry, "tagColor")
		for _, tag in view.tags do
			if type(tag) == "table" then
				addPart(parts, tostring(tag.text), if typeof(tag.color) == "Color3" then tag.color else color)
			else
				addPart(parts, tostring(tag), color)
			end
		end
	end
	return parts
end

local function freshParts(entry)
	local parts = entry.partsBuffer
	table.clear(parts)
	return parts
end

local function healthShown(entry)
	local view = entry.view
	if not option(entry, "health", "enabled") or view.fraction == nil then
		return false
	end
	return not (option(entry, "health", "hideFull") and view.health >= view.maxHealth)
end

local projection = { inverse = CFrame.identity, centerX = 0, centerY = 0, scale = 1, viewport = Vector2.zero }

local function updateProjection(camera)
	local viewport = camera.ViewportSize
	projection.inverse = camera.CFrame:Inverse()
	projection.centerX, projection.centerY = viewport.X / 2, viewport.Y / 2
	projection.viewport = viewport
	projection.scale = projection.centerY / math.tan(math.rad(camera.FieldOfView) / 2)
end

local function screen(point)
	local relative = projection.inverse * point
	local depth = -relative.Z
	local scale = projection.scale / depth
	return Vector2.new(projection.centerX + relative.X * scale, projection.centerY - relative.Y * scale), depth > 0
end

local function drawBox(entry)
	if not option(entry, "box", "enabled") then
		return
	end
	local view = entry.view
	local style = option(entry, "box", "style")

	if style == "3d" then
		local corners = view.corners3d
		if corners then
			for index, edge in BOX_EDGES do
				line(entry, EDGE_KEYS[index], corners[edge[1]], corners[edge[2]], "box")
			end
		end
		return
	end

	local width, height = view.maxX - view.minX, view.maxY - view.minY
	if width < 2 or height < 2 then
		return
	end
	local position, size = Vector2.new(view.minX, view.minY), Vector2.new(width, height)
	if option(entry, "box", "filled") then
		square(entry, "boxFill", "boxFill", 0, theme(entry, "boxFillColor"), theme(entry, "boxFillTransparency"), position, size)
	end

	local thickness = math.max(1, math.floor(theme(entry, "boxThickness")))
	local length = if style == "corners"
		then math.max(thickness + 1, math.floor(math.min(width, height) * theme(entry, "cornerLength")))
		else math.huge
	local lengthX, lengthY = math.min(length, width + 1), math.min(length, height + 1)
	local outlined = theme(entry, "boxOutline")
	local root = use(entry, "boxRoot", newBoxRoot, entry.esp.gui)
	set(root, "Position", UDim2.fromOffset(view.minX, view.minY))
	set(root, "Size", UDim2.fromOffset(width + 1, height + 1))
	set(root, "ZIndex", layerZ(entry, "box", 0))
	set(root, "Visible", true)
	if root.lengthX ~= lengthX or root.lengthY ~= lengthY or root.thickness ~= thickness or root.outlined ~= outlined then
		root.lengthX, root.lengthY, root.thickness, root.outlined = lengthX, lengthY, thickness, outlined
		for index, shape in ARM_SHAPES do
			local horizontal, xScale, yScale = shape[1], shape[2], shape[3]
			local armWidth = if horizontal then lengthX else thickness
			local armHeight = if horizontal then thickness else lengthY
			local x, y = -xScale * armWidth, -yScale * armHeight
			local arm, border = root.arms[index], root.borders[index]
			set(arm, "Position", UDim2.new(xScale, x, yScale, y))
			set(arm, "Size", UDim2.fromOffset(armWidth, armHeight))
			set(border, "Position", UDim2.new(xScale, x - 1, yScale, y - 1))
			set(border, "Size", UDim2.fromOffset(armWidth + 2, armHeight + 2))
			set(border, "Visible", outlined)
		end
	end
	local color = theme(entry, "boxColor")
	local alpha = guiAlpha(entry, theme(entry, "boxTransparency"))
	local outline = theme(entry, "outlineColor")
	if root.color ~= color or root.alpha ~= alpha or root.outline ~= outline then
		root.color, root.alpha, root.outline = color, alpha, outline
		for index = 1, #ARM_SHAPES do
			set(root.arms[index], "BackgroundColor3", color)
			set(root.arms[index], "BackgroundTransparency", alpha)
			set(root.borders[index], "BackgroundColor3", outline)
			set(root.borders[index], "BackgroundTransparency", alpha)
		end
	end
end

local function drawTracer(entry, viewport, mouse)
	if not option(entry, "tracer", "enabled") then
		return
	end
	local view = entry.view
	local origin = option(entry, "tracer", "origin")
	local from = if origin == "center" then viewport / 2
		elseif origin == "top" then Vector2.new(viewport.X / 2, 0)
		elseif origin == "mouse" then mouse
		else Vector2.new(viewport.X / 2, viewport.Y)
	local target = option(entry, "tracer", "target")
	local centerX = (view.minX + view.maxX) / 2
	local to = Vector2.new(centerX, view.maxY)
	if target == "center" then
		to = Vector2.new(centerX, (view.minY + view.maxY) / 2)
	elseif target == "top" then
		to = Vector2.new(centerX, view.minY)
	elseif target == "head" then
		local head, inFront = nil, false
		if view.head then
			head, inFront = screen(view.head.Position)
		end
		to = if inFront then head else Vector2.new(centerX, view.minY)
	end
	line(entry, "tracer", from, to, "tracer")
end

local function frameOf(frames, part)
	local cframe = frames[part]
	if not cframe then
		cframe = part.CFrame
		frames[part] = cframe
	end
	return cframe
end

local function jointPosition(joint, frames)
	if not joint then
		return nil
	end
	local motor = joint.motor
	if motor then
		local part0 = joint.part0
		return (if frames then frameOf(frames, part0) else part0.CFrame) * motor.C0.Position
	end
	local attachment = joint.attachment
	return if attachment.Parent then attachment.WorldPosition else nil
end

local function longAxis(cframe, size, direction)
	local right, up, look = cframe.RightVector, cframe.UpVector, cframe.LookVector
	local dx, dy, dz = right:Dot(direction), up:Dot(direction), look:Dot(direction)
	local ax, ay, az = math.abs(dx), math.abs(dy), math.abs(dz)
	if ax >= ay and ax >= az then
		return if dx >= 0 then right else -right, size.X / 2
	elseif ay >= az then
		return if dy >= 0 then up else -up, size.Y / 2
	end
	return if dz >= 0 then look else -look, size.Z / 2
end

local function chainPoints(chain, motors, sizes, frames, points, owners)
	table.clear(points)
	table.clear(owners)
	local first = chain[1]
	local entry = jointPosition(motors[first], frames)
	if not entry then
		return points, owners
	end
	points[1], owners[1] = entry, first
	local count = #chain
	for index = 2, count do
		local joint = jointPosition(motors[chain[index]], frames)
		if joint then
			table.insert(points, joint)
			table.insert(owners, chain[index])
		end
	end
	local firstFrame = frameOf(frames, first)
	local center = firstFrame.Position
	local axis = longAxis(firstFrame, sizes[first], (points[2] or center) - entry)
	points[1] = center + axis * (entry - center):Dot(axis)
	local last, lastPoint = chain[count], points[#points]
	local lastFrame = frameOf(frames, last)
	local lastCenter = lastFrame.Position
	if count > 1 and #points > 1 then
		local direction = lastPoint - points[#points - 1]
		if direction.Magnitude > 1e-3 then
			local unit = direction.Unit
			local along = (lastCenter - lastPoint):Dot(unit)
			if along > 0 then
				table.insert(points, lastPoint + unit * along)
				table.insert(owners, last)
			end
		end
	else
		local tipAxis, half = longAxis(lastFrame, sizes[last], lastCenter - lastPoint)
		table.insert(points, lastCenter + tipAxis * math.max(half - LIMB_TIP_INSET, 0))
		table.insert(owners, last)
	end
	return points, owners
end

local function joinLimbs(left, leftOwners, right, rightOwners)
	local points, owners = {}, {}
	if left then
		for index = #left, 1, -1 do
			table.insert(points, left[index])
			table.insert(owners, leftOwners[index])
		end
	end
	if right then
		table.move(right, 1, #right, #points + 1, points)
		table.move(rightOwners, 1, #rightOwners, #owners + 1, owners)
	end
	return points, owners
end

local function anchored(points, owners)
	local offsets = table.create(#points)
	for index, point in points do
		offsets[index] = owners[index].CFrame:PointToObjectSpace(point)
	end
	return { parts = owners, offsets = offsets }
end

local function rigPaths(rig)
	local motors, sizes, frames = rig.motors, rig.sizes, {}
	local function limb(chain)
		if chain then
			return chainPoints(chain, motors, sizes, frames, {}, {})
		end
		return nil, nil
	end
	local leftArm, leftArmOwners = limb(rig.leftArm)
	local rightArm, rightArmOwners = limb(rig.rightArm)
	local leftLeg, leftLegOwners = limb(rig.leftLeg)
	local rightLeg, rightLegOwners = limb(rig.rightLeg)
	local spine, spineOwners = {}, {}
	local function add(point, owner)
		if point then
			table.insert(spine, point)
			table.insert(spineOwners, owner)
		end
	end
	if rig.head then
		add(rig.head.Position, rig.head)
		add(jointPosition(motors[rig.head], frames), rig.head)
	end
	for index = #rig.torso, 2, -1 do
		add(jointPosition(motors[rig.torso[index]], frames), rig.torso[index])
	end
	local leftHip, rightHip = leftLeg and leftLeg[1], rightLeg and rightLeg[1]
	add(if leftHip and rightHip then (leftHip + rightHip) / 2 else jointPosition(motors[rig.torso[1]], frames), rig.torso[1])
	return {
		anchored(spine, spineOwners),
		anchored(joinLimbs(leftArm, leftArmOwners, rightArm, rightArmOwners)),
		anchored(joinLimbs(leftLeg, leftLegOwners, rightLeg, rightLegOwners)),
	}
end

local PATH_KEYS = { { "spine", "spineBorder" }, { "arms", "armsBorder" }, { "legs", "legsBorder" } }
local pathCoords, pathControls = {}, {}

local function newPath(parent)
	local path = Instance.new("Path2D")
	path.Visible = false
	path.Parent = parent
	local item = cached(path)
	item.coords = {}
	return item
end

local function pathChanged(item, coords)
	local last, count = item.coords, #coords
	if #last == count then
		local index = 1
		while index <= count and last[index] == coords[index] do
			index += 1
		end
		if index > count then
			return false
		end
	end
	table.clear(last)
	table.move(coords, 1, count, 1, last)
	return true
end

local function stroke(entry, key, thickness, color, alpha, z)
	local item = use(entry, key, newPath, entry.esp.gui)
	set(item, "Thickness", thickness)
	set(item, "Color3", color)
	set(item, "Transparency", alpha)
	set(item, "ZIndex", z)
	set(item, "Visible", true)
	if pathChanged(item, pathCoords) then
		if #pathControls == 0 then
			for index = 1, #pathCoords, 2 do
				table.insert(pathControls, Path2DControlPoint.new(UDim2.fromOffset(pathCoords[index], pathCoords[index + 1])))
			end
		end
		item.object:SetControlPoints(pathControls)
	end
end

local function drawPath(entry, keys, path, frames)
	local parts, offsets = path.parts, path.offsets
	if #parts < 2 then
		return
	end
	table.clear(pathCoords)
	table.clear(pathControls)
	local inverse, centerX, centerY, scale = projection.inverse, projection.centerX, projection.centerY, projection.scale
	for index, part in parts do
		local relative = inverse * (frameOf(frames, part) * offsets[index])
		local depth = -relative.Z
		if depth <= 0 then
			return
		end
		table.insert(pathCoords, centerX + relative.X * scale / depth)
		table.insert(pathCoords, centerY - relative.Y * scale / depth)
	end
	local style = styleOf(entry, "skeleton")
	local thickness = math.max(style.thickness, 1)
	if style.outlined then
		stroke(entry, keys[2], thickness + style.outlineWidth * 2, style.outlineColor, style.alpha, style.z)
	end
	stroke(entry, keys[1], thickness, style.color, style.alpha, style.z + 1)
end

local function drawSkeleton(entry, camera)
	if not option(entry, "skeleton", "enabled") then
		return
	end
	local rig = entry.rig
	if rig then
		table.clear(rig.frames)
		for index, path in rig.paths do
			drawPath(entry, PATH_KEYS[index], path, rig.frames)
		end
		return
	end
	local count = 0
	if not entry.bones then
		return
	end
	for _, bone in entry.bones do
		local joint, child = bone[1], bone[2]
		local from = jointPosition(joint)
		if not from then
			continue
		end
		local to
		if child then
			to = jointPosition(child)
			if not to then
				continue
			end
		else
			to = from + (joint.part1.Position - from) * 2
		end
		local a, aFront = screen(from)
		local b, bFront = screen(to)
		if aFront and bFront and count < #BONE_KEYS then
			count += 1
			line(entry, BONE_KEYS[count], a, b, "skeleton")
		end
	end
end

local function drawHead(entry, camera)
	local head = entry.view.head
	if not head then
		return
	end
	local center, inFront = screen(head.Position)
	if not inFront then
		return
	end
	if option(entry, "headDot", "enabled") then
		local edge = screen(head.Position + camera.CFrame.UpVector * head.Size.Y / 2)
		local radius = (edge - center).Magnitude
		if radius >= 4 then
			circle(entry, "headDot", center, radius, "headDot")
		end
	end
	if option(entry, "look", "enabled") then
		local tip, tipFront = screen(head.Position + head.CFrame.LookVector * option(entry, "look", "length"))
		if tipFront then
			line(entry, "look", center, tip, "look")
		end
	end
end

local function snap(point)
	return Vector2.new(math.round(point.X), math.round(point.Y))
end

local function rotate(vector, angle)
	local cos, sin = math.cos(angle), math.sin(angle)
	return Vector2.new(vector.X * cos - vector.Y * sin, vector.X * sin + vector.Y * cos)
end

local function arrowLabel(entry, tip, base, direction, edge)
	local parts = freshParts(entry)
	local view = entry.view
	if option(entry, "name", "enabled") then
		addPart(parts, displayName(entry), theme(entry, "nameColor"))
	end
	if healthShown(entry) then
		addPart(parts, healthText(entry), healthColor(entry, view.fraction))
	end
	if option(entry, "distance", "enabled") then
		addPart(parts, distanceText(entry), theme(entry, "distanceColor"))
	end
	addDetails(entry, parts)
	if #parts == 0 then
		return
	end
	local rich, plain = join(parts, " · ")
	local main, shadow = text(entry, "arrowLabel", entry.esp.gui, theme(entry, "smallTextSize"), theme(entry, "nameColor"), plain, rich)
	local gap = theme(entry, "textGap")
	local point = if edge then base - direction * gap else tip + direction * gap
	local side = if edge then 1 else -1
	local anchorX = 0.5 + side * math.clamp(direction.X * 2, -1, 1) / 2
	local anchorY = 0.5 + side * math.clamp(direction.Y * 2, -1, 1) / 2
	pinText(entry, main, shadow, 0, math.round(point.X), 0, math.round(point.Y), anchorX, anchorY)
end

local function drawArrow(entry, camera, viewport)
	local maxDistance = option(entry, "arrow", "maxDistance")
	if maxDistance > 0 and entry.view.distance > maxDistance then
		return
	end
	local cframe = camera.CFrame
	local flat = CFrame.fromMatrix(cframe.Position, cframe.RightVector, Vector3.yAxis)
	local relative = flat:PointToObjectSpace(entry.view.position)
	local direction = Vector2.new(relative.X, relative.Z)
	if direction.Magnitude < 1e-3 then
		return
	end
	direction = direction.Unit
	local size = option(entry, "arrow", "size")
	local center = viewport / 2
	local edge = option(entry, "arrow", "placement") == "edge"
	local tip
	if edge then
		local inset = option(entry, "arrow", "inset")
		local reachX = if math.abs(direction.X) > 1e-3 then (center.X - inset) / math.abs(direction.X) else math.huge
		local reachY = if math.abs(direction.Y) > 1e-3 then (center.Y - inset) / math.abs(direction.Y) else math.huge
		tip = center + direction * math.max(math.min(reachX, reachY), 0)
	else
		tip = center + direction * math.min(option(entry, "arrow", "radius"), center.Y - 20)
	end
	local point = snap(tip)
	line(entry, "arrowLeft", point, snap(tip - rotate(direction, ARROW_SPREAD) * size), "arrow")
	line(entry, "arrowRight", point, snap(tip - rotate(direction, -ARROW_SPREAD) * size), "arrow")
	if option(entry, "arrow", "label") then
		arrowLabel(entry, tip, tip - direction * size, direction, edge)
	end
end

local function drawSideBar(entry)
	local view = entry.view
	local width = theme(entry, "barWidth")
	local border = if theme(entry, "barOutline") then 1 else 0
	local gap = theme(entry, "barGap")
	local onRight = option(entry, "health", "side") == "right"
	local xScale = if onRight then 1 else 0
	local x = if onRight then gap - border else -gap - width - border
	local item = use(entry, "healthBar", newBar, entry.anchor)
	set(item, "Position", UDim2.new(xScale, x, 0, -border))
	set(item, "Size", UDim2.new(0, width + border * 2, 1, border * 2))
	set(item, "BackgroundColor3", theme(entry, "outlineColor"))
	set(item, "BackgroundTransparency", guiAlpha(entry, if border > 0 then 0 else 1))
	set(item, "ZIndex", layerZ(entry, "healthBar", 0))
	set(item, "Visible", true)
	set(item.back, "Position", UDim2.fromOffset(border, border))
	set(item.back, "Size", UDim2.new(0, width, 1, -border * 2))
	set(item.back, "BackgroundColor3", theme(entry, "barBackgroundColor"))
	set(item.back, "BackgroundTransparency", guiAlpha(entry, theme(entry, "barBackgroundTransparency")))

	local fraction = math.clamp(view.fraction, 0.001, 1)
	set(item.clip, "Position", UDim2.fromScale(0, 1 - fraction))
	set(item.clip, "Size", UDim2.fromScale(1, fraction))
	set(item.clip, "Visible", view.fraction > 0.002)
	set(item.fill, "Position", UDim2.fromScale(0, 1 - 1 / fraction))
	set(item.fill, "Size", UDim2.fromScale(1, 1 / fraction))
	set(item.fill, "BackgroundTransparency", guiAlpha(entry, 0))
	if option(entry, "health", "gradient") then
		set(item.gradient, "Enabled", true)
		set(item.gradient, "Color", theme(entry, "healthColors"))
		set(item.fill, "BackgroundColor3", Color3.new(1, 1, 1))
	else
		set(item.gradient, "Enabled", false)
		set(item.fill, "BackgroundColor3", healthColor(entry, view.fraction))
	end
	return xScale, if onRight then x + width + border * 2 else x
end

local function leaderBar(entry, key, x, top, bottom, width, color, transparency, zIndex)
	local item = use(entry, key, newFrame, entry.esp.gui)
	set(item, "Position", UDim2.fromOffset(x - math.floor(width / 2), top))
	set(item, "Size", UDim2.fromOffset(width, math.max(bottom - top, 0)))
	set(item, "BackgroundColor3", color)
	set(item, "BackgroundTransparency", guiAlpha(entry, transparency))
	set(item, "ZIndex", layerZ(entry, "leader", zIndex))
	set(item, "Visible", true)
end

local function drawLeader(entry, x, top, bottom)
	if bottom - top < 2 then
		return
	end
	local width = math.max(1, math.round(theme(entry, "leaderThickness")))
	local transparency = theme(entry, "leaderTransparency")
	if theme(entry, "leaderOutline") then
		local outline = math.max(1, math.round(theme(entry, "lineOutlineWidth")))
		leaderBar(entry, "leaderOutline", x, top, bottom, width + outline * 2, theme(entry, "outlineColor"), transparency, 0)
	end
	leaderBar(entry, "leader", x, top, bottom, width, theme(entry, "leaderColor"), transparency, 1)
end

local function overlaps(a, x, y, width, height, spacing)
	return x < a.x + a.width + spacing and a.x < x + width + spacing and y < a.y + a.height + spacing and a.y < y + height + spacing
end

local function claim(entry, x, y, width, height)
	if not option(entry, "declutter", "enabled") then
		return y
	end
	local claims = entry.esp.claims
	local spacing = option(entry, "declutter", "spacing")
	local lowest = y - option(entry, "declutter", "maxLift")
	local placed = y
	for _ = 1, #claims + 1 do
		local blocker
		for _, other in claims do
			if overlaps(other, x, placed, width, height, spacing) then
				blocker = other
				break
			end
		end
		if not blocker then
			break
		end
		placed = blocker.y - height - spacing
		if placed < lowest then
			placed = y
			break
		end
	end
	table.insert(claims, { x = x, y = placed, width = width, height = height })
	if placed < y - 1 and option(entry, "declutter", "leaders") then
		drawLeader(entry, math.floor(x + width / 2), placed + height, entry.view.minY - 1)
	end
	return placed
end

local function drawClassic(entry)
	local view = entry.view
	local minX, minY, maxX = view.minX, view.minY, view.maxX
	local root = entry.anchor
	local gap = theme(entry, "textGap")
	local small = theme(entry, "smallTextSize")
	local onRight = option(entry, "health", "side") == "right"
	local edgeScale, edgeOffset = if onRight then 1 else 0, if onRight then 1 else -1

	if healthShown(entry) then
		local style = option(entry, "health", "style")
		if style ~= "number" then
			edgeScale, edgeOffset = drawSideBar(entry)
		end
		local tooSmall = option(entry, "shrink", "enabled") and view.distance > option(entry, "shrink", "numberBeyond")
		if style ~= "bar" and not tooSmall then
			local main, shadow = text(entry, "healthText", root, small, healthColor(entry, view.fraction), healthText(entry))
			local yScale = if style == "both" then 1 - view.fraction else 0
			local x = if onRight then edgeOffset + gap else edgeOffset - gap
			pinText(entry, main, shadow, edgeScale, x, yScale, 0, if onRight then 0 else 1, yScale)
		end
	end

	local name = option(entry, "name", "enabled") and displayName(entry)
	local avatar = option(entry, "avatar", "enabled") and view.avatar
	if name or avatar then
		local nameWidth, nameHeight = 0, 0
		local main, shadow, bounds
		if name then
			main, shadow, bounds = text(entry, "name", root, theme(entry, "textSize"), theme(entry, "nameColor"), name)
			nameWidth, nameHeight = math.ceil(bounds.X), math.ceil(bounds.Y)
		end
		local avatarSize = if avatar then theme(entry, "avatarSize") else 0
		local avatarSpace = if avatar and name then avatarSize + 3 else avatarSize
		local rowHeight = math.max(nameHeight, avatarSize)
		local rowWidth = nameWidth + avatarSpace
		local xScale, x, top = 0.5, -math.floor(rowWidth / 2), -1 - gap - rowHeight
		if option(entry, "declutter", "enabled") then
			local absoluteX = math.floor((minX + maxX - rowWidth) / 2)
			xScale, x, top = 0, absoluteX - minX, claim(entry, absoluteX, minY + top, rowWidth, rowHeight) - minY
		end
		if avatar then
			avatarImage(entry, "avatar", root, avatar, xScale, x, 0, top + math.floor((rowHeight - avatarSize) / 2), avatarSize, theme(entry, "avatarCornerRadius"))
		end
		if main then
			pinText(entry, main, shadow, xScale, x + avatarSpace, 0, top + math.floor((rowHeight - nameHeight) / 2))
		end
	end

	local parts = freshParts(entry)
	if option(entry, "distance", "enabled") then
		addPart(parts, distanceText(entry), theme(entry, "distanceColor"))
	end
	addDetails(entry, parts)
	local y = 1 + gap
	local spacing = theme(entry, "lineSpacing")
	for index = 1, #parts, 2 do
		local main, shadow, bounds = text(entry, DETAIL_KEYS[(index + 1) / 2], root, small, parts[index + 1], parts[index])
		pinText(entry, main, shadow, 0.5, 0, 1, y, 0.5, 0)
		y += math.ceil(bounds.Y) + spacing
	end
end

local function drawPanel(entry, pill)
	local view = entry.view
	local showHealth = healthShown(entry)
	local style = option(entry, "health", "style")
	local barBeside = showHealth and style ~= "number" and option(entry, "box", "enabled")
	local showNumber = showHealth and (style ~= "bar" or not barBeside)
	local showDistance = option(entry, "distance", "enabled")
	local avatar = option(entry, "avatar", "enabled") and view.avatar
	if barBeside then
		drawSideBar(entry)
	end

	local headline = freshParts(entry)
	if option(entry, "name", "enabled") then
		addPart(headline, displayName(entry))
	end
	local stats = entry.detailBuffer
	table.clear(stats)
	if showNumber then
		addPart(if pill then headline else stats, healthText(entry), healthColor(entry, view.fraction))
	end
	if not pill then
		if showDistance then
			addPart(stats, distanceText(entry), theme(entry, "distanceColor"))
		end
		addDetails(entry, stats)
	end
	local showSideDistance = pill and showDistance
	if #headline == 0 and #stats == 0 and not showSideDistance and not avatar then
		return
	end

	local padding = theme(entry, "panelPadding")
	local spacing = theme(entry, "panelSpacing")
	local small = theme(entry, "smallTextSize")
	local panel = use(entry, "panel", newPanel, entry.anchor)
	local parent = panel.object

	local rowWidth, rowHeight = 0, 0
	local nameMain, nameShadow, nameBounds
	if #headline > 0 then
		local rich, plain = join(headline, "  ")
		nameMain, nameShadow, nameBounds = text(entry, "panelName", parent, theme(entry, "textSize"), theme(entry, "nameColor"), plain, rich)
		rowWidth, rowHeight = nameBounds.X, nameBounds.Y
	end
	local distanceMain, distanceShadow, distanceBounds
	if showSideDistance then
		distanceMain, distanceShadow, distanceBounds = text(entry, "panelDistance", parent, small, theme(entry, "distanceColor"), distanceText(entry))
		rowWidth += (if rowWidth > 0 then spacing else 0) + distanceBounds.X
		rowHeight = math.max(rowHeight, distanceBounds.Y)
	end
	local statsMain, statsShadow, statsBounds
	if #stats > 0 then
		local rich, plain = join(stats, "  ·  ")
		statsMain, statsShadow, statsBounds = text(entry, "panelDetails", parent, small, theme(entry, "nameColor"), plain, rich)
	end

	rowHeight = math.ceil(rowHeight)
	local blockHeight = rowHeight
	if statsBounds then
		blockHeight += (if rowHeight > 0 then 1 else 0) + math.ceil(statsBounds.Y)
	end
	local contentWidth = math.ceil(math.max(rowWidth, if statsBounds then statsBounds.X else 0))
	local avatarSize = if avatar then math.max(theme(entry, "avatarSize"), blockHeight) else 0
	local contentHeight = math.max(blockHeight, avatarSize)
	local height = padding * 2 + contentHeight
	local endPadding = if pill then math.max(padding, math.floor(height * 0.45)) else padding
	local textX = if avatar then padding + avatarSize + (if contentWidth > 0 then spacing else 0) else endPadding
	local width = math.max(if contentWidth > 0 then theme(entry, "panelMinWidth") else 0, textX + contentWidth + endPadding)
	local top = padding + math.floor((contentHeight - blockHeight) / 2)

	local originX, originY = entry.originX, entry.originY
	entry.originX, entry.originY = 0, 0
	if avatar then
		local radius = if pill then math.floor(avatarSize / 2) else theme(entry, "avatarCornerRadius")
		avatarImage(entry, "panelAvatar", parent, avatar, 0, padding, 0, padding + math.floor((contentHeight - avatarSize) / 2), avatarSize, radius)
	end
	if nameMain then
		place(entry, nameMain, nameShadow, textX, top + math.floor((rowHeight - nameBounds.Y) / 2))
	end
	if distanceMain then
		place(entry, distanceMain, distanceShadow, width - endPadding - math.ceil(distanceBounds.X), top + rowHeight - math.ceil(distanceBounds.Y))
	end
	if statsMain then
		place(entry, statsMain, statsShadow, textX, top + blockHeight - math.ceil(statsBounds.Y))
	end

	set(panel, "BackgroundColor3", theme(entry, "panelColor"))
	set(panel, "BackgroundTransparency", guiAlpha(entry, theme(entry, "panelTransparency")))
	set(panel, "Size", UDim2.fromOffset(width, height))
	entry.originX, entry.originY = originX, originY
	local panelTop = -1 - theme(entry, "textGap") - height
	if option(entry, "declutter", "enabled") then
		local panelX = math.floor((view.minX + view.maxX - width) / 2)
		set(panel, "Position", UDim2.fromOffset(panelX - originX, claim(entry, panelX, view.minY + panelTop, width, height) - originY))
	else
		set(panel, "Position", UDim2.new(0.5, -math.floor(width / 2), 0, panelTop))
	end
	set(panel, "ZIndex", layerZ(entry, "text", 0))
	set(panel, "Visible", true)
	set(panel.corner, "CornerRadius", UDim.new(0, if pill then math.floor(height / 2) else theme(entry, "panelCornerRadius")))
	set(panel.stroke, "Color", theme(entry, "panelStrokeColor"))
	set(panel.stroke, "Thickness", theme(entry, "panelStrokeThickness"))
	set(panel.stroke, "Transparency", guiAlpha(entry, theme(entry, "panelStrokeTransparency")))
end

local function drawMinimal(entry)
	local view = entry.view
	local name = option(entry, "name", "enabled") and displayName(entry)
	local parts = freshParts(entry)
	if healthShown(entry) then
		addPart(parts, healthText(entry), healthColor(entry, view.fraction))
	end
	if option(entry, "distance", "enabled") then
		addPart(parts, distanceText(entry), theme(entry, "distanceColor"))
	end
	addDetails(entry, parts)
	if not name and #parts == 0 then
		return
	end

	local root = entry.anchor
	local nameMain, nameShadow, nameBounds
	local width, height = 0, 0
	if name then
		nameMain, nameShadow, nameBounds = text(entry, "minimalName", root, theme(entry, "textSize"), theme(entry, "nameColor"), name)
		width, height = math.ceil(nameBounds.X), math.ceil(nameBounds.Y)
	end
	local statsMain, statsShadow, statsBounds
	if #parts > 0 then
		local rich, plain = join(parts, "  ")
		statsMain, statsShadow, statsBounds = text(entry, "minimal", root, theme(entry, "smallTextSize"), theme(entry, "nameColor"), plain, rich)
		width += (if name then theme(entry, "panelSpacing") else 0) + math.ceil(statsBounds.X)
		height = math.max(height, math.ceil(statsBounds.Y))
	end

	local xScale, x, bottom = 0.5, -math.floor(width / 2), -1 - theme(entry, "textGap")
	if option(entry, "declutter", "enabled") then
		local absoluteX = math.floor((view.minX + view.maxX - width) / 2)
		xScale, x = 0, absoluteX - view.minX
		bottom = claim(entry, absoluteX, view.minY + bottom - height, width, height) + height - view.minY
	end
	if nameMain then
		pinText(entry, nameMain, nameShadow, xScale, x, 0, bottom - math.ceil(nameBounds.Y))
		x += math.ceil(nameBounds.X) + theme(entry, "panelSpacing")
	end
	if statsMain then
		pinText(entry, statsMain, statsShadow, xScale, x, 0, bottom - math.ceil(statsBounds.Y) - (if nameMain then 1 else 0))
	end
end

local LAYOUTS = {
	classic = drawClassic,
	card = function(entry)
		drawPanel(entry, false)
	end,
	badge = function(entry)
		drawPanel(entry, true)
	end,
	minimal = drawMinimal,
}

local function pivotOf(model)
	if model:IsA("PVInstance") then
		return model:GetPivot()
	elseif model:IsA("Attachment") then
		return model.WorldCFrame
	end
	return nil
end

local function collectJoints(model)
	local joints = {}
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("Motor6D") then
			local part0, part1 = descendant.Part0, descendant.Part1
			if part0 and part1 then
				joints[part1] = { motor = descendant, part0 = part0, part1 = part1 }
			end
		elseif descendant:IsA("AnimationConstraint") then
			local attachment0, attachment1 = descendant.Attachment0, descendant.Attachment1
			local part0 = attachment0 and attachment0.Parent
			local part1 = attachment1 and attachment1.Parent
			if part0 and part1 and part0:IsA("BasePart") and part1:IsA("BasePart") and not joints[part1] then
				joints[part1] = { attachment = attachment0, part0 = part0, part1 = part1 }
			end
		end
	end
	return joints
end

local function limbChain(limb, limbOf, motors, children)
	local start
	for part, kind in limbOf do
		if kind == limb and limbOf[motors[part].part0] ~= limb then
			start = part
			break
		end
	end
	if not start then
		return nil
	end
	local chain, current = { start }, start
	while true do
		local nextPart
		for _, child in children[current] or {} do
			if limbOf[child] == limb then
				nextPart = child
				break
			end
		end
		if not nextPart then
			break
		end
		table.insert(chain, nextPart)
		current = nextPart
	end
	return chain
end

local function humanoidRig(model, humanoid)
	local motors, children, limbOf = collectJoints(model), {}, {}
	for part, joint in motors do
		children[joint.part0] = children[joint.part0] or {}
		table.insert(children[joint.part0], part)
	end
	for part in motors do
		local ok, limb = pcall(humanoid.GetLimb, humanoid, part)
		if ok and limb ~= Enum.Limb.Unknown then
			limbOf[part] = limb
		end
	end
	local sizes = {}
	for part in motors do
		sizes[part] = part.Size
	end
	local torso = limbChain(Enum.Limb.Torso, limbOf, motors, children)
	if not torso then
		return nil
	end
	local head
	for part, kind in limbOf do
		if kind == Enum.Limb.Head then
			head = part
			break
		end
	end
	local rig = {
		motors = motors,
		torso = torso,
		head = head,
		leftArm = limbChain(Enum.Limb.LeftArm, limbOf, motors, children),
		rightArm = limbChain(Enum.Limb.RightArm, limbOf, motors, children),
		leftLeg = limbChain(Enum.Limb.LeftLeg, limbOf, motors, children),
		rightLeg = limbChain(Enum.Limb.RightLeg, limbOf, motors, children),
		frames = {},
		sizes = sizes,
	}
	rig.paths = rigPaths(rig)
	return rig
end

local function skeletonOf(model, root)
	local joints, children = collectJoints(model), {}
	for _, joint in joints do
		children[joint.part0] = children[joint.part0] or {}
		table.insert(children[joint.part0], joint)
	end
	local bones = {}
	for _, joint in joints do
		local childJoints = children[joint.part1]
		if childJoints then
			for _, child in childJoints do
				table.insert(bones, { joint, child })
			end
		elseif joint.part0 ~= root then
			table.insert(bones, { joint, false })
		end
	end
	return bones
end

local function refreshParts(entry, model)
	local now = os.clock()
	if entry.partsModel ~= model or now - entry.partsAt > PARTS_REFRESH then
		local parts = entry.accessors.parts(entry.target, model)
		local halves = table.create(#parts)
		for index, part in parts do
			halves[index] = part.Size / 2
		end
		entry.parts, entry.halves = parts, halves
		entry.partsModel, entry.partsAt = model, now
		local humanoid = humanoidOf(model)
		if entry.rigModel ~= model or now - entry.rigAt > RIG_REFRESH then
			entry.rigModel, entry.rigAt = model, now
			entry.rig = if humanoid then humanoidRig(model, humanoid) else nil
			entry.bones = if humanoid and not entry.rig then skeletonOf(model, humanoid.RootPart) else nil
			local head = entry.rig and entry.rig.head or model:FindFirstChild("Head")
			entry.head = if head and head:IsA("BasePart") then head else nil
		end
	end
	return entry.parts
end

local function localBounds(parts, pivot)
	local low, high
	for _, part in parts do
		if not part.Parent then
			continue
		end
		local half = part.Size / 2
		local relative = pivot:ToObjectSpace(part.CFrame)
		local center = relative.Position
		local a, b, c = relative.XVector * half.X, relative.YVector * half.Y, relative.ZVector * half.Z
		for _, sign in CORNERS do
			local point = center + a * sign.X + b * sign.Y + c * sign.Z
			low = if low then low:Min(point) else point
			high = if high then high:Max(point) else point
		end
	end
	return low, high
end

local function projectBox(cframe, low, high, corners)
	local inverse, centerX, centerY, scale = projection.inverse, projection.centerX, projection.centerY, projection.scale
	local relative = inverse * cframe
	local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
	local inFront = true
	local middle, extent = (low + high) / 2, (high - low) / 2
	for index, sign in CORNERS do
		local corner = relative * (middle + extent * sign)
		local depth = -corner.Z
		if depth <= 0 then
			inFront = false
			continue
		end
		local x, y = centerX + corner.X * scale / depth, centerY - corner.Y * scale / depth
		if corners then
			corners[index] = Vector2.new(x, y)
		end
		minX, maxX = math.min(minX, x), math.max(maxX, x)
		minY, maxY = math.min(minY, y), math.max(maxY, y)
	end
	return inFront, minX, minY, maxX, maxY
end

local bounds = {}

local function extend(point)
	local depth = -point.Z
	if depth <= 0 then
		bounds.behind = true
		return
	end
	local u, v = point.X / depth, point.Y / depth
	if u < bounds.minU then
		bounds.minU = u
	end
	if u > bounds.maxU then
		bounds.maxU = u
	end
	if v < bounds.minV then
		bounds.minV = v
	end
	if v > bounds.maxV then
		bounds.maxV = v
	end
end

local function exactBounds(parts, halves)
	local inverse = projection.inverse
	bounds.minU, bounds.maxU, bounds.minV, bounds.maxV, bounds.behind = math.huge, -math.huge, math.huge, -math.huge, false
	for index, part in parts do
		local half = halves[index]
		local relative = inverse * part.CFrame
		local center = relative.Position
		local a, b, c = relative.XVector * half.X, relative.YVector * half.Y, relative.ZVector * half.Z
		local plus, minus, near, far = a + b, a - b, center + c, center - c
		extend(near + plus)
		extend(far + plus)
		extend(near - plus)
		extend(far - plus)
		extend(near + minus)
		extend(far + minus)
		extend(near - minus)
		extend(far - minus)
	end
	if bounds.minU == math.huge then
		return not bounds.behind, math.huge, math.huge, -math.huge, -math.huge
	end
	local centerX, centerY, scale = projection.centerX, projection.centerY, projection.scale
	return not bounds.behind, centerX + bounds.minU * scale, centerY - bounds.maxV * scale, centerX + bounds.maxU * scale, centerY - bounds.minV * scale
end

local function measure(entry, model, camera, pivot)
	local view = entry.view
	local parts = entry.parts
	local now = os.clock()
	if entry.localModel ~= model or now - entry.localAt > LOCAL_BOUNDS_REFRESH then
		entry.localLow, entry.localHigh = localBounds(parts, pivot)
		entry.localModel, entry.localAt = model, now
		entry.radius = if entry.localLow then math.max(entry.localLow.Magnitude, entry.localHigh.Magnitude) else 0
	end
	local low, high, radius = entry.localLow, entry.localHigh, entry.radius
	local viewport = projection.viewport
	local wants3d = option(entry, "box", "enabled") and option(entry, "box", "style") == "3d"
	view.corners3d = nil

	local relative = projection.inverse * pivot.Position
	local depth = -relative.Z
	if low then
		if depth + radius <= 0 then
			view.onScreen = false
			return
		end
		if depth - radius > 0 then
			local spread = projection.scale * radius / (depth - radius)
			local x = projection.centerX + relative.X * projection.scale / depth
			local y = projection.centerY - relative.Y * projection.scale / depth
			if x + spread < 0 or x - spread > viewport.X or y + spread < 0 or y - spread > viewport.Y then
				view.onScreen = false
				return
			end
		end
	end

	local inFront, minX, minY, maxX, maxY
	local coarse = low and depth > radius and (high.Y - low.Y) * projection.scale / depth < LOD_PIXELS
	if coarse then
		inFront, minX, minY, maxX, maxY = projectBox(pivot, low, high, if wants3d then view.cornerBuffer else nil)
		if wants3d and inFront then
			view.corners3d = view.cornerBuffer
		end
	else
		inFront, minX, minY, maxX, maxY = exactBounds(parts, entry.halves)
		if wants3d and low and inFront then
			projectBox(pivot, low, high, view.cornerBuffer)
			view.corners3d = view.cornerBuffer
		end
	end

	if minX == math.huge then
		local point, front = screen(pivot.Position)
		inFront = front
		minX, minY, maxX, maxY = point.X, point.Y, point.X, point.Y
	end
	view.minX, view.minY = math.floor(minX), math.floor(minY)
	view.maxX, view.maxY = math.ceil(maxX), math.ceil(maxY)
	view.onScreen = inFront and maxX >= 0 and minX <= viewport.X and maxY >= 0 and minY <= viewport.Y
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function occluded(entry, origin, model, point)
	local now = os.clock()
	if now - entry.rayAt >= VISIBILITY_INTERVAL then
		entry.rayAt = now
		raycastParams.FilterDescendantsInstances = { LocalPlayer.Character, model }
		entry.occluded = Workspace:Raycast(origin, point - origin, raycastParams) ~= nil
	end
	return entry.occluded
end

local function describe(entry, camera, origin, from, deltaTime)
	local accessors, target = entry.accessors, entry.target
	local overlays = entry.overlays
	table.clear(overlays)
	local model = accessors.model(target)
	if not model or not model.Parent then
		return false
	end
	local variantName = accessors.variant(target, model)
	local variant = variantName and entry.group.settings.variants[variantName]
	if variant then
		table.insert(overlays, variant)
	end
	if not setting(entry, "enabled") then
		return false
	end

	local pivot = pivotOf(model)
	if not pivot then
		return false
	end
	local view = entry.view
	view.model, view.position = model, pivot.Position
	view.distance = (pivot.Position - from).Magnitude
	if view.distance > setting(entry, "maxDistance") then
		return false
	end

	local health, maxHealth = accessors.health(target, model)
	if health and health <= 0 then
		return false
	end

	refreshParts(entry, model)
	view.head = if entry.head and entry.head.Parent then entry.head else nil
	if setting(entry, "visibilityCheck") and occluded(entry, origin, model, if view.head then view.head.Position else view.position) then
		table.insert(overlays, 1, entry.group.settings.occluded)
	end

	local now = os.clock()
	if now >= entry.infoAt or view.infoModel ~= model then
		entry.infoAt = now + INFO_INTERVAL * (0.75 + math.random() * 0.5)
		view.infoModel = model
		view.name = tostring(accessors.name(target, model) or "")
		view.username = if entry.isPlayer then target.Name else nil
		view.avatar = accessors.avatar(target, model)
		local weapon = accessors.weapon(target, model)
		view.weapon = if weapon then tostring(weapon) else nil
		local teamName, teamColor = accessors.team(target, model)
		view.teamName = if teamName then tostring(teamName) else nil
		view.teamColor = if typeof(teamColor) == "Color3" then teamColor else nil
		view.tags = accessors.tags(target, model)
	end
	view.health, view.maxHealth = health, maxHealth or 100
	view.fraction = nil
	if health then
		local fraction = math.clamp(health / math.max(view.maxHealth, 1), 0, 1)
		local shown = entry.shownHealth
		local blend = 1 - math.exp(-theme(entry, "healthSmoothing") * deltaTime)
		entry.shownHealth = if shown then shown + (fraction - shown) * blend else fraction
		view.fraction = entry.shownHealth
	end

	entry.opacity = 1
	if option(entry, "fade", "enabled") then
		local start, finish = option(entry, "fade", "start"), option(entry, "fade", "finish")
		local t = math.clamp((view.distance - start) / math.max(finish - start, 1), 0, 1)
		entry.opacity = 1 - t * (1 - option(entry, "fade", "minOpacity"))
	end

	measure(entry, model, camera, pivot)
	return true
end

local function destroyElements(entry)
	for _, item in entry.elements do
		item.object:Destroy()
	end
	table.clear(entry.elements)
end

local function sweep(entry)
	for _, item in entry.elements do
		if item.tick ~= entry.tick then
			set(item, "Visible", false)
		end
	end
end

local function removeEntry(group, target, entry)
	if group.entries[target] == entry then
		group.entries[target] = nil
		destroyElements(entry)
	end
end

local function report(entry, problem)
	entry.tick += 1
	entry.shownHealth = nil
	if not entry.reported then
		entry.reported = true
		warn(string.format("sightline: %s failed and is hidden until it recovers: %s", tostring(entry.target), tostring(problem)))
	end
end

local function effectiveLayout(entry)
	local layout = setting(entry, "layout")
	if layout == "classic" or layout == "minimal" or not option(entry, "shrink", "enabled") then
		return layout
	end
	local distance = entry.view.distance
	if distance > option(entry, "shrink", "minimalBeyond") then
		return "minimal"
	elseif distance > option(entry, "shrink", "badgeBeyond") then
		return "badge"
	end
	return layout
end

local function newAnchor(parent)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.new()
	frame.Visible = false
	frame.Parent = parent
	return cached(frame)
end

local function layoutChanged(entry, layout)
	local view, last = entry.view, entry.lastLayout
	local overlays = entry.overlays
	local health = if view.health then math.round(view.health) else -1
	local fraction = if view.fraction then math.round(view.fraction * 200) else -1
	local distance = math.floor(view.distance)
	local opacity = math.round(entry.opacity * 100)
	local first, second, third = overlays[1], overlays[2], overlays[3]
	if last.version == settingsVersion and last.layout == layout
		and last.health == health and last.maxHealth == view.maxHealth and last.fraction == fraction
		and last.distance == distance and last.opacity == opacity and last.name == view.name
		and last.avatar == view.avatar and last.weapon == view.weapon and last.teamName == view.teamName
		and last.teamColor == view.teamColor and last.tags == view.tags
		and last.first == first and last.second == second and last.third == third then
		return false
	end
	last.version, last.layout = settingsVersion, layout
	last.health, last.maxHealth, last.fraction, last.distance, last.opacity = health, view.maxHealth, fraction, distance, opacity
	last.name, last.avatar, last.weapon, last.teamName, last.teamColor, last.tags = view.name, view.avatar, view.weapon, view.teamName, view.teamColor, view.tags
	last.first, last.second, last.third = first, second, third
	return true
end

local function drawLayout(entry)
	local view = entry.view
	local anchor = use(entry, "anchor", newAnchor, entry.esp.gui)
	set(anchor, "Position", UDim2.fromOffset(view.minX, view.minY))
	set(anchor, "Size", UDim2.fromOffset(view.maxX - view.minX, view.maxY - view.minY))
	set(anchor, "ZIndex", layerZ(entry, "text", 0))
	set(anchor, "Visible", true)
	entry.anchor = anchor.object
	entry.originX, entry.originY = view.minX, view.minY
	local layout = effectiveLayout(entry)
	local items = entry.layoutItems
	if not entry.staleBounds and not option(entry, "declutter", "enabled") and not layoutChanged(entry, layout) then
		local tick = entry.tick
		for _, item in items do
			item.tick = tick
		end
		return
	end
	table.clear(items)
	entry.staleBounds = false
	entry.recording = items
	LAYOUTS[layout](entry)
	entry.recording = nil
end

local function drawEntry(entry, camera, viewport, mouse)
	local view = entry.view
	if view.onScreen then
		drawBox(entry)
		drawTracer(entry, viewport, mouse)
		if not (option(entry, "shrink", "enabled") and view.distance > option(entry, "shrink", "detailBeyond")) then
			drawSkeleton(entry, camera)
			drawHead(entry, camera)
		end
		drawLayout(entry)
	elseif option(entry, "arrow", "enabled") then
		drawArrow(entry, camera, viewport)
	end
end

local function byDistance(a, b)
	return a.view.distance < b.view.distance
end

local function applyFocus(group, shown, mouse)
	local best, bestDistance = nil, group.settings.focus.radius
	for _, entry in shown do
		local view = entry.view
		if view.onScreen then
			local center = Vector2.new((view.minX + view.maxX) / 2, (view.minY + view.maxY) / 2)
			local distance = (center - mouse).Magnitude
			if distance < bestDistance then
				best, bestDistance = entry, distance
			end
		end
	end
	if best then
		table.insert(best.overlays, 1, group.settings.focused)
	end
	group.focusedEntry = best
end

local function orderShown(esp)
	esp.frame += 1
	local frame = esp.frame
	for _, group in esp.groups do
		for _, entry in group.shown do
			entry.shownFrame = frame
		end
	end
	local order, kept = esp.order, 0
	for index = 1, #order do
		local entry = order[index]
		order[index] = nil
		if entry.shownFrame == frame and not entry.ordered then
			kept += 1
			order[kept] = entry
			entry.ordered = true
		end
	end
	for _, group in esp.groups do
		for _, entry in group.shown do
			if not entry.ordered then
				kept += 1
				order[kept] = entry
			end
			entry.ordered = nil
		end
	end
	for index = 2, kept do
		local position = index
		while position > 1 and order[position].view.distance < order[position - 1].view.distance - ORDER_MARGIN do
			order[position], order[position - 1] = order[position - 1], order[position]
			position -= 1
		end
	end
	for index, entry in order do
		entry.zBase = (kept - index) * Z_STEP
	end
	return order
end

local function updateChams(esp, candidates)
	if #candidates > MAX_HIGHLIGHTS then
		table.sort(candidates, byDistance)
	end
	for index = 1, MAX_HIGHLIGHTS do
		local entry = candidates[index]
		local highlight = esp.highlights[index]
		if entry then
			if not highlight then
				local instance = Instance.new("Highlight")
				instance.Parent = esp.folder
				highlight = cached(instance)
				esp.highlights[index] = highlight
			end
			set(highlight, "Adornee", entry.view.model)
			set(highlight, "FillColor", theme(entry, "chamsFillColor"))
			set(highlight, "FillTransparency", guiAlpha(entry, theme(entry, "chamsFillTransparency")))
			set(highlight, "OutlineColor", theme(entry, "chamsOutlineColor"))
			set(highlight, "OutlineTransparency", guiAlpha(entry, theme(entry, "chamsOutlineTransparency")))
			set(highlight, "DepthMode", if option(entry, "chams", "throughWalls") then Enum.HighlightDepthMode.AlwaysOnTop else Enum.HighlightDepthMode.Occluded)
			set(highlight, "Enabled", true)
		elseif highlight then
			set(highlight, "Enabled", false)
			set(highlight, "Adornee", nil)
		end
	end
end

function Group:add(target, accessors)
	local existing = self.entries[target]
	if existing then
		removeEntry(self, target, existing)
	end
	local entry = {
		group = self,
		esp = self.esp,
		target = target,
		isPlayer = target:IsA("Player"),
		accessors = withAccessors(self.accessors, accessors),
		elements = {},
		overlays = {},
		detailBuffer = {},
		layoutItems = {},
		lastLayout = {},
		originX = 0,
		originY = 0,
		labels = {},
		partsBuffer = {},
		styles = {},
		view = { cornerBuffer = {} },
		tick = 0,
		zBase = 0,
		opacity = 1,
		partsAt = -math.huge,
		rigAt = -math.huge,
		infoAt = -math.huge,
		localAt = -math.huge,
		radius = 0,
		rayAt = -math.huge,
	}
	self.entries[target] = entry
	return {
		remove = function()
			removeEntry(self, target, entry)
		end,
	}
end

function Group:watch(container, accessors)
	accessors = table.clone(accessors or {})
	local filter, recursive = accessors.filter, accessors.recursive
	accessors.filter, accessors.recursive = nil, nil
	local handles = {}
	local function consider(child)
		if not handles[child] and (not filter or filter(child)) then
			handles[child] = self:add(child, accessors)
		end
	end
	local function drop(child)
		local handle = handles[child]
		if handle then
			handles[child] = nil
			handle.remove()
		end
	end
	local added = if recursive then container.DescendantAdded else container.ChildAdded
	local removed = if recursive then container.DescendantRemoving else container.ChildRemoved
	local connections = { added:Connect(consider), removed:Connect(drop) }
	for _, connection in connections do
		table.insert(self.connections, connection)
	end
	local existing = if recursive then container:GetDescendants() else container:GetChildren()
	for _, child in existing do
		consider(child)
	end
	return {
		remove = function()
			for _, connection in connections do
				connection:Disconnect()
			end
			for child in handles do
				drop(child)
			end
		end,
	}
end

function Group:focusedTarget()
	local entry = self.focusedEntry
	return entry and self.entries[entry.target] == entry and entry.target or nil
end

function Group:remove()
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	for target, entry in self.entries do
		removeEntry(self, target, entry)
	end
	local index = table.find(self.esp.groups, self)
	if index then
		table.remove(self.esp.groups, index)
	end
end

local function newGroup(esp, settings, accessors)
	local group = setmetatable({
		esp = esp,
		settings = buildSettings(settings, false),
		accessors = accessors,
		entries = {},
		connections = {},
		shown = {},
	}, Group)
	table.insert(esp.groups, group)
	return group
end

function Esp:group(settings, accessors)
	return newGroup(self, settings, withAccessors(DEFAULT_ACCESSORS, accessors))
end

function Esp:players(settings, accessors)
	local base = withAccessors(DEFAULT_ACCESSORS, { variant = playerVariant })
	local group = newGroup(self, overlay(PLAYER_PRESET, settings), withAccessors(base, accessors))
	group:watch(Players, {
		filter = function(child)
			return child:IsA("Player") and child ~= LocalPlayer
		end,
	})
	return group
end

function Esp:render(deltaTime)
	local camera = Workspace.CurrentCamera
	local chams = self.chamsBuffer
	table.clear(chams)
	if camera and self.enabled then
		measureLabels(self)
		local origin = camera.CFrame.Position
		updateProjection(camera)
		local character = LocalPlayer.Character
		local localHumanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = localHumanoid and localHumanoid.RootPart
		local from = if root then root.Position else origin
		local viewport = camera.ViewportSize
		local mouse = UserInputService:GetMouseLocation()
		for _, group in self.groups do
			local shown = group.shown
			table.clear(shown)
			for target, entry in group.entries do
				if not entry.isPlayer and not target.Parent then
					removeEntry(group, target, entry)
					continue
				end
				entry.tick += 1
				local ok, visible = pcall(describe, entry, camera, origin, from, deltaTime)
				if not ok then
					report(entry, visible)
				elseif visible then
					table.insert(shown, entry)
				else
					entry.shownHealth = nil
				end
			end
			local limit = group.settings.maxTargets
			if limit > 0 and #shown > limit then
				table.sort(shown, byDistance)
				for index = #shown, limit + 1, -1 do
					shown[index] = nil
				end
			end
			if group.settings.focus.enabled then
				applyFocus(group, shown, mouse)
			else
				group.focusedEntry = nil
			end
		end

		local order = orderShown(self)
		table.clear(self.claims)
		for _, entry in order do
			local ok, problem = pcall(drawEntry, entry, camera, viewport, mouse)
			if not ok then
				report(entry, problem)
			else
				entry.reported = nil
				if option(entry, "chams", "enabled") then
					table.insert(chams, entry)
				end
			end
		end
	end
	for _, group in self.groups do
		for _, entry in group.entries do
			if not self.enabled then
				entry.tick += 1
			end
			sweep(entry)
		end
	end
	updateChams(self, chams)
end

function Esp:unload()
	RunService:UnbindFromRenderStep(self.stepName)
	for index = #self.groups, 1, -1 do
		self.groups[index]:remove()
	end
	self.gui:Destroy()
	self.folder:Destroy()
	if getgenv()[SESSION_KEY] == self then
		getgenv()[SESSION_KEY] = nil
	end
end

function Sightline.start(themeOverrides)
	local running = getgenv()[SESSION_KEY]
	if running then
		running:unload()
	end

	local container = if gethui then gethui() else CoreGui
	local gui = Instance.new("ScreenGui")
	gui.Name = tostring(math.random(1e6, 1e7))
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 1e6
	gui.Parent = container
	local folder = Instance.new("Folder")
	folder.Name = tostring(math.random(1e6, 1e7))
	folder.Parent = container

	local esp = setmetatable({
		enabled = true,
		theme = strict(THEME_DEFAULTS, themeOverrides, "theme.", false),
		gui = gui,
		folder = folder,
		groups = {},
		highlights = {},
		chamsBuffer = {},
		order = {},
		claims = {},
		frame = 0,
		stepName = tostring(math.random(1e6, 1e7)),
	}, Esp)
	RunService:BindToRenderStep(esp.stepName, Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
		esp:render(deltaTime)
	end)
	getgenv()[SESSION_KEY] = esp
	return esp
end

return Sightline
