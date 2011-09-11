-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

local lpeg = require "lpeg"

function lpeg.anywhere (p)
	return lpeg.P{ p + 1 * lpeg.V(1) }
end

function table.print(src, offset)
	offset = offset or ""
	for k, e in pairs(src) do
		-- Deep copy subtables, but not objects!
		if type(e) == "table" and not e.__CLASSNAME then
			print(("%s[%s] = {"):format(offset, tostring(k)))
			table.print(e, offset.."  ")
			print(("%s}"):format(offset))
		else
			print(("%s[%s] = %s"):format(offset, tostring(k), tostring(e)))
		end
	end
end

function table.clone(tbl, deep, k_filter)
	local n = {}
	k_filter = k_filter or {}
	for k, e in pairs(tbl) do
		if not k_filter[k] then
			-- Deep copy subtables, but not objects!
			if deep and type(e) == "table" and not e.__CLASSNAME then
				n[k] = table.clone(e, true, k_filter)
			else
				n[k] = e
			end
		end
	end
	return n
end

function table.merge(dst, src, deep, k_filter)
	k_filter = k_filter or {}
	for k, e in pairs(src) do
		if not k_filter[k] then
			if deep and dst[k] and type(e) == "table" and type(dst[k]) == "table" and not e.__CLASSNAME then
				table.merge(dst[k], e, true, k_filter)
			elseif deep and not dst[k] and type(e) == "table" and not e.__CLASSNAME then
				dst[k] = table.clone(e, true, k_filter)
			else
				dst[k] = e
			end
		end
	end
	return dst
end

function table.mergeAdd(dst, src, deep)
	for k, e in pairs(src) do
		if deep and dst[k] and type(e) == "table" and type(dst[k]) == "table" and not e.__CLASSNAME then
			table.mergeAdd(dst[k], e, true)
		elseif deep and not dst[k] and type(e) == "table" and not e.__CLASSNAME then
			dst[k] = table.clone(e, true)
		elseif dst[k] and type(e) == "number" then
			dst[k] = dst[k] + e
		else
			dst[k] = e
		end
	end
	return dst
end

--- Merges additively the named fields and append the array part
-- Yes this is weird and you'll probably not need it, but the engine does :)
function table.mergeAddAppendArray(dst, src, deep)
	-- Append the array part
	for i = 1, #src do
		local b = src[i]
		if deep and type(b) == "table" and not b.__CLASSNAME then b = table.clone(b, true)
		elseif deep and type(b) == "table" and b.__CLASSNAME then b = b:clone()
		end
		table.insert(dst, b)
	end

	-- Copy the table part
	for k, e in pairs(src) do
		if type(k) ~= "number" then
			if deep and dst[k] and type(e) == "table" and type(dst[k]) == "table" and not e.__CLASSNAME then
				-- WARNING we do not recurse on ourself but instead of the simple mergeAdd, we do not want to do the array stuff for subtables
				-- yes I warned you this is weird
				table.mergeAdd(dst[k], e, true)
			elseif deep and not dst[k] and type(e) == "table" and not e.__CLASSNAME then
				dst[k] = table.clone(e, true)
			elseif dst[k] and type(e) == "number" then
				dst[k] = dst[k] + e
			else
				dst[k] = e
			end
		end
	end
end

function table.append(dst, src)
	for i = 1, #src do dst[#dst+1] = src[i] end
end

function table.reverse(t)
	local tt = {}
	for i, e in ipairs(t) do tt[e] = i end
	return tt
end

function table.listify(t)
	local tt = {}
	for k, e in pairs(t) do tt[#tt+1] = {k, e} end
	return tt
end

function table.keys_to_values(t)
	local tt = {}
	for k, e in pairs(t) do tt[e] = k end
	return tt
end

function table.keys(t)
	local tt = {}
	for k, e in pairs(t) do tt[#tt+1] = k end
	return tt
end

function table.values(t)
	local tt = {}
	for k, e in pairs(t) do tt[#tt+1] = e end
	return tt
end

function table.from_list(t, k, v)
	local tt = {}
	for i, e in ipairs(t) do tt[e[k or 1]] = e[v or 2] end
	return tt
end

function table.update(dst, src, deep)
	for k, e in pairs(src) do
		if deep and dst[k] and type(e) == "table" and type(dst[k]) == "table" and not e.__CLASSNAME then
			table.update(dst[k], e, true)
		elseif deep and not dst[k] and type(e) == "table" and not e.__CLASSNAME then
			dst[k] = table.clone(e, true)
		elseif not dst[k] and type(dst[k]) ~= "boolean" then
			dst[k] = e
		end
	end
end

function string.ordinal(number)
	local suffix = "th"
	number = tonumber(number)
	local base = number % 10
	if base == 1 then
		suffix = "st"
	elseif base == 2 then
		suffix = "nd"
	elseif base == 3 then
		suffix = "rd"
	end
	return number..suffix
end

function string.a_an(str)
	local first = str:sub(1, 1)
	if first == "a" or first == "e" or first == "i" or first == "o" or first == "u" or first == "y" then return "an "..str
	else return "a "..str end
end

function string.capitalize(str)
	if #str > 1 then
		return string.upper(str:sub(1, 1))..str:sub(2)
	elseif #str == 1 then
		return str:upper()
	else
		return str
	end
end

function string.bookCapitalize(str)
	local words = str:split(' ')

	for i = 1, #words do
		local word = words[i]

		-- Don't capitalize certain words unless they are at the beginning
		-- of the string.
		if i == 1 or (word ~= "of" and word ~= "the" and word ~= "and" and word ~= "a" and word ~= "an")
		then
			words[i] = word:gsub("^(.)",
							function(x)
								return x:upper()
							end)
		end
	end

	return table.concat(words, " ")
end

function string.lpegSub(s, patt, repl)
	patt = lpeg.P(patt)
	patt = lpeg.Cs((patt / repl + 1)^0)
	return lpeg.match(patt, s)
end

-- Those matching patterns are used both by splitLine and drawColorString*
local Pextra = "&" * -lpeg.S"#"^1
local Puid = "UID:" * lpeg.R"09"^1 * ":" * lpeg.R"09"
local Puid_cap = "UID:" * lpeg.C(lpeg.R"09"^1) * ":" * lpeg.C(lpeg.R"09")
local Pcolorname = (lpeg.R"AZ" + "_")^3
local Pcode = (lpeg.R"af" + lpeg.R"09" + lpeg.R"AF")
local Pcolorcode = Pcode * Pcode
local Pfontstyle = "{" * (lpeg.P"bold" + lpeg.P"italic" + lpeg.P"underline" + lpeg.P"normal") * "}"
local Pfontstyle_cap = "{" * lpeg.C(lpeg.P"bold" + lpeg.P"italic" + lpeg.P"underline" + lpeg.P"normal") * "}"
local Pcolorcodefull = Pcolorcode * Pcolorcode * Pcolorcode

function string.removeColorCodes(str)
	return str:lpegSub("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle) * "#", "")
end

function string.removeUIDCodes(str)
	return str:lpegSub("#" * Puid * "#", "")
end

function string.splitLine(str, max_width, font)
	local space_w = font:size(" ")
	local lines = {}
	local cur_line, cur_size = "", 0
	local v
	local ls = str:split(lpeg.S"\n ")
	for i = 1, #ls do
		local v = ls[i]
		local shortv = v:lpegSub("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle + Pextra) * "#", "")
		local w, h = font:size(shortv)

		if cur_size + space_w + w < max_width then
			cur_line = cur_line..(cur_size==0 and "" or " ")..v
			cur_size = cur_size + (cur_size==0 and 0 or space_w) + w
		else
			lines[#lines+1] = cur_line
			cur_line = v
			cur_size = w
		end
	end
	if cur_size > 0 then lines[#lines+1] = cur_line end
	return lines
end

function string.splitLines(str, max_width, font)
	local lines = {}
	local ls = str:split(lpeg.S"\n")
	local v
	for i = 1, #ls do
		v = ls[i]
		local ls = v:splitLine(max_width, font)
		if #ls > 0 then
			for i, l in ipairs(ls) do
				lines[#lines+1] = l
			end
		else
			lines[#lines+1] = ""
		end
	end
	return lines
end

-- Split a string by the given character(s)
function string.split(str, char, keep_separator)
	char = lpeg.P(char)
	if keep_separator then char = lpeg.C(char) end
	local elem = lpeg.C((1 - char)^0)
	local p = lpeg.Ct(elem * (char * elem)^0)
	return lpeg.match(p, str)
end


local hex_to_dec = {
	["0"] = 0,
	["1"] = 1,
	["2"] = 2,
	["3"] = 3,
	["4"] = 4,
	["5"] = 5,
	["6"] = 6,
	["7"] = 7,
	["8"] = 8,
	["9"] = 9,
	["a"] = 10,
	["b"] = 11,
	["c"] = 12,
	["d"] = 13,
	["e"] = 14,
	["f"] = 15,
}
local hexcache = {}
function string.parseHex(str)
	if hexcache[str] then return hexcache[str] end
	local res = 0
	local power = 1
	str = str:lower()
	for i = 1, #str do
		res = res + power * (hex_to_dec[str:sub(#str-i+1,#str-i+1)] or 0)
		power = power * 16
	end
	hexcache[str] = res
	return res
end

function __get_uid_surface(uid, w, h)
	uid = tonumber(uid)
	local e = uid and __uids[uid]
	if e and game.level then
		return e:getEntityFinalSurface(game.level.map.tiles, w, h)
	end
	return nil
end

local tmps = core.display.newSurface(1, 1)
getmetatable(tmps).__index.drawColorString = function(s, font, str, x, y, r, g, b, alpha_from_texture, limit_w)
	local list = str:split("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle + Pextra) * "#", true)
	r = r or 255
	g = g or 255
	b = b or 255
	limit_w = limit_w or 99999999
	local oldr, oldg, oldb = r, g, b
	local max_h = 0
	local sw = 0
	local bx, by = x, y
	for i, v in ipairs(list) do
		local nr, ng, nb = lpeg.match("#" * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * "#", v)
		local col = lpeg.match("#" * lpeg.C(Pcolorname) * "#", v)
		local uid, mo = lpeg.match("#" * Puid_cap * "#", v)
		local fontstyle = lpeg.match("#" * Pfontstyle_cap * "#", v)
		local extra = lpeg.match("#" * lpeg.C(Pextra) * "#", v)
		if nr and ng and nb then
			oldr, oldg, oldb = r, g, b
			r, g, b = nr:parseHex(), ng:parseHex(), nb:parseHex()
		elseif col then
			if col == "LAST" then
				r, g, b = oldr, oldg, oldb
			else
				oldr, oldg, oldb = r, g, b
				r, g, b = colors[col].r, colors[col].g, colors[col].b
			end
		elseif uid and mo and game.level then
			uid = tonumber(uid)
			mo = tonumber(mo)
			local e = __uids[uid]
			if e then
				local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
				if surf then
					local w, h = surf:getSize()
					if sw + w > limit_w then break end
					s:merge(surf, x, y)
					if h > max_h then max_h = h end
					x = x + (w or 0)
					sw = sw + (w or 0)
				end
			end
		elseif fontstyle then
			font:setStyle(fontstyle)
		elseif extra then
			--
		else
			local w, h = font:size(v)
			local stop = false
			while sw + w > limit_w do
				v = v:sub(1, #v - 1)
				if #v == 0 then break end
				w, h = font:size(v)
				stop = true
			end
			if h > max_h then max_h = h end
			s:drawStringBlended(font, v, x, y, r, g, b, alpha_from_texture)
			x = x + w
			sw = sw + w
			if stop then break end
		end
	end
	return r, g, b, sw, max_h, bx, by
end

getmetatable(tmps).__index.drawColorStringCentered = function(s, font, str, dx, dy, dw, dh, r, g, b, alpha_from_texture, limit_w)
	local w, h = font:size(str)
	local x, y = dx + (dw - w) / 2, dy + (dh - h) / 2
	s:drawColorString(font, str, x, y, r, g, b, alpha_from_texture, limit_w)
end


getmetatable(tmps).__index.drawColorStringBlended = function(s, font, str, x, y, r, g, b, alpha_from_texture, limit_w)
	local list = str:split("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle + Pextra) * "#", true)
	r = r or 255
	g = g or 255
	b = b or 255
	limit_w = limit_w or 99999999
	local oldr, oldg, oldb = r, g, b
	local max_h = 0
	local sw = 0
	local bx, by = x, y
	for i, v in ipairs(list) do
		local nr, ng, nb = lpeg.match("#" * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * "#", v)
		local col = lpeg.match("#" * lpeg.C(Pcolorname) * "#", v)
		local uid, mo = lpeg.match("#" * Puid_cap * "#", v)
		local fontstyle = lpeg.match("#" * Pfontstyle_cap * "#", v)
		local extra = lpeg.match("#" * lpeg.C(Pextra) * "#", v)
		if nr and ng and nb then
			oldr, oldg, oldb = r, g, b
			r, g, b = nr:parseHex(), ng:parseHex(), nb:parseHex()
		elseif col then
			if col == "LAST" then
				r, g, b = oldr, oldg, oldb
			else
				oldr, oldg, oldb = r, g, b
				r, g, b = colors[col].r, colors[col].g, colors[col].b
			end
		elseif uid and mo and game.level then
			uid = tonumber(uid)
			mo = tonumber(mo)
			local e = __uids[uid]
			if e then
				local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
				if surf then
					local w, h = surf:getSize()
					if sw + (w or 0) > limit_w then break end
					s:merge(surf, x, y)
					if h > max_h then max_h = h end
					x = x + (w or 0)
					sw = sw + (w or 0)
				end
			end
		elseif fontstyle then
			font:setStyle(fontstyle)
		elseif extra then
			--
		else
			local w, h = font:size(v)
			local stop = false
			while sw + w > limit_w do
				v = v:sub(1, #v - 1)
				if #v == 0 then break end
				w, h = font:size(v)
				stop = true
			end
			if h > max_h then max_h = h end
			s:drawStringBlended(font, v, x, y, r, g, b, alpha_from_texture)
			x = x + w
			sw = sw + w
			if stop then break end
		end
	end
	return r, g, b, sw, max_h, bx, by
end

getmetatable(tmps).__index.drawColorStringBlendedCentered = function(s, font, str, dx, dy, dw, dh, r, g, b, alpha_from_texture, limit_w)
	local w, h = font:size(str)
	local x, y = dx + (dw - w) / 2, dy + (dh - h) / 2
	s:drawColorStringBlended(font, str, x, y, r, g, b, alpha_from_texture, limit_w)
end

local font_cache = {}
local oldNewFont = core.display.newFont

core.display.resetAllFonts = function(state)
	for font, sizes in pairs(font_cache) do for size, f in pairs(sizes) do
		f:setStyle(state)
	end end
end

core.display.newFont = function(font, size)
	if font_cache[font] and font_cache[font][size] then print("Using cached font", font, size) return font_cache[font][size] end
	font_cache[font] = font_cache[font] or {}
	font_cache[font][size] = oldNewFont(font, size)
	return font_cache[font][size]
end

local tmps = core.display.newFont("/data/font/Vera.ttf", 12)
local word_size_cache = {}
local fontoldsize = getmetatable(tmps).__index.size
getmetatable(tmps).__index.size = function(font, str)
	local list = str:split("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle + Pextra) * "#", true)
	local mw, mh = 0, 0
	local fstyle = font:getStyle()
	word_size_cache[font] = word_size_cache[font] or {}
	word_size_cache[font][fstyle] = word_size_cache[font][fstyle] or {}
	local v
	for i = 1, #list do
		v = list[i]
		local nr, ng, nb = lpeg.match("#" * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * "#", v)
		local col = lpeg.match("#" * lpeg.C(Pcolorname) * "#", v)
		local uid, mo = lpeg.match("#" * Puid_cap * "#", v)
		local fontstyle = lpeg.match("#" * Pfontstyle_cap * "#", v)
		local extra = lpeg.match("#" * lpeg.C(Pextra) * "#", v)
		if nr and ng and nb then
			-- Ignore
		elseif col then
			-- Ignore
		elseif uid and mo and game.level then
			uid = tonumber(uid)
			mo = tonumber(mo)
			local e = __uids[uid]
			if e then
				local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
				if surf then
					local w, h = surf:getSize()
					mw = mw + w
					if h > mh then mh = h end
				end
			end
		elseif fontstyle then
			font:setStyle(fontstyle)
			fstyle = fontstyle
			word_size_cache[font][fstyle] = word_size_cache[font][fstyle] or {}
		elseif extra then
			--
		else
			local w, h
			if word_size_cache[font][fstyle][v] then
				w, h = word_size_cache[font][fstyle][v][1], word_size_cache[font][fstyle][v][2]
			else
				w, h = fontoldsize(font, v)
				word_size_cache[font][fstyle][v] = {w, h}
			end
			if h > mh then mh = h end
			mw = mw + w
		end
	end
	return mw, mh
end

tstring = {}
tstring.is_tstring = true

function tstring:add(...)
	local v = {...}
	for i = 1, #v do
		self[#self+1] = v[i]
	end
	return self
end

function tstring:merge(v)
	if not v then return end
	for i = 1, #v do
		self[#self+1] = v[i]
	end
	return self
end

function tstring:countLines()
	local nb = 1
	local v
	for i = 1, #self do
		v = self[i]
		if type(v) == "boolean" then nb = nb + 1 end
	end
	return nb
end

function tstring.from(str)
	if type(str) ~= "table" then
		return tstring{str}
	else
		return str
	end
end

--- Parse a string and return a tstring
function string.toTString(str)
	local tstr = tstring{}
	local list = str:split(("#" * (Puid + Pcolorcodefull + Pcolorname + Pfontstyle + Pextra) * "#") + lpeg.P"\n", true)
	for i = 1, #list do
		v = list[i]
		local nr, ng, nb = lpeg.match("#" * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * lpeg.C(Pcolorcode) * "#", v)
		local col = lpeg.match("#" * lpeg.C(Pcolorname) * "#", v)
		local uid, mo = lpeg.match("#" * Puid_cap * "#", v)
		local fontstyle = lpeg.match("#" * Pfontstyle_cap * "#", v)
		local extra = lpeg.match("#" * lpeg.C(Pextra) * "#", v)
		if nr and ng and nb then
			tstr:add({"color", nr:parseHex(), ng:parseHex(), nb:parseHex()})
		elseif col then
			tstr:add({"color", col})
		elseif uid and mo then
			tstr:add({"uid", tonumber(uid)})
		elseif fontstyle then
			tstr:add({"font", fontstyle})
		elseif extra then
			tstr:add({"extra", extra:sub(2)})
		elseif v == "\n" then
			tstr:add(true)
		else
			tstr:add(v)
		end
	end
	return tstr
end
function string:toString() return self end

--- Tablestrings degrade "peacefully" into normal formated strings
function tstring:toString()
	local ret = {}
	local v
	for i = 1, #self do
		v = self[i]
		if type(v) == "boolean" then ret[#ret+1] = "\n"
		elseif type(v) == "string" then ret[#ret+1] = v
		elseif type(v) == "table" then
			if v[1] == "color" and v[2] == "LAST" then ret[#ret+1] = "#LAST#"
			elseif v[1] == "color" and not v[3] then ret[#ret+1] = "#"..v[2].."#"
			elseif v[1] == "color" then ret[#ret+1] = ("#%02x%02x%02x#"):format(v[2], v[3], v[4]):upper()
			elseif v[1] == "font" then ret[#ret+1] = "#{"..v[2].."}#"
			elseif v[1] == "uid" then ret[#ret+1] = "#UID:"..v[2]..":0#"
			elseif v[1] == "extra" then ret[#ret+1] = "#&"..v[2].."#"
			end
		end
	end
	return table.concat(ret)
end
function tstring:toTString() return self end

--- Tablestrings can not be formated, this just returns self
function tstring:format() return self end

function tstring:splitLines(max_width, font)
	local space_w = font:size(" ")
	local ret = tstring{}
	local cur_size = 0
	local max_w = 0
	local v, tv
	for i = 1, #self do
		v = self[i]
		tv = type(v)
		if tv == "string" then
			local ls = v:split(lpeg.S"\n ", true)
			for i = 1, #ls do
				local vv = ls[i]
				if vv == "\n" then
					ret[#ret+1] = true
					max_w = math.max(max_w, cur_size)
					cur_size = 0
				else
					local w, h = fontoldsize(font, vv)
					if cur_size + w < max_width then
						cur_size = cur_size + w
						ret[#ret+1] = vv
					else
						ret[#ret+1] = true
						ret[#ret+1] = vv
						max_w = math.max(max_w, cur_size)
						cur_size = w
					end
				end
			end
		elseif tv == "table" and v[1] == "font" then
			font:setStyle(v[2])
			ret[#ret+1] = v
		elseif tv == "table" and v[1] == "extra" then
			ret[#ret+1] = v
		elseif tv == "table" and v[1] == "uid" then
			local e = __uids[v[2]]
			if e and game.level then
				local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
				if surf then
					local w, h = surf:getSize()
					if cur_size + w < max_width then
						cur_size = cur_size + w
						ret[#ret+1] = v
					else
						ret[#ret+1] = true
						ret[#ret+1] = v
						max_w = math.max(max_w, cur_size)
						cur_size = w
					end
				end
			end
		elseif tv == "boolean" then
			max_w = math.max(max_w, cur_size)
			cur_size = 0
			ret[#ret+1] = v
		else
			ret[#ret+1] = v
		end
	end
	max_w = math.max(max_w, cur_size)
	return ret, max_w
end

function tstring:tokenize(tokens)
	local ret = tstring{}
	local v, tv
	for i = 1, #self do
		v = self[i]
		tv = type(v)
		if tv == "string" then
			local ls = v:split(lpeg.S("\n"..tokens), true)
			for i = 1, #ls do
				local vv = ls[i]
				if vv == "\n" then
					ret[#ret+1] = true
				else
					ret[#ret+1] = vv
				end
			end
		else
			ret[#ret+1] = v
		end
	end
	return ret
end

function tstring:extractLines()
	local rets = {}
	local ret = tstring{}
	local v, tv
	for i = 1, #self do
		v = self[i]
		tv = type(v)
		if tv == true then
			rets[#rets+1] = ret
			ret = tstring{}
		else
			ret[#ret+1] = v
		end
	end
	rets[#rets+1] = ret
	return rets
end

function tstring:isEmpty()
	return #self == 0
end

function tstring:makeLineTextures(max_width, font, no_split, r, g, b)
	local list = no_split and self or self:splitLines(max_width, font)
	local fh = font:lineSkip()
	local s = core.display.newSurface(max_width, fh)
	s:erase(0, 0, 0, 0)
	local texs = {}
	local w = 0
	local r, g, b = r or 255, g or 255, b or 255
	local oldr, oldg, oldb = r, g, b
	local v, tv
	for i = 1, #list do
		v = list[i]
		tv = type(v)
		if tv == "string" then
			s:drawStringBlended(font, v, w, 0, r, g, b, true)
			w = w + fontoldsize(font, v)
		elseif tv == "boolean" then
			w = 0
			local dat = {w=max_width, h=fh}
			dat._tex, dat._tex_w, dat._tex_h = s:glTexture()
			texs[#texs+1] = dat
			s:erase(0, 0, 0, 0)
		else
			if v[1] == "color" and v[2] == "LAST" then
				r, g, b = oldr, oldg, oldb
			elseif v[1] == "color" and not v[3] then
				oldr, oldg, oldb = r, g, b
				r, g, b = unpack(colors.simple(colors[v[2]] or {255,255,255}))
			elseif v[1] == "color" then
				oldr, oldg, oldb = r, g, b
				r, g, b = v[2], v[3], v[4]
			elseif v[1] == "font" then
				font:setStyle(v[2])
			elseif v[1] == "extra" then
				--
			elseif v[1] == "uid" then
				local e = __uids[v[2]]
				if e then
					local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
					if surf then
						local sw = surf:getSize()
						s:merge(surf, w, 0)
						w = w + sw
					end
				end
			end
		end
	end

	-- Last line
	local dat = {w=max_width, h=fh}
	dat._tex, dat._tex_w, dat._tex_h = s:glTexture()
	texs[#texs+1] = dat

	return texs
end

function tstring:drawOnSurface(s, max_width, max_lines, font, x, y, r, g, b, no_alpha, on_word)
	local list = self:splitLines(max_width, font)
	max_lines = util.bound(max_lines or #list, 1, #list)
	local fh = font:lineSkip()
	local w, h = 0, 0
	r, g, b = r or 255, g or 255, b or 255
	local oldr, oldg, oldb = r, g, b
	local v, tv
	local on_word_w, on_word_h
	for i = 1, #list do
		v = list[i]
		tv = type(v)
		if tv == "string" then
			if on_word then on_word_w, on_word_h = on_word(v, w, h) end
			if on_word_w and on_word_h then
				w, h = on_word_w, on_word_h
			else
				s:drawStringBlended(font, v, x + w, y + h, r, g, b, not no_alpha)
				w = w + fontoldsize(font, v)
			end
		elseif tv == "boolean" then
			w = 0
			h = h + fh
			max_lines = max_lines - 1
			if max_lines <= 0 then break end
		else
			if v[1] == "color" and v[2] == "LAST" then
				r, g, b = oldr, oldg, oldb
			elseif v[1] == "color" and not v[3] then
				oldr, oldg, oldb = r, g, b
				r, g, b = unpack(colors.simple(colors[v[2]] or {255,255,255}))
			elseif v[1] == "color" then
				oldr, oldg, oldb = r, g, b
				r, g, b = v[2], v[3], v[4]
			elseif v[1] == "font" then
				font:setStyle(v[2])
			elseif v[1] == "extra" then
				--
			elseif v[1] == "uid" then
				local e = __uids[v[2]]
				if e then
					local surf = e:getEntityFinalSurface(game.level.map.tiles, font:lineSkip(), font:lineSkip())
					if surf then
						local sw = surf:getSize()
						s:merge(surf, x + w, y + h)
						w = w + sw
					end
				end
			end
		end
	end
end

function tstring:diffWith(str2, on_diff)
	local res = tstring{}
	local j = 1
	for i = 1, #self do
		if type(self[i]) == "string" and self[i] ~= str2[j] then
			on_diff(self[i], str2[j], res)
		else
			res:add(self[i])
		end
		j = j + 1
	end
	return res
end

-- Make tstring into an object
local tsmeta = {__index=tstring, __tostring = tstring.toString}
setmetatable(tstring, {
	__call = function(self, t)
		setmetatable(t, tsmeta)
		return t
	end,
})


dir_to_angle = {
	[1] = 225,
	[2] = 270,
	[3] = 315,
	[4] = 180,
	[5] = 0,
	[6] = 0,
	[7] = 135,
	[8] = 90,
	[9] = 45,
}
dir_to_coord = {
	[1] = {-1, 1},
	[2] = { 0, 1},
	[3] = { 1, 1},
	[4] = {-1, 0},
	[5] = { 0, 0},
	[6] = { 1, 0},
	[7] = {-1,-1},
	[8] = { 0,-1},
	[9] = { 1,-1},
}
coord_to_dir = {
	[-1] = {
		[-1] = 7,
		[ 0] = 4,
		[ 1] = 1,
	},
	[ 0] = {
		[-1] = 8,
		[ 0] = 5,
		[ 1] = 2,
	},
	[ 1] = {
		[-1] = 9,
		[ 0] = 6,
		[ 1] = 3,
	},
}

dir_sides =
{
	[1] = {left=2, right=4},
	[2] = {left=3, right=1},
	[3] = {left=6, right=2},
	[4] = {left=1, right=7},
	[5] = {left=7, right=9}, -- To avoid problems
	[6] = {left=9, right=3},
	[7] = {left=4, right=8},
	[8] = {left=7, right=9},
	[9] = {left=8, right=6},
}

opposed_dir = {
	[1] = 9,
	[2] = 8,
	[3] = 7,
	[4] = 6,
	[5] = 5,
	[6] = 4,
	[7] = 3,
	[8] = 2,
	[9] = 1,
}

util = {}

function util.getDir(x1, y1, x2, y2)
	local xd, yd = x1 - x2, y1 - y2
	if xd ~= 0 then xd = xd / math.abs(xd) end
	if yd ~= 0 then yd = yd / math.abs(yd) end
	return coord_to_dir[xd][yd], xd, yd
end

function util.coordAddDir(x, y, dir)
	return x + dir_to_coord[dir][1], y + dir_to_coord[dir][2]
end

function util.boundWrap(i, min, max)
	if i < min then i = max
	elseif i > max then i = min end
	return i
end
function util.bound(i, min, max)
	if min and i < min then i = min
	elseif max and i > max then i = max end
	return i
end
function util.scroll(sel, scroll, max)
	if sel > scroll + max - 1 then scroll = sel - max + 1 end
	if sel < scroll then scroll = sel end
	return scroll
end

function util.getval(val, ...)
	if type(val) == "function" then return val(...)
	elseif type(val) == "table" then return val[rng.range(1, #val)]
	else return val
	end
end

function util.loadfilemods(file, env)
	-- Base loader
	local prev, err = loadfile(file)
	if err then error(err) end
	setfenv(prev, env)

	for i, addon in ipairs(fs.list("/mod/addons/")) do
		local fn = "/mod/addons/"..addon.."/superload/"..file
		if fs.exists(fn) then
			local f, err = loadfile(fn)
			if err then error(err) end
			local base = prev
			setfenv(f, setmetatable({
				loadPrevious = function()
					local ok, err = pcall(base, bname)
					if not ok and err then error(err) end
				end
			}, {__index=env}))
			print("Loaded mod", f, fn)
			prev = f
		end
	end
	return prev
end

function core.fov.circle_grids(x, y, radius, block)
	if not x or not y then return {} end
	if radius == 0 then return {[x]={[y]=true}} end
	local grids = {}
	core.fov.calc_circle(x, y, game.level.map.w, game.level.map.h, radius, function(_, lx, ly)
		if block and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then return true end
	end,
	function(_, lx, ly)
		if not grids[lx] then grids[lx] = {} end
		grids[lx][ly] = true
	end, nil)

	-- point of origin
	if not grids[x] then grids[x] = {} end
	grids[x][y] = true

	return grids
end

function core.fov.beam_grids(x, y, radius, dir, angle, block)
	if not x or not y then return {} end
	if radius == 0 then return {[x]={[y]=true}} end
	local grids = {}
	core.fov.calc_beam(x, y, game.level.map.w, game.level.map.h, radius, dir, angle, function(_, lx, ly)
		if block and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then return true end
	end,
	function(_, lx, ly)
		if not grids[lx] then grids[lx] = {} end
		grids[lx][ly] = true
	end, nil)

	-- point of origin
	if not grids[x] then grids[x] = {} end
	grids[x][y] = true

	return grids
end

function core.fov.beam_any_angle_grids(x, y, radius, delta_x, delta_y, angle, block)
	if not x or not y then return {} end
	if radius == 0 then return {[x]={[y]=true}} end
	local grids = {}
	core.fov.calc_beam_any_angle(x, y, game.level.map.w, game.level.map.h, radius, delta_x, delta_y, angle, function(_, lx, ly)
		if block and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then return true end
	end,
	function(_, lx, ly)
		if not grids[lx] then grids[lx] = {} end
		grids[lx][ly] = true
	end, nil)

	-- point of origin
	if not grids[x] then grids[x] = {} end
	grids[x][y] = true

	return grids
end

function core.fov.line(sx, sy, tx, ty, block, start_at_end)
	local what = type(block) == "string" and block or "block_sight"
	block = type(block) == "function" and block or
		block == false and function(_, x, y) return end or
		function(_, x, y)
			return game.level.map:checkAllEntities(x, y, what)
		end
	return core.fov.line_base(sx, sy, tx, ty, game.level.map.w, game.level.map.h, block)
end

tmps = core.fov.line_base(0, 0, 0, 0, 0, 0, function(_, x, y) end)
getmetatable(tmps).__index.step = function(l, block_corner, dont_stop_at_end)
	block_corner = type(block_corner) == "function" and block_corner or
		block_corner == false and function(_, x, y) return end or
		type(block_corner) == "string" and function(_, x, y) return game.level.map:checkAllEntities(x, y, what) end or
		function(_, x, y) return game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") and
			not game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "pass_projectile") end
	return l:step_base(dont_stop_at_end, game.level.map.w, game.level.map.h, block_corner)
end

--- Sets the permissiveness of FoV based on the shape of blocked terrain
-- @param val can be a number between 0 and 1 (least permissive to most permissive) or the name of a shape: square, diamond, octagon, firstpeek.
-- val = 0.0 is equivalent to "square", and val = 1.0 is equivalent to "diamond"
-- "firstpeek" is the least permissive setting that allows @ to see r below:
-- @##
-- ..r
function core.fov.set_permissiveness(val)
	val = type(val) == "string" and (string.lower(val) == "square" and 0.0 or
						string.lower(val) == "diamond" and 0.5 or
						string.lower(val) == "octagon" and 1 - math.sqrt(0.5) or   --0.29289321881345247560 or
						string.lower(val) == "firstpeek" and 0.167) or
					type(tonumber(val)) == "number" and 0.5*tonumber(val)

	if type(val) ~= "number" then return end
	val = util.bound(val, 0.0, 0.5)
	core.fov.set_permissiveness_base(val)
	return val
end

--- Finds free grids around coords in a radius.
-- This will return a random grid, the closest possible to the epicenter
-- @param sx the epicenter coordinates
-- @param sy the epicenter coordinates
-- @param radius the radius in which to search
-- @param block true if we only consider line of sight
-- @param what a table which can have the fields Map.ACTOR, Map.OBJECT, ..., set to true. If so it will only return grids that are free of this kind of entities.
function util.findFreeGrid(sx, sy, radius, block, what)
	if not sx or not sy then return nil, nil, {} end
	what = what or {}
	local grids = core.fov.circle_grids(sx, sy, radius, block)
	local gs = {}
	for x, yy in pairs(grids) do for y, _ in pairs(yy) do
		local ok = true
		if not game.level.map:isBound(x, y) then ok = false end
		for w, _ in pairs(what) do
--			print("findFreeGrid test", x, y, w, ":=>", game.level.map(x, y, w))
			if game.level.map(x, y, w) then ok = false end
		end
		if game.level.map:checkEntity(x, y, game.level.map.TERRAIN, "block_move") then ok = false end
--		print("findFreeGrid", x, y, "from", sx,sy,"=>", ok)
		if ok then
			gs[#gs+1] = {x, y, core.fov.distance(sx, sy, x, y), rng.range(1, 1000)}
		end
	end end

	if #gs == 0 then return nil end

	table.sort(gs, function(a, b)
		if a[3] == b[3] then
			return a[4] < b[4]
		else
			return a[3] < b[3]
		end
	end)

--	print("findFreeGrid using", gs[1][1], gs[1][2])
	return gs[1][1], gs[1][2], gs
end

function util.showMainMenu(no_reboot, reboot_engine, reboot_engine_version, reboot_module, reboot_name, reboot_new, reboot_einfo)
	-- Turn based by default
	core.game.setRealtime(0)

	-- Save any remaining files
	savefile_pipe:forceWait()

	if game and type(game) == "table" and game.__session_time_played_start then
		if game.onDealloc then game:onDealloc() end
		profile:saveGenericProfile("modules_played", {name=game.__mod_info.short_name, time_played={"inc", os.time() - game.__session_time_played_start}})
	end

	-- Join threads
	if game and type(game) == "table" then game:joinThreads(30) end

	if no_reboot then
		local Module = require("engine.Module")
		local ms = Module:listModules(true)
		local mod = ms[__load_module]
		Module:instanciate(mod, __player_name, __player_new, true)
	else
		-- Tell the C engine to discard the current lua state and make a new one
		print("[MAIN] rebooting lua state: ", reboot_engine, reboot_engine_version, reboot_module, reboot_name, reboot_new)
		core.game.reboot("te4core", -1, reboot_engine or "te4", reboot_engine_version or "LATEST", reboot_module or "boot", reboot_name or "player", reboot_new, reboot_einfo or "")
	end
end

function util.factorial(n)
	if n == 0 then
		return 1
	else
		return n * util.factorial(n - 1)
	end
end

function rng.poissonProcess(k, turn_scale, rate)
	return math.exp(-rate*turn_scale) * ((rate*turn_scale) ^ k)/ util.factorial(k)
end

function util.show_backtrace()
	local level = 2

	print("backtrace:")
	while true do
		local stacktrace = debug.getinfo(level, "nlS")
		if stacktrace == nil then break end
		print(("    function: %s (%s) at %s:%d"):format(stacktrace.name or "???", stacktrace.what, stacktrace.source or stacktrace.short_src or "???", stacktrace.currentline))
		level = level + 1
	end
end

function util.uuid()
	local x = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'}
	local y = {'8', '9', 'a', 'b'}
	local tpl = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	local uuid = tpl:gsub("[xy]", function(c) if c=='y' then return rng.table(y) else return rng.table(x) end end)
	return uuid
end

function util.browserOpenUrl(url)
	local tries = {
		"rundll32 url.dll,FileProtocolHandler %s",  -- Windows
		"open %s",  -- OSX
		"xdg-open %s",  -- Linux - portable way
		"gnome-open %s",  -- Linux - Gnome
		"kde-open %s",  -- Linux - Kde
		"firefox %s",  -- Linux - try to find something
		"mozilla-firefox %s",  -- Linux - try to find something
	}
	while #tries > 0 do
		local urlbase = table.remove(tries, 1)
		urlbase = urlbase:format(url)
		print("Trying to run URL with command: ", urlbase)
		if os.execute(urlbase) == 0 then return true end
	end
	return false
end

-- Ultra weird, this is used by the C serialization code because I'm too dumb to make lua_dump() work on windows ...
function __dump_fct(f)
	return string.format("%q", string.dump(f))
end

-- Tries to load a lua module from a list, returns the first available
function require_first(...)
	local list = {...}
	for i = 1, #list do
		local ok, m = xpcall(function() return require(list[i]) end, function(...)
			local str = debug.traceback(...)
			if not str:find("No such file or directory") then print(str) end
		end)
		if ok then return m end
	end
	return nil
end

