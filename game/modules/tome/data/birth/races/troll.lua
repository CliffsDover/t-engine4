---------------------------------------------------------
--                       Trolls                       --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Troll",
	desc = {
		"",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "never",
			Troll = "allow",
		},
		sex =
		{
			__ALL__ = "never",
			Male = "allow",
		},
	},
	stats = { str=4, con=3, wil=3, mag=-2, dex=-2 },
	talents = {
--		[ActorTalents.T_DWARF_RESILIENCE]=1,
	},
	copy = {
		type = "humanoid", subtype="troll",
		default_wilderness = {"wilderness/east", 39, 17},
		starting_zone = "tower-amon-sul",
		starting_quest = "start-dunadan",
		starting_intro = "dwarf",
		life_rating=10,
	},
	experience = 1.1,
}

---------------------------------------------------------
--                       Dwarves                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Troll",
	desc = {
		"",
	},
}
