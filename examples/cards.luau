local Sightline = loadstring(game:HttpGet("https://raw.githubusercontent.com/mixercodes/sightline-esp/main/sightline.luau"), "sightline")()

local esp = Sightline.start()

esp:players({
	layout = "card",
	box = { enabled = false },
	health = { style = "number" },
	avatar = { enabled = true },
	name = { style = "both" },
	distance = { enabled = true },
	weapon = { enabled = true },
	team = { enabled = true },
	tags = { enabled = true },
}, {
	tags = function(player)
		local bounty = player:GetAttribute("Bounty")
		return if bounty then { "$" .. bounty } else nil
	end,
})
