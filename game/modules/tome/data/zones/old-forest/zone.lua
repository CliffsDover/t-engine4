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

return {
	name = "Old Forest",
	level_range = {7, 12},
	level_scheme = "player",
	max_level = 7,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	persistant = "zone",
	color_shown = {0.6, 0.6, 0.6, 1},
	color_obscure = {0.6*0.6, 0.6*0.6, 0.6*0.6, 1},
	ambiant_music = "Woods of Eremae.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = {6,4},
			rooms = {"forest_clearing", {"lesser_vault",8}},
			rooms_config = {forest_clearing={pit_chance=5, filters={{type="insect", subtype="ant"}, {type="insect"}, {type="animal", subtype="snake"}, {type="animal", subtype="canine"}}}},
			lesser_vaults_list = {"honey_glade_dark", "troll-hideout-dark", "mage-hideout-dark"},
			['.'] = "GRASS_DARK1",
			['#'] = {"TREE_DARK1","TREE_DARK2","TREE_DARK3","TREE_DARK4","TREE_DARK5","TREE_DARK6","TREE_DARK7","TREE_DARK8","TREE_DARK9","TREE_DARK10","TREE_DARK11","TREE_DARK12","TREE_DARK13","TREE_DARK14","TREE_DARK15","TREE_DARK16","TREE_DARK17","TREE_DARK18","TREE_DARK19","TREE_DARK20",},
			up = "UP",
			down = "DOWN",
			door = "GRASS_DARK1",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "OLD_MAN_WILLOW",
		},
		object = {
			class = "engine.generator.object.Random",
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
			filters = { {} }
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {9, 15},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
	},

	post_process = function(level)
		local Map = require "engine.Map"
		level.foreground_particle = require("engine.Particles").new("raindrops", 1, {width=Map.viewport.width, height=Map.viewport.height})
	end,

	foreground = function(level, x, y)
		local Map = require "engine.Map"
		level.foreground_particle:update()
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,
}
