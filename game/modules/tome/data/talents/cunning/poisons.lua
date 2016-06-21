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

----------------------------------------------------------------
-- Poisons
----------------------------------------------------------------

newTalent{
	name = "Apply Poison",
	type = {"cunning/poisons", 1},
	require = cuns_req1,
	mode = "sustained",
	points = 5,
	cooldown = 10,
	no_break_stealth = true,
	tactical = { BUFF = 2 },
	sustain_stamina = 10,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 7)) end,
	getChance = function(self,t) return 20 + self:getTalentLevel(t) * 5 end,
	getDamage = function(self, t) return 8 + self:combatTalentStatDamage(t, "cun", 10, 60) * 0.6 end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if target then
			if target:canBe("poison") and rng.percent(t.getChance(self,t)) then
				local insidious = 0
				if self:isTalentActive(self.T_INSIDIOUS_POISON) then insidious = self:callTalent(self.T_INSIDIOUS_POISON, "getEffect") end
				local numbing = 0
				if self:isTalentActive(self.T_NUMBING_POISON) then numbing = self:callTalent(self.T_NUMBING_POISON, "getEffect") end
				local crippling = 0
				if self:isTalentActive(self.T_CRIPPLING_POISON) then crippling = self:callTalent(self.T_CRIPPLING_POISON, "getEffect") end
				local leeching = 0
				if self:isTalentActive(self.T_LEECHING_POISON) then leeching = self:callTalent(self.T_LEECHING_POISON, "getEffect") end
				local volatile = 0
				if self:isTalentActive(self.T_VOLATILE_POISON) then volatile = self:callTalent(self.T_VOLATILE_POISON, "getEffect")/100 end
				local dam = t.getDamage(self,t) * (1 + volatile)
				target:setEffect(target.EFF_DEADLY_POISON, t.getDuration(self, t), {src=self, power=dam, max_power=dam*4, insidious=insidious, crippling=crippling, numbing=numbing, leeching=leeching, volatile=volatile, apply_power=self:combatAttack(), no_ct_effect=true})
				if self:knowTalent(self.T_VULNERABILITY_POISON) then 
					target:setEffect(target.EFF_VULNERABILITY_POISON, t.getDuration(self, t), {src=self, power=self:callTalent(self.T_VULNERABILITY_POISON, "getDamage") , apply_power=self:combatAttack(), no_ct_effect=true})
				end
			end
		end
	end,
	callbackOnArcheryAttack = function(self, t, target, hitted)
		if target then
			if target:canBe("poison") and rng.percent(t.getChance(self,t)) then
				local insidious = 0
				if self:isTalentActive(self.T_INSIDIOUS_POISON) then insidious = self:callTalent(self.T_INSIDIOUS_POISON, "getEffect") end
				local numbing = 0
				if self:isTalentActive(self.T_NUMBING_POISON) then numbing = self:callTalent(self.T_NUMBING_POISON, "getEffect") end
				local crippling = 0
				if self:isTalentActive(self.T_CRIPPLING_POISON) then crippling = self:callTalent(self.T_CRIPPLING_POISON, "getEffect") end
				local leeching = 0
				if self:isTalentActive(self.T_LEECHING_POISON) then leeching = self:callTalent(self.T_LEECHING_POISON, "getEffect") end
				local volatile = 0
				if self:isTalentActive(self.T_VOLATILE_POISON) then volatile = self:callTalent(self.T_VOLATILE_POISON, "getEffect")/100 end
				local dam = t.getDamage(self,t) * (1 + volatile)
				target:setEffect(target.EFF_DEADLY_POISON, t.getDuration(self, t), {src=self, power=dam, max_power=dam*4, insidious=insidious, crippling=crippling, numbing=numbing, leeching=leeching, volatile=volatile, apply_power=self:combatAttack(), no_ct_effect=true})
				if self:knowTalent(self.T_VULNERABILITY_POISON) then 
					target:setEffect(target.EFF_VULNERABILITY_POISON, t.getDuration(self, t), {src=self, power=self:callTalent(self.T_VULNERABILITY_POISON, "getDamage") , apply_power=self:combatAttack(), no_ct_effect=true})
				end
			end
		end
	end,
	activate = function(self, t)
		local ret = {
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Learn how to coat your melee weapons, throwing knives, sling and bow ammo with poison, giving your attacks a %d%% chance to poison the target for %d nature damage per turn for %d turns. Every application of the poison stacks, up to a maximum of %d nature damage per turn.
		The damage scales with your Cunning.]]):
		format(t.getChance(self,t), damDesc(self, DamageType.NATURE, t.getDamage(self, t)), t.getDuration(self, t), damDesc(self, DamageType.NATURE, t.getDamage(self, t)*4))
	end,
}

newTalent{
	name = "Toxic Death",
	type = {"cunning/poisons", 2},
	points = 5,
	mode = "passive",
	require = cuns_req2,
	getRadius = function(self, t) return self:combatTalentScale(t, 1, 3) end,
	on_kill = function(self, t, target)
		local poisons = {}
		for k, v in pairs(target.tmp) do
			local e = target.tempeffect_def[k]
			if e.subtype.poison and v.src and v.src == self then
				poisons[k] = target:copyEffect(k)
			end
		end

		local tg = {type="ball", range = 10, radius=t.getRadius(self, t), selffire = false, friendlyfire = false, talent=t}
		self:project(tg, target.x, target.y, function(tx, ty)
			local target2 = game.level.map(tx, ty, Map.ACTOR)
			if not target2 or target2 == self then return end
			for eff, p in pairs(poisons) do
				target2:setEffect(eff, p.dur, table.clone(p))
			end
		end)
	end,
	info = function(self, t)
		return ([[When you kill a creature, all the poisons affecting it will have a %d%% chance to spread to foes in a radius of %d.]]):format(20 + self:getTalentLevelRaw(t) * 8, t.getRadius(self, t))
	end,
}

newTalent{
	name = "Vile Poisons",
	type = {"cunning/poisons", 3},
	points = 5,
	mode = "passive",
	require = cuns_req3,
	on_learn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 1 then
			self.vile_poisons = {}
			self:learnTalent(self.T_NUMBING_POISON, true, nil, {no_unlearn=true})
		elseif lev == 2 then
			self:learnTalent(self.T_INSIDIOUS_POISON, true, nil, {no_unlearn=true})
		elseif lev == 3 then
			self:learnTalent(self.T_CRIPPLING_POISON, true, nil, {no_unlearn=true})
		elseif lev == 4 then
			self:learnTalent(self.T_LEECHING_POISON, true, nil, {no_unlearn=true})
		elseif lev == 5 then
			self:learnTalent(self.T_VOLATILE_POISON, true, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 0 then
			self:unlearnTalent(self.T_NUMBING_POISON)
			self.vile_poisons = nil
		elseif lev == 1 then
			self:unlearnTalent(self.T_INSIDIOUS_POISON)
		elseif lev == 2 then
			self:unlearnTalent(self.T_CRIPPLING_POISON)
		elseif lev == 3 then
			self:unlearnTalent(self.T_LEECHING_POISON)
		elseif lev == 4 then
			self:unlearnTalent(self.T_VOLATILE_POISON)
		end
	end,
info = function(self, t)
	return ([[Learn how to enhance your Deadly Poison with new effects, causing it's standard poison to be replaced with a new effect. Each level, you will learn a new kind of poison:
	Level 1: Numbing Poison
	Level 2: Insidious Poison
	Level 3: Crippling Poison
	Level 4: Leeching Poison
	Level 5: Volatile Poison
	New poisons can also be learned from special teachers in the world.
	Also increases the effectiveness of your poisons by %d%%. (The effect varies for each poison.)
	Coating your weapons in poisons does not break stealth.
	You may only have two poisons active at once, and the one which is applied is randomly determined.]]):
	format(self:getTalentLevel(t) * 20)
end,
}

newTalent{
	name = "Venomous Strike",
	type = {"cunning/poisons", 4},
	points = 5,
	cooldown = 10,
	stamina = 14,
	require = cuns_req4,
	requires_target = true,
	on_learn = function(self, t)
		if self:knowTalent(self.T_THROWING_KNIVES) and not self:knowTalent(self.T_VENOMOUS_THROW) then
			self:learnTalent(self.T_VENOMOUS_THROW, true, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		if self:knowTalent(self.T_VENOMOUS_THROW) then
			self:unlearnTalent(self.T_VENOMOUS_THROW)
		end
	end,
	getDamage = function (self, t) return self:combatTalentWeaponDamage(t, 1.2, 2.1) end,
	getSecondaryDamage = function (self, t) return self:combatTalentStatDamage(t, "cun", 50, 550) end,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	getPower = function(self, t) return self:combatTalentLimit(t, 50, 10, 30)/100 end,
	tactical = { ATTACK = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.poison then nb = nb + 1 end
		end
		return { NATURE = nb}
	end },
--	archery_onreach = function(self, t, x, y, tg, target)
--		if not target then return end
--
--		local nb = 0
--		for eff_id, p in pairs(target.tmp) do
--			local e = target.tempeffect_def[eff_id]
--			if e.subtype.poison then nb = nb + 1 end
--		end
--		tg.archery.mult = self:combatTalentWeaponDamage(t, 0.5 + nb * 0.6, 0.9 + nb * 1)
--	end,
	speed = "weapon",
	is_melee = function(self, t) return not self:hasArcheryWeapon() end,
	range = function(self, t)
		if self:hasArcheryWeapon() then return util.getval(archery_range, self, t) end
		return 1
	end,
	action = function(self, t)

		local dam = t.getDamage(self,t)
		local idam = t.getSecondaryDamage(self,t)
		local vdam = t.getSecondaryDamage(self,t)*0.6
		local power = t.getPower(self,t)
		local heal = t.getSecondaryDamage(self,t)
		local nb = t.getNb(self,t)
		
		if not self:hasArcheryWeapon() then
			local tg = {type="hit", range=self:getTalentRange(t)}
			local x, y, target = self:getTarget(tg)
			if not target or not self:canProject(tg, x, y) then return nil end
			local hit = self:attackTarget(target, DamageType.NATURE, dam, true)
			
			if hit and self:isTalentActive(self.T_INSIDIOUS_POISON) then target:setEffect(target.EFF_POISONED, 5, {src=self, power=idam/5, no_ct_effect=true}) end		
			if hit and self:isTalentActive(self.T_NUMBING_POISON) then target:setEffect(target.EFF_SLOW, 3, {power=power, no_ct_effect=true}) end
			if hit and self:isTalentActive(self.T_CRIPPLING_POISON) then 
				local tids = {}
				for tid, lev in pairs(target.talents) do
					local t = target:getTalentFromId(tid)
					if t and not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
				end
		
				local count = 0
				local cdr = nb*1.5
		
				for i = 1, nb do
					local t = rng.tableRemove(tids)
					if not t then break end
					target.talents_cd[t.id] = cdr
					game.logSeen(target, "%s's %s is disrupted by the crippling poison!", target.name:capitalize(), t.name)
					count = count + 1
				end		
			end
			if hit and self:isTalentActive(self.T_LEECHING_POISON) then self:heal(heal, target) end
			if hit and self:isTalentActive(self.T_VOLATILE_POISON) then 
				local tg = {type="ball", radius=nb, friendlyfire=false, x=target.x, y=target.y}
				self:project(tg, target.x, target.y, DamageType.NATURE, vdam)
			end

		else
			local targets = self:archeryAcquireTargets(nil, {one_shot=true})
			if not targets then return end
			local hit = self:archeryShoot(targets, t, nil, {mult=dam, damtype=DamageType.NATURE})
			if hit and self:isTalentActive(self.T_INSIDIOUS_POISON) then target:setEffect(target.EFF_POISONED, 5, {src=self, power=idam/5, no_ct_effect=true}) end		
			if hit and self:isTalentActive(self.T_NUMBING_POISON) then target:setEffect(target.EFF_SLOW, 5, {power=power, no_ct_effect=true}) end
			if hit and self:isTalentActive(self.T_CRIPPLING_POISON) then 
				local tids = {}
				for tid, lev in pairs(target.talents) do
					local t = target:getTalentFromId(tid)
					if t and not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
				end
		
				local count = 0
				local cdr = nb*1.5
		
				for i = 1, nb do
					local t = rng.tableRemove(tids)
					if not t then break end
					target.talents_cd[t.id] = cdr
					game.logSeen(target, "%s's %s is disrupted by the crippling poison!", target.name:capitalize(), t.name)
					count = count + 1
				end		
			end
			if hit and self:isTalentActive(self.T_LEECHING_POISON) then self:heal(heal, target) end
			if hit and self:isTalentActive(self.T_VOLATILE_POISON) then 
				local tg = {type="ball", radius=nb, friendlyfire=false, x=target.x, y=target.y}
				self:project(tg, target.x, target.y, DamageType.NATURE, vdam)
			end
		end
		
		self.talents_cd[self.T_VENOMOUS_THROW] = 8

		return true
	end,
	info = function(self, t)
		local dam = 100 * t.getDamage(self,t)
		local idam = t.getSecondaryDamage(self,t)
		local vdam = t.getSecondaryDamage(self,t)*0.6
		local power = t.getPower(self,t)
		local heal = t.getSecondaryDamage(self,t)
		local nb = t.getNb(self,t)
		return ([[You hit your target, doing %d%% weapon damage as nature and inflicting additional effects based on your active vile poisons:
		Numbing Poison - Reduces global speed by %d%% for 5 turns.
		Insidious Poison - Deals a further %0.2f nature damage over 5 turns.
		Crippling Poison - Places %d talents on cooldown for %d turns.
		Leeching Poison - Heals you for %d.
		Volatile Poison - Deals a further %0.2f nature damage in a %d radius ball.
		If you wield a bow or sling you shoot instead, and you also learn the Venomous Throw talent which can be used with Throwing Knives talent.]]):
		format(dam, power*100, damDesc(self, DamageType.NATURE, idam), nb, nb*1.5, heal, damDesc(self, DamageType.NATURE, vdam), nb, nb)
	end,
}

----------------------------------------------------------------
-- Poisons effects
----------------------------------------------------------------

local function checkChance(self, target)
	local chance = 20 + self:getTalentLevel(self.T_VILE_POISONS) * 5
	local nb = 1
	for eff_id, p in pairs(target.tmp) do
		local e = target.tempeffect_def[eff_id]
		if e.subtype.poison then nb = nb + 1 end
	end
	return rng.percent(chance / nb)
end

local function cancelPoisons(self)
	local todel = {}
	for tid, p in pairs(self.sustain_talents) do
		local t = self:getTalentFromId(tid)
		if t.type[1] == "cunning/poisons-effects" then
			todel[#todel+1] = tid
		end
	end
	while #todel > 1 do self:forceUseTalent(rng.tableRemove(todel), {ignore_energy=true}) end
end

newTalent{
	name = "Numbing Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	no_unlearn_last = true,
	getEffect = function(self, t) return self:combatTalentLimit(self:getTalentLevel(self.T_VILE_POISONS), 100, 13, 25) end, -- Limit effect to <100%
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
	return ([[Enhances your Deadly Poison with a numbing agent, causing the poison to reduce all damage the target deals by %d%%.]]):
	format(t.getEffect(self, t))
	end,
}

newTalent{
	name = "Insidious Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	no_unlearn_last = true,
	getEffect = function(self, t) return self:combatTalentLimit(self:getTalentLevel(self.T_VILE_POISONS), 100, 35.5, 57.5) end, -- Limit -healing effect to <100%
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
	return ([[Enhances your Deadly Poison with an insidious agent, causing it to reduce the healing taken by enemies by %d%%.]]):
	format(t.getEffect(self, t))
	end	
}

newTalent{
	name = "Crippling Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	no_unlearn_last = true,
	getEffect = function(self, t) return self:combatTalentLimit(self:getTalentLevel(self.T_VILE_POISONS), 50, 13, 25) end, --	Limit effect to < 50%
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
	return ([[Enhances your Deadly Poison with a crippling agent, giving enemies a %d%% chance on using a talent to fail and lose a turn.]]):
	format(t.getEffect(self, t))
	end,
}

newTalent{
	name = "Leeching Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	no_unlearn_last = true,
	getEffect = function(self, t) return self:combatTalentLimit(self:getTalentLevel(self.T_VILE_POISONS), 15, 2, 8) end, 
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
	return ([[Enhances your Deadly Poison with a leeching agent, causing all damage you deal to targets affected by your deadly poison to heal you for %d%%.]]):
	format(t.getEffect(self, t))
	end,
}

newTalent{
	name = "Volatile Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	no_unlearn_last = true,
	getEffect = function(self, t) return self:combatTalentLimit(self:getTalentLevel(self.T_VILE_POISONS), 100, 15, 50) end, --	Limit effect to < 100%
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
	return ([[Enhances your Deadly Poison with a volatile agent, causing the poison to deal %d%% increased damage and damage all adjacent enemies.]]):
	format(t.getEffect(self, t))
	end,
}

newTalent{
	name = "Vulnerability Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "passive",
	no_unlearn_last = true,
	getDamage = function(self, t) return 10 + self:getCun() end,
	info = function(self, t)
	return ([[Whenever you apply deadly poison you also apply a magical poison dealing %0.2f arcane damage each turn. Those affected by the poison take 10%% increased damage and have their poison resistance reduced by 50%%.]]):
	format(damDesc(self, DamageType.ARCANE, t.getDamage(self,t)))
	end,
}

newTalent{
	name = "Stoning Poison",
	type = {"cunning/poisons-effects", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_break_stealth = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	no_unlearn_last = true,
	getDuration = function(self, t) return math.ceil(self:combatTalentLimit(self:getTalentLevel(self.T_VILE_POISONS), 0, 11, 7)) end, -- Make sure it takes at least 1 turn
	getDOT = function(self, t) return 8 + self:combatTalentStatDamage(self.T_VILE_POISONS, "cun", 10, 30) * 0.4 end,
	getEffect = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_VILE_POISONS), 3, 5)) end,
	proc = function(self, t, target)
		if not checkChance(self, target) then return end
		if target:hasEffect(target.EFF_STONED) or target:hasEffect(target.EFF_STONE_POISON) then return end
		target:setEffect(target.EFF_STONE_POISON, t.getDuration(self, t), {src=self, power=t.getDOT(self, t), stone=t.getEffect(self, t)})
	end,
	activate = function(self, t)
		cancelPoisons(self)
		self.vile_poisons = self.vile_poisons or {}
		self.vile_poisons[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.vile_poisons[t.id] = nil
		return true
	end,
	info = function(self, t)
		return ([[Coat your weapons with a stoning poison, inflicting %d nature damage per turn for %d turns.
		When the poison runs its full duration, the victim will turn to stone for %d turns.
		The damage scales with your Cunning.]]):
		format(damDesc(self, DamageType.NATURE, t.getDOT(self, t)), t.getDuration(self, t), t.getEffect(self, t))
	end,
}