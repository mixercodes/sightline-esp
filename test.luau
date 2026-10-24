local DUMMY_COUNT = 6
local DUMMY_SPACING = 5
local DUMMY_DISTANCE = 14
local HEALTH_CYCLE_SPEED = 0.8
local DUMMY_LAYOUTS = { "card", "card", "badge", "badge", "minimal", "classic" }

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if getgenv().VisualsTest then
	getgenv().VisualsTest.stop()
end

local Visuals = loadstring(readfile("visuals.luau"), "visuals")()

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
character.Archivable = true
local template = character:Clone()
character.Archivable = false
for _, descendant in template:GetDescendants() do
	if descendant:IsA("LuaSourceContainer") then
		descendant:Destroy()
	end
end

local folder = Instance.new("Folder")
folder.Name = "VisualsDummies"
folder.Parent = Workspace

local humanoids = {}
for index = 1, DUMMY_COUNT do
	local dummy = template:Clone()
	dummy.Name = "Dummy" .. index
	dummy:SetAttribute("Layout", DUMMY_LAYOUTS[index])
	local humanoid = dummy:FindFirstChildOfClass("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	local offsetX = (index - (DUMMY_COUNT + 1) / 2) * DUMMY_SPACING
	dummy:PivotTo(root.CFrame * CFrame.new(offsetX, 0, -DUMMY_DISTANCE - index * 2))
	dummy:FindFirstChild("HumanoidRootPart").Anchored = true
	dummy.Parent = folder
	humanoids[index] = humanoid
end

local crate = Instance.new("Part")
crate.Name = "Crate"
crate.Size = Vector3.new(3, 3, 3)
crate.Anchored = true
crate.CanCollide = false
crate.CFrame = root.CFrame * CFrame.new(-4, -1, -8) * CFrame.Angles(0, math.rad(30), 0)
crate.Parent = folder

local healthLoop = RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for index, humanoid in humanoids do
		local wave = math.sin(now * HEALTH_CYCLE_SPEED + index) * 0.5 + 0.5
		humanoid.Health = math.max(1, wave * humanoid.MaxHealth)
	end
end)

local esp = Visuals.start()

local players = esp:players({
	health = { style = "both" },
	avatar = { enabled = true },
	distance = { enabled = true },
	weapon = { enabled = true },
	team = { enabled = true },
	tags = { enabled = true },
	skeleton = { enabled = true },
	headDot = { enabled = true },
	look = { enabled = true },
	arrow = { enabled = true },
	focus = { enabled = true },
	focused = { theme = { boxColor = Color3.fromRGB(255, 80, 80) } },
	variants = { teammate = { theme = { boxColor = Color3.fromRGB(80, 160, 255) } } },
})

local dummies = esp:group({
	box = { enabled = true, style = "corners" },
	health = { enabled = true, style = "both" },
	avatar = { enabled = true },
	distance = { enabled = true },
	tags = { enabled = true },
	variants = {
		card = { layout = "card" },
		badge = { layout = "badge", box = { enabled = false } },
		minimal = { layout = "minimal", box = { enabled = false } },
		classic = { layout = "classic", box = { style = "full", filled = true }, health = { style = "bar" } },
	},
}, {
	avatar = function()
		return string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=60&h=60", LocalPlayer.UserId)
	end,
	variant = function(model)
		return model:GetAttribute("Layout")
	end,
	tags = function(model)
		return if model.Name == "Dummy1" then { "Boss", "$500" } else nil
	end,
})
dummies:watch(folder, { filter = function(child) return child:IsA("Model") end })

local loot = esp:group({
	layout = "minimal",
	maxDistance = 300,
	box = { enabled = true, style = "3d" },
	distance = { enabled = true },
})
loot:add(crate)

getgenv().VisualsTest = {
	esp = esp,
	players = players,
	dummies = dummies,
	loot = loot,
	stop = function()
		healthLoop:Disconnect()
		esp:unload()
		folder:Destroy()
		getgenv().VisualsTest = nil
	end,
}
