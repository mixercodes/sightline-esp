local Sightline = loadstring(game:HttpGet("https://raw.githubusercontent.com/mixercodes/sightline-esp/main/sightline.luau"), "sightline")()

local esp = Sightline.start({ textSize = 12, smallTextSize = 10 })

esp:players({
	layout = "minimal",
	box = { enabled = false },
	health = { enabled = false },
	distance = { enabled = true, unit = "meters" },
	maxDistance = 400,
	fade = { enabled = true, start = 40, finish = 400, minOpacity = 0.3 },
})
