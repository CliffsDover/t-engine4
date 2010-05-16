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
	name = "Elven Ruins",
	level_range = {15, 28},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 30, height = 30,
--	all_remembered = true,
--	all_lited = true,
	persistant = "zone",
	generator =  {
		map = {
			class = "engine.generator.map.TileSet",
			tileset = {"3x3/base", "3x3/tunnel", "3x3/windy_tunnel"},
			tunnel_chance = 100,
			['.'] = "OLD_FLOOR",
			['#'] = {"OLD_WALL","WALL","WALL","WALL","WALL"},
			['+'] = "DOOR",
			["'"] = "DOOR",
			up = "UP",
			down = "DOWN",
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 20},
			guardian = "GREATER_MUMMY_LORD",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
		[3] = {
			width = 100, height = 100,
			generator = {
				map = {
					tileset = {"5x5/base", "5x5/tunnel", "5x5/windy_tunnel", "5x5/crypt"},
					start_tiles = {{tile="LONG_TUNNEL_82", x=8, y=0}},
					tunnel_chance = 60,
					force_last_stair = true,
					down = "QUICK_EXIT",
				},
				actor = {
					nb_npc = {20*3, 25*3},
				},
				object = {
					nb_object = {6*3, 9*3},
				},
				trap = {
					nb_trap = {6*4, 9*4},
				},
			},
		},
	},
}
