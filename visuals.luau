local THEME_DEFAULTS = {
	font = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
	textSize = 13,
	smallTextSize = 11,
	textColor = Color3.new(1, 1, 1),
	mutedTextColor = Color3.fromRGB(170, 170, 180),
	shadowColor = Color3.new(0, 0, 0),
	shadowTransparency = 0.3,
	shadowOffset = Vector2.new(1, 1),
	boxColor = Color3.new(1, 1, 1),
	outlineColor = Color3.new(0, 0, 0),
	healthyHue = 1 / 3,
	healthSmoothing = 10,
	barWidth = 1,
	barGap = 4,
	textGap = 3,
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
	box = { enabled = false },
	healthBar = { enabled = false },
	name = { enabled = false },
	distance = { enabled = false },
}
local GROUP_PRESET = { name = { enabled = true } }
local PLAYER_PRESET = { box = { enabled = true }, healthBar = { enabled = true }, name = { enabled = true } }
local PARTS_REFRESH = 0.5
local SESSION_KEY = "VisualsSession"
local CORNERS = {
	Vector3.new(-1, -1, -1), Vector3.new(-1, -1, 1), Vector3.new(-1, 1, -1), Vector3.new(-1, 1, 1),
	Vector3.new(1, -1, -1), Vector3.new(1, -1, 1), Vector3.new(1, 1, -1), Vector3.new(1, 1, 1),
}

local cloneref = cloneref or function(instance) return instance end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local Workspace = cloneref(game:GetService("Workspace"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local LocalPlayer = Players.LocalPlayer

local Visuals = {}
local Esp = {}
Esp.__index = Esp
local Group = {}
Group.__index = Group

local function unknown(kind, path, key)
	error(string.format("visuals: unknown %s '%s%s'", kind, path, tostring(key)), 3)
end

local function strict(defaults, given, path, partial)
	given = given or {}
	if type(given) ~= "table" then
		error(string.format("visuals: '%s' must be a table", path), 3)
	end
	for key in given do
		if defaults[key] == nil then
			unknown("setting", path, key)
		end
	end
	local result = {}
	for key, default in defaults do
		local value = given[key]
		if type(default) == "table" then
			result[key] = strict(default, value, path .. key .. ".", partial)
		elseif value ~= nil then
			result[key] = value
		elseif not partial then
			result[key] = default
		end
	end
	return setmetatable(result, {
		__index = function(_, key)
			if defaults[key] == nil then
				unknown("setting", path, key)
			end
			return nil
		end,
		__newindex = function(self, key, value)
			if defaults[key] == nil then
				unknown("setting", path, key)
			end
			rawset(self, key, value)
		end,
	})
end

local function buildSettings(given, partial)
	local plain = table.clone(given or {})
	local theme, variants = plain.theme, plain.variants
	plain.theme, plain.variants = nil, nil
	local settings = strict(SETTINGS_DEFAULTS, plain, "", partial)
	rawset(settings, "theme", strict(THEME_DEFAULTS, theme, "theme.", true))
	if not partial then
		local built = {}
		for name, variant in variants or {} do
			built[name] = buildSettings(variant, true)
		end
		rawset(settings, "variants", built)
	end
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
	local variant = entry.variant
	local value = variant and variant[key]
	if value == nil then
		value = entry.group.settings[key]
	end
	return value
end

local function option(entry, feature, key)
	local variant = entry.variant
	local value = variant and variant[feature][key]
	if value == nil then
		value = entry.group.settings[feature][key]
	end
	return value
end

local function theme(entry, key)
	local variant = entry.variant
	local value = variant and variant.theme[key]
	if value == nil then
		value = entry.group.settings.theme[key]
	end
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
	item.frame = entry.frame
	return item
end

local function newSquare(filled, zIndex)
	local drawing = Drawing.new("Square")
	drawing.Filled = filled
	drawing.Thickness = 1
	drawing.ZIndex = zIndex
	drawing.Visible = false
	return cached(drawing)
end

local function newLabel(parent)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.XY
	label.Size = UDim2.new()
	label.Visible = false
	label.Parent = parent
	return cached(label)
end

local function newFrame(parent, cornerRadius)
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = cornerRadius
	corner.Parent = frame
	local item = cached(frame)
	item.corner = cached(corner)
	return item
end

local function rect(entry, key, filled, zIndex, color, position, size)
	local item = use(entry, key, newSquare, filled, zIndex)
	set(item, "Color", color)
	set(item, "Position", position)
	set(item, "Size", size)
	set(item, "Visible", true)
end

local function label(entry, item, text, size, color, transparency, zIndex)
	set(item, "Text", text)
	set(item, "FontFace", theme(entry, "font"))
	set(item, "TextSize", size)
	set(item, "TextColor3", color)
	set(item, "TextTransparency", transparency)
	set(item, "ZIndex", zIndex)
	set(item, "Visible", true)
end

local function text(entry, key, value, size, color, parent)
	local shadow = use(entry, key .. "Shadow", newLabel, parent)
	local main = use(entry, key, newLabel, parent)
	label(entry, shadow, value, size, theme(entry, "shadowColor"), theme(entry, "shadowTransparency"), 1)
	label(entry, main, value, size, color, 0, 2)
	return main, shadow
end

local function place(entry, main, shadow, x, y)
	local offset = theme(entry, "shadowOffset")
	set(main, "Position", UDim2.fromOffset(x, y))
	set(shadow, "Position", UDim2.fromOffset(x + offset.X, y + offset.Y))
end

local function healthColor(entry, fraction)
	return Color3.fromHSV(theme(entry, "healthyHue") * fraction, 1, 1)
end

local function drawBox(entry, frame)
	if not option(entry, "box", "enabled") or frame.maxX - frame.minX < 2 then
		return
	end
	local outline = theme(entry, "outlineColor")
	local position = Vector2.new(frame.minX, frame.minY)
	local size = Vector2.new(frame.maxX - frame.minX, frame.maxY - frame.minY)
	rect(entry, "boxOuter", false, 1, outline, position - Vector2.one, size + Vector2.one * 2)
	rect(entry, "boxInner", false, 1, outline, position + Vector2.one, size - Vector2.one * 2)
	rect(entry, "box", false, 2, theme(entry, "boxColor"), position, size)
end

local function drawClassic(entry, frame)
	local minX, minY, maxX, maxY = frame.minX, frame.minY, frame.maxX, frame.maxY
	local gap = theme(entry, "textGap")
	local root = entry.esp.gui

	if option(entry, "healthBar", "enabled") and frame.fraction and maxY - minY >= 2 then
		local width = theme(entry, "barWidth")
		local x = minX - theme(entry, "barGap") - width
		local fill = math.floor((maxY - minY) * frame.fraction + 0.5)
		rect(entry, "barBack", true, 1, theme(entry, "outlineColor"), Vector2.new(x - 1, minY - 1), Vector2.new(width + 2, maxY - minY + 2))
		rect(entry, "bar", true, 2, healthColor(entry, frame.fraction), Vector2.new(x, maxY - fill), Vector2.new(width, fill))
	end

	if option(entry, "name", "enabled") then
		local main, shadow = text(entry, "name", frame.name, theme(entry, "textSize"), theme(entry, "textColor"), root)
		local bounds = main.object.TextBounds
		place(entry, main, shadow, math.floor((minX + maxX - bounds.X) / 2), minY - 1 - gap - math.ceil(bounds.Y))
	end

	if option(entry, "distance", "enabled") then
		local value = string.format("%d studs", frame.distance)
		local main, shadow = text(entry, "distance", value, theme(entry, "smallTextSize"), theme(entry, "mutedTextColor"), root)
		local bounds = main.object.TextBounds
		place(entry, main, shadow, math.floor((minX + maxX - bounds.X) / 2), maxY + 1 + gap)
	end
end

local function drawCard(entry, frame)
	local showName = option(entry, "name", "enabled")
	local showDistance = option(entry, "distance", "enabled")
	local showHealth = option(entry, "healthBar", "enabled") and frame.fraction ~= nil
	if not (showName or showDistance or showHealth) then
		return
	end

	local padding = theme(entry, "panelPadding")
	local panel = use(entry, "panel", newFrame, entry.esp.gui, UDim.new())
	set(panel, "BackgroundColor3", theme(entry, "panelColor"))
	set(panel, "BackgroundTransparency", theme(entry, "panelTransparency"))
	set(panel.corner, "CornerRadius", UDim.new(0, theme(entry, "panelCornerRadius")))
	set(panel, "Visible", true)

	local nameMain, nameShadow, nameBounds = nil, nil, Vector2.zero
	if showName then
		nameMain, nameShadow = text(entry, "cardName", frame.name, theme(entry, "textSize"), theme(entry, "textColor"), panel.object)
		nameBounds = nameMain.object.TextBounds
	end
	local distanceMain, distanceShadow, distanceBounds = nil, nil, Vector2.zero
	if showDistance then
		local value = string.format("%d studs", frame.distance)
		distanceMain, distanceShadow = text(entry, "cardDistance", value, theme(entry, "smallTextSize"), theme(entry, "mutedTextColor"), panel.object)
		distanceBounds = distanceMain.object.TextBounds
	end

	local spacing = if showName and showDistance then theme(entry, "panelSpacing") else 0
	local textHeight = math.ceil(math.max(nameBounds.Y, distanceBounds.Y))
	local barHeight = theme(entry, "panelBarHeight")
	local width = math.max(theme(entry, "panelMinWidth"), math.ceil(nameBounds.X + spacing + distanceBounds.X) + padding * 2)
	local height = padding * 2 + textHeight
	if showHealth then
		height += barHeight + (if textHeight > 0 then 3 else 0)
	end

	if nameMain then
		place(entry, nameMain, nameShadow, padding, padding)
	end
	if distanceMain then
		place(entry, distanceMain, distanceShadow, width - padding - math.ceil(distanceBounds.X), padding + textHeight - math.ceil(distanceBounds.Y))
	end
	if showHealth then
		local barWidth = width - padding * 2
		local back = use(entry, "cardBarBack", newFrame, panel.object, UDim.new(1, 0))
		set(back, "BackgroundColor3", theme(entry, "panelBarColor"))
		set(back, "Position", UDim2.fromOffset(padding, height - padding - barHeight))
		set(back, "Size", UDim2.fromOffset(barWidth, barHeight))
		set(back, "ZIndex", 1)
		set(back, "Visible", true)
		local fill = use(entry, "cardBar", newFrame, panel.object, UDim.new(1, 0))
		set(fill, "BackgroundColor3", healthColor(entry, frame.fraction))
		set(fill, "Position", UDim2.fromOffset(padding, height - padding - barHeight))
		set(fill, "Size", UDim2.fromOffset(math.floor(barWidth * frame.fraction + 0.5), barHeight))
		set(fill, "ZIndex", 2)
		set(fill, "Visible", true)
	end

	local x = math.floor((frame.minX + frame.maxX - width) / 2)
	local y = frame.minY - 1 - theme(entry, "textGap") - height
	set(panel, "Size", UDim2.fromOffset(width, height))
	set(panel, "Position", UDim2.fromOffset(x, y))
end

local LAYOUTS = {
	classic = drawClassic,
	card = drawCard,
}

local function pivotOf(model)
	if model:IsA("PVInstance") then
		return model:GetPivot().Position
	elseif model:IsA("Attachment") then
		return model.WorldPosition
	end
	return nil
end

local function partsOf(entry, model)
	local now = os.clock()
	if entry.partsModel ~= model or now - entry.partsAt > PARTS_REFRESH then
		entry.parts = entry.accessors.parts(entry.target, model)
		entry.partsModel, entry.partsAt = model, now
	end
	return entry.parts
end

local function screenBounds(entry, model, camera, position)
	local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
	for _, part in partsOf(entry, model) do
		if not part.Parent then
			continue
		end
		local cframe, half = part.CFrame, part.Size / 2
		for _, sign in CORNERS do
			local point = camera:WorldToViewportPoint(cframe * (half * sign))
			if point.Z <= 0 then
				return nil
			end
			minX, minY = math.min(minX, point.X), math.min(minY, point.Y)
			maxX, maxY = math.max(maxX, point.X), math.max(maxY, point.Y)
		end
	end
	if minX == math.huge then
		local point = camera:WorldToViewportPoint(position)
		if point.Z <= 0 then
			return nil
		end
		local x, y = math.floor(point.X), math.floor(point.Y)
		return x, y, x, y
	end
	return math.floor(minX), math.floor(minY), math.ceil(maxX), math.ceil(maxY)
end

local function describe(entry, camera, origin, deltaTime)
	local accessors, target = entry.accessors, entry.target
	local model = accessors.model(target)
	if not model or not model.Parent then
		return nil
	end
	local variantName = accessors.variant(target, model)
	entry.variant = variantName and entry.group.settings.variants[variantName]
	if not setting(entry, "enabled") then
		return nil
	end

	local position = pivotOf(model)
	if not position then
		return nil
	end
	local distance = (position - origin).Magnitude
	if distance > setting(entry, "maxDistance") then
		return nil
	end

	local health, maxHealth = accessors.health(target, model)
	if health and health <= 0 then
		return nil
	end

	local minX, minY, maxX, maxY = screenBounds(entry, model, camera, position)
	if not minX then
		return nil
	end

	local frame = entry.snapshot
	frame.minX, frame.minY, frame.maxX, frame.maxY = minX, minY, maxX, maxY
	frame.distance = distance
	frame.name = accessors.name(target, model)
	frame.fraction = nil
	if health then
		local fraction = math.clamp(health / math.max(maxHealth or 100, 1), 0, 1)
		local shown = entry.shownHealth
		local blend = 1 - math.exp(-theme(entry, "healthSmoothing") * deltaTime)
		entry.shownHealth = if shown then shown + (fraction - shown) * blend else fraction
		frame.fraction = entry.shownHealth
	end
	return frame
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

local function removeEntry(group, target, entry)
	if group.entries[target] == entry then
		group.entries[target] = nil
		destroyElements(entry)
	end
end

local function renderEntry(entry, camera, origin, deltaTime)
	entry.frame += 1
	local frame = describe(entry, camera, origin, deltaTime)
	if frame then
		drawBox(entry, frame)
		local layout = setting(entry, "layout")
		local draw = LAYOUTS[layout]
		if not draw then
			error(string.format("visuals: unknown layout '%s'", tostring(layout)))
		end
		draw(entry, frame)
	else
		entry.shownHealth = nil
	end
	for _, item in entry.elements do
		if item.frame ~= entry.frame then
			set(item, "Visible", false)
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
		snapshot = {},
		frame = 0,
		partsAt = -math.huge,
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
	local filter = accessors.filter
	accessors.filter = nil
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
	local connections = {
		container.ChildAdded:Connect(consider),
		container.ChildRemoved:Connect(drop),
	}
	for _, connection in connections do
		table.insert(self.connections, connection)
	end
	for _, child in container:GetChildren() do
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
	if not camera then
		return
	end
	local origin = camera.CFrame.Position
	for _, group in self.groups do
		for target, entry in group.entries do
			if not target:IsA("Player") and not target.Parent then
				removeEntry(group, target, entry)
				continue
			end
			renderEntry(entry, camera, origin, deltaTime)
		end
	end
end

function Esp:unload()
	RunService:UnbindFromRenderStep(self.stepName)
	for index = #self.groups, 1, -1 do
		self.groups[index]:remove()
	end
	self.gui:Destroy()
	if getgenv()[SESSION_KEY] == self then
		getgenv()[SESSION_KEY] = nil
	end
end

function Visuals.start(themeOverrides)
	local running = getgenv()[SESSION_KEY]
	if running then
		running:unload()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = tostring(math.random(1e6, 1e7))
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 1e6
	gui.Parent = if gethui then gethui() else CoreGui

	local esp = setmetatable({
		theme = strict(THEME_DEFAULTS, themeOverrides, "theme.", false),
		gui = gui,
		groups = {},
		stepName = tostring(math.random(1e6, 1e7)),
	}, Esp)
	RunService:BindToRenderStep(esp.stepName, Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
		esp:render(deltaTime)
	end)
	getgenv()[SESSION_KEY] = esp
	return esp
end

return Visuals
