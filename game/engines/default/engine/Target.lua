-- TE4 - T-Engine 4
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

require "engine.class"
local Map = require "engine.Map"
local Shader = require "engine.Shader"

--- handles targetting
-- @classmod engine.Target
module(..., package.seeall, class.make)

_M.defaults = {}

function _M:init(map, source_actor)
	self.display_x, self.display_y = map.display_x, map.display_y
	self.w, self.h = map.viewport.width, map.viewport.height
	self.tile_w, self.tile_h = map.tile_w, map.tile_h
	self.active = false
	self.target_type = {}
	self.cursor_rotate = 0

	self.source_actor = source_actor

	-- Setup the tracking target table
	-- Notice its values are set to weak references, this has no effects on the number for x and y
	-- but it means if the entity field is set to an entity, when it disappears this link wont prevent
	-- the garbage collection
	self.target = {x=self.source_actor.x, y=self.source_actor.y, entity=nil}
--	setmetatable(self.target, {__mode='v'})


	self.renderer = core.renderer.renderer("static"):setRendererName("Targetting System") -- The prime renderer

	self.fbo = core.renderer.target() -- The fbo into which we draw the targetting quads
	self.fbo:displaySize(Map.viewport.width, Map.viewport.height)
	
	self.fborenderer = core.renderer.renderer("stream") -- The renderer used to draw into the fbo
	self.fbo:setAutoRender(self.fborenderer)

	self.renderer:add(self.fbo)

	-- Targetting retina
	self.cursor = core.renderer.surface(engine.Tiles:loadImage("target_cursor.png"), -self.tile_w/2, -self.tile_h/2, self.tile_w, self.tile_h)
	self.renderer:add(self.cursor)

	-- Zone layer will contain the constantly updated affected layer
	self.zone_layer = core.renderer.vertexes()
	self.fborenderer:add(self.zone_layer)

	-- The 8 directions arrows
	self.arrows_layer = core.renderer.container()
	local a = core.renderer.surface(engine.Tiles:loadImage("target_arrow.png"), -self.tile_w * Map.zoom/2, -self.tile_h * Map.zoom/2, self.tile_w * Map.zoom, self.tile_h * Map.zoom)
	self.arrow = {}
	for dir, spot in pairs(util.adjacentCoords(0, 0)) do self.arrow[dir] = a:clone() self.arrows_layer:add(self.arrow[dir]) end
	self.renderer:add(self.arrows_layer)
	-- self.renderer:countTime(true)

	self.zone_layer:texture(core.renderer.plaincolor)

	-- Create the colors we will use
	self:defineColors()
end

function _M:defineColors()
	self.sr = colors.smart1{255, 0, 0, self.fbo_shader and 150 or 90}
	self.sb = colors.smart1{0, 0, 255, self.fbo_shader and 150 or 90}
	self.sg = colors.smart1{0, 255, 0, self.fbo_shader and 150 or 90}
	self.sy = colors.smart1{255, 255, 0, self.fbo_shader and 150 or 90}
	self.syg = colors.smart1{153, 204, 50, self.fbo_shader and 150 or 90}
end

function _M:enableFBORenderer(texture, shader)
	if shader then self.fbo_shader = Shader.new(shader) else self.fbo_shader = nil end

	if not self.fbo_shader then
		self.fbo:shader(nil)
		self:defineColors()
		return
	end
	self.fbo_shader.shad:uniTileSize(self.tile_w, self.tile_h)
	self.fbo_shader.shad:uniMapCoord(Map.viewport.width, Map.viewport.height)
	self.fbo_shader.shad:uniScrollOffset(0, 0)

	self.quad_texture = engine.Tiles:loadImage(texture):glTexture()
	self.fbo:shader(self.fbo_shader)
	self.fbo:texture(self.quad_texture, 1)

	self:defineColors()
end

-- Being completely blocked by the corner of an adjacent tile is annoying, so let's make it a special case and hit it instead.
_M.defaults.display_blocked_by_adjacent = function(self, d)
	if d.blocked_corner_x then
		d.block = true
		d.hit = true
		d.hit_radius = false
		stopped = true
		if self.target_type.min_range and core.fov.distance(self.target_type.start_x, self.target_type.start_y, d.lx, d.ly) < self.target_type.min_range then
			d.s = self.sr
		end
		if game.level.map:isBound(d.blocked_corner_x, d.blocked_corner_y) then
			d.display_highlight(d.s, d.blocked_corner_x, d.blocked_corner_y)
		end
		d.s = self.sr
	end
end

_M.defaults.display_check_block_path = function(self, d)
	d.block, d.hit, d.hit_radius = false, true, true
	d.block, d.hit, d.hit_radius = self.target_type:block_path(d.lx, d.ly, true)
end

-- Update coordinates and set color
_M.defaults.display_update_hit = function(self, d)
	if d.hit then
		d.stop_x, d.stop_y = d.lx, d.ly
		if not d.block and d.hit == "unknown" then d.s = self.sy end
	else
		d.s = self.sr
	end
end

_M.defaults.display_update_radius = function(self, d)
	if d.hit_radius then
		d.stop_radius_x, d.stop_radius_y = d.lx, d.ly
	end
end

_M.defaults.display_update_min_range = function(self, d)
	if self.target_type.min_range then
		-- Check if we should be "red"
		if core.fov.distance(self.target_type.start_x, self.target_type.start_y, d.lx, d.ly) < self.target_type.min_range then
			d.s = self.sr
		-- Check if we were only "red" because of minimum distance
		elseif d.s == self.sr then
			d.s = self.sb
		end
	end
end

_M.defaults.display_line_step = function(self, d)
	d.display_highlight(d.s, d.lx, d.ly)
end

_M.defaults.display_on_block = function(self, d)
	d.s = self.sr
	d.stopped = true
end

_M.defaults.display_on_block_corner = function(self, d)
	d.block = true
	d.stopped = true
	d.hit_radius = false
	d.s = self.sr
	-- double the fun :-P
	if game.level.map:isBound(d.blocked_corner_x, d.blocked_corner_y) then
		if self.target_type.display_corner_block then
			self.target_type.display_corner_block(self, d)
		else
			d.display_highlight(d.s, d.blocked_corner_x, d.blocked_corner_y, 2)
		end
	end
end

_M.defaults.display_default_target = function(self, d)
	-- Entity tracking, if possible and if visible
	if self.target.entity and self.target.entity.x and self.target.entity.y and game.level.map.seens(self.target.entity.x, self.target.entity.y) then
		self.target.x, self.target.y = self.target.entity.x, self.target.entity.y
	end
	self.target.x = self.target.x or self.source_actor.x
	self.target.y = self.target.y or self.source_actor.y
end

function _M:display(dispx, dispy, prevfbo, rotate_keyframes)
	local ox, oy = self.display_x, self.display_y
	local sx, sy = game.level.map._map:getScroll()
	sx = sx + game.level.map.display_x
	sy = sy + game.level.map.display_y
	self.display_x, self.display_y = dispx or sx or self.display_x, dispy or sy or self.display_y

	if self.active then
		self:realDisplay(self.display_x, self.display_y)
		self.renderer:toScreen(self.display_x, self.display_y)
	end

	self.display_x, self.display_y = ox, oy
end

function _M:realDisplay(dispx, dispy, display_highlight)
	self.zone_layer:clear()

	if not display_highlight then
		if util.isHex() then
			-- DGDGDGDG
			-- display_highlight = function(texture, tx, ty, count)
			-- 	count = count or 1
			-- 	if self.target_type.filter and not self.target_type.no_filter_highlight and self.target_type.filter(tx, ty) then count = count + 1 end
			-- 	for i = 1, count do
			-- 		texture:toScreenHighlightHex(
			-- 			dispx + (tx - game.level.map.mx) * self.tile_w * Map.zoom,
			-- 			dispy + (ty - game.level.map.my + util.hexOffset(tx)) * self.tile_h * Map.zoom,
			-- 			self.tile_w * Map.zoom,
			-- 			self.tile_h * Map.zoom)
			-- 	end
			-- end
		else
			display_highlight = function(color, tx, ty, count)
				count = count or 1
				if self.target_type.filter and not self.target_type.no_filter_highlight and self.target_type.filter(tx, ty) then count = count + 1 end
				for i = 1, count do
					local x1 = dispx + (tx - game.level.map.mx) * self.tile_w * Map.zoom
					local y1 = dispy + (ty - game.level.map.my) * self.tile_h * Map.zoom
					local x2 = x1 + self.tile_w * Map.zoom
					local y2 = y1 + self.tile_h * Map.zoom
					self.zone_layer:quad(
						x1, y1, 0, 0,
						x2, y1, 1, 0,
						x2, y2, 1, 1,
						x1, y2, 0, 1,
						unpack(color)
					)

					-- texture:toScreen(
					-- 	dispx + (tx - game.level.map.mx) * self.tile_w * Map.zoom,
					-- 	dispy + (ty - game.level.map.my) * self.tile_h * Map.zoom,
					-- 	self.tile_w * Map.zoom,
					-- 	self.tile_h * Map.zoom)
				end
			end
		end
	end

	-- DGDGDGDG oh my .. multitarget !! !
	-- if self.target_type.multiple then
	-- 	local make_display_highlight = function(collector)
	-- 		return function(texture, tx, ty, count)
	-- 			count = count or 1
	-- 			collector[tx] = collector[tx] or {}
	-- 			collector[tx][ty] = {texture, count}
	-- 		end
	-- 	end
	-- 	local draw_highlight = function(collector)
	-- 		for x, ys in pairs(collector) do
	-- 			for y, tex in pairs(ys) do
	-- 				display_highlight(tex[1], x, y, tex[2])
	-- 			end
	-- 		end
	-- 	end

	-- 	local target_type = self.target_type

	-- 	local textures = {}
	-- 	local sub_display_highlight = make_display_highlight(textures)
	-- 	for _, tt in ipairs(target_type) do
	-- 		self.target_type = tt
	-- 		self:realDisplay(dispx, dispy, sub_display_highlight)
	-- 	end
	-- 	draw_highlight(textures)

	-- 	self.target_type = target_type
	-- 	return
	-- end

	local d = {}
	d.display_highlight = display_highlight

	-- Make sure we have a source
	if not self.target_type.source_actor then
		self.target_type.source_actor = self.source_actor
	end

	-- Pick default target
	self.target_type.display_default_target(self, d)

	self.target_type.start_x = self.target_type.start_x or self.target_type.x or self.target_type.source_actor and self.target_type.source_actor.x or self.x
	self.target_type.start_y = self.target_type.start_y or self.target_type.y or self.target_type.source_actor and self.target_type.source_actor.y or self.y

--	self.cursor:toScreen(dispx + (self.target.x - game.level.map.mx) * self.tile_w * Map.zoom, dispy + (self.target.y - game.level.map.my) * self.tile_h * Map.zoom, self.tile_w * Map.zoom, self.tile_h * Map.zoom)

	d.s = self.sb
	if self.target_type.source_actor.lineFOV then
		d.l = self.target_type.source_actor:lineFOV(self.target.x, self.target.y, nil, nil, self.target_type.start_x, self.target_type.start_y)
	else
		d.l = core.fov.line(self.target_type.start_x, self.target_type.start_y, self.target.x, self.target.y)
	end
	local block_corner = self.target_type.block_path and function(_, bx, by) local b, h, hr = self.target_type:block_path(bx, by, true) ; return b and h and not hr end
		or function(_, bx, by) return false end

	d.l:set_corner_block(block_corner)
	d.lx, d.ly, d.blocked_corner_x, d.blocked_corner_y = d.l:step()

	d.stop_x, d.stop_y = self.target_type.start_x, self.target_type.start_y
	d.stop_radius_x, d.stop_radius_y = self.target_type.start_x, self.target_type.start_y
	d.stopped = false

	d.firstx, d.firsty = d.lx, d.ly

	-- Being completely blocked by the corner of an adjacent tile is annoying, so let's make it a special case and hit it instead
	self.target_type.display_blocked_by_adjacent(self, d)

	while d.lx and d.ly do
		if not d.stopped then
			self.target_type.display_check_block_path(self, d)
			-- Update coordinates and set color
			self.target_type.display_update_hit(self, d)
			self.target_type.display_update_radius(self, d)
			self.target_type.display_update_min_range(self, d)
		end

		if self.target_type.display_line_step then self.target_type.display_line_step(self, d) end

		if d.block then self.target_type.display_on_block(self, d) end

		d.lx, d.ly, d.blocked_corner_x, d.blocked_corner_y = d.l:step()

		if d.blocked_corner_x and not d.stopped then
			self.target_type.display_on_block_corner(self, d)
		end
	end

	if self.target_type.ball and self.target_type.ball > 0 then
		core.fov.calc_circle(
			d.stop_radius_x,
			d.stop_radius_y,
			game.level.map.w,
			game.level.map.h,
			self.target_type.ball,
			function(_, px, py)
				if self.target_type.block_radius and self.target_type:block_radius(px, py, true) then return true end
			end,
			function(_, px, py)
				if not self.target_type.no_restrict and not game.level.map.remembers(px, py) and not game.level.map.seens(px, py) then
					d.display_highlight(self.syg, px, py)
				else
					d.display_highlight(self.sg, px, py)
				end
			end,
			nil)
	end

	if self.target_type.cone and self.target_type.cone > 0 then
		--local dir_angle = math.deg(math.atan2(self.target.y - self.source_actor.y, self.target.x - self.source_actor.x))
		core.fov.calc_beam_any_angle(
			d.stop_radius_x,
			d.stop_radius_y,
			game.level.map.w,
			game.level.map.h,
			self.target_type.cone,
			self.target_type.cone_angle,
			self.target_type.start_x,
			self.target_type.start_y,
			self.target.x - self.target_type.start_x,
			self.target.y - self.target_type.start_y,
			function(_, px, py)
				if self.target_type.block_radius and self.target_type:block_radius(px, py, true) then return true end
			end,
			function(_, px, py)
				if not self.target_type.no_restrict and not game.level.map.remembers(px, py) and not game.level.map.seens(px, py) then
					d.display_highlight(self.syg, px, py)
				else
					d.display_highlight(self.sg, px, py)
				end
			end,
		nil)
	end

	if self.target_type.wall and self.target_type.wall > 0 then
		core.fov.calc_wall(
			d.stop_radius_x,
			d.stop_radius_y,
			game.level.map.w,
			game.level.map.h,
			self.target_type.wall,
			self.target_type.halfmax_spots,
			self.target_type.start_x,
			self.target_type.start_y,
			self.target.x - self.target_type.start_x,
			self.target.y - self.target_type.start_y,
			function(_, px, py)
				if self.target_type.block_radius and self.target_type:block_radius(px, py, true) then return true end
			end,
			function(_, px, py)
				if not self.target_type.no_restrict and not game.level.map.remembers(px, py) and not game.level.map.seens(px, py) then
					d.display_highlight(self.syg, px, py)
				else
					d.display_highlight(self.sg, px, py)
				end
			end,
		nil)
	end

	d[1] = "Target:realDisplay"
	self:triggerHook(d)

	if self.target_type.immediate_keys then
		self.arrows_layer:shown(true)
		for dir, spot in pairs(util.adjacentCoords(0, 0)) do
			local tx, ty = spot[1], spot[2]
			local x, y = tx * 2.5 / 3.5, ty * 2.5 / 3.5
			if d.firstx == self.target_type.start_x + tx and d.firsty == self.target_type.start_y + ty then x, y = tx, ty end

			local a = self.arrow[dir]
			a:translate((self.target_type.start_x - game.level.map.mx + 0.5 + x) * self.tile_w * Map.zoom, (self.target_type.start_y - game.level.map.my + 0.5 + y + util.hexOffset(x)) * self.tile_h * Map.zoom, 0)
			a:rotate(math.rad(180), 0, math.rad(90+util.dirToAngle(dir)))
		end
	else
		self.arrows_layer:shown(false)
	end

	if not self.target_type.immediate_keys or d.firstx then
		self.cursor:shown(true)
		self.cursor:translate((self.target.x - game.level.map.mx) * self.tile_w * Map.zoom + self.tile_w * Map.zoom / 2, (self.target.y - game.level.map.my + util.hexOffset(self.target.x)) * self.tile_h * Map.zoom + self.tile_h * Map.zoom / 2)
		self.cursor:rotate(0, 0, core.game.getTime() / 1600)
	else
		self.cursor:shown(false)
	end
end

--- Determine if a grid blocks projection along a path based on targeting table parameters
-- @see Target:getType(t) below
-- @param typ = updated targeting table (from Target:getType)
-- @param lx, ly = grid coordinates
-- @param for_highlights [type=boolean] grid highlighting mode for player targeting
-- @return[1] [type=boolean] grid blocks the projection
-- @return[2] [type=boolean] grid may be hit by the projection
-- @return[2] "unknown" (with for_highlights) if the grid is unknown
-- @return[3] [type=boolean] grid blocks the projection, path around not allowed (corner blocked)
_M.defaults.block_path = function(typ, lx, ly, for_highlights)
	local map = game.level.map
	if not map:isBound(lx, ly) then
		return true, false, false
	elseif not typ.no_restrict then
		if typ.range and typ.start_x then
			local dist = core.fov.distance(typ.start_x, typ.start_y, lx, ly)
			if dist > typ.range then return true, false, false end
		elseif typ.range and typ.source_actor and typ.source_actor.x then
			local dist = core.fov.distance(typ.source_actor.x, typ.source_actor.y, lx, ly)
			if dist > typ.range then return true, false, false end
		end
		local is_known = map.remembers(lx, ly) or map.seens(lx, ly)
		if typ.requires_knowledge and not is_known then
			return true, false, false
		end
		local trn_block, trn_pass
		if not typ.pass_terrain then -- check terrain
			trn_block = map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") or false
			if trn_block then 
				trn_pass = map:checkEntity(lx, ly, engine.Map.TERRAIN, "pass_projectile") or false
				if not trn_pass then -- blocked by terrain
					if for_highlights and not is_known then
						return false, "unknown", true
					else
						return true, true, false
					end
				end
			end
		end
		-- If the projection is blocked by something other than terrain, the grid should be hit
		if typ.stop_block then -- check all entities
			 -- get #blocking entities and subtract for each entity that can be explicitly passed through
			local nb = map:checkAllEntitiesCount(lx, ly, "block_move")
			if nb > 0 then -- decrement for passable terrain
				if trn_block == nil then trn_block = map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") end
				if trn_block and (typ.pass_terrain or (trn_pass == nil and map:checkEntity(lx, ly, engine.Map.TERRAIN, "pass_projectile") or trn_pass)) then
				nb = nb - 1
				end
			end
			if nb > 0 and (typ.friendlyblock ~= nil or not typ.actorblock) then -- decrement for passable actors
				local a = map(lx, ly, engine.Map.ACTOR)
				if a then -- friendly block controls if specified
					if typ.friendlyblock ~= nil and typ.source_actor and typ.source_actor.reactionToward and typ.source_actor:reactionToward(a) >= 0 then
						if not typ.friendlyblock then nb = nb - 1 end
					elseif not typ.actorblock then 
						nb = nb - 1
					end
				end
			end
			if nb > 0 then
				if for_highlights then
					-- Targeting highlight should be yellow if the grid is not known
					if not is_known then
						return false, "unknown", true
					-- Don't show the path as blocked if it's blocked by an actor we can't see
					elseif nb == 1 and typ.source_actor and typ.source_actor.canSee and not typ.source_actor:canSee(map(lx, ly, engine.Map.ACTOR)) then
						return false, true, true
					end
				end
				return true, true, true
			end
		end
		if for_highlights and not is_known then
			return false, "unknown", true
		end
	end
	-- Projection not blocked, grid is hit
	return false, true, true
end

--- Determine if a grid blocks projection based on targeting table parameters (radius test)
-- @see Target:getType(t) below
-- @param typ = updated targeting table (from Target:getType)
-- @param lx, ly = grid coordinates
-- @param for_highlights [type=boolean] grid highlighting mode for player targeting
-- @return[1] [type=boolean] grid blocks the projection
_M.defaults.block_radius = function(typ, lx, ly, for_highlights)
	local map = game.level.map
	if not map:isBound(lx, ly) then return true end
	if typ.no_restrict then return end
	if typ.requires_knowledge and not (map.remembers(lx, ly) or map.seens(lx, ly)) then return true end

	local blocked, trn_block, trn_pass
	if not typ.pass_terrain then -- check terrain
		trn_block = map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") or false
		if trn_block then 
			trn_pass = map:checkEntity(lx, ly, engine.Map.TERRAIN, "pass_projectile") or false
			if not trn_pass then blocked = true end -- blocked by terrain
		end
	end
	if not blocked and typ.stop_block then -- check all entities
		 -- get #blocking entities and subtract for each entity that can be explicitly passed through
		local nb = map:checkAllEntitiesCount(lx, ly, "block_move")
		if nb > 0 then -- decrement for passable terrain
			if trn_block == nil then trn_block = map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") end
			if trn_block and (typ.pass_terrain or (trn_pass == nil and map:checkEntity(lx, ly, engine.Map.TERRAIN, "pass_projectile") or trn_pass)) then
				nb = nb - 1
			end
		end
		
		if nb > 0 then
			local a = map(lx, ly, engine.Map.ACTOR)
			if a then -- decrement for passable actors
				-- For targeting highlights, don't show as blocked if the player can't see the actor
				if for_highlights and typ.source_actor and typ.source_actor.canSee and not typ.source_actor:canSee(a) then
					nb = nb - 1
				else
					if typ.friendlyblock == nil and not typ.actorblock then  -- friendly block controls if specified
						nb = nb - 1
					else
						if typ.friendlyblock ~= nil and typ.source_actor and typ.source_actor.reactionToward and typ.source_actor:reactionToward(a) >= 0 then
							if not typ.friendlyblock then nb = nb - 1 end
						elseif not typ.actorblock then 
							nb = nb - 1
						end
					end
				end
			end
		end
		if nb > 0 then blocked = true end
	end
	-- treat unknown grids as non-blocking for player targeting highlights
	if blocked and not (for_highlights and not (map.remembers(lx, ly) or map.seens(lx, ly))) then return true end
end

--- targeting type strings -> modification function.
_M.types_def = {
	ball = function(dest, src) dest.ball = src.radius end,
	cone = function(dest, src)
		dest.cone = src.radius
		dest.cone_angle = src.cone_angle or 55
		dest.selffire = false
	end,
	wall = function(dest, src)
		if util.isHex() then
			--with a hex grid, a wall should only be defined by the number of spots
			src.halfmax_spots = src.halflength
			src.halflength = 2 * src.halflength
		end
		dest.wall = src.halflength
		end,
	bolt = function(dest, src) dest.stop_block = true end,
	beam = function(dest, scr) dest.line = true end,
}

--- Interpret a targeting table, applying default fields needed by ActorProject and realDisplay
-- @param t = targeting table to be interpreted/updated, containing specific target parameters
-- @param t.type = string target geometric type, populates other default variables (see below), defined types:
-- 		hit: hit a single grid in LOS
-- 		beam: hit all grids along a LOS path
-- 		bolt: hit the first blocking grid along a LOS path
-- 		ball: hit all grids in a ball around the target
-- 		cone: hit all grids in a cone aimed at the target
-- @param t.range = maximum range from origin to target <default: 20>
-- @param t.min_range = minimum range from origin to target
-- @param t.cone_angle = angle for cone AoE <default: 55°>
-- @param t.radius = radius for ball/cone AoE
-- @param t.grid_exclude = {[x1][y1]=true,...[x2][y2]=true...} Grids to exclude - (makes holes in AoE)
-- @param t.act_exclude = {[uid] = true,...} exclude grids containing actor(s) with the matching uid(s)
-- @param t.selffire = boolean or % chance to project against grids with self <default: true>
-- @param t.friendlyfire = boolean or % chance to project against grids with friendly Actors (based on Actor:reactionToward(target)>0) <default: true>
-- @param t.multiple = boolean t contains multiple indexed targeting tables (interpreted in place)
-- @param t.block_path = function(typ, lx, ly, for_highlights) (default set according to t.type):
--		Determines if/how a projection is blocked along a path
--		returns block (grid blocks), hit (grid hit), hit_radius (grid blocks, path around disallowed)
-- @param t.block_radius = function(typ, lx, ly, for_highlights) (default set according to t.type):
--		Determines if a radial projection from a point is blocked
 --Parameters interpreted by the default blocking functions:
-- @param t.no_restrict = boolean all grids are treated as non-blocking
-- @param t.pass_terrain = boolean pass through all terrain (Grid.pass_projectile also checked)
-- @param t.requires_knowledge = boolean stop at unknown grids (for player)
-- @param t.stop_block = boolean stop at first grid that has any entity (not just terrain) that blocks move
-- @param t.actorblock (req. stop_block) = boolean stop at the first Actor <default: true>
-- @param t.friendlyblock (req. stop_block) = boolean stop/no stop at friendly Actors (overrides actorblock)
-- @return[1] An updated targeting table ready to be used by ActorProject
function _M:getType(t)
	if not t then return {} end

	-- Allow multiple targeting types.
	if t.multiple then
		for k, v in ipairs(t) do
			t[k] = self:getType(v)
		end
		return t
	end

	-- Add the default values
	t = table.clone(t)
	-- Default type def
	local target_type = {
		range = 20,
		selffire = true,
		friendlyfire = true,
		actorblock = true,
	}
	for k, v in pairs(self.defaults) do target_type[k] = v end

	-- And now modify for the default types
	if t.type then
		for type_name, fun in pairs(self.types_def) do
			if t.type:find(type_name) then fun(target_type, t) end
		end
	end

	table.update(t, target_type)
	return t
end

function _M:setActive(v, type)
	if v == nil then
		return self.active
	else
		self.active = v
		if v and type then
			self.target_type = self:getType(type)
			-- Targeting will generally want to stop at unseen/remembered tiles
--			table.update(self.target_type, {requires_knowledge=true})
		else
			self.target_type = {}
		end
	end
end

function _M:freemove(dir)
	local dx, dy = util.dirToCoord(dir, self.target.x, self.target.y)
	self.target.x = self.target.x + dx
	self.target.y = self.target.y + dy
	self.target.entity = game.level.map(self.target.x, self.target.y, engine.Map.ACTOR)
	if self.on_set_target then self:on_set_target("freemove") end
end

function _M:setDirFrom(dir, src)
	local dx, dy = util.dirToCoord(dir, src.x, src.y)
	self.target.x = src.x + dx
	self.target.y = src.y + dy
	self.target.entity = game.level.map(self.target.x, self.target.y, engine.Map.ACTOR)
	if self.on_set_target then self:on_set_target("dir_from") end
end

function _M:setSpot(x, y, how)
	self.target.x = x
	self.target.y = y
	self.target.entity = game.level.map(self.target.x, self.target.y, engine.Map.ACTOR)
end

function _M:setSpotInMotion(x, y, how)
	if self.on_set_target then self:on_set_target(how) end
end

function _M:scan(dir, radius, sx, sy, filter, kind)
	sx = sx or self.target.x
	sy = sy or self.target.y
	if not sx or not sy then return end

	kind = kind or engine.Map.ACTOR
	radius = radius or 20
	local actors = {}
	local checker = function(_, x, y)
		if sx == x and sy == y then return false end
		if game.level.map.seens(x, y) and game.level.map(x, y, kind) then
			local a = game.level.map(x, y, kind)

			if (not self.source_actor or self.source_actor:canSee(a)) and (not filter or filter(a)) then
				table.insert(actors, {
					a = a,
					dist = math.abs(sx - x)*math.abs(sx - x) + math.abs(sy - y)*math.abs(sy - y),
					has_los = (self.source_actor and self.source_actor:hasLOS(x, y)) and 1 or 0,
				})
				actors[a] = true
			end
		end
		return false
	end

	if dir ~= 5 then
		-- Get a list of actors in the direction given
		core.fov.calc_beam(sx, sy, game.level.map.w, game.level.map.h, radius, dir, 55, checker, function()end, nil)
	else
		-- Get a list of actors all around
		core.fov.calc_circle(sx, sy, game.level.map.w, game.level.map.h, radius, checker, function()end, nil)
	end

	table.sort(actors, function(a,b)
		if a.has_los == b.has_los then return a.dist<b.dist
		else return a.has_los > b.has_los end
	end)
	if #actors > 0 then
		self.target.entity = actors[1].a
		self.target.x = self.target.entity.x
		self.target.y = self.target.entity.y
		if self.on_set_target then self:on_set_target("scan") end
	end
end

--- Returns the point at distance from the source on a line to the destination
function _M:pointAtRange(srcx, srcy, destx, desty, dist)
	local l = line.new(srcx, srcy, destx, desty)
	local lx, ly = l()
	while lx and ly do
		if core.fov.distance(srcx, srcy, lx, ly) >= dist then break end
		lx, ly = l()
	end
	if not lx then
		return destx, desty
	else
		return lx, ly
	end
end
