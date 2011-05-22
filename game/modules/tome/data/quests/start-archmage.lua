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

name = "Spellblaze Fallouts"
stables = 0
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "The Abashed Expanse is a part of Eyal torn apart by the Spellblaze and thrown into the void between the stars.\n"
	desc[#desc+1] = "It has recently begun to destabilize threatening to crash onto Eyal, destroying everything in its path.\n"
	desc[#desc+1] = "You have entered it and must now stabilize three wormholes by firing any spell at them.\n"
	desc[#desc+1] = "Remember, the floating islands are not stable and might teleport randomly, however the disturbances also help you, your Phase Door spell is fully controllable even if not of high level yet.\n"
	if self:isCompleted("abashed") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the expanse and closed all three wormholes.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You have closed "..self.stables.." wormhole(s).#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("abashed") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("starter-allied")
		end
	end
end

stabilized = function(self)
	self.stables = self.stables + 1
end
