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
	return resolvers.current_level >= 5
end)
specialList("actor", {
	"/data/general/npcs/orc.lua",
}, true)
specialList("trap", {
	"/data/general/traps/complex.lua",
	"/data/general/traps/elemental.lua",
}, true)

defineTile(' ', "FLOOR")
defineTile('!', "DOOR_VAULT", nil, nil, nil, {room_map={special=false, room=false, can_open=true}})
defineTile('+', "DOOR")
defineTile('X', "HARDWALL")
defineTile('^', "FLOOR", nil, nil, {random_filter={add_levels=10}})
defineTile('$', "FLOOR", {random_filter={add_levels=15, tome_mod="gvault"}})
defineTile('m', "FLOOR", nil, {random_filter={add_levels=20}})
defineTile('o', "FLOOR", nil, "HILL_ORC_ARCHER")

startx = 21
starty = 7

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

return {
[[XXXXXXXXXXXXXXXXXXXXXX]],
[[XoommmmmmmmommmmmmmmmX]],
[[X$$XXXXXXXX XXXXXXXXmX]],
[[X$$XXXXXXXX XXXXXXXXmX]],
[[X$$XXXXXXXX XXXXXXXX+X]],
[[X$$X            $$   X]],
[[X$$X^       ^ ^     ^X]],
[[X$$+  ^           ^  !]],
[[X$$X^      ^  ^     ^X]],
[[X$$X  $$   ^ ^    ^ ^X]],
[[X$$XXXXXXXX XXXXXXXX+X]],
[[X$$XXXXXXXX XXXXXXXXmX]],
[[X$$XXXXXXXX XXXXXXXXmX]],
[[XoommmmmmmmommmmmmmmmX]],
[[XXXXXXXXXXXXXXXXXXXXXX]],
}