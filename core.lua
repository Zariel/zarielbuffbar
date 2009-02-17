--[[
Copyright (c) 2008 Chris Bannister,
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
local _G = getfenv(0)

local GetPlayerBuffName = GetPlayerBuffName
local GetPlayerBuff = GetPlayerBuff
local DebuffTypeColor = DebuffTypeColor
local GetPlayerBuffDispelType = GetPlayerBuffDispelType
local GetPlayerBuffApplications = GetPlayerBuffApplications
local DebuffTypeColor = DebuffTypeColor

local s_sub = string.sub
local gmatch = string.gmatch
local mod = math.fmod
local floor = math.floor
local format = string.format

local snova = "Interface\\AddOns\\ZarielBuffBar\\nokiafc22.ttf"
local number = "Fonts\\ARIALN.TTF"

local caith = "Interface\\AddOns\\ZarielBuffBar\\apathy\\Normal.tga"

BUFF_ROW_SPACING = 25

BuffFrame_OnUpdate = function() end

TemporaryEnchantFrame:ClearAllPoints()
TemporaryEnchantFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -5, -15)
TemporaryEnchantFrame.SetPoint = function() end

QuestWatchFrame:ClearAllPoints()
QuestWatchFrame:SetPoint("TOPLEFT", MinimapCluster, "TOPRIGHT", 10, -5)

local subs = setmetatable({}, {
	__mode = "k",
})

local Truncate = function(str)
	if subs[str] then
		return subs[str]
	else
		if not str then return end
		local s = ""
		for w in gmatch(str, "%S+") do s = s .. s_sub(w, 1, 1) end

		s = s_sub(s, 1, 4)

		subs[str] = s

		return s
	end
end

local AddText = function(buttonName, index, filter)
	local buffIndex = index
	local buffName = buttonName .. index
	local buff = _G[buffName]
	local time = _G[buffName .. "Duration"]
	local count = _G[buffName .. "Count"]
	if count then count.show = function() end; count:Hide() end

	local name = Truncate(UnitAura("player", buffIndex, filter))

	if buff.Text then
		if name and name ~= buff.Text:GetText() then
			buff.Text:SetText(name)
		end
	else
		local text = buff:CreateFontString(nil, "OVERLAY")
		text:SetFont(snova, 8, "THINOUTLINE")
		text:SetShadowOffset(1, -1)
		text:SetShadowColor(0,0,0,1)
		text:SetPoint("CENTER")
		text:SetPoint("TOP", buff, "BOTTOM", 0, -2)
		text:SetText(name)
		text:SetJustifyH("CENTER")
		buff.Text = text
	end

	if filter and filter == "HARMFUL" then
		local col = DebuffTypeColor[select(4, UnitAura("player", buffIndex, filter))]
		if col then
			buff.Text:SetTextColor(col.r, col.g, col.b)
		else
			buff.Text:SetTextColor(1, 0, 0)
		end
	else
		buff.Text:SetTextColor(0, 1, 0)
	end

	if not time.Set then
		time:ClearAllPoints()
		time.ClearAllPoints = function() end
		time:SetParent(buff)
		time:SetPoint("CENTER")
		time:SetPoint("BOTTOM", buff, "TOP", 0, 2)
		time:SetTextColor(1, 1, 1, 1)
		time.SetVertexColor = function() end

		time:SetFont(snova, 8, "THINOUTLINE")
		time:SetShadowOffset(1, -1)
		time:SetShadowColor(0,0,0,0.8)

		time:SetJustifyH("CENTER")
		time.Set = true
	end

	local num = select(4, UnitAura("player", buffIndex, filter)) or 0
	if num > 1 then
		if buff.count then
			if buff.count:GetText() ~= num then
				buff.count:SetText(num)
			end
		else
			local count = buff:CreateFontString(nil, "OVERLAY")
			count:SetFont("Fonts\\ARIALN.TTF", 18, "OUTLINE")
			count:ClearAllPoints()
			count:SetPoint("CENTER", buff, "CENTER")
			count:SetTextColor(1, 0, 0, 1)
			count:SetShadowColor(0, 0, 0, 1)
			count:SetShadowOffset(1, -1)
			count:SetText(num)
			buff.count = count
		end
		buff.count:Show()
	else
		if buff.count then
			buff.count:Hide()
		end
	end
end

local border = function(name, index)
	local buff = _G[name .. index]
	local b = _G[name .. index .. "Border"]

	if b then
		b:Hide()
		b.Show = function() end
	end

	local col = DebuffTypeColor[select(4, UnitAura("player", index, filter))]

	if col then
		buff.bg:SetVertexColor(0.45 * col.r, 0.45 * col.g, 0.45 * col.b)
	else
		buff.bg:SetVertexColor(0.45, 0, 0)
	end
end

local Skin = function(button, index)
	local buff = _G[button .. index]
	local icon = _G[button .. index .. "Icon"]

	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	icon:SetParent(buff)
	icon:ClearAllPoints()
	icon:SetPoint("LEFT", 2, 0)
	icon:SetPoint("RIGHT", -2, 0)
	icon:SetPoint("TOP", 0, -2)
	icon:SetPoint("BOTTOM", 0, 2)
	icon:SetDrawLayer("ARTWORK")

	if not buff.bg then
		local skin = buff:CreateTexture(nil, "ARTWORK")
		skin:SetTexture(caith)
		--skin:SetBlendMode("BLEND")
		skin:SetPoint("TOP", 0, 2)
		skin:SetPoint("LEFT", -2, 0)
		skin:SetPoint("BOTTOM", 0, -2)
		skin:SetPoint("RIGHT", 2, 0)
		skin:SetHeight(33)
		skin:SetWidth(33)
		skin:SetVertexColor(0.45, 0.45, 0.45)
		buff.bg = skin
	end

	buff.Skinned = true
end

local f = CreateFrame("Frame")

local OnEvent = function(self, event, unit)
	return self[event](self, unit)
end

function f:UNIT_AURA(unit)
	if unit ~= "player" then return end

	BUFF_ROW_SPACING = 30

	for i = 1, 40 do
		local buff = _G["BuffButton"..i]
		local debuff = _G["DebuffButton" .. i]

		if buff then
			AddText("BuffButton", i, "HELPFUL")
			if not buff.Skinned then
				Skin("BuffButton", i)
			end
		end

		if debuff then
			AddText("DebuffButton", i, "HARMFUL")
			if not debuff.Skinned then
				Skin("DebuffButton", i)
			end
			border("DebuffButton", i)
		end

		if not buff and not debuff then break end
	end
end

function f:PLAYER_LOGIN()
	self:UNIT_AURA("player")

	Skin("TempEnchant", 1)
	Skin("TempEnchant", 2)

	border("TempEnchant", 1)
	border("TempEnchant", 2)

	AddText("TempEnchant", 1)
	AddText("TempEnchant", 2)

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

f:UNIT_AURA("player")

f:SetScript("OnEvent", OnEvent)
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("PLAYER_LOGIN")

SecondsToTimeAbbrev = function(time)
	local hr, m, s, text
	if time <= 0 then text = ""
	elseif time < 3600 then
		m = floor(time / 60)
		s = mod(time, 60)
		if m > 9 then
			text = format("%dm", m)
		elseif m == 0 then
			text = format("%ds", s)
		else
			text = format("%d:%02d", m, s)
		end
	else
		hr = floor(time / 3600)
		m = floor(mod(time, 3600) / 60)
		text = format("%d.%2d h", hr, m)
	end

	return text
end
