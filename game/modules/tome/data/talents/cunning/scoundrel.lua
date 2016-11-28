-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2016 Nicolas Casalini
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

local Map = require "engine.Map"

newTalent{
	name = "Lacerating Strikes",
	type = {"cunning/scoundrel", 1},
	points = 5,
	require = cuns_req1,
	mode = "sustained",
	no_break_stealth = true,
	getChance = function(self,t) return self:combatTalentLimit(t, 50, 15, 35) end, --Limit < 100%
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if not target then return nil end
		if self:reactionToward(target) >=0 then return nil end
		if rng.percent(t.getChance(self, t)) then
			local energyDrain = (game.energy_to_act * 0.1)	
			target.energy.value = target.energy.value - energyDrain
			if target:canBe("cut") then
				local bleed = dam*0.75
				target:setEffect(target.EFF_CUT, 10, {src=self, power=(dam / 10)})
			end
		end		
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t)
		return true
	end,
	info = function(self, t)
		local chance = t.getChance(self,t)
		return ([[You melee attacks have a %d%% chance to inflict a deep, disabling wound inflicting an additional 75%% of the damage dealt as a bleed over 10 turns, as well as causing the target to lose 10%% of a turn.]]):
		format(chance)
	end,
}

newTalent{
	name = "Scoundrel's Strategies", short_name = "SCOUNDREL",
	type = {"cunning/scoundrel", 2},
	require = cuns_req2,
	mode = "passive",
	points = 5,
	getCritPenalty = function(self,t) return self:combatTalentScale(t, 10, 30) end,
	getDuration = function(self,t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	getChance = function(self, t) return self:combatTalentScale(t, 8, 24) end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if not target then return nil end
		if self:reactionToward(target) >=0 then return nil end
		if target then target:setEffect(target.EFF_SCOUNDREL, 10, {src=self, power=t.getCritPenalty(self,t) }) end
		if self:knowTalent(self.T_FUMBLE) and target then
			local dam = self:callTalent(self.T_FUMBLE, "getDamage")
			local stacks = self:callTalent(self.T_FUMBLE, "getStacks")
			target:setEffect(target.EFF_FUMBLE, 10, {power=3, max_power = stacks*3, dam=dam, stacks=1, max_stacks=stacks })
		end

		local nb = 0
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.cut then nb = nb + 1 end
		end
		
		if nb <= 0 or not rng.percent(t.getChance(self,t)) or target.turn_procs.scoundrel then return end
		local tids = {}
		for tid, lev in pairs(target.talents) do
			local t = target:getTalentFromId(tid)
			if t and not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
		end
		
		local cd = t.getDuration(self,t)
		local t = rng.tableRemove(tids)
		if not t or #tids<=0 then return end
		target.talents_cd[t.id] = cd
		game.logSeen(target, "%s's %s is disrupted by their wounds!", target.name:capitalize(), t.name)
		target.turn_procs.scoundrel = true
		
	end,
	info = function(self, t)
		local chance = t.getChance(self,t)
		local crit = t.getCritPenalty(self, t)
		local dur = t.getDuration(self,t)
		return ([[Your melee attacks inflict distracting wounds that reduce the target’s critical strike chance by %d%% for 10 turns. 
In addition, your attacks against bleeding targets have a %d%% chance to inflict a painful wound that causes them to forget a random talent for %d turns. This cannot affect a target more than once per turn.
		]]):format(crit, chance, dur)
	end,
}

newTalent{
	name = "Misdirection",
	type = {"cunning/scoundrel", 3},
	mode = "passive",
	points = 5,
	require = cuns_req3,
	mode = "passive",
	getDuration = function(self, t) return self:combatTalentLimit(t, 100, 30, 55) end, --limit < 100%
	getChance = function(self, t) return self:combatTalentLimit(t, 50, 5, 25) end, --limit < 100%
	callbackOnTemporaryEffect = function(self, eff, eff_id, e, p)
		if e.status ~= "detrimental" or e.type ~= "physical" then return end
		local chance = self:callTalent(self.T_MISDIRECTION, "getChance")
		if not rng.percent(chance) then return end
		game.logSeen(self, "#ORANGE#%s redirects the effect '%s'!", self.name:capitalize(), e.desc)
		
		local tgts = {}
		self:project({type="ball", radius=1}, self.x, self.y, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if not act or self:reactionToward(act) >= 0 then return end
			tgts[#tgts+1] = act
		end)
		if #tgts > 0 then
			local target = rng.table(tgts)
			local newp = table.clone(p, false)
			newp.apply_power = self:combatAttack()
			target:setEffect(eff_id, newp.dur, newp)
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Your abilities in sowing confusion and chaos have reached their peak. Whenever a foe attempts to apply a detrimental physical effect to you, they have a %d%% chance to fail. If there is an adjacent enemy to you, you misdirect your foe into applying it to them at %d%% duration.
The chance to apply status effects increases with your Accuracy.]]):
		format(t.getChance(self,t),t.getDuration(self,t))
	end,
}

newTalent{
	name = "Fumble",
	type = {"cunning/scoundrel", 4},
	require = cuns_req4,
	mode = "passive",
	points = 5,
	getDamage = function(self, t) return self:combatTalentStatDamage(t, "cun", 25, 300) end,
	getStacks = function(self,t) return math.floor(self:combatTalentLimit(t, 20, 3, 15)) end,
	info = function(self, t)
		local stacks = t.getStacks(self, t)
		local dam = t.getDamage(self, t)
		return ([[Your Scoundrel's Strategies effect leaves your foes unable to focus on any complex actions, giving them a stacking 3%% chance to fail their next talent usage (to a maximum of %d%%).
		On failing a talent the target fumbles and injures themself, taking %0.2f physical damage and removing the fumble effect.
		The damage dealt increases with your Cunning.
		]]):format(stacks*3, damDesc(self, DamageType.PHYSICAL, dam))
	end,
}