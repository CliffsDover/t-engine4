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

local function attack(str)
	return function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) npc:doEmote(str, 150) end
end

-----------------------------------------------------------------------
-- Default
-----------------------------------------------------------------------
if not game.player:isQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "slasul-story") then

newChat{ id="welcome",
	text = [[What is this? Why have you entered my temple and slain my followers?
Speak or die, for I am Slasul and you shall not disrupt my plans.]],
	answers = {
		{"[attack]", action=attack("So be it... Die now!")},
		{"I was sent by Ukllmswwik to stop your mad schemes to control all underwater life!", jump="quest"},
	}
}

newChat{ id="quest",
	text = [[I see, so the dragon sent you. He told you I am insane, I assume?
But which of us is truly evil? Myself, working to better my people, doing no harm to anyone, or you, who comes here to kill me, destroying my friends and planning to do the same to me?
Who is the insane one?]],
	answers = {
		{"Your feeble attempt to sway me from the side of good will not work. Pay for you sins!", action=attack("If you refuse to see reason, you leave me no choice!")},
		{"Your words are ... disturbing. Why should I spare you?", jump="givequest"},
	}
}

newChat{ id="givequest",
	text = [[Spare me?#LIGHT_GREEN#*He laughs.*#WHITE#
Do not be so hasty to assume YOU are in a position to offer mercy to ME!
Yet I shall tell you my story. You surface dwellers do not know much about nagas, but let me tell you this: our current condition was not our choice.
When Nalore sank, many of us died, so we resorted to using the magic of this temple. It worked, it saved us, and yet we are cursed. Cursed in this form by the terrible magic.
If you do not believe anything else of what I say, please believe at least this: the Sher'Tul are hidding, not gone, and they are not benevolent entities.
Recently, that water dragon that sent you here started sending "agents" to secure the temple. I can only imagine his goals, but they are clearly not peaceful.]],
	answers = {
		{"You do not sound mad to me ... could Ukllmswwik have lied?", jump="portal_back", action=function(npc, player) player:setQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "slasul-story") end},
		{"I will not be deceived by your lies! I will make your pay for your victims!", action=attack("As you wish. It did not have to come to it...")},
	}
}

newChat{ id="portal_back",
	text = [[Use this portal, it will bring you back to his cave; ask him the truth.]],
	answers = {
		{"I will make him pay for his treachery.", action=function(npc, player) player:hasQuest("temple-of-creation"):portal_back() end},
	}
}

-----------------------------------------------------------------------
-- Coming back later
-----------------------------------------------------------------------
else
newChat{ id="welcome",
	text = [[Thank you for listening to me.]],
	answers = {
		{"[attack]", action=attack("So be it... Die now!")},
		{"Farewell, Slasul."},
	}
}
end

return "welcome"
