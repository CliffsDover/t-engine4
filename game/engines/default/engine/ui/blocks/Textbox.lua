-- TE4 - T-Engine 4
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

require "engine.class"
local Block = require "engine.ui.blocks.Block"
local tween = require "tween"

--- A text entry zone
-- @classmod engine.ui.blocks.block
module(..., package.seeall, class.inherit(Block))

function _M:init(t, text, color, w, h)
	color = color or {255,255,255}

	Block.init(self, t)

	self.selected = false

	self.frame = self.parent.ui:makeFrameDO("ui/textbox", w, h)
	self.frame_sel = self.parent.ui:makeFrameDO("ui/textbox-sel", w, h)
	self.frame_sel.container:shown(false)
	self.cur_frame = self.frame

	self.text = core.renderer.text(self.font)
	self.text:translate(self.frame.b4.w, (h - self.font_h) / 2, 10)
	self.text:textColor(color[1] / 255, color[2] / 255, color[3] / 255, 1)
	
	self.do_container:add(self.frame.container)
	self.do_container:add(self.frame_sel.container)
	self.do_container:add(self.text)

	self:setText(text)
end

function _M:onFocusChange(v)
	-- tween.stop(self.tweenid)
	self.cur_frame.container:shown(false)
	self.cur_frame = v and self.frame_sel or self.frame
	if self.selected then self.cur_frame.container:shown(true) end
end

function _M:setText(text, color)
	if color then
		self.text:textColor(color[1] / 255, color[2] / 255, color[3] / 255, 1)
	end
	self.text:text(text)
end
