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

name = "In the void, no one can hear you scream"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have destroyed the sorcerers, sadly the portal to the Void remains open: the Creator is coming."
	desc[#desc+1] = "This can not be allowed to happen, after thousands of years trapped in the void between the stars Gerlyk is mad with rage."
	desc[#desc+1] = "You must now finish what the Sher'tuls started, take the Staff of Absorption and become a Godslayer yourself."
	return table.concat(desc, "\n")
end
