-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2017 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

---------------------------------------------------------
--                       Ghouls                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Undead",
	locked = function() return profile.mod.allow_build.undead end,
	locked_desc = "Grave strength, dread will, this flesh cannot stay still. Kings die, masters fall, we will outlast them all.",
	desc = {
		"Undead are humanoids (Humans, Elves, Dwarves, ...) that have been brought back to life by the corruption of dark magics.",
		"Undead can take many forms, from ghouls to vampires and liches.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Ghoul = "allow",
			Skeleton = "allow",
			Vampire = "allow",
			Wight = "allow",
		},
		class =
		{
			Wilder = "disallow",
		},
		subclass =
		{
			Necromancer = "nolore",
			-- Only human, elves, halflings and undeads are supposed to be archmages
			Archmage = "allow",
		},
	},
	talents = {
		[ActorTalents.T_UNDEAD_ID]=1,
	},
	copy = {
		-- Force undead faction to undead
		resolvers.genericlast(function(e) e.faction = "undead" end),
		starting_zone = "blighted-ruins",
		starting_level = 3, starting_level_force_down = true,
		starting_quest = "start-undead",
		undead = 1,
		forbid_nature = 1,
		inscription_forbids = { ["inscriptions/infusions"] = true },
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=130}),
		--resolvers.inscription("RUNE:_PHASE_DOOR", {cooldown=7, range=10, dur=5, power=15}),
		resolvers.inscription("RUNE:_SHATTER_AFFLICTIONS", {cooldown=16, shield=50}), -- yeek and undead starts are unfun to the point of absurdity
		resolvers.inventory({id=true, transmo=false, alter=function(o) o.inscription_data.cooldown=7 o.inscription_data.dur=5 o.inscription_data.power=15 o.inscription_data.range=10 end, {type="scroll", subtype="rune", name="phase door rune", ego_chance=-1000, ego_chance=-1000}}), -- keep this in inventory incase people actually want it, can't add it baseline because some classes start with 3 inscribed
	},

	cosmetic_unlock = {
		cosmetic_bikini =  {
			{name="Bikini [donator only]", donator=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name.Bikini if not o then print("No bikini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull()
				else actor:registerOnBirthForceWear("FUN_BIKINI") end
			end, check=function(birth) return birth.descriptors_by_type.sex == "Female" end},
			{name="Mankini [donator only]", donator=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name.Mankini if not o then print("No mankini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull()
				else actor:registerOnBirthForceWear("FUN_MANKINI") end
			end, check=function(birth) return birth.descriptors_by_type.sex == "Male" end},
		},
	},
	
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}

newBirthDescriptor
{
	type = "subrace",
	name = "Ghoul",
	locked = function() return profile.mod.allow_build.undead_ghoul end,
	locked_desc = "Slow to shuffle, quick to bite, learn from master, rule the night!",
	desc = {
		"Ghouls are dumb, but resilient, rotting undead creatures, making good fighters.",
		"They have access to #GOLD#special ghoul talents#WHITE# and a wide range of undead abilities:",
		"- great poison resistance",
		"- bleeding immunity",
		"- stun resistance",
		"- fear immunity",
		"- special ghoul talents: ghoulish leap, gnaw and retch",
		"The rotting bodies of ghouls also force them to act a bit more slowly than most creatures.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +3 Strength, +1 Dexterity, +5 Constitution",
		"#LIGHT_BLUE# * +0 Magic, -2 Willpower, -2 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 14",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 25%",
		"#GOLD#Speed penalty:#LIGHT_BLUE# -20%",
	},
	moddable_attachement_spots = "race_ghoul", moddable_attachement_spots_sexless=true,
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
	},
	inc_stats = { str=3, con=5, wil=-2, mag=0, dex=1, cun=-2 },
	talents_types = {
		["undead/ghoul"]={true, 0.1},
	},
	talents = {
		[ActorTalents.T_GHOUL]=1,
	},
	copy = {
		type = "undead", subtype="ghoul",
		default_wilderness = {"playerpop", "low-undead"},
		starting_intro = "ghoul",
		life_rating=14,
		poison_immune = 0.8,
		cut_immune = 1,
		stun_immune = 0.5,
		fear_immune = 1,
		global_speed_base = 0.8,
		moddable_tile = "ghoul",
		moddable_tile_nude = 1,
	},
	experience = 1.25,
}

newBirthDescriptor
{
	type = "subrace",
	name = "Skeleton",
	locked = function() return profile.mod.allow_build.undead_skeleton end,
	locked_desc = "The marching bones, each step we rattle; but servants no more, we march to battle!",
	desc = {
		"Skeletons are animated bones, undead creatures both strong and dexterous.",
		"They have access to #GOLD#special skeleton talents#WHITE# and a wide range of undead abilities:",
		"- poison immunity",
		"- bleeding immunity",
		"- fear immunity",
		"- no need to breathe",
		"- special skeleton talents: bone armour, resilient bones, re-assemble",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +3 Strength, +4 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 12",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 40%",
	},
	moddable_attachement_spots = "race_skeleton", moddable_attachement_spots_sexless=true,
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
	},
	inc_stats = { str=3, con=0, wil=0, mag=0, dex=4, cun=0 },
	talents_types = {
		["undead/skeleton"]={true, 0.1},
	},
	talents = {
		[ActorTalents.T_SKELETON]=1,
	},
	copy = {
		type = "undead", subtype="skeleton",
		default_wilderness = {"playerpop", "low-undead"},
		starting_intro = "skeleton",
		life_rating=12,
		poison_immune = 1,
		cut_immune = 1,
		fear_immune = 1,
		no_breath = 1,
		blood_color = colors.GREY,
		moddable_tile = "skeleton",
		moddable_tile_nude = 1,
	},
	experience = 1.4,
}
