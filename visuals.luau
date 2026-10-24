local THEME_DEFAULTS = {
	font = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
	textSize = 13,
	smallTextSize = 11,
	textColor = Color3.new(1, 1, 1),
	mutedTextColor = Color3.fromRGB(170, 170, 180),
	tagColor = Color3.fromRGB(255, 200, 80),
	shadowColor = Color3.new(0, 0, 0),
	shadowTransparency = 0.3,
	shadowOffset = Vector2.new(1, 1),
	outlineColor = Color3.new(0, 0, 0),
	lineThickness = 1,
	lineOutline = true,
	boxColor = Color3.new(1, 1, 1),
	boxFillColor = Color3.new(1, 1, 1),
	boxFillTransparency = 0.85,
	cornerLength = 0.25,
	tracerColor = Color3.new(1, 1, 1),
	skeletonColor = Color3.new(1, 1, 1),
	headDotColor = Color3.new(1, 1, 1),
	lookColor = Color3.fromRGB(255, 90, 90),
	arrowColor = Color3.new(1, 1, 1),
	chamsFillColor = Color3.fromRGB(255, 70, 70),
	chamsFillTransparency = 0.5,
	chamsOutlineColor = Color3.new(1, 1, 1),
	chamsOutlineTransparency = 0,
	healthyHue = 1 / 3,
	healthSmoothing = 10,
	barWidth = 1,
	barGap = 4,
	textGap = 3,
	lineSpacing = 1,
	avatarSize = 18,
	avatarCornerRadius = 4,
	panelColor = Color3.fromRGB(16, 16, 20),
	panelTransparency = 0.15,
	panelCornerRadius = 6,
	panelPadding = 5,
	panelSpacing = 6,
	panelMinWidth = 48,
	panelBarHeight = 2,
	panelBarColor = Color3.fromRGB(45, 45, 52),
}
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
	health = { enabled = false, style = "bar", format = "value", gradient = true },
	name = { enabled = false, style = "display" },
	avatar = { enabled = false },
	distance = { enabled = false, unit = "studs" },
	weapon = { enabled = false },
	team = { enabled = false },
	tags = { enabled = false },
	tracer = { enabled = false, origin = "bottom" },
	skeleton = { enabled = false },
	headDot = { enabled = false },
	look = { enabled = false, length = 6 },
	arrow = { enabled = false, radius = 160, size = 12 },
	chams = { enabled = false, throughWalls = true },
}
local CHOICES = {
	layout = { classic = true, card = true, badge = true, minimal = true },
	["box.style"] = { full = true, corners = true, ["3d"] = true },
	["health.style"] = { bar = true, number = true, both = true },
	["health.format"] = { value = true, percent = true, fraction = true },
	["name.style"] = { display = true, username = true, both = true },
	["distance.unit"] = { studs = true, meters = true },
	["tracer.origin"] = { bottom = true, center = true, top = true, mouse = true },
}
local OVERLAY_KEYS = { theme = true, variants = true, occluded = true, focused = true }
local TEAM_TINTED = {
	boxColor = true, tracerColor = true, skeletonColor = true, headDotColor = true,
	arrowColor = true, chamsFillColor = true, chamsOutlineColor = true,
}
local GROUP_PRESET = { name = { enabled = true } }
local PLAYER_PRESET = { box = { enabled = true }, health = { enabled = true }, name = { enabled = true } }
local HEADSHOT = "rbxthumb://type=AvatarHeadShot&id=%d&w=60&h=60"
local FRIEND_TAGS = { "Friend" }
local STUDS_TO_METERS = 0.28
local MAX_HIGHLIGHTS = 31
local PARTS_REFRESH = 0.5
local VISIBILITY_INTERVAL = 0.1
local SESSION_KEY = "VisualsSession"
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

local INVERTED_TRANSPARENCY = (function()
	local probe = Drawing.new("Line")
	local inverted = probe.Transparency == 1
	probe:Remove()
	return inverted
end)()

local function numberedKeys(prefix, count)
	local keys = {}
	for index = 1, count do
		keys[index] = prefix .. index
	end
	return keys
end
local BONE_KEYS = numberedKeys("bone", 64)
local EDGE_KEYS = numberedKeys("edge", 12)
local CORNER_KEYS = numberedKeys("corner", 8)
local DETAIL_KEYS = numberedKeys("detail", 16)
local BOX_EDGES = {}
for corner = 0, 7 do
	for _, bit in { 1, 2, 4 } do
		if bit32.band(corner, bit) == 0 then
			table.insert(BOX_EDGES, { corner + 1, bit32.bor(corner, bit) + 1 })
		end
	end
end

local Visuals = {}
local Esp = {}
Esp.__index = Esp
local Group = {}
Group.__index = Group

local function unknown(kind, path, key)
	error(string.format("visuals: unknown %s '%s%s'", kind, path, tostring(key)), 4)
end

local function checkChoice(path, key, value)
	local choices = CHOICES[path .. key]
	if choices and value ~= nil and not choices[value] then
		error(string.format("visuals: '%s%s' cannot be '%s'", path, key, tostring(value)), 4)
	end
end

local function strict(defaults, given, path, partial)
	given = given or {}
	if type(given) ~= "table" then
		error(string.format("visuals: '%s' must be a table", path), 3)
	end
	for key, value in given do
		if defaults[key] == nil then
			unknown("setting", path, key)
		end
		checkChoice(path, key, value)
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
	return setmetatable({}, {
		__index = function(_, key)
			local value = store[key]
			if value == nil and defaults[key] == nil then
				unknown("setting", path, key)
			end
			return value
		end,
		__newindex = function(_, key, value)
			if defaults[key] == nil then
				unknown("setting", path, key)
			elseif type(defaults[key]) == "table" then
				error(string.format("visuals: '%s%s' is a table, set its fields instead", path, key), 2)
			end
			checkChoice(path, key, value)
			store[key] = value
		end,
		__iter = function()
			return next, store
		end,
	})
end

local function buildSettings(given, partial)
	local plain = table.clone(given or {})
	local overlays = {}
	for key in OVERLAY_KEYS do
		overlays[key] = plain[key]
		plain[key] = nil
	end
	local settings = strict(SETTINGS_DEFAULTS, plain, "", partial)
	rawset(settings, "theme", strict(THEME_DEFAULTS, overlays.theme, "theme.", true))
	if partial then
		if overlays.variants or overlays.occluded or overlays.focused then
			error("visuals: variants, occluded and focused only go at the top of a group's settings", 3)
		end
		return settings
	end
	local variants = {}
	for name, variant in overlays.variants or {} do
		variants[name] = buildSettings(variant, true)
	end
	rawset(settings, "variants", variants)
	rawset(settings, "occluded", buildSettings(overlays.occluded, true))
	rawset(settings, "focused", buildSettings(overlays.focused, true))
	return settings
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
		local source = if humanoidOf(model) then model:GetChildren() else model:GetDescendants()
		for _, part in source do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 1 then
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
		local value = layer[key]
		if value ~= nil then
			return value
		end
	end
	return entry.group.settings[key]
end

local function option(entry, feature, key)
	for _, layer in entry.overlays do
		local value = layer[feature][key]
		if value ~= nil then
			return value
		end
	end
	return entry.group.settings[feature][key]
end

local function theme(entry, key)
	if TEAM_TINTED[key] and entry.view.teamColor and setting(entry, "useTeamColor") then
		return entry.view.teamColor
	end
	for _, layer in entry.overlays do
		local value = layer.theme[key]
		if value ~= nil then
			return value
		end
	end
	local value = entry.group.settings.theme[key]
	if value == nil then
		value = entry.esp.theme[key]
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
	return item
end

local function drawingAlpha(entry, transparency)
	local value = 1 - (1 - transparency) * entry.opacity
	return if INVERTED_TRANSPARENCY then 1 - value else value
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

local function healthColor(entry, fraction)
	return Color3.fromHSV(theme(entry, "healthyHue") * fraction, 1, 1)
end

local gradientCache = {}
local function healthGradient(hue, vertical)
	local key = hue .. (if vertical then "v" else "h")
	local sequence = gradientCache[key]
	if not sequence then
		local points = {}
		for step = 0, 6 do
			local t = step / 6
			local fraction = if vertical then 1 - t else t
			table.insert(points, ColorSequenceKeypoint.new(t, Color3.fromHSV(hue * fraction, 1, 1)))
		end
		sequence = ColorSequence.new(points)
		gradientCache[key] = sequence
	end
	return sequence
end

local function newDrawing(kind, zIndex, filled)
	local drawing = Drawing.new(kind)
	drawing.Visible = false
	drawing.ZIndex = zIndex
	if filled ~= nil then
		drawing.Filled = filled
	end
	return cached(drawing)
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

local function newImage(parent)
	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency = 1
	image.ScaleType = Enum.ScaleType.Crop
	image.Visible = false
	image.Parent = parent
	local item = cached(image)
	item.corner = addCorner(image)
	return item
end

local function newBar(parent)
	local item = newFrame(parent)
	local clip = Instance.new("Frame")
	clip.BackgroundTransparency = 1
	clip.BorderSizePixel = 0
	clip.ClipsDescendants = true
	clip.Parent = item.object
	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.Parent = clip
	local gradient = Instance.new("UIGradient")
	gradient.Parent = fill
	item.clip = cached(clip)
	item.fill = cached(fill)
	item.fillCorner = addCorner(fill)
	item.gradient = cached(gradient)
	return item
end

local function square(entry, key, zIndex, filled, color, transparency, position, size)
	local item = use(entry, key, newDrawing, "Square", zIndex, filled)
	set(item, "Color", color)
	set(item, "Transparency", drawingAlpha(entry, transparency))
	set(item, "Thickness", 1)
	set(item, "Position", position)
	set(item, "Size", size)
	set(item, "Visible", true)
end

local function line(entry, key, from, to, color)
	local thickness = theme(entry, "lineThickness")
	if theme(entry, "lineOutline") then
		local border = use(entry, key .. "Border", newDrawing, "Line", 1)
		set(border, "From", from)
		set(border, "To", to)
		set(border, "Color", theme(entry, "outlineColor"))
		set(border, "Thickness", thickness + 2)
		set(border, "Transparency", drawingAlpha(entry, 0))
		set(border, "Visible", true)
	end
	local main = use(entry, key, newDrawing, "Line", 2)
	set(main, "From", from)
	set(main, "To", to)
	set(main, "Color", color)
	set(main, "Thickness", thickness)
	set(main, "Transparency", drawingAlpha(entry, 0))
	set(main, "Visible", true)
end

local function circle(entry, key, center, radius, color)
	local thickness = theme(entry, "lineThickness")
	if theme(entry, "lineOutline") then
		local border = use(entry, key .. "Border", newDrawing, "Circle", 1, false)
		set(border, "Position", center)
		set(border, "Radius", radius)
		set(border, "NumSides", 24)
		set(border, "Color", theme(entry, "outlineColor"))
		set(border, "Thickness", thickness + 2)
		set(border, "Transparency", drawingAlpha(entry, 0))
		set(border, "Visible", true)
	end
	local main = use(entry, key, newDrawing, "Circle", 2, false)
	set(main, "Position", center)
	set(main, "Radius", radius)
	set(main, "NumSides", 24)
	set(main, "Color", color)
	set(main, "Thickness", thickness)
	set(main, "Transparency", drawingAlpha(entry, 0))
	set(main, "Visible", true)
end

local function triangle(entry, key, a, b, c, color)
	if theme(entry, "lineOutline") then
		local border = use(entry, key .. "Border", newDrawing, "Triangle", 1, false)
		set(border, "PointA", a)
		set(border, "PointB", b)
		set(border, "PointC", c)
		set(border, "Color", theme(entry, "outlineColor"))
		set(border, "Thickness", 3)
		set(border, "Transparency", drawingAlpha(entry, 0))
		set(border, "Visible", true)
	end
	local main = use(entry, key, newDrawing, "Triangle", 2, true)
	set(main, "PointA", a)
	set(main, "PointB", b)
	set(main, "PointC", c)
	set(main, "Color", color)
	set(main, "Transparency", drawingAlpha(entry, 0))
	set(main, "Visible", true)
end

local function styleLabel(entry, item, value, size, color, transparency, zIndex)
	set(item, "Text", value)
	set(item, "FontFace", theme(entry, "font"))
	set(item, "TextSize", size)
	set(item, "TextColor3", color)
	set(item, "TextTransparency", guiAlpha(entry, transparency))
	set(item, "ZIndex", zIndex)
	set(item, "Visible", true)
end

local function text(entry, key, parent, size, color, rich, plain)
	local shadow = use(entry, key .. "Shadow", newLabel, parent)
	local main = use(entry, key, newLabel, parent)
	styleLabel(entry, shadow, escape(plain or rich), size, theme(entry, "shadowColor"), theme(entry, "shadowTransparency"), 3)
	styleLabel(entry, main, rich, size, color, 0, 4)
	return main, shadow, main.object.TextBounds
end

local function place(entry, main, shadow, x, y)
	local offset = theme(entry, "shadowOffset")
	set(main, "Position", UDim2.fromOffset(x, y))
	set(shadow, "Position", UDim2.fromOffset(x + offset.X, y + offset.Y))
end

local function avatarImage(entry, key, parent, image, x, y, size, radius)
	local item = use(entry, key, newImage, parent)
	set(item, "Image", image)
	set(item, "ImageTransparency", guiAlpha(entry, 0))
	set(item, "Position", UDim2.fromOffset(x, y))
	set(item, "Size", UDim2.fromOffset(size, size))
	set(item, "ZIndex", 4)
	set(item, "Visible", true)
	set(item.corner, "CornerRadius", UDim.new(0, radius))
end

local function healthBar(entry, key, parent, x, y, width, height, inset, vertical, backColor, backTransparency, rounded)
	local view = entry.view
	local item = use(entry, key, newBar, parent)
	set(item, "Position", UDim2.fromOffset(x, y))
	set(item, "Size", UDim2.fromOffset(width, height))
	set(item, "BackgroundColor3", backColor)
	set(item, "BackgroundTransparency", guiAlpha(entry, backTransparency))
	set(item, "ZIndex", 3)
	set(item, "Visible", true)
	local radius = if rounded then UDim.new(1, 0) else UDim.new()
	set(item.corner, "CornerRadius", radius)
	set(item.fillCorner, "CornerRadius", radius)

	local innerWidth, innerHeight = width - inset * 2, height - inset * 2
	if vertical then
		local fill = math.floor(innerHeight * view.fraction + 0.5)
		set(item.clip, "Position", UDim2.fromOffset(inset, inset + innerHeight - fill))
		set(item.clip, "Size", UDim2.fromOffset(innerWidth, fill))
		set(item.fill, "Position", UDim2.fromOffset(0, fill - innerHeight))
	else
		local fill = math.floor(innerWidth * view.fraction + 0.5)
		set(item.clip, "Position", UDim2.fromOffset(inset, inset))
		set(item.clip, "Size", UDim2.fromOffset(fill, innerHeight))
		set(item.fill, "Position", UDim2.fromOffset(0, 0))
	end
	set(item.fill, "Size", UDim2.fromOffset(innerWidth, innerHeight))
	set(item.fill, "BackgroundTransparency", guiAlpha(entry, 0))
	set(item.fill, "ZIndex", 4)

	if option(entry, "health", "gradient") then
		set(item.gradient, "Enabled", true)
		set(item.gradient, "Color", healthGradient(theme(entry, "healthyHue"), vertical))
		set(item.gradient, "Rotation", if vertical then 90 else 0)
		set(item.fill, "BackgroundColor3", Color3.new(1, 1, 1))
	else
		set(item.gradient, "Enabled", false)
		set(item.fill, "BackgroundColor3", healthColor(entry, view.fraction))
	end
	return item
end

local function displayName(entry)
	local view = entry.view
	local style = option(entry, "name", "style")
	if view.username then
		if style == "username" then
			return view.username
		elseif style == "both" and view.username ~= view.name then
			return view.name .. " @" .. view.username
		end
	end
	return view.name
end

local function healthText(entry)
	local view = entry.view
	local format = option(entry, "health", "format")
	if format == "percent" then
		return string.format("%d%%", math.floor(view.rawFraction * 100 + 0.5))
	elseif format == "fraction" then
		return string.format("%d/%d", math.floor(view.health + 0.5), math.floor(view.maxHealth + 0.5))
	end
	return tostring(math.floor(view.health + 0.5))
end

local function distanceText(entry)
	if option(entry, "distance", "unit") == "meters" then
		return string.format("%dm", entry.view.distance * STUDS_TO_METERS)
	end
	return string.format("%d studs", entry.view.distance)
end

local function details(entry)
	local view = entry.view
	local list = entry.detailBuffer
	table.clear(list)
	if option(entry, "weapon", "enabled") and view.weapon then
		table.insert(list, colored(view.weapon, theme(entry, "mutedTextColor")))
		table.insert(list, view.weapon)
	end
	if option(entry, "team", "enabled") and view.teamName then
		table.insert(list, colored(view.teamName, view.teamColor or theme(entry, "mutedTextColor")))
		table.insert(list, view.teamName)
	end
	if option(entry, "tags", "enabled") and view.tags then
		local color = theme(entry, "tagColor")
		for _, tag in view.tags do
			table.insert(list, colored(tag, color))
			table.insert(list, tag)
		end
	end
	return list
end

local function healthShown(entry)
	return option(entry, "health", "enabled") and entry.view.fraction ~= nil
end

local function drawBox(entry)
	if not option(entry, "box", "enabled") then
		return
	end
	local view = entry.view
	local color = theme(entry, "boxColor")
	local style = option(entry, "box", "style")

	if style == "3d" then
		local corners = view.corners3d
		if corners then
			for index, edge in BOX_EDGES do
				line(entry, EDGE_KEYS[index], corners[edge[1]], corners[edge[2]], color)
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
		square(entry, "boxFill", 0, true, theme(entry, "boxFillColor"), theme(entry, "boxFillTransparency"), position, size)
	end

	if style == "corners" then
		local length = math.max(2, math.floor(math.min(width, height) * theme(entry, "cornerLength")))
		local left, top, right, bottom = view.minX, view.minY, view.maxX, view.maxY
		local points = {
			{ Vector2.new(left, top), Vector2.new(left + length, top) },
			{ Vector2.new(left, top), Vector2.new(left, top + length) },
			{ Vector2.new(right, top), Vector2.new(right - length, top) },
			{ Vector2.new(right, top), Vector2.new(right, top + length) },
			{ Vector2.new(left, bottom), Vector2.new(left + length, bottom) },
			{ Vector2.new(left, bottom), Vector2.new(left, bottom - length) },
			{ Vector2.new(right, bottom), Vector2.new(right - length, bottom) },
			{ Vector2.new(right, bottom), Vector2.new(right, bottom - length) },
		}
		for index, pair in points do
			line(entry, CORNER_KEYS[index], pair[1], pair[2], color)
		end
		return
	end

	local outline = theme(entry, "outlineColor")
	square(entry, "boxOuter", 1, false, outline, 0, position - Vector2.one, size + Vector2.one * 2)
	square(entry, "boxInner", 1, false, outline, 0, position + Vector2.one, size - Vector2.one * 2)
	square(entry, "box", 2, false, color, 0, position, size)
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
	line(entry, "tracer", from, Vector2.new((view.minX + view.maxX) / 2, view.maxY), theme(entry, "tracerColor"))
end

local function drawSkeleton(entry, camera)
	if not option(entry, "skeleton", "enabled") or not entry.bones then
		return
	end
	local color = theme(entry, "skeletonColor")
	local count = 0
	for _, bone in entry.bones do
		local motor, child = bone[1], bone[2]
		if not (motor.Part0 and motor.Part1) then
			continue
		end
		local from = (motor.Part0.CFrame * motor.C0).Position
		local to
		if child then
			if not child.Part0 then
				continue
			end
			to = (child.Part0.CFrame * child.C0).Position
		else
			to = from + (motor.Part1.Position - from) * 2
		end
		local a = camera:WorldToViewportPoint(from)
		local b = camera:WorldToViewportPoint(to)
		if a.Z > 0 and b.Z > 0 and count < #BONE_KEYS then
			count += 1
			line(entry, BONE_KEYS[count], Vector2.new(a.X, a.Y), Vector2.new(b.X, b.Y), color)
		end
	end
end

local function drawHead(entry, camera)
	local head = entry.view.head
	if not head then
		return
	end
	if option(entry, "headDot", "enabled") then
		local center = camera:WorldToViewportPoint(head.Position)
		local edge = camera:WorldToViewportPoint(head.Position + camera.CFrame.UpVector * head.Size.Y / 2)
		if center.Z > 0 then
			local radius = math.max(2, (Vector2.new(edge.X, edge.Y) - Vector2.new(center.X, center.Y)).Magnitude)
			circle(entry, "headDot", Vector2.new(center.X, center.Y), radius, theme(entry, "headDotColor"))
		end
	end
	if option(entry, "look", "enabled") then
		local from = camera:WorldToViewportPoint(head.Position)
		local to = camera:WorldToViewportPoint(head.Position + head.CFrame.LookVector * option(entry, "look", "length"))
		if from.Z > 0 and to.Z > 0 then
			line(entry, "look", Vector2.new(from.X, from.Y), Vector2.new(to.X, to.Y), theme(entry, "lookColor"))
		end
	end
end

local function rotate(vector, angle)
	local cos, sin = math.cos(angle), math.sin(angle)
	return Vector2.new(vector.X * cos - vector.Y * sin, vector.X * sin + vector.Y * cos)
end

local function drawArrow(entry, camera, viewport)
	local cframe = camera.CFrame
	local flat = CFrame.fromMatrix(cframe.Position, cframe.RightVector, Vector3.yAxis)
	local relative = flat:PointToObjectSpace(entry.view.position)
	local direction = Vector2.new(relative.X, relative.Z)
	if direction.Magnitude < 1e-3 then
		return
	end
	direction = direction.Unit
	local radius = math.min(option(entry, "arrow", "radius"), viewport.Y / 2 - 20)
	local size = option(entry, "arrow", "size")
	local tip = viewport / 2 + direction * radius
	triangle(entry, "arrow", tip, tip - rotate(direction, 0.5) * size, tip - rotate(direction, -0.5) * size, theme(entry, "arrowColor"))
end

local function nameRow(entry)
	local rich, plain = nil, nil
	if option(entry, "name", "enabled") then
		local name = displayName(entry)
		rich, plain = escape(name), name
	end
	return rich, plain
end

local function drawClassic(entry, camera)
	local view = entry.view
	local minX, minY, maxX, maxY = view.minX, view.minY, view.maxX, view.maxY
	local root = entry.esp.gui
	local gap = theme(entry, "textGap")
	local small = theme(entry, "smallTextSize")
	local left = minX - 1

	if healthShown(entry) then
		local style = option(entry, "health", "style")
		local fillTop = maxY - (maxY - minY) * view.fraction
		if style ~= "number" and maxY - minY >= 2 then
			local width = theme(entry, "barWidth")
			local x = minX - theme(entry, "barGap") - width - 1
			healthBar(entry, "healthBar", root, x, minY - 1, width + 2, maxY - minY + 2, 1, true, theme(entry, "outlineColor"), 0, false)
			left = x
		end
		if style ~= "bar" then
			local value = healthText(entry)
			local main, shadow, bounds = text(entry, "healthText", root, small, healthColor(entry, view.fraction), escape(value), value)
			local y = if style == "both" then math.clamp(fillTop - bounds.Y / 2, minY, math.max(minY, maxY - bounds.Y)) else minY
			place(entry, main, shadow, left - 2 - math.ceil(bounds.X), math.floor(y))
		end
	end

	local rich, plain = nameRow(entry)
	local avatar = option(entry, "avatar", "enabled") and view.avatar
	if rich or avatar then
		local nameWidth, nameHeight = 0, 0
		local main, shadow, bounds
		if rich then
			main, shadow, bounds = text(entry, "name", root, theme(entry, "textSize"), theme(entry, "textColor"), rich, plain)
			nameWidth, nameHeight = math.ceil(bounds.X), math.ceil(bounds.Y)
		end
		local avatarSize = if avatar then theme(entry, "avatarSize") else 0
		local avatarSpace = if avatar and rich then avatarSize + 3 else avatarSize
		local rowHeight = math.max(nameHeight, avatarSize)
		local x = math.floor((minX + maxX - nameWidth - avatarSpace) / 2)
		local top = minY - 1 - gap - rowHeight
		if avatar then
			avatarImage(entry, "avatar", root, avatar, x, top + math.floor((rowHeight - avatarSize) / 2), avatarSize, theme(entry, "avatarCornerRadius"))
		end
		if main then
			place(entry, main, shadow, x + avatarSpace, top + math.floor((rowHeight - nameHeight) / 2))
		end
	end

	local y = maxY + 1 + gap
	local function below(key, richValue, plainValue, color)
		local main, shadow, bounds = text(entry, key, root, small, color, richValue, plainValue)
		place(entry, main, shadow, math.floor((minX + maxX - bounds.X) / 2), y)
		y += math.ceil(bounds.Y) + theme(entry, "lineSpacing")
	end
	if option(entry, "distance", "enabled") then
		local value = distanceText(entry)
		below("distance", escape(value), value, theme(entry, "mutedTextColor"))
	end
	local list = details(entry)
	for index = 1, #list, 2 do
		below(DETAIL_KEYS[(index + 1) / 2], list[index], list[index + 1], theme(entry, "textColor"))
	end
end

local function drawPanel(entry, pill)
	local view = entry.view
	local showHealth = healthShown(entry)
	local style = option(entry, "health", "style")
	local showBar = showHealth and style ~= "number"
	local showNumber = showHealth and style ~= "bar"
	local showDistance = option(entry, "distance", "enabled")
	local avatar = option(entry, "avatar", "enabled") and view.avatar
	local rich, plain = nameRow(entry)
	local list = if pill then nil else details(entry)

	if showNumber then
		local value = healthText(entry)
		local separator = if rich then "  " else ""
		rich = (rich or "") .. separator .. colored(value, healthColor(entry, view.fraction))
		plain = (plain or "") .. separator .. value
	end
	if not (rich or showDistance or showBar or avatar or (list and #list > 0)) then
		return
	end

	local padding = theme(entry, "panelPadding")
	local spacing = theme(entry, "panelSpacing")
	local barHeight = theme(entry, "panelBarHeight")
	local panel = use(entry, "panel", newFrame, entry.esp.gui)
	local parent = panel.object

	local rowWidth, rowHeight = 0, 0
	local nameMain, nameShadow, nameBounds
	if rich then
		nameMain, nameShadow, nameBounds = text(entry, "panelName", parent, theme(entry, "textSize"), theme(entry, "textColor"), rich, plain)
		rowWidth, rowHeight = nameBounds.X, nameBounds.Y
	end
	local distanceMain, distanceShadow, distanceBounds
	if showDistance then
		local value = distanceText(entry)
		distanceMain, distanceShadow, distanceBounds = text(entry, "panelDistance", parent, theme(entry, "smallTextSize"), theme(entry, "mutedTextColor"), escape(value), value)
		rowWidth += (if rowWidth > 0 then spacing else 0) + distanceBounds.X
		rowHeight = math.max(rowHeight, distanceBounds.Y)
	end
	local detailMain, detailShadow, detailBounds
	if list and #list > 0 then
		local richParts, plainParts = {}, {}
		for index = 1, #list, 2 do
			table.insert(richParts, list[index])
			table.insert(plainParts, list[index + 1])
		end
		detailMain, detailShadow, detailBounds = text(entry, "panelDetails", parent, theme(entry, "smallTextSize"), theme(entry, "textColor"), table.concat(richParts, "  ·  "), table.concat(plainParts, "  ·  "))
	end

	rowHeight = math.ceil(rowHeight)
	local blockHeight = rowHeight
	if detailBounds then
		blockHeight += math.ceil(detailBounds.Y) + 1
	end
	if showBar then
		blockHeight += barHeight + (if blockHeight > 0 then 3 else 0)
	end
	local contentWidth = math.ceil(math.max(rowWidth, if detailBounds then detailBounds.X else 0))
	local avatarSize = if avatar then math.max(theme(entry, "avatarSize"), blockHeight) else 0
	local contentHeight = math.max(blockHeight, avatarSize)
	local textX = padding + (if avatar then avatarSize + (if contentWidth > 0 or showBar then spacing else 0) else 0)
	local width = math.max(if contentWidth > 0 or showBar then theme(entry, "panelMinWidth") else 0, textX + contentWidth + padding)
	contentWidth = width - textX - padding
	local height = padding * 2 + contentHeight
	local top = padding + math.floor((contentHeight - blockHeight) / 2)

	if avatar then
		local radius = if pill then math.floor(avatarSize / 2) else theme(entry, "avatarCornerRadius")
		avatarImage(entry, "panelAvatar", parent, avatar, padding, padding + math.floor((contentHeight - avatarSize) / 2), avatarSize, radius)
	end
	if nameMain then
		place(entry, nameMain, nameShadow, textX, top + math.floor((rowHeight - nameBounds.Y) / 2))
	end
	if distanceMain then
		place(entry, distanceMain, distanceShadow, width - padding - math.ceil(distanceBounds.X), top + rowHeight - math.ceil(distanceBounds.Y))
	end
	if detailMain then
		place(entry, detailMain, detailShadow, textX, top + rowHeight + 1)
	end
	if showBar then
		healthBar(entry, "panelBar", parent, textX, top + blockHeight - barHeight, contentWidth, barHeight, 0, false, theme(entry, "panelBarColor"), 0, true)
	end

	set(panel, "BackgroundColor3", theme(entry, "panelColor"))
	set(panel, "BackgroundTransparency", guiAlpha(entry, theme(entry, "panelTransparency")))
	set(panel, "Size", UDim2.fromOffset(width, height))
	set(panel, "Position", UDim2.fromOffset(math.floor((view.minX + view.maxX - width) / 2), view.minY - 1 - theme(entry, "textGap") - height))
	set(panel, "ZIndex", 2)
	set(panel, "Visible", true)
	set(panel.corner, "CornerRadius", UDim.new(0, if pill then math.floor(height / 2) else theme(entry, "panelCornerRadius")))
end

local function drawMinimal(entry)
	local view = entry.view
	local richParts, plainParts = {}, {}
	local rich, plain = nameRow(entry)
	if rich then
		table.insert(richParts, rich)
		table.insert(plainParts, plain)
	end
	if healthShown(entry) then
		local value = healthText(entry)
		table.insert(richParts, colored(value, healthColor(entry, view.fraction)))
		table.insert(plainParts, value)
	end
	if option(entry, "distance", "enabled") then
		local value = distanceText(entry)
		table.insert(richParts, colored(value, theme(entry, "mutedTextColor")))
		table.insert(plainParts, value)
	end
	local list = details(entry)
	for index = 1, #list, 2 do
		table.insert(richParts, list[index])
		table.insert(plainParts, list[index + 1])
	end
	if #richParts == 0 then
		return
	end
	local main, shadow, bounds = text(entry, "minimal", entry.esp.gui, theme(entry, "smallTextSize"), theme(entry, "textColor"), table.concat(richParts, "  "), table.concat(plainParts, "  "))
	place(entry, main, shadow, math.floor((view.minX + view.maxX - bounds.X) / 2), view.minY - 1 - theme(entry, "textGap") - math.ceil(bounds.Y))
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

local function skeletonOf(model)
	local motors, children = {}, {}
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("Motor6D") and descendant.Part0 and descendant.Part1 then
			table.insert(motors, descendant)
			children[descendant.Part0] = children[descendant.Part0] or {}
			table.insert(children[descendant.Part0], descendant)
		end
	end
	local bones = {}
	for _, motor in motors do
		local childMotors = children[motor.Part1]
		if childMotors then
			for _, child in childMotors do
				table.insert(bones, { motor, child })
			end
		elseif motor.Part0.Name ~= "HumanoidRootPart" then
			table.insert(bones, { motor, false })
		end
	end
	return bones
end

local function refreshParts(entry, model)
	local now = os.clock()
	if entry.partsModel ~= model or now - entry.partsAt > PARTS_REFRESH then
		entry.parts = entry.accessors.parts(entry.target, model)
		entry.bones = if option(entry, "skeleton", "enabled") and humanoidOf(model) then skeletonOf(model) else nil
		entry.partsModel, entry.partsAt = model, now
	end
	return entry.parts
end

local function project(camera, point)
	local screen = camera:WorldToViewportPoint(point)
	return screen.X, screen.Y, screen.Z > 0
end

local function measure(entry, model, camera, pivot)
	local view = entry.view
	local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
	local wants3d = option(entry, "box", "enabled") and option(entry, "box", "style") == "3d"
	local low, high
	local inFront = true
	for _, part in refreshParts(entry, model) do
		if not part.Parent then
			continue
		end
		local cframe, half = part.CFrame, part.Size / 2
		for _, sign in CORNERS do
			local world = cframe * (half * sign)
			local x, y, front = project(camera, world)
			if not front then
				inFront = false
			end
			minX, minY = math.min(minX, x), math.min(minY, y)
			maxX, maxY = math.max(maxX, x), math.max(maxY, y)
			if wants3d then
				local localPoint = pivot:PointToObjectSpace(world)
				low = if low then low:Min(localPoint) else localPoint
				high = if high then high:Max(localPoint) else localPoint
			end
		end
	end

	view.corners3d = nil
	if minX == math.huge then
		local x, y, front = project(camera, pivot.Position)
		inFront = front
		minX, minY, maxX, maxY = x, y, x, y
	elseif wants3d and low and inFront then
		local corners = view.cornerBuffer
		for index = 0, 7 do
			local point = Vector3.new(
				if bit32.band(index, 1) == 0 then low.X else high.X,
				if bit32.band(index, 2) == 0 then low.Y else high.Y,
				if bit32.band(index, 4) == 0 then low.Z else high.Z
			)
			local x, y = project(camera, pivot * point)
			corners[index + 1] = Vector2.new(x, y)
		end
		view.corners3d = corners
	end

	view.minX, view.minY = math.floor(minX), math.floor(minY)
	view.maxX, view.maxY = math.ceil(maxX), math.ceil(maxY)
	local viewport = camera.ViewportSize
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

local function describe(entry, camera, origin, deltaTime)
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
	view.model, view.pivot, view.position = model, pivot, pivot.Position
	view.distance = (pivot.Position - origin).Magnitude
	if view.distance > setting(entry, "maxDistance") then
		return false
	end

	local health, maxHealth = accessors.health(target, model)
	if health and health <= 0 then
		return false
	end

	local head = if model:IsA("Model") then model:FindFirstChild("Head") else nil
	view.head = if head and head:IsA("BasePart") then head else nil
	if setting(entry, "visibilityCheck") and occluded(entry, origin, model, if view.head then view.head.Position else view.position) then
		table.insert(overlays, 1, entry.group.settings.occluded)
	end

	view.name = accessors.name(target, model)
	view.username = if target:IsA("Player") then target.Name else nil
	view.avatar = accessors.avatar(target, model)
	view.weapon = accessors.weapon(target, model)
	view.teamName, view.teamColor = accessors.team(target, model)
	view.tags = accessors.tags(target, model)
	view.health, view.maxHealth = health, maxHealth or 100
	view.fraction, view.rawFraction = nil, nil
	if health then
		local fraction = math.clamp(health / math.max(view.maxHealth, 1), 0, 1)
		local shown = entry.shownHealth
		local blend = 1 - math.exp(-theme(entry, "healthSmoothing") * deltaTime)
		entry.shownHealth = if shown then shown + (fraction - shown) * blend else fraction
		view.fraction, view.rawFraction = entry.shownHealth, fraction
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
		if typeof(item.object) == "Instance" then
			item.object:Destroy()
		else
			item.object:Remove()
		end
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

local function drawEntry(entry, camera, viewport, mouse)
	local view = entry.view
	if view.onScreen then
		drawBox(entry)
		drawTracer(entry, viewport, mouse)
		drawSkeleton(entry, camera)
		drawHead(entry, camera)
		LAYOUTS[setting(entry, "layout")](entry, camera)
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

local function updateChams(esp, candidates)
	table.sort(candidates, byDistance)
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
		accessors = withAccessors(self.accessors, accessors),
		elements = {},
		overlays = {},
		detailBuffer = {},
		view = { cornerBuffer = {} },
		tick = 0,
		opacity = 1,
		partsAt = -math.huge,
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
	return newGroup(self, overlay(GROUP_PRESET, settings), withAccessors(DEFAULT_ACCESSORS, accessors))
end

function Esp:players(settings, accessors)
	local base = withAccessors(DEFAULT_ACCESSORS, { variant = playerVariant })
	local group = newGroup(self, overlay(PLAYER_PRESET, settings), withAccessors(base, accessors))
	local function add(player)
		if player ~= LocalPlayer then
			group:add(player)
		end
	end
	table.insert(group.connections, Players.PlayerAdded:Connect(add))
	table.insert(group.connections, Players.PlayerRemoving:Connect(function(player)
		local entry = group.entries[player]
		if entry then
			removeEntry(group, player, entry)
		end
	end))
	for _, player in Players:GetPlayers() do
		add(player)
	end
	return group
end

function Esp:render(deltaTime)
	local camera = Workspace.CurrentCamera
	local chams = self.chamsBuffer
	table.clear(chams)
	if camera and self.enabled then
		local origin = camera.CFrame.Position
		local viewport = camera.ViewportSize
		local mouse = UserInputService:GetMouseLocation()
		for _, group in self.groups do
			local shown = group.shown
			table.clear(shown)
			for target, entry in group.entries do
				if not target:IsA("Player") and not target.Parent then
					removeEntry(group, target, entry)
					continue
				end
				entry.tick += 1
				if describe(entry, camera, origin, deltaTime) then
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
			for _, entry in shown do
				drawEntry(entry, camera, viewport, mouse)
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

function Visuals.start(themeOverrides)
	local running = getgenv()[SESSION_KEY]
	if running then
		running:unload()
	end

	local container = if gethui then gethui() else CoreGui
	local gui = Instance.new("ScreenGui")
	gui.Name = tostring(math.random(1e6, 1e7))
	gui.IgnoreGuiInset = true
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
		stepName = tostring(math.random(1e6, 1e7)),
	}, Esp)
	RunService:BindToRenderStep(esp.stepName, Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
		esp:render(deltaTime)
	end)
	getgenv()[SESSION_KEY] = esp
	return esp
end

return Visuals
