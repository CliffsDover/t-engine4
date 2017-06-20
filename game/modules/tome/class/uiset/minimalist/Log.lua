-- ToME - Tales of Maj'Eyal
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
local FontPackage = require "engine.FontPackage"
local LogDisplay = require "engine.LogDisplay"
local MiniContainer = require "mod.class.uiset.minimalist.MiniContainer"

--- Log display for Minimalist ui
module(..., package.seeall, class.inherit(MiniContainer))

function _M:init(minimalist)
	MiniContainer.init(self, minimalist)
	self.resize_mode = "resize"

	self.do_container = core.renderer.container()

	local font, size = FontPackage:getFont("default")
	self.logdisplay = LogDisplay.new(0, 0, self.w, self.h, nil, font, size, nil, nil)
	self.logdisplay.resizeToLines = function() end
	self.logdisplay:setTextOutline(0.7)
	self.logdisplay:enableFading(config.settings.tome.log_fade or 3)
	self.do_container:add(self.logdisplay.renderer)

	minimalist.logdisplay = self.logdisplay -- for old code compatibility

	self.mouse:registerZone(0, 0, self.w, self.h, function(button, mx, my, xrel, yrel, bx, by, event)
		self.logdisplay:mouseEvent(button, mx, my, xrel, yrel, bx, by, event)
	end, nil, "log", true, 1)

	self.logdisplay:onMouse(function(item, sub_es, button, event, x, y, xrel, yrel, bx, by)
		local mx, my = core.mouse.get()
		if ((not item or not sub_es or #sub_es == 0) and (not item or not item.url)) or (item and item.faded == 0) then game.mouse:delegate(button, mx, my, xrel, yrel, nil, nil, event, "playmap") return end

		local tooltips = {}
		if sub_es then for i, e in ipairs(sub_es) do
			if e.tooltip then
				local t = e:tooltip()
				if t then table.append(tooltips, t) end
				if i < #sub_es then table.append(tooltips, { tstring{ true, "---" } } )
				else table.append(tooltips, { tstring{ true } } ) end
			end
		end end
		if item.url then
			table.append(tooltips, tstring{"Clicking will open ", {"color", "LIGHT_BLUE"}, {"font", "italic"}, item.url, {"color", "WHITE"}, {"font", "normal"}, " in your browser"})
		end

		local extra = {}
		extra.log_str = tooltips
		game.tooltip.old_ttmx = -100
		game.mouse:delegate(button, mx, my, xrel, yrel, nil, nil, event, "playmap", extra)
	end)
end

function _M:getName()
	return "Game Log"
end

function _M:getDefaultGeometry()
	local th = 60
	if config.settings.tome.hotkey_icons then th = (19 + config.settings.tome.hotkey_icons_size) * config.settings.tome.hotkey_icons_rows end

	local x = 0
	local w = math.floor(game.w / 2)
	local h = math.floor(game.h / 4) - th
	local y = game.h - h - th
	return x, y, w, h
end

function _M:getDO()
	return self.do_container
end

function _M:move(x, y)
	MiniContainer.move(self, x, y)
end

function _M:resize(w, h)
	MiniContainer.resize(self, w, h)
	self.logdisplay:resize(0, 0, w, h)
end