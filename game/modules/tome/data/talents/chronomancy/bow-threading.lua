-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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

-- EDGE TODO: Particles, Timed Effect Particles

local function blade_warden(self, target)
	if self:knowTalent(self.T_BLENDED_THREADS) then self:callTalent(self.T_BLENDED_THREADS, "doBladeWarden", target) end
end

newTalent{
	name = "Threaded Arrow",
	type = {"chronomancy/bow-threading", 1},
	require = chrono_req1,
	points = 5,
	cooldown = 4,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	tactical = { ATTACK = {weapon = 2} },
	requires_target = true,
	range = archery_range,
	speed = 'archery',
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 2.2) end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "bow") then if not silent then game.logPlayer(self, "You require a bow to use this talent.") end return false end return true end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p,"archery_pass_friendly", 1)
	end,
	archery_onhit = function(self, t, target, x, y)
		game:onTickEnd(function()blade_warden(self, target)end)
	end,
	action = function(self, t)
		local swap, dam = doWardenWeaponSwap(self, t, t.getDamage(self, t), "bow")

		local targets = self:archeryAcquireTargets({type="bolt"}, {one_shot=true, infinite=true, no_energy = true})
		if not targets then if swap then doWardenWeaponSwap(self, t, nil, "blade") end return end
		self:archeryShoot(targets, t, {type="bolt"}, {mult=dam, damtype=DamageType.TEMPORAL})

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Fire a shot doing %d%% temporal damage.  This attack does not consume ammo.
		Learning this talent allows your arrows to shoot through friendly targets.]])
		:format(damage, paradox)
	end
}

newTalent{
	name = "Arrow Stitching",
	type = {"chronomancy/bow-threading", 2},
	require = chrono_req2,
	points = 5,
	cooldown = 6,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	tactical = { ATTACK = {weapon = 4} },
	requires_target = true,
	range = archery_range,
	speed = 'archery',
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getClones = function(self, t) return self:getTalentLevel(t) >= 5 and 3 or self:getTalentLevel(t) >= 3 and 2 or 1 end,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, friendlyblock=false}
	end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "bow") then if not silent then game.logPlayer(self, "You require a bow to use this talent.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		game:onTickEnd(function()blade_warden(self, target)end)
	end,
	action = function(self, t)
		local swap, dam = doWardenWeaponSwap(self, t, t.getDamage(self, t), "bow")
		
		-- Grab our target so we can spawn clones
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then if swap == true then doWardenWeaponSwap(self, t, nil, "blade") end return nil end
		local __, x, y = self:canProject(tg, x, y)
		
		-- Don't cheese arrow stitching through walls
		if not self:hasLOS(x, y) then
			game.logSeen(self, "You do not have line of sight.")
			return nil
		end
				
		local targets = self:archeryAcquireTargets(self:getTalentTarget(t), {one_shot=true, x=x, y=y, no_energy = true})
		if not targets then return end
		self:archeryShoot(targets, t, {type="bolt", friendlyfire=false, friendlyblock=false}, {mult=dam})
		
		-- Summon our clones
		if not self.arrow_stitching_done then
			for i = 1, t.getClones(self, t) do
				local m = makeParadoxClone(self, self, 2)
				local poss = {}
				local range = self:getTalentRange(t)
				for i = x - range, x + range do
					for j = y - range, y + range do
						if game.level.map:isBound(i, j) and
							core.fov.distance(x, y, i, j) <= range and -- make sure they're within arrow range
							core.fov.distance(i, j, self.x, self.y) <= range/2 and -- try to place them close to the caster so enemies dodge less
							self:canMove(i, j) and target:hasLOS(i, j) then
							poss[#poss+1] = {i,j}
						end
					end
				end
				if #poss == 0 then break  end
				local pos = poss[rng.range(1, #poss)]
				x, y = pos[1], pos[2]
				game.zone:addEntity(game.level, m, "actor", x, y)
				m.arrow_stitched_target = target
				m.generic_damage_penalty = 50
				m.energy.value = 1000
				m:attr("archery_pass_friendly", 1)
				m.on_act = function(self)
					if not self.arrow_stitched_target.dead then
						self.arrow_stitching_done = true
						self:forceUseTalent(self.T_ARROW_STITCHING, {force_level=t.level, ignore_cd=true, ignore_energy=true, force_target=self.arrow_stitched_target, ignore_ressources=true, silent=true})
						self:useEnergy()
					end
					game:onTickEnd(function()self:die()end)
					game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
				end
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local clones = t.getClones(self, t)
		return ([[Fire upon the target for %d%% damage and call up to %d wardens (depending on available space) that will each fire a single shot before returning to their timelines.
		The wardens are out of phase with normal reality and deal 50%% damage but shoot through friendly targets.
		At talent level three and five you can summon an additional clone.]])
		:format(damage, clones)
	end
}

newTalent{
	name = "Singularity Arrow",
	type = {"chronomancy/bow-threading", 3},
	require = chrono_req3,
	points = 5,
	cooldown = 10,
	paradox = function (self, t) return getParadoxCost(self, t, 15) end,
	tactical = { ATTACKAREA = {PHYSICAL = 2}, DISABLE = 2 },
	requires_target = true,
	range = archery_range,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.7)) end,
	speed = 'archery',
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getDamageAoE = function(self, t) return self:combatTalentSpellDamage(t, 25, 290, getParadoxSpellpower(self, t)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, friendlyfire=false}
	end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "bow") then if not silent then game.logPlayer(self, "You require a bow to use this talent.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		game:onTickEnd(function()blade_warden(self, target)end)
	end,
	archery_onreach = function(self, t, x, y)
		game:onTickEnd(function() -- Let the arrow hit first
			local tg = self:getTalentTarget(t)
			if not x or not y then return nil end
			local _ _, _, _, x, y = self:canProject(tg, x, y)
			
			local tgts = {}
			self:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and not target:isTalentActive(target.T_GRAVITY_LOCUS) then
					-- If we've already moved this target don't move it again
					for _, v in pairs(tgts) do
						if v == target then
							return
						end
					end

					-- Do our Knockback
					local can = function(target)
						if target:checkHit(getParadoxSpellpower(self, t), target:combatPhysicalResist(), 0, 95) and target:canBe("knockback") then -- Deprecated Checkhit call
							return true
						else
							game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
						end
					end
					if can(target) then
						target:pull(x, y, tg.radius, can)
						tgts[#tgts+1] = target
						game.logSeen(target, "%s is drawn in by the singularity!", target.name:capitalize())
						target:crossTierEffect(target.EFF_OFFBALANCE, getParadoxSpellpower(self, t))
					end
				end
			end)
			
			-- 25% bonus damage per target beyond the first
			local dam = self:spellCrit(t.getDamageAoE(self, t))
			dam = dam + math.min(dam, dam*(#tgts-1)/4)
			
			-- Project our damage last based on number of targets hit
			self:project(tg, x, y, function(px, py)
				local dist_factor = 1 + (core.fov.distance(x, y, px, py)/5)
				local damage = dam/dist_factor
				DamageType:get(DamageType.GRAVITY).projector(self, px, py, DamageType.GRAVITY, damage)
			end)

			game.level.map:particleEmitter(x, y, tg.radius, "gravity_spike", {radius=tg.radius, allow=core.shader.allow("distort")})

			game:playSoundNear(self, "talents/earth")
		end)
	end,
	action = function(self, t)
		local swap, dam = doWardenWeaponSwap(self, t, t.getDamage(self, t), "bow")
		
		-- Pull x, y from getTarget and pass it so we can show the player the area of effect
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then if swap == true then doWardenWeaponSwap(self, t, nil, "blade") end return nil end
		
		tg.type = "bolt" -- switch our targeting back to a bolt

		local targets = self:archeryAcquireTargets(tg, {one_shot=true, x=x, y=y, no_energy = true})
		if not targets then return end
		self:archeryShoot(targets, t, {type="bolt"}, {mult=dam})

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local radius = self:getTalentRadius(t)
		local aoe = t.getDamageAoE(self, t)
		return ([[Fire an arrow for %d%% weapon damage.  When the arrow reaches its destination it will draw in enemies in a radius of %d and inflict %0.2f physical damage.
		Each target moved beyond the first deals an additional %0.2f physical damage (up to %0.2f bonus damage).
		Targets take reduced damage the further they are from the epicenter (20%% less per tile).
		The additional damage scales with your Spellpower.]])
		:format(damage, radius, damDesc(self, DamageType.PHYSICAL, aoe), damDesc(self, DamageType.PHYSICAL, aoe/4), damDesc(self, DamageType.PHYSICAL, aoe))
	end
}

newTalent{
	name = "Arrow Echoes",
	type = {"chronomancy/bow-threading", 4},
	require = chrono_req4,
	points = 5,
	cooldown = 12,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	tactical = { ATTACK = {weapon = 4} },
	requires_target = true,
	range = archery_range,
	speed = 'archery',
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, friendlyblock=false}
	end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 2, 4))) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	archery_onhit = function(self, t, target, x, y)
		game:onTickEnd(function() blade_warden(self, target) end)
	end,
	doEcho = function(self, t, eff)
		game:onTickEnd(function()
			local target = eff.target
			local targets = self:archeryAcquireTargets({type="bolt"}, {one_shot=true, x=target.x, y=target.y, infinite=true, no_energy = true})
			if not targets then return end
			self:archeryShoot(targets, t, {type="bolt", start_x=eff.x, start_y=eff.y}, {mult=t.getDamage(self, t)})
			eff.shots = eff.shots - 1
		end)
	end,
	action = function(self, t)
		local swap, dam = doWardenWeaponSwap(self, t, t.getDamage(self, t), "bow")
		
		-- Grab our target so we can set our echo
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then if swap == true then doWardenWeaponSwap(self, t, nil, "blade") end return nil end
		local __, x, y = self:canProject(tg, x, y)
		
		-- Sanity check
		if not self:hasLOS(x, y) then
			game.logSeen(self, "You do not have line of sight.")
			return nil
		end
		
		self:setEffect(self.EFF_ARROW_ECHOES, t.getDuration(self, t), {shots=t.getDuration(self, t), x=self.x, y=self.y, target=target})
		
		local targets = self:archeryAcquireTargets(self:getTalentTarget(t), {one_shot=true, x=x, y=y, no_energy=true})
		if not targets then return end
		self:archeryShoot(targets, t, {type="bolt"}, {mult=dam})
		
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Fire an arrow for %d%% weapon damage at the target.  Over the next %d turns you'll fire up to %d additional arrows at this target from your original location.
		These echoed shots do not consume ammo.]])
		:format(damage, duration, duration)
	end
}