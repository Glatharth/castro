-- Valid town id list
app.Custom.ValidTownList = {3}

-- Valid vocation id list
app.Custom.ValidVocationList = {0}

-- New character values
app.Custom.NewCharacterValues = {
	[0] = { -- no voc (vocation ID -1)
		level = 1,
	    experience = 0,
	    health = 150,
	    healthmax = 150,
	    mana = 0,
	    manamax = 0,
	    cap = 435,
	    soul = 0
	},
	[1] = { -- sorc
		level = 8,
	    experience = 4200,
	    health = 185,
	    healthmax = 185,
	    mana = 35,
	    manamax = 35,
	    cap = 470,
	    soul = 100,
	    -- extra = {["maglevel"] = 45, ["skill_shielding"] = 20}
	    -- NOTE: the keys in extra ( ["key"] = value ) must be valid column names in your players table.
	},
	[2] = { -- druid
		inherit_from = 2 -- remove this line if you want to use custom values
	},
	[3] = { -- paladin
		inherit_from = 2
	},
	[4] = { -- knight
		inherit_from = 2
	}
}
