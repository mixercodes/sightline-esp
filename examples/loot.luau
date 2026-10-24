local Sightline = loadstring(game:HttpGet("https://raw.githubusercontent.com/mixercodes/sightline-esp/main/sightline.luau"), "sightline")()

local RARITY_COLORS = {
	Common = Color3.fromRGB(190, 190, 200),
	Rare = Color3.fromRGB(80, 160, 255),
	Legendary = Color3.fromRGB(255, 190, 60),
}

local variants = {}
for rarity, color in RARITY_COLORS do
	variants[rarity] = { theme = { boxColor = color, nameColor = color } }
end

local esp = Sightline.start()

local loot = esp:group({
	layout = "minimal",
	maxDistance = 500,
	box = { enabled = true, style = "3d" },
	distance = { enabled = true },
	variants = variants,
}, {
	variant = function(item)
		return item:GetAttribute("Rarity")
	end,
})

loot:watch(workspace, {
	recursive = true,
	filter = function(instance)
		return instance:IsA("BasePart") and instance:GetAttribute("Rarity") ~= nil
	end,
})
