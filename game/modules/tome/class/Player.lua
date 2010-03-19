require "engine.class"
require "mod.class.Actor"
require "engine.interface.PlayerRest"
require "engine.interface.PlayerRun"
require "engine.interface.PlayerHotkeys"
require "engine.interface.PlayerSlide"
local Map = require "engine.Map"
local Dialog = require "engine.Dialog"
local ActorTalents = require "engine.interface.ActorTalents"
local LevelupStatsDialog = require "mod.dialogs.LevelupStatsDialog"
local LevelupTalentsDialog = require "mod.dialogs.LevelupTalentsDialog"
local DeathDialog = require "mod.dialogs.DeathDialog"

--- Defines the player for ToME
-- It is a normal actor, with some redefined methods to handle user interaction.<br/>
-- It is also able to run and rest and use hotkeys
module(..., package.seeall, class.inherit(
	mod.class.Actor,
	engine.interface.PlayerRest,
	engine.interface.PlayerRun,
	engine.interface.PlayerHotkeys,
	engine.interface.PlayerSlide
))

function _M:init(t, no_default)
	t.body = {
		INVEN = 1000,
		MAINHAND = 1,
		OFFHAND = 1,
		FINGER = 2,
		NECK = 1,
		LITE = 1,
		BODY = 1,
		HEAD = 1,
		HANDS = 1,
		FEET = 1,
		TOOL = 1,
	}
	mod.class.Actor.init(self, t, no_default)
	engine.interface.PlayerHotkeys.init(self, t)
	self.player = true
	self.type = "humanoid"
	self.subtype = "player"
	self.faction = "players"

	self.display='@'
	self.color_r=230
	self.color_g=230
	self.color_b=230
--	self.image="player.png"

	self.fixed_rating = true

	self.max_life=150
	self.max_mana=85
	self.max_stamina=85
	self.unused_stats = 6
	self.unused_talents = 2
	self.move_others=true

	self.lite = 0

	self.descriptor = {}
end

function _M:move(x, y, force)
--	x, y = self:tryPlayerSlide(x, y, force)

	local moved = mod.class.Actor.move(self, x, y, force)
	if moved then
		game.level.map:moveViewSurround(self.x, self.y, 8, 8)

		local obj = game.level.map:getObject(self.x, self.y, 1)
		if obj and game.level.map:getObject(self.x, self.y, 2) then
			game.logSeen(self, "There is more than one objects lying here.")
		elseif obj then
			game.logSeen(self, "There is an item here: %s", obj:getName{do_color=true})
		end
	end

	-- Update wilderness coords
	if game.zone.short_name == "wilderness" then
		self.wild_x, self.wild_y = self.x, self.y
	end

	return moved
end

function _M:act()
	if not mod.class.Actor.act(self) then return end

	-- Clean log flasher
	game.flash:empty()

	-- Resting ? Running ? Otherwise pause
	if not self:restStep() and not self:runStep() then
		game.paused = true
	end
end

--- Called before taking a hit, overload mod.class.Actor:onTakeHit() to stop resting and running
function _M:onTakeHit(value, src)
	self:runStop("taken damage")
	self:restStop("taken damage")
	local ret = mod.class.Actor.onTakeHit(self, value, src)
	if self.life < self.max_life * 0.3 then
		local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
		game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, 2, "LOW HEALTH!", {255,0,0}, true)
	end
	return ret
end

function _M:die()
	game.paused = true
	game:registerDialog(DeathDialog.new(self))
end

function _M:setName(name)
	self.name = name
	game.save_name = name
end

--- Notify the player of available cooldowns
function _M:onTalentCooledDown(tid)
	local t = self:getTalentFromId(tid)

	local x, y = game.level.map:getTileToScreen(self.x, self.y)
	game.flyers:add(x, y, 30, -0.3, -3.5, ("%s available"):format(t.name:capitalize()), {0,255,00})
	game.log("#00ff00#Talent %s is ready to use.", t.name)
end

function _M:levelup()
	mod.class.Actor.levelup(self)

	local x, y = game.level.map:getTileToScreen(self.x, self.y)
	game.flyers:add(x, y, 80, 0.5, -2, "LEVEL UP!", {0,255,255})
	game.log("#00ffff#Welcome to level %d.", self.level)
	if self.unused_stats > 0 then game.log("You have %d stat point(s) to spend. Press G to use them.", self.unused_stats) end
	if self.unused_talents > 0 then game.log("You have %d talent point(s) to spend. Press G to use them.", self.unused_talents) end
	if self.unused_talents_types > 0 then game.log("You have %d talent category point(s) to spend. Press G to use them.", self.unused_talents_types) end
end

--- Tries to get a target from the user
-- *WARNING* If used inside a coroutine it will yield and resume it later when a target is found.
-- This is usualy just what you want so dont think too much about it :)
function _M:getTarget(typ)
	if coroutine.running() then
		local msg
		if type(typ) == "string" then msg, typ = typ, nil
		elseif type(typ) == "table" then
			if typ.default_target then game.target.target.entity = typ.default_target end
			msg = typ.msg
		end
		game:targetMode("exclusive", msg, coroutine.running(), typ)
		if typ.nolock then
			game.target_style = "free"
		end
		return coroutine.yield()
	end
	return game.target.target.x, game.target.target.y, game.target.target.entity
end

--- Sets the current target
function _M:setTarget(target)
	game.target.target.entity = target
	game.target.target.x = target.x
	game.target.target.y = target.y
end

local function spotHostiles(self)
	local seen = false
	-- Check for visible monsters, only see LOS actors, so telepathy wont prevent resting
	core.fov.calc_circle(self.x, self.y, 20, function(_, x, y) game.level.map:opaque(x, y) end, function(_, x, y)
		local actor = game.level.map(x, y, game.level.map.ACTOR)
		if actor and self:reactionToward(actor) < 0 and self:canSee(actor) and game.level.map.seens(x, y) then seen = true end
	end, nil)
	return seen
end

--- Can we continue resting ?
-- We can rest if no hostiles are in sight, and if we need life/mana/stamina (and their regen rates allows them to fully regen)
function _M:restCheck()
	if spotHostiles(self) then return false, "hostile spotted" end

	-- Check ressources, make sure they CAN go up, otherwise we will never stop
	if self:getMana() < self:getMaxMana() and self.mana_regen > 0 then return true end
	if self:getStamina() < self:getMaxStamina() and self.stamina_regen > 0 then return true end
	if self.life < self.max_life and self.life_regen> 0 then return true end

	return false, "all resources and life at maximun"
end

--- Can we continue running?
-- We can run if no hostiles are in sight, and if we no interresting terrains are next to us
function _M:runCheck()
	if spotHostiles(self) then return false, "hostile spotted" end

	-- Notice any noticable terrain
	local noticed = false
	self:runScan(function(x, y)
		-- Only notice interresting terrains
		local grid = game.level.map(x, y, Map.TERRAIN)
		if grid and grid.notice then noticed = "interesting terrain" end

		-- Objects are always interresting
		local obj = game.level.map:getObject(x, y, 1)
		if obj then noticed = "object seen" end

		-- Traps are always interresting if known
		local trap = game.level.map(x, y, Map.TRAP)
		if trap and trap:knownBy(self) then noticed = "trap spotted" end
	end)
	if noticed then return false, noticed end

	return engine.interface.PlayerRun.runCheck(self)
end

function _M:doDrop(inven, item)
	if game.zone.short_name == "wilderness" then game.logPlayer(self, "You can not drop on the world map.") return end
	self:dropFloor(inven, item, true, true)
	self:sortInven()
	self:useEnergy()
	self.changed = true
end

function _M:doWear(inven, item, o)
	self:removeObject(self.INVEN_INVEN, item, true)
	local ro = self:wearObject(o, true, true)
	if ro then
		if type(ro) == "table" then self:addObject(self.INVEN_INVEN, ro) end
	else
		self:addObject(self.INVEN_INVEN, o)
	end
	self:sortInven()
	self:useEnergy()
	self.changed = true
end

function _M:doTakeoff(inven, item, o)
	if self:takeoffObject(inven, item) then
		self:addObject(self.INVEN_INVEN, o)
	end
	self:sortInven()
	self:useEnergy()
	self.changed = true
end

function _M:playerPickup()
	-- If 2 or more objects, display a pickup dialog, otehrwise just picks up
	if game.level.map:getObject(self.x, self.y, 2) then
		self:showPickupFloor(nil, nil, function(o, item)
			self:pickupFloor(item, true)
			self:sortInven()
			self.changed = true
		end)
	else
		self:pickupFloor(1, true)
		self:sortInven()
		self:useEnergy()
	self.changed = true
	end
end

function _M:playerDrop()
	local inven = self:getInven(self.INVEN_INVEN)
	self:showInventory("Drop object", inven, nil, function(o, item)
		self:doDrop(inven, item)
	end)
end

function _M:playerWear()
	local inven = self:getInven(self.INVEN_INVEN)
	self:showInventory("Wield/wear object", inven, function(o)
		return o:wornInven() and true or false
	end, function(o, item)
		self:doWear(inven, item, o)
	end)
end

function _M:playerTakeoff()
	self:showEquipment("Take off object", nil, function(o, inven, item)
		self:doTakeoff(inven, item, o)
	end)
end

function _M:playerUseItem(object, item)
	if game.zone.short_name == "wilderness" then game.logPlayer(self, "You can not use items on the world map.") return end

	local use_fct = function(o, item)
		self.changed = true
		local ret, no_id = o:use(self)
		if not no_id then
			o:identify(true)
		end
		if ret and ret == "destroy" then
			if o.multicharge and o.multicharge > 1 then
				o.multicharge = o.multicharge - 1
			else
				self:removeObject(self:getInven(self.INVEN_INVEN), item)
				game.log("You have no more %s", o:getName{no_count=true, do_color=true})
				self:sortInven()
			end
		end
		self:breakStealth()
		self.changed = true
	end

	if object and item then return use_fct(object, item) end

	self:showInventory(nil, self:getInven(self.INVEN_INVEN),
		function(o)
			return o:canUseObject()
		end,
		use_fct,
		true
	)
end

function _M:playerLevelup(on_finish)
	if self.unused_stats > 0 then
		local ds = LevelupStatsDialog.new(self, on_finish)
		game:registerDialog(ds)
	else
		local dt = LevelupTalentsDialog.new(self, on_finish)
		game:registerDialog(dt)
	end
end


------ Quest Events
function _M:on_quest_grant(quest)
	game.logPlayer(self, "#LIGHT_GREEN#Accepted quest '%s'! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
end

function _M:on_quest_status(quest, status, sub)
	if sub then
		game.logPlayer(self, "#LIGHT_GREEN#Quest '%s' status updated! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
	elseif status == engine.Quest.COMPLETED then
		game.logPlayer(self, "#LIGHT_GREEN#Quest '%s' completed! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
	elseif status == engine.Quest.DONE then
		game.logPlayer(self, "#LIGHT_GREEN#Quest '%s' is done! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
	elseif status == engine.Quest.FAILED then
		game.logPlayer(self, "#LIGHT_RED#Quest '%s' is failed! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
	end
end
