local Sightline = loadstring(game:HttpGet("https://raw.githubusercontent.com/mixercodes/sightline-esp/main/sightline.luau"), "sightline")()

local FOCUS_COLOR = Color3.fromRGB(255, 80, 80)

local esp = Sightline.start()

esp:players({
	layout = "minimal",
	box = { enabled = false },
	health = { style = "number" },
	skeleton = { enabled = true },
	headDot = { enabled = true },
	look = { enabled = true, length = 8 },
	tracer = { enabled = true, origin = "bottom", target = "head" },
	focus = { enabled = true, radius = 200 },
	focused = {
		theme = { skeletonColor = FOCUS_COLOR, headDotColor = FOCUS_COLOR, tracerColor = FOCUS_COLOR, nameColor = FOCUS_COLOR },
	},
	theme = { tracerTransparency = 0.6, tracerOutline = false },
})
