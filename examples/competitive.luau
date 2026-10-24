local Sightline = loadstring(game:HttpGet("https://raw.githubusercontent.com/mixercodes/sightline-esp/main/sightline.luau"), "sightline")()

local esp = Sightline.start()

esp:players({
	box = { style = "corners" },
	health = { style = "both" },
	distance = { enabled = true },
	visibilityCheck = true,
	occluded = {
		theme = { boxColor = Color3.fromRGB(140, 140, 150), nameColor = Color3.fromRGB(170, 170, 180) },
	},
	variants = {
		teammate = { enabled = false },
	},
})
