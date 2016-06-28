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
local Dialog = require "engine.ui.Dialog"
local List = require "engine.ui.List"
local Button = require "engine.ui.Button"
local ButtonImage = require "engine.ui.ButtonImage"
local Textzone = require "engine.ui.Textzone"
local Textbox = require "engine.ui.Textbox"
local Separator = require "engine.ui.Separator"
local KeyBind = require "engine.KeyBind"
local FontPackage = require "engine.FontPackage"
local Module = require "engine.Module"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "Main Menu", 250, 400, 450, 50)
	self.__showup = false
	self.absolute = true

	local l = {}
	self.list = l
	l[#l+1] = {name="New Game", fct=function() game:registerDialog(require("mod.dialogs.NewGame").new()) end}
	l[#l+1] = {name="Load Game", fct=function() game:registerDialog(require("mod.dialogs.LoadGame").new()) end}
--	l[#l+1] = {name="Online Profile", fct=function() game:registerDialog(require("mod.dialogs.Profile").new()) end}
	l[#l+1] = {name="View High Scores", fct=function() game:registerDialog(require("mod.dialogs.ViewHighScores").new()) end}
	l[#l+1] = {name="Addons", fct=function() game:registerDialog(require("mod.dialogs.Addons").new()) end}
--	if config.settings.install_remote then l[#l+1] = {name="Install Module", fct=function() end} end
--	l[#l+1] = {name="Update", fct=function() game:registerDialog(require("mod.dialogs.UpdateAll").new()) end}
	l[#l+1] = {name="Options", fct=function()
		local list = {
			"resume",
			"keybinds_all",
			{"Game Options", function()
				-- OMFG this is such a nasty hack, I'm nearly pround of it !
				local mod = Module:listModules().tome
				if not mod then return end

				local allmounts = fs.getSearchPath(true)
				if not mod.team then fs.mount(fs.getRealPath(mod.dir), "/mod", false)
				else fs.mount(fs.getRealPath(mod.team), "/", false) end

				local d = require("mod.dialogs.GameOptions").new()
				function d:unload()
					fs.reset()
					fs.mountAll(allmounts)
				end
				game:registerDialog(d)
			end},
			"video",
			"sound",
			"steam",
			"cheatmode",
		}
		local menu = require("engine.dialogs.GameMenu").new(list)
		game:registerDialog(menu)
	end}
	l[#l+1] = {name="Credits", fct=function() game:registerDialog(require("mod.dialogs.Credits").new()) end}
	l[#l+1] = {name="Exit", fct=function() game:onQuit() end}
	if config.settings.cheat then l[#l+1] = {name="Reboot", fct=function() util.showMainMenu() end} end
--	if config.settings.cheat then l[#l+1] = {name="webtest", fct=function() util.browserOpenUrl("http://google.com") end} end
--	if config.settings.cheat then l[#l+1] = {name="webtest", fct=function() util.browserOpenUrl("asset://te4/html/test.html") end} end

	self.c_background = Button.new{text=game.stopped and "Enable background" or "Disable background", fct=function() self:switchBackground() end}
	self.c_version = Textzone.new{font={FontPackage:getFont("default"), 10}, auto_width=true, auto_height=true, text=("#B9E100#T-Engine4 version: %d.%d.%d"):format(engine.version[1], engine.version[2], engine.version[3])}

	self.c_list = List.new{width=self.iw, nb_items=#self.list, list=self.list, fct=function(item) end, font={FontPackage:getFont("default")}}

	self.c_facebook = ButtonImage.new{no_decoration=true, alpha_unfocus=0.5, file="facebook.png", fct=function() util.browserOpenUrl("https://www.facebook.com/tales.of.maj.eyal", {is_external=true}) end}
	self.c_twitter = ButtonImage.new{no_decoration=true, alpha_unfocus=0.5, file="twitter.png", fct=function() util.browserOpenUrl("https://twitter.com/TalesOfMajEyal", {is_external=true}) end}
	self.c_forums = ButtonImage.new{no_decoration=true, alpha_unfocus=0.5, file="forums.png", fct=function() util.browserOpenUrl("http://forums.te4.org/", {is_external=true}) end}

	self.base_uis = {
		{left=0, top=0, ui=self.c_list},
		{left=0, bottom=0, absolute=true, ui=self.c_background},
		{right=self.c_facebook.w, bottom=0, absolute=true, ui=self.c_version},
		{right=0, bottom=self.c_facebook.h+self.c_twitter.h, absolute=true, ui=self.c_forums},
		{right=0, bottom=self.c_twitter.h, absolute=true, ui=self.c_facebook},
		{right=0, bottom=0, absolute=true, ui=self.c_twitter},
	}

	self:enableWebtooltip()

	if game.__mod_info.publisher_logo then
		local c_pub = ButtonImage.new{no_decoration=true, alpha_unfocus=1, file="background/"..game.__mod_info.publisher_logo..".png", fct=function()
			if game.__mod_info.publisher_url then util.browserOpenUrl(game.__mod_info.publisher_url, {is_external=true}) end
		end}
		if game.w - 450 - 250 - c_pub.w - 20 > 0 then
			table.insert(self.base_uis, 1, {right=0, top=0, absolute=true, ui=c_pub})
		end
	end

	self:updateUI()
end

function _M:enableWebtooltip()
	if self.c_tooltip then return end
	if core.webview and game.webtooltip then self.c_tooltip = game.webtooltip
	else self.c_tooltip = game.tooltip end

	self.base_uis[#self.base_uis+1] = {left=20, top=20, absolute=true, ui=self.c_tooltip}
end

function _M:updateUI()
	local uis = table.clone(self.base_uis)

	if profile.auth then
		self:uiStats(uis)
	else
		self:uiLogin(uis)
	end

	-- local tree = {}
	-- for i = 1, 100 do tree[#tree+1] = {name="toto"..i, b1="lol"..i, b2=""..(100-i)} end
	-- tree[1].nodes = {} tree[1].shown = true tree[1].color = function() return colors_simple.RED end
	-- tree[2].nodes = {} tree[2].shown = true tree[2].color = function() return colors_simple.RED end
	-- tree[3].nodes = {} tree[3].shown = true tree[3].color = function() return colors_simple.RED end
	-- for i = 1, 3 do tree[1].nodes[#tree[1].nodes+1] = {name="caca"..i, b1="lol"..i, b2=""..(100-i)} end
	-- for i = 1, 2 do tree[2].nodes[#tree[2].nodes+1] = {name="caca"..i, b1="lol"..i, b2=""..(100-i)} end
	-- local test = require("engine.ui.TreeList").new{width=self.iw, height=self.ih, sel_by_col=true, scrollbar=true, columns={
	-- 		{width=50, display_prop="name"},
	-- 		{width=30, display_prop="b1"},
	-- 		{width=20, display_prop="b2"},
	-- 	}, tree = tree,
	-- 	fct = function() end,
	-- }
	-- uis = { {left=0, top=0, ui=test} }  


	self:loadUI(uis)
	self:setupUI(false, true)
	self.key:addBind("LUA_CONSOLE", function()
		if config.settings.cheat then
			game:registerDialog(require("engine.DebugConsole").new())
		end
	end)
	self.key:addBind("SCREENSHOT", function() game:saveScreenshot() end)
	KeyBind:load("chat")
	self.key:bindKeys() -- Make sure it updates
	self.key:addBind("USERCHAT_TALK", function() profile.chat:talkBox(nil, true) end)

	self:setFocus(self.c_list)

	-- game:onTickEnd(function()
	-- 	local sp1  = core.renderer.spriter("/data/gfx/spriters/test_02/test_embedded_03.scml", "Player") sp1:setAnim('walk')
	-- 	sp1:scale(0.2, 0.2, 0.2)
	-- 	-- game.player._mo:displayObject(sp1)
	-- 	local spr = core.renderer.renderer()
	-- 	spr:add(sp1)
	-- 	game.player._mo:displayObject(spr)
	-- end)

	local ps = require("engine.Particles").new("fireflash", 1, {radius=0.2})
	local psr = core.renderer.renderer()
	psr:translate(self.iw/2, 0, 0)
	psr:add(ps)
	self.do_container:add(psr)
end

function _M:uiLogin(uis)
	if core.steam then return self:uiLoginSteam(uis) end

	local str = Textzone.new{auto_width=true, auto_height=true, text="#GOLD#Online Profile"}
	local bt = Button.new{text="Login", width=50, fct=function() self:login() end}
	local btr = Button.new{text="Register", fct=function() self:register() end}
	self.c_login = Textbox.new{title="Username: ", text="", chars=16, max_len=20, fct=function(text) self:login() end}
	self.c_pass = Textbox.new{title="Password: ", size_title=self.c_login.title, text="", chars=16, max_len=20, hide=true, fct=function(text) self:login() end}

	uis[#uis+1] = {left=10, bottom=bt.h + self.c_login.h + self.c_pass.h + str.h, ui=Separator.new{dir="vertical", size=self.iw - 20}}
	uis[#uis+1] = {hcenter=0, bottom=bt.h + self.c_login.h + self.c_pass.h, ui=str}
	uis[#uis+1] = {left=0, bottom=bt.h + self.c_pass.h, ui=self.c_login}
	uis[#uis+1] = {left=0, bottom=bt.h, ui=self.c_pass}
	uis[#uis+1] = {left=0, bottom=0, ui=bt}
	uis[#uis+1] = {right=0, bottom=0, ui=btr}
end

function _M:uiLoginSteam(uis)
	local str = Textzone.new{auto_width=true, auto_height=true, text="#GOLD#Online Profile"}
	local bt = Button.new{text="Login with Steam", fct=function() self:loginSteam() end}

	uis[#uis+1] = {left=10, bottom=bt.h + str.h, ui=Separator.new{dir="vertical", size=self.iw - 20}}
	uis[#uis+1] = {hcenter=0, bottom=bt.h, ui=str}
	uis[#uis+1] = {hcenter=0, bottom=0, ui=bt}
end

function _M:uiStats(uis)
	self.logged_url = "http://te4.org/users/"..profile.auth.page
	local str1 = Textzone.new{auto_width=true, auto_height=true, text="#GOLD#Online Profile#WHITE#"}
	local str2 = Textzone.new{auto_width=true, auto_height=true, text="#LIGHT_BLUE##{underline}#"..self.logged_url.."#LAST##{normal}#", fct=function() util.browserOpenUrl(self.logged_url, {is_external=true}) end}

	local logoff = Textzone.new{text="#LIGHT_BLUE##{underline}#Logout", auto_height=true, width=50, fct=function() self:logout() end}

	uis[#uis+1] = {left=10, bottom=logoff.h + str2.h + str1.h, ui=Separator.new{dir="vertical", size=self.iw - 20}}
	uis[#uis+1] = {hcenter=0, bottom=logoff.h + str2.h, ui=str1}
	uis[#uis+1] = {left=0, bottom=logoff.h, ui=str2}
	uis[#uis+1] = {right=0, bottom=0, ui=logoff}
end

function _M:login()
	if self.c_login.text:len() < 2 then
		Dialog:simplePopup("Username", "Your username is too short")
		return
	end
	if self.c_pass.text:len() < 4 then
		Dialog:simplePopup("Password", "Your password is too short")
		return
	end
	game:createProfile({create=false, login=self.c_login.text, pass=self.c_pass.text})
end

function _M:loginSteam()
	local d = self:simpleWaiter("Login...", "Login in your account, please wait...") core.display.forceRedraw()
	d:timeout(10, function() Dialog:simplePopup("Steam", "Steam client not found.")	end)
	core.steam.sessionTicket(function(ticket)
		if not ticket then
			Dialog:simplePopup("Steam", "Steam client not found.")
			d:done()
			return
		end
		profile:performloginSteam((ticket:toHex()))
		profile:waitFirstAuth()
		d:done()
		if not profile.auth and profile.auth_last_error then
			if profile.auth_last_error == "auth error" then
				game:newSteamAccount()
			end
		end
	end)
end

function _M:register()
	local dialogdef = {}
	dialogdef.fct = function(login) game:setPlayerLogin(login) end
	dialogdef.name = "creation"
	dialogdef.justlogin = false
	game:registerDialog(require('mod.dialogs.ProfileLogin').new(dialogdef, game.profile_help_text))
end

function _M:logout()
	profile:logOut()
	self:on_recover_focus()
end

function _M:switchBackground()
	game.stopped = not game.stopped
	game:saveSettings("boot_menu_background", ("boot_menu_background = %s\n"):format(tostring(game.stopped)))
	self.c_background.text = game.stopped and "Enable background" or "Disable background"
	self.c_background:generate()

	if game.stopped then
		core.game.setRealtime(0)
	else
		core.game.setRealtime(8)
	end
end

function _M:on_recover_focus()
	-- Remove them from us so they can be added back
	if game.tooltip then game.tooltip.do_container:removeFromParent() end
	if game.webtooltip then game.webtooltip.do_container:removeFromParent() end

	game:unregisterDialog(self)
	local d = new()
	game:registerDialog(d)
end
