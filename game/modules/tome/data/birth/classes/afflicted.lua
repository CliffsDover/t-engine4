-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

newBirthDescriptor{
	type = "class",
	name = "Afflicted",
	desc = {
		"Afflicted classes have been twisted by their association with evil forces.",
		"They can use these forces to their advantage, but at a cost...",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Cursed = function() return profile.mod.allow_build.afflicted_cursed and "allow" or "disallow" end,
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Cursed",
	desc = {
		"Through ignorance, greed or folly the cursed served some dark design and are now doomed to pay for their sins.",
		"Their only master now is the hatred they carry for every living thing.",
		"Drawing strength from the death of all they encounter, the cursed become terrifying combatants.",
		"Worse, any who approach the cursed can be driven mad by their terrible aura.",
		"Their most important stats are: Strength and Willpower",
	},
	stats = { wil=4, str=5, },
	talents_types = {
		["cursed/gloom"]={true, 0.0},
		["cursed/slaughter"]={true, 0.0},
		["cursed/endless-hunt"]={true, 0.0},
		["cursed/cursed-form"]={true, 0.0},
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={false, 0.0}
	},
	talents = {
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_UNNATURAL_BODY] = 1,
		[ActorTalents.T_GLOOM] = 1,
		[ActorTalents.T_SLASH] = 1,
		[ActorTalents.T_DOMINATE] = 1,
		[ActorTalents.T_AXE_MASTERY] = 1
	},
	copy = {
		max_life = 110,
		life_rating = 12,
		resolvers.equip{ id=true,
			{type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true}
		},
	},
}
