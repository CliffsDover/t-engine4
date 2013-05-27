-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

local Object = require "engine.Object"

newTalent{
	name = "Stone Skin",
	type = {"spell/earth", 1},
	mode = "sustained",
	require = spells_req1,
	points = 5,
	sustain_mana = 30,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getArmor = function(self, t) return self:combatTalentSpellDamage(t, 10, 23) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/earth")
		return {
			armor = self:addTemporaryValue("combat_armor", t.getArmor(self, t)),
			particle = self:addParticles(Particles.new("stone_skin", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("combat_armor", p.armor)
		return true
	end,
	info = function(self, t)
		local armor = t.getArmor(self, t)
		return ([[The caster's skin grows as hard as stone, granting a %d bonus to Armour.
		The bonus to Armour will increase with your Spellpower.]]):
		format(armor)
	end,
}

newTalent{
	name = "Pulverizing Auger", short_name="DIG",
	type = {"spell/earth",2},
	require = spells_req2,
	points = 5,
	mana = 15,
	cooldown = 6,
	range = function(self, t) return math.min(10, math.floor(self:combatTalentScale(t, 3, 7))) end,
	tactical = { ATTACK = {PHYSICAL = 2} },
	direct_hit = true,
	requires_target = true,
	getDigs = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 300) end,
	target = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		return tg
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		for i = 1, t.getDigs(self, t) do self:project(tg, x, y, DamageType.DIG, 1) end

		self:project(tg, x, y, DamageType.PHYSICAL, self:spellCrit(t.getDamage(self, t)), nil)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "earth_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local nb = t.getDigs(self, t)
		return ([[Fire a powerful beam of stone shaterring forces, digging out any walls in its path up to %d.
		The beam also affect any creatures in its path, dealing %0.2f physical damage to all.
		The damage will increase with your Spellpower.]]):
		format(nb, damDesc(self, DamageType.PHYSICAL, damage))
	end,
}

newTalent{
	name = "Mudslide",
        type = {"spell/earth",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 40,
	cooldown = 12,
	direct_hit = true,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 }, ESCAPE = { knockback = 1 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	requires_target = true,
	target = function(self, t) return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 250) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SPELLKNOCKBACK, {dist=4, dam=self:spellCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "mudflow", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Conjures a mudslide, dealing %0.2f physical damage in a radius of %d. Any creatures caught inside will be knocked back.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.PHYSICAL, damage), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Stone Wall",
	type = {"spell/earth",4},
	require = spells_req4,
	points = 5,
	cooldown = 40,
	mana = 50,
	range = 7,
	tactical = { ATTACKAREA = {PHYSICAL = 2}, DISABLE = 4, DEFEND = 3, PROTECT = 3, ESCAPE = 1 },
	target = function(self, t) return {type="ball", nowarning=true, selffire=false, friendlyfire=false, range=self:getTalentRange(t), radius=1, talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 250) end,
	requires_target = function(self, t) return self:getTalentLevel(t) >= 4 end,
	getDuration = function(self, t) return util.bound(2 + self:combatTalentSpellDamage(t, 5, 12), 2, 25) end,
	action = function(self, t)
		local x, y = self.x, self.y
		local tg = self:getTalentTarget(t)
		if self:getTalentLevel(t) >= 4 then
			x, y = self:getTarget(tg)
			if not x or not y then return nil end
			local _ _, _, _, x, y = self:canProject(tg, x, y)
		end

		self:project(tg, x, y, DamageType.PHYSICAL, self:spellCrit(t.getDamage(self, t)))

		for i = -1, 1 do for j = -1, 1 do if game.level.map:isBound(x + i, y + j) then
			local oe = game.level.map(x + i, y + j, Map.TERRAIN)
			if oe and not oe:attr("temporary") and not game.level.map:checkAllEntities(x + i, y + j, "block_move") and not oe.special then
				-- Ok some explanation, we make a new *OBJECT* because objects can have energy and act
				-- it stores the current terrain in "old_feat" and restores it when it expires
				-- We CAN set an object as a terrain because they are all entities

				local e = Object.new{
					old_feat = oe,
					name = "summoned wall", image = "terrain/granite_wall1.png",
					display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
					always_remember = true,
					can_pass = {pass_wall=1},
					block_move = true,
					block_sight = true,
					temporary = t.getDuration(self, t),
					x = x + i, y = y + j,
					canAct = false,
					act = function(self)
						self:useEnergy()
						self.temporary = self.temporary - 1
						if self.temporary <= 0 then
							game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
							game.level:removeEntity(self)
--							game.level.map:redisplay()
						end
					end,
					dig = function(src, x, y, old)
						game.level:removeEntity(old)
--						game.level.map:redisplay()
						return nil, old.old_feat
					end,
					summoner_gain_exp = true,
					summoner = self,
				}
				game.level:addEntity(e)
				game.level.map(x + i, y + j, Map.TERRAIN, e)
			end
		end end end

		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		return ([[Entomb yourself in a wall of stone for %d turns.
		At level 4, it becomes targetable.
		Any hostile creature caught in the radius will also suffer %0.2f physical dmage.
		Duration and damage will improve with your Spellpower.]]):
		format(duration, damDesc(self, DamageType.PHYSICAL, damage))
	end,
}
