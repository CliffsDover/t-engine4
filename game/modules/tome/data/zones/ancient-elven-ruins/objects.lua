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

load("/data/general/objects/objects-maj-eyal.lua")
load("/data/general/objects/mummy-wrappings.lua")

local Stats = require "engine.interface.ActorStats"
--local Talents = require "engine.interface.ActorTalents"

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "ancient papyrus scroll", lore="ancient-elven-ruins-note-"..i,
	desc = [[This seems to be an account of the last days of a great Shaloren mage.]],
	rarity = false,
}
end

newEntity{ base = "BASE_MUMMY_WRAPPING", define_as = "BINDINGS_ETERNAL_NIGHT",
	power_source = {arcane=true},
	unique = true,
	name = "Bindings of Eternal Night", image = "object/artifact/bindings_of_eternal_night.png",
	unided_name = "blackened, slithering mummy wrappings",
	desc = [[Woven through with fell magics of undeath, these bindings suck the light and life out of everything they touch. Any who don them will find themselves suspended in a nightmarish limbo between life and death.]],
	color = colors.DARK_GREY,
	level_range = {1, 50},
	rarity = 20, -- not particularly rare, to be loaded only with mummy NPCs
	cost = 200,
	material_level = 4,
	wielder = {
		combat_armor = 12,
		combat_def = 12,
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_MAG] = 5, },
		resists = {
			[DamageType.BLIGHT] = 30,
			[DamageType.DARKNESS] = 30,
			[DamageType.LIGHT] = -10,
			[DamageType.FIRE] = -10,
		},
		inc_damage={[DamageType.DARKNESS] = 20},
		on_melee_hit={[DamageType.DARKNESS] = 10},
		life_regen = 1,
		lite = -1,
		poison_immune = 1,
		disease_immune = 1,
		undead = 1,
		forbid_nature = 1,
	},
	max_power = 80, power_regen = 1,

	set_list = { {"define_as","CROWN_ETERNAL_NIGHT"} },
	set_desc = {
		eternalnight = "A complementing item would be your crowning glory.",
	},
	on_set_complete = function(self, who)
		self.use_talent = { id = "T_ABYSSAL_SHROUD", level = 2, power = 47 }
	end,
	on_set_broken = function(self, who)
		self.use_talent = nil
	end,
}

newEntity{ base = "BASE_LEATHER_CAP", define_as = "CROWN_ETERNAL_NIGHT",
	power_source = {arcane=true},
	unique = true,
	name = "Crown of Eternal Night", image = "object/artifact/crown_of_eternal_night.png",
	unided_name = "blackened crown",
	desc = [[This crown looks useless, yet you can feel it is woven with fell magics of undeath. Maybe it has a use.]],
	color = colors.DARK_GREY,
	level_range = {1, 50},
	cost = 100,
	rarity = 20, -- not particularly rare, to be loaded only with mummy NPCs
	material_level = 3,
	wielder = {
		combat_armor = 3,
		fatigue = 3,
		inc_damage = {},
		melee_project = {},
		flat_damage_armor = {all=10},
	},
	max_power = 80, power_regen = 1,

	set_list = { {"define_as","BINDINGS_ETERNAL_NIGHT"} },
	set_desc = {
		eternalnight = "You need to find something to bind its powers.",
	},
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","lite"}, -1)
		self:specialSetAdd({"wielder","confusion_immune"}, 0.3)
		self:specialSetAdd({"wielder","knockback_immune"}, 0.3)
		self:specialSetAdd({"wielder","combat_mentalresist"}, 15)
		self:specialSetAdd({"wielder","combat_spellresist"}, 15)
		self:specialSetAdd({"wielder","flat_damage_armor"}, {all=20})
		self:specialSetAdd({"wielder","inc_stats"}, {[who.STAT_CUN]=10})
		self:specialSetAdd({"wielder","melee_project"}, {[engine.DamageType.DARKNESS]=40})
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.DARKNESS]=20})
		self:specialSetAdd({"wielder","talents_types_mastery"}, {["cunning/stealth"] = 0.1,})
		self.use_talent = { id = "T_RETCH", level = 2, power = 47 }
		game.logSeen(who, "#ANTIQUE_WHITE#The Crown of Eternal Night seems to react with the Bindings, you feel tremendous dark power.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#ANTIQUE_WHITE#The powerful darkness aura you felt wanes away.")
		self.use_talent = nil
	end,
}
