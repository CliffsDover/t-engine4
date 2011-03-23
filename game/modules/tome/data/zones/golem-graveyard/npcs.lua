-- ToME - Tales of Maj'Eyal
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

load("/data/general/npcs/construct.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "ATAMATHON", base = "BASE_NPC_CONSTRUCT",
	allow_infinite_dungeon = true,
	unique = true,
	name = "Atamathon the Giant Golem", image = "npc/atamathon.png",
	color=colors.VIOLET,
	desc = [[This giant golem was constructed by the halflings during the Pyre Wars to fight the orcs, but was felled by Garkul the Devourer. Someone foolish has tried to reconstruct it, but has lost control of it, and now it rampages in search of its original creators, who are long dead. Its body is made of marble, its joints of solid voratun, and its eyes of purest ruby. At over 40 feet high it towers above you, and its crimson orbs seem to glow with rage.]],
	level_range = {70, nil}, exp_worth = 2,
	max_life = 350, life_rating = 30, fixed_rating = true,
	stats = { str=35, dex=10, cun=8, mag=30, con=30 },
	rank = 3.5,
	size_category = 5,
	infravision = 20,
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, GEM=4 },
	resolvers.equip{
		{type="weapon", subtype="greatmaul", tome_drops="boss", tome_mod="uvault", autoreq=true },
		{type="armour", subtype="massive", tome_drops="boss", tome_mod="uvault", autoreq=true },
	},
	combat_armor = 50,
	resolvers.drops{chance=100, nb=7, {type="gem"} },
	resolvers.inventory{ inven="GEM",
		{defined="ATAMATHON_RUBY_EYE"},
		{defined="GEM_DIAMOND"},
		{defined="GEM_BLOODSTONE"},
		{defined="GEM_AMETHYST"},
	},

	inc_damage = {all=100},

	no_auto_resists = true,
	resists = {
		all = 40,
		[DamageType.PHYSICAL] = 30,
		[DamageType.FIRE] = 40,
		[DamageType.LIGHTNING] = 40,
		[DamageType.ACID] = 40,
		[DamageType.COLD] = 40,
	},

	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]={base=12, every=3},
		[Talents.T_WEAPONS_MASTERY]={base=14, every=3},
		[Talents.T_GOLEM_BEAM]={base=8, every=3},
		[Talents.T_GOLEM_ARCANE_PULL]={base=8, every=3},
		[Talents.T_GOLEM_REFLECTIVE_SKIN]={base=8, every=3},
		[Talents.T_GOLEM_MOLTEN_SKIN]={base=8, every=3},
		[Talents.T_GOLEM_KNOCKBACK]={base=8, every=3},
		[Talents.T_GOLEM_CRUSH]={base=8, every=3},
		[Talents.T_GOLEM_POUND]={base=8, every=3},
	},
	resolvers.inscriptions(5, "rune"),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
}
