-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

startx = 63
starty = 32
endx = 0
endy = 32

subGenerator{
	x = 8, y = 8, w = 48, h = 48,
	generator = data.sublevel.class,
	data = table.clone(data.sublevel),
}

local floor = data.floor or data.sublevel.floor

-- defineTile section
defineTile("#", "HARDWALL")
defineTile("o", floor, nil, {entity_mod=function(e) e.make_escort = nil return e end, random_filter={type='humanoid', subtype='orc', special=function(e) return e.pride == data.sublevel.pride end}})
quickEntity("g", 'o')
defineTile("+", data.sublevel.door)
defineTile("<", data.up)
defineTile(">", data.down, nil, nil, nil, {no_teleport=true})
if level.level == 1 then defineTile("O", floor, nil, {random_filter={type='humanoid', subtype='orc', special=function(e) return e.pride == data.sublevel.pride end, random_boss={nb_classes=1, loot_quality="store", loot_quantity=3, rank=3.5,}}})
else quickEntity('O', 'o') end
defineTile(".", floor)
defineTile(";", floor, nil, nil, nil, {no_teleport=true})
defineTile("*", "LEVER_DOOR", nil, nil, nil, nil, {type="lever", subtype="door"})
defineTile("&", "LEVER", nil, nil, nil, nil, {type="lever", subtype="lever"})
defineTile(" ", floor, nil, {entity_mod=function(e) e.make_escort = nil return e end, random_filter={type='humanoid', subtype='orc', special=function(e) return e.pride == data.sublevel.pride end, random_boss={nb_classes=1, loot_quality="store", loot_quantity=1, no_loot_randart=true, rank=3}}}, nil, {no_teleport=true})

-- addSpot section

-- addZone section

-- ASCII map section
return [[
################################################################
################################################################
########################..g...##################################
########################&#g......###############################
########################..g...##.###############################
################################.###############################
################################.###############################
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
###;;;#..................................................#ooo###
##;;;##..................................................##...##
##;;;##..................................................##...##
;;;;;##..................................................##.....
;;;;;#....................................................#.....
; ;;;#....................................................#.....
> ;;;*....................................................+O...<
; ;;;#....................................................#.....
;;;;;#....................................................#.....
;;;;;##..................................................##.....
##;;;##..................................................##...##
##;;;##..................................................##...##
###;;;#..................................................#ooo###
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
#######..................................................#######
################################.###############################
################################.###############################
########################..g...##.###############################
########################&#g......###############################
########################..g...##################################
################################################################
################################################################]]