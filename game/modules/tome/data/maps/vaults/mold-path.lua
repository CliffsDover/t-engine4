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

setStatusAll{no_teleport=true}
roomCheck(function(room, zone, level, map)
	return resolvers.current_level <= 25
end)
rotates = {"default", "90", "180", "270", "flipx", "flipy"}
specialList("terrain", {
	"/data/general/grids/water.lua",
	"/data/general/grids/forest.lua",
})
specialList("actor", {
	"/data/general/npcs/ooze.lua",
	"/data/general/npcs/molds.lua",
})
defineTile('.', "GRASS_SHORT")
defineTile('#', "TREE")
defineTile('X', "HARDTREE")
defineTile('~', "POISON_DEEP_WATER")
defineTile('!', "ROCK_VAULT", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})

defineTile('m', "GRASS_SHORT", nil, {random_filter={subtype="molds", add_levels=2}})
defineTile('j', "GRASS_SHORT", nil, {random_filter={subtype="oozes", add_levels=2}})

defineTile('$', "GRASS_SHORT", {random_filter={add_levels=5, tome_mod="vault"}})

startx = 19
starty = 7

return {
[[#XXXXXXXXX#####XXXX#]],
[[XXm~~~~~~XXXX#XX$$XX]],
[[X~~~~.j..~~jXXXmmmmX]],
[[X~.~~mXX.j~~~j..jjXX]],
[[Xm.~~XXXXX~~~~.jXXX#]],
[[XX.mmXXXXXXXXXXXX###]],
[[XmmmXXXXXXXXXXXXXXXX]],
[[X~~~mXXXX~.mmXXm...!]],
[[XXm..~m~....~~~~~mXX]],
[[#XXXX~~~mXXXm~m~XXX#]],
[[####XXXXXX#XXXXXX###]],
}
