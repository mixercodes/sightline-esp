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
	health = { enabled = false, style = "bar", format = "value", gradient = true, side = "left" },
	name = { enabled = true, style = "display" },
	avatar = { enabled = false },
	distance = { enabled = false, unit = "studs" },
	weapon = { enabled = false },
	team = { enabled = false },
	tags = { enabled = false },
	tracer = { enabled = false, origin = "bottom", target = "bottom" },
	skeleton = { enabled = false },
	headDot = { enabled = false },
	look = { enabled = false, length = 6 },
	arrow = { enabled = false, radius = 160, size = 12 },
	chams = { enabled = false, throughWalls = true },
	shrink = { enabled = true, badgeBeyond = 60, minimalBeyond = 120, numberBeyond = 160 },
	declutter = { enabled = true, maxLift = 150, spacing = 2, leaders = false },
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
local ORDER_MARGIN = 2
local Z_STEP = 8
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
local CORNER_OUTLINE_KEYS = numberedKeys("cornerOutline", 8)
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

local function square(entry, key, zIndex, filled, color, transparency, position, size)
	local item = use(entry, key, newDrawing, "Square", zIndex, filled)
	set(item, "ZIndex", entry.zBase + zIndex)
	set(item, "Color", color)
	set(item, "Transparency", drawingAlpha(entry, transparency))
	set(item, "Thickness", 1)
	set(item, "Position", position)
	set(item, "Size", size)
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
		style.alpha = drawingAlpha(entry, theme(entry, keys.transparency))
		style.outlineColor = theme(entry, "outlineColor")
		style.outlineWidth = theme(entry, "lineOutlineWidth")
	end
	return style
end

local function line(entry, key, from, to, feature)
	local style = styleOf(entry, feature)
	local thickness, alpha = style.thickness, style.alpha
	local delta = to - from
	local direction = if delta.Magnitude > 1e-3 then delta.Unit else Vector2.zero
	if style.outlined then
		local reach = direction * (thickness / 2 + style.outlineWidth)
		local border = use(entry, key .. "Border", newDrawing, "Line", 1)
		set(border, "ZIndex", entry.zBase + 1)
		set(border, "From", from - reach)
		set(border, "To", to + reach)
		set(border, "Color", style.outlineColor)
		set(border, "Thickness", thickness + style.outlineWidth * 2)
		set(border, "Transparency", alpha)
		set(border, "Visible", true)
	end
	local reach = direction * (thickness / 2)
	local main = use(entry, key, newDrawing, "Line", 2)
	set(main, "ZIndex", entry.zBase + 2)
	set(main, "From", from - reach)
	set(main, "To", to + reach)
	set(main, "Color", style.color)
	set(main, "Thickness", thickness)
	set(main, "Transparency", alpha)
	set(main, "Visible", true)
end

local function ring(entry, key, center, radius, color, thickness, alpha, zIndex)
	local item = use(entry, key, newDrawing, "Circle", zIndex, false)
	set(item, "ZIndex", entry.zBase + zIndex)
	set(item, "Position", center)
	set(item, "Radius", radius)
	set(item, "NumSides", 32)
	set(item, "Color", color)
	set(item, "Thickness", thickness)
	set(item, "Transparency", alpha)
	set(item, "Visible", true)
end

local function circle(entry, key, center, radius, feature)
	local style = styleOf(entry, feature)
	local thickness, alpha = style.thickness, style.alpha
	if style.outlined then
		local width = style.outlineWidth
		local offset = (thickness + width) / 2
		ring(entry, key .. "Outer", center, radius + offset, style.outlineColor, width, alpha, 1)
		ring(entry, key .. "Inner", center, math.max(radius - offset, 0.5), style.outlineColor, width, alpha, 1)
	end
	ring(entry, key, center, radius, style.color, thickness, alpha, 2)
	set(entry.elements[key], "Filled", theme(entry, feature .. "Filled") == true)
end

local function grow(a, b, c, amount)
	local sideA, sideB, sideC = (b - c).Magnitude, (c - a).Magnitude, (a - b).Magnitude
	local perimeter = sideA + sideB + sideC
	local area = math.abs((b - a).X * (c - a).Y - (b - a).Y * (c - a).X) / 2
	if perimeter < 1e-3 or area < 1e-3 then
		return a, b, c
	end
	local center = (a * sideA + b * sideB + c * sideC) / perimeter
	local inradius = area / (perimeter / 2)
	local scale = (inradius + amount) / inradius
	return center + (a - center) * scale, center + (b - center) * scale, center + (c - center) * scale
end

local function triangle(entry, key, a, b, c, feature)
	local style = styleOf(entry, feature)
	local alpha = style.alpha
	if style.outlined then
		local outerA, outerB, outerC = grow(a, b, c, style.outlineWidth)
		local border = use(entry, key .. "Border", newDrawing, "Triangle", 1, true)
		set(border, "ZIndex", entry.zBase + 1)
		set(border, "PointA", outerA)
		set(border, "PointB", outerB)
		set(border, "PointC", outerC)
		set(border, "Color", style.outlineColor)
		set(border, "Transparency", alpha)
		set(border, "Visible", true)
	end
	local main = use(entry, key, newDrawing, "Triangle", 2, true)
	set(main, "ZIndex", entry.zBase + 2)
	set(main, "PointA", a)
	set(main, "PointB", b)
	set(main, "PointC", c)
	set(main, "Color", style.color)
	set(main, "Transparency", alpha)
	set(main, "Visible", true)
end

local function styleLabel(entry, item, value, size, color, transparency, zIndex)
	set(item, "Text", value)
	set(item, "FontFace", theme(entry, "font"))
	set(item, "TextSize", size)
	set(item, "TextColor3", color)
	set(item, "TextTransparency", guiAlpha(entry, transparency))
	set(item, "ZIndex", entry.zBase + zIndex)
	set(item, "Visible", true)
end

local function text(entry, key, parent, size, color, plain, rich)
	local escaped = escape(plain)
	local shadow
	if theme(entry, "textShadow") then
		shadow = use(entry, key .. "Shadow", newLabel, parent)
		styleLabel(entry, shadow, escaped, size, theme(entry, "shadowColor"), theme(entry, "shadowTransparency"), 3)
	end
	local main = use(entry, key, newLabel, parent)
	styleLabel(entry, main, rich or escaped, size, color, 0, 4)
	return main, shadow, main.object.TextBounds
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

local function place(entry, main, shadow, x, y)
	local offset = theme(entry, "shadowOffset")
	set(main, "Position", UDim2.fromOffset(x, y))
	if shadow then
		set(shadow, "Position", UDim2.fromOffset(x + offset.X, y + offset.Y))
	end
end

local function avatarImage(entry, key, parent, image, x, y, size, radius)
	local item = use(entry, key, newImage, parent)
	set(item, "Image", image)
	set(item, "ImageTransparency", guiAlpha(entry, 0))
	set(item, "BackgroundColor3", theme(entry, "avatarBackgroundColor"))
	set(item, "BackgroundTransparency", guiAlpha(entry, theme(entry, "avatarBackgroundTransparency")))
	set(item, "Position", UDim2.fromOffset(x, y))
	set(item, "Size", UDim2.fromOffset(size, size))
	set(item, "ZIndex", entry.zBase + 4)
	set(item, "Visible", true)
	set(item.corner, "CornerRadius", UDim.new(0, radius))
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
			addPart(parts, tostring(tag), color)
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
	return option(entry, "health", "enabled") and entry.view.fraction ~= nil
end

local projection = { inverse = CFrame.identity, centerX = 0, centerY = 0, scale = 1 }

local function updateProjection(camera)
	local viewport = camera.ViewportSize
	projection.inverse = camera.CFrame:Inverse()
	projection.centerX, projection.centerY = viewport.X / 2, viewport.Y / 2
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
		square(entry, "boxFill", 0, true, theme(entry, "boxFillColor"), theme(entry, "boxFillTransparency"), position, size)
	end

	local thickness = math.max(1, math.floor(theme(entry, "boxThickness")))
	local length = if style == "corners"
		then math.max(thickness + 1, math.floor(math.min(width, height) * theme(entry, "cornerLength")))
		else math.huge
	local lengthX, lengthY = math.min(length, width + 1), math.min(length, height + 1)
	local left, top = view.minX, view.minY
	local right, bottom = view.maxX - thickness + 1, view.maxY - thickness + 1
	local farX, farY = view.maxX - lengthX + 1, view.maxY - lengthY + 1
	local arms = entry.armBuffer
	arms[1], arms[2], arms[3], arms[4] = left, top, lengthX, thickness
	arms[5], arms[6], arms[7], arms[8] = left, top, thickness, lengthY
	arms[9], arms[10], arms[11], arms[12] = farX, top, lengthX, thickness
	arms[13], arms[14], arms[15], arms[16] = right, top, thickness, lengthY
	arms[17], arms[18], arms[19], arms[20] = left, bottom, lengthX, thickness
	arms[21], arms[22], arms[23], arms[24] = left, farY, thickness, lengthY
	arms[25], arms[26], arms[27], arms[28] = farX, bottom, lengthX, thickness
	arms[29], arms[30], arms[31], arms[32] = right, farY, thickness, lengthY
	local color = theme(entry, "boxColor")
	local transparency = theme(entry, "boxTransparency")
	local outline = theme(entry, "outlineColor")
	local outlined = theme(entry, "boxOutline")
	for index = 1, 8 do
		local base = (index - 1) * 4
		local armPosition = Vector2.new(arms[base + 1], arms[base + 2])
		local armSize = Vector2.new(arms[base + 3], arms[base + 4])
		if outlined then
			square(entry, CORNER_OUTLINE_KEYS[index], 1, true, outline, transparency, armPosition - Vector2.one, armSize + Vector2.one * 2)
		end
		square(entry, CORNER_KEYS[index], 2, true, color, transparency, armPosition, armSize)
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

local function limbEnds(part, inset)
	local cframe, half = part.CFrame, part.Size.Y / 2
	return cframe * Vector3.new(0, half - inset, 0), cframe * Vector3.new(0, inset - half, 0)
end

local function r6Segments(rig, segments)
	table.clear(segments)
	local torso = rig.Torso
	local torsoHalf = torso.Size.Y / 2
	local neck = torso.CFrame * Vector3.new(0, torsoHalf, 0)
	local pelvis = torso.CFrame * Vector3.new(0, -torsoHalf, 0)
	local leftShoulder, leftHand = limbEnds(rig["Left Arm"], rig["Left Arm"].Size.X / 2)
	local rightShoulder, rightHand = limbEnds(rig["Right Arm"], rig["Right Arm"].Size.X / 2)
	local leftHip, leftFoot = limbEnds(rig["Left Leg"], 0)
	local rightHip, rightFoot = limbEnds(rig["Right Leg"], 0)
	table.move({
		rig.Head.Position, neck,
		neck, pelvis,
		leftShoulder, rightShoulder,
		leftShoulder, leftHand,
		rightShoulder, rightHand,
		pelvis, leftHip,
		pelvis, rightHip,
		leftHip, leftFoot,
		rightHip, rightFoot,
	}, 1, 18, 1, segments)
	return segments
end

local function jointPosition(motor)
	return if motor.Part0 then (motor.Part0.CFrame * motor.C0).Position else nil
end

local function extend(from, to, part)
	if not (from and to) then
		return nil
	end
	local delta = to - from
	if delta.Magnitude < 1e-3 then
		return nil
	end
	local along = (part.Position - to):Dot(delta.Unit)
	return if along > 0 then to + delta.Unit * along else nil
end

local function addSegment(segments, from, to)
	if from and to then
		table.insert(segments, from)
		table.insert(segments, to)
	end
end

local function r15Segments(rig, segments)
	table.clear(segments)
	local joints = rig.joints
	local neck, waist = jointPosition(joints.Neck), jointPosition(joints.Waist)
	local leftShoulder, rightShoulder = jointPosition(joints.LeftShoulder), jointPosition(joints.RightShoulder)
	local leftElbow, rightElbow = jointPosition(joints.LeftElbow), jointPosition(joints.RightElbow)
	local leftWrist, rightWrist = jointPosition(joints.LeftWrist), jointPosition(joints.RightWrist)
	local leftHip, rightHip = jointPosition(joints.LeftHip), jointPosition(joints.RightHip)
	local leftKnee, rightKnee = jointPosition(joints.LeftKnee), jointPosition(joints.RightKnee)
	local leftAnkle, rightAnkle = jointPosition(joints.LeftAnkle), jointPosition(joints.RightAnkle)
	local pelvis = if leftHip and rightHip then (leftHip + rightHip) / 2 else nil
	addSegment(segments, rig.Head.Position, neck)
	addSegment(segments, neck, waist)
	addSegment(segments, waist, pelvis)
	addSegment(segments, leftShoulder, rightShoulder)
	addSegment(segments, leftShoulder, leftElbow)
	addSegment(segments, leftElbow, leftWrist)
	addSegment(segments, leftWrist, extend(leftElbow, leftWrist, rig.LeftHand))
	addSegment(segments, rightShoulder, rightElbow)
	addSegment(segments, rightElbow, rightWrist)
	addSegment(segments, rightWrist, extend(rightElbow, rightWrist, rig.RightHand))
	addSegment(segments, leftHip, rightHip)
	addSegment(segments, leftHip, leftKnee)
	addSegment(segments, leftKnee, leftAnkle)
	addSegment(segments, leftAnkle, extend(leftKnee, leftAnkle, rig.LeftFoot))
	addSegment(segments, rightHip, rightKnee)
	addSegment(segments, rightKnee, rightAnkle)
	addSegment(segments, rightAnkle, extend(rightKnee, rightAnkle, rig.RightFoot))
	return segments
end

local function drawSkeleton(entry, camera)
	if not option(entry, "skeleton", "enabled") then
		return
	end
	local count = 0
	if entry.r6 or entry.r15 then
		local segments = if entry.r6 then r6Segments(entry.r6, entry.segmentBuffer) else r15Segments(entry.r15, entry.segmentBuffer)
		local projected, front = entry.projectBuffer, entry.frontBuffer
		table.clear(projected)
		table.clear(front)
		for _, point in segments do
			if projected[point] == nil then
				projected[point], front[point] = screen(point)
			end
		end
		for index = 1, #segments, 2 do
			local from, to = segments[index], segments[index + 1]
			local a, aFront = projected[from], front[from]
			local b, bFront = projected[to], front[to]
			if aFront and bFront then
				count += 1
				line(entry, BONE_KEYS[count], a, b, "skeleton")
			end
		end
		return
	end
	if not entry.bones then
		return
	end
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
	triangle(entry, "arrow", snap(tip), snap(tip - rotate(direction, 0.5) * size), snap(tip - rotate(direction, -0.5) * size), "arrow")
end

local function drawSideBar(entry)
	local view = entry.view
	local minX, minY, maxY = view.minX, view.minY, view.maxY
	local height = maxY - minY
	if height < 2 then
		return minX - 1
	end
	local width = theme(entry, "barWidth")
	local border = if theme(entry, "barOutline") then 1 else 0
	local onRight = option(entry, "health", "side") == "right"
	local x = if onRight then view.maxX + theme(entry, "barGap") - border else minX - theme(entry, "barGap") - width - border
	local item = use(entry, "healthBar", newBar, entry.esp.gui)
	set(item, "Position", UDim2.fromOffset(x, minY - border))
	set(item, "Size", UDim2.fromOffset(width + border * 2, height + border * 2))
	set(item, "BackgroundColor3", theme(entry, "outlineColor"))
	set(item, "BackgroundTransparency", guiAlpha(entry, if border > 0 then 0 else 1))
	set(item, "ZIndex", entry.zBase + 3)
	set(item, "Visible", true)
	set(item.back, "Position", UDim2.fromOffset(border, border))
	set(item.back, "Size", UDim2.fromOffset(width, height))
	set(item.back, "BackgroundColor3", theme(entry, "barBackgroundColor"))
	set(item.back, "BackgroundTransparency", guiAlpha(entry, theme(entry, "barBackgroundTransparency")))

	local fill = math.round(height * view.fraction)
	set(item.clip, "Position", UDim2.fromOffset(0, height - fill))
	set(item.clip, "Size", UDim2.fromOffset(width, fill))
	set(item.fill, "Position", UDim2.fromOffset(0, fill - height))
	set(item.fill, "Size", UDim2.fromOffset(width, height))
	set(item.fill, "BackgroundTransparency", guiAlpha(entry, 0))
	if option(entry, "health", "gradient") then
		set(item.gradient, "Enabled", true)
		set(item.gradient, "Color", theme(entry, "healthColors"))
		set(item.fill, "BackgroundColor3", Color3.new(1, 1, 1))
	else
		set(item.gradient, "Enabled", false)
		set(item.fill, "BackgroundColor3", healthColor(entry, view.fraction))
	end
	return if onRight then x + width + border * 2 else x
end

local function leaderBar(entry, key, x, top, bottom, width, color, transparency, zIndex)
	local item = use(entry, key, newFrame, entry.esp.gui)
	set(item, "Position", UDim2.fromOffset(x - math.floor(width / 2), top))
	set(item, "Size", UDim2.fromOffset(width, math.max(bottom - top, 0)))
	set(item, "BackgroundColor3", color)
	set(item, "BackgroundTransparency", guiAlpha(entry, transparency))
	set(item, "ZIndex", entry.zBase + zIndex)
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
	local minX, minY, maxX, maxY = view.minX, view.minY, view.maxX, view.maxY
	local root = entry.esp.gui
	local gap = theme(entry, "textGap")
	local small = theme(entry, "smallTextSize")
	local onRight = option(entry, "health", "side") == "right"
	local edge = if onRight then maxX + 1 else minX - 1

	if healthShown(entry) then
		local style = option(entry, "health", "style")
		if style ~= "number" then
			edge = drawSideBar(entry)
		end
		local tooSmall = option(entry, "shrink", "enabled") and view.distance > option(entry, "shrink", "numberBeyond")
		if style ~= "bar" and not tooSmall then
			local main, shadow, bounds = text(entry, "healthText", root, small, healthColor(entry, view.fraction), healthText(entry))
			local fillTop = maxY - (maxY - minY) * view.fraction
			local y = if style == "both" then math.clamp(fillTop - bounds.Y / 2, minY, math.max(minY, maxY - bounds.Y)) else minY
			local x = if onRight then edge + theme(entry, "textGap") else edge - theme(entry, "textGap") - math.ceil(bounds.X)
			place(entry, main, shadow, x, math.floor(y))
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
		local x = math.floor((minX + maxX - nameWidth - avatarSpace) / 2)
		local top = claim(entry, x, minY - 1 - gap - rowHeight, nameWidth + avatarSpace, rowHeight)
		if avatar then
			avatarImage(entry, "avatar", root, avatar, x, top + math.floor((rowHeight - avatarSize) / 2), avatarSize, theme(entry, "avatarCornerRadius"))
		end
		if main then
			place(entry, main, shadow, x + avatarSpace, top + math.floor((rowHeight - nameHeight) / 2))
		end
	end

	local parts = freshParts(entry)
	if option(entry, "distance", "enabled") then
		addPart(parts, distanceText(entry), theme(entry, "distanceColor"))
	end
	addDetails(entry, parts)
	local y = maxY + 1 + gap
	local spacing = theme(entry, "lineSpacing")
	for index = 1, #parts, 2 do
		local main, shadow, bounds = text(entry, DETAIL_KEYS[(index + 1) / 2], root, small, parts[index + 1], parts[index])
		place(entry, main, shadow, math.floor((minX + maxX - bounds.X) / 2), y)
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
	local panel = use(entry, "panel", newPanel, entry.esp.gui)
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

	if avatar then
		local radius = if pill then math.floor(avatarSize / 2) else theme(entry, "avatarCornerRadius")
		avatarImage(entry, "panelAvatar", parent, avatar, padding, padding + math.floor((contentHeight - avatarSize) / 2), avatarSize, radius)
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
	local panelX = math.floor((view.minX + view.maxX - width) / 2)
	local panelY = claim(entry, panelX, view.minY - 1 - theme(entry, "textGap") - height, width, height)
	set(panel, "Position", UDim2.fromOffset(panelX, panelY))
	set(panel, "ZIndex", entry.zBase + 2)
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

	local root = entry.esp.gui
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

	local x = math.floor((view.minX + view.maxX - width) / 2)
	local bottom = claim(entry, x, view.minY - 1 - theme(entry, "textGap") - height, width, height) + height
	if nameMain then
		place(entry, nameMain, nameShadow, x, bottom - math.ceil(nameBounds.Y))
		x += math.ceil(nameBounds.X) + theme(entry, "panelSpacing")
	end
	if statsMain then
		place(entry, statsMain, statsShadow, x, bottom - math.ceil(statsBounds.Y) - (if nameMain then 1 else 0))
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

local R6_PARTS = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }

local function r6Rig(model)
	local rig = {}
	for _, name in R6_PARTS do
		local part = model:FindFirstChild(name)
		if not (part and part:IsA("BasePart")) then
			return nil
		end
		rig[name] = part
	end
	return rig
end

local R15_JOINTS = {
	"Neck", "Waist", "LeftShoulder", "LeftElbow", "LeftWrist", "RightShoulder", "RightElbow", "RightWrist",
	"LeftHip", "LeftKnee", "LeftAnkle", "RightHip", "RightKnee", "RightAnkle",
}
local R15_ENDS = { "Head", "LeftHand", "RightHand", "LeftFoot", "RightFoot" }

local function r15Rig(model)
	local joints = {}
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("Motor6D") then
			joints[descendant.Name] = descendant
		end
	end
	local rig = { joints = joints }
	for _, name in R15_JOINTS do
		if not joints[name] then
			return nil
		end
	end
	for _, name in R15_ENDS do
		local part = model:FindFirstChild(name)
		if not (part and part:IsA("BasePart")) then
			return nil
		end
		rig[name] = part
	end
	return rig
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
		local humanoid = humanoidOf(model)
		local wantsSkeleton = humanoid and option(entry, "skeleton", "enabled")
		local isR6 = wantsSkeleton and humanoid.RigType == Enum.HumanoidRigType.R6
		entry.r6 = if isR6 then r6Rig(model) else nil
		entry.r15 = if wantsSkeleton and not isR6 then r15Rig(model) else nil
		entry.bones = if wantsSkeleton and not entry.r6 and not entry.r15 then skeletonOf(model) else nil
		entry.partsModel, entry.partsAt = model, now
	end
	return entry.parts
end

local function measure(entry, model, camera, pivot)
	local view = entry.view
	local low2, high2
	local wants3d = option(entry, "box", "enabled") and option(entry, "box", "style") == "3d"
	local low3, high3
	local inFront = true
	for _, part in refreshParts(entry, model) do
		if not part.Parent then
			continue
		end
		local cframe, half = part.CFrame, part.Size / 2
		for _, sign in CORNERS do
			local world = cframe * (half * sign)
			local point, front = screen(world)
			inFront = inFront and front
			low2 = if low2 then low2:Min(point) else point
			high2 = if high2 then high2:Max(point) else point
			if wants3d then
				local localPoint = pivot:PointToObjectSpace(world)
				low3 = if low3 then low3:Min(localPoint) else localPoint
				high3 = if high3 then high3:Max(localPoint) else localPoint
			end
		end
	end

	view.corners3d = nil
	if not low2 then
		low2, inFront = screen(pivot.Position)
		high2 = low2
	elseif low3 and inFront then
		local center, extent = (low3 + high3) / 2, (high3 - low3) / 2
		local corners = view.cornerBuffer
		for index, sign in CORNERS do
			corners[index] = screen(pivot * (center + extent * sign))
		end
		view.corners3d = corners
	end

	view.minX, view.minY = math.floor(low2.X), math.floor(low2.Y)
	view.maxX, view.maxY = math.ceil(high2.X), math.ceil(high2.Y)
	local viewport = camera.ViewportSize
	view.onScreen = inFront and high2.X >= 0 and low2.X <= viewport.X and high2.Y >= 0 and low2.Y <= viewport.Y
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

	local head = if model:IsA("Model") then model:FindFirstChild("Head") else nil
	view.head = if head and head:IsA("BasePart") then head else nil
	if setting(entry, "visibilityCheck") and occluded(entry, origin, model, if view.head then view.head.Position else view.position) then
		table.insert(overlays, 1, entry.group.settings.occluded)
	end

	view.name = tostring(accessors.name(target, model) or "")
	view.username = if entry.isPlayer then target.Name else nil
	view.avatar = accessors.avatar(target, model)
	local weapon = accessors.weapon(target, model)
	view.weapon = if weapon then tostring(weapon) else nil
	local teamName, teamColor = accessors.team(target, model)
	view.teamName = if teamName then tostring(teamName) else nil
	view.teamColor = if typeof(teamColor) == "Color3" then teamColor else nil
	view.tags = accessors.tags(target, model)
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

local function drawEntry(entry, camera, viewport, mouse)
	local view = entry.view
	if view.onScreen then
		drawBox(entry)
		drawTracer(entry, viewport, mouse)
		drawSkeleton(entry, camera)
		drawHead(entry, camera)
		LAYOUTS[effectiveLayout(entry)](entry)
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
		partsBuffer = {},
		segmentBuffer = {},
		armBuffer = {},
		projectBuffer = {},
		frontBuffer = {},
		styles = {},
		view = { cornerBuffer = {} },
		tick = 0,
		zBase = 0,
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
		local origin = camera.CFrame.Position
		updateProjection(camera)
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
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
