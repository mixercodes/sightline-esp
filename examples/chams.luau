local Sightline = loadstring(game:HttpGet("https://raw.githubusercontent.com/mixercodes/sightline-esp/main/sightline.luau"), "sightline")()

local esp = Sightline.start()

esp:players({
	layout = "minimal",
	box = { enabled = false },
	health = { enabled = false },
	chams = { enabled = true },
	useTeamColor = true,
	theme = { chamsFillColor = Color3.fromRGB(80, 200, 255), chamsFillTransparency = 0.6, chamsOutlineTransparency = 0.2 },
})
