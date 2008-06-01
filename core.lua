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

-- CPU usage reduced by ~ 150%
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


BUFF_ROW_SPACING = 25

BuffFrame_OnUpdate = function() end

TemporaryEnchantFrame:ClearAllPoints()
TemporaryEnchantFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -5, -30)
TemporaryEnchantFrame.SetPoint = function() end

QuestWatchFrame:ClearAllPoints()
QuestWatchFrame:SetPoint("TOPLEFT", MinimapCluster, "TOPRIGHT", 10, -5)

local print = function(str) return ChatFrame1:AddMessage(tostring(str)) end
local printf = function(str, ...) return ChatFrame1:AddMessage(tostring(str:format(...))) end

local subs = setmetatable({}, {
	__mode = "k",
})

local Truncate = function(str)
	if subs[str] then
		return subs[str]
	end

	if not str then return end
	local s = ""
	for w in gmatch(str, "%S+") do s = s .. s_sub(w, 1, 1) end

	s = s_sub(s, 1, 4)

	subs[str] = s

	return s
end

local AddText = function(buttonName, index, filter)
	local buffIndex = GetPlayerBuff(index, filter)
	local buffName = buttonName .. index
	local buff = _G[buffName]
	local time = _G[buffName .. "Duration"]
	local count = _G[buffName .. "Count"]
	if count then count.show = function() end; count:Hide() end

	local name = Truncate(GetPlayerBuffName(buffIndex))

	if buff.Text then
		if name and name ~= buff.Text:GetText() then
			buff.Text:SetText(name)
		end
	else
		local text = buff:CreateFontString(nil, "OVERLAY")
		text:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
		text:SetPoint("TOP", buff, "BOTTOM", 0, -1)
		--text:SetShadowColor(0,0,0,1)
		--text:SetShadowOffset(1, -1)
		text:SetText(name)
		buff.Text = text
	end

	if filter == "HARMFUL" then
		local col = DebuffTypeColor[GetPlayerBuffDispelType(buffIndex)]
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
		time:SetPoint("BOTTOM", buff, "TOP", 0, 1)
		time.ClearAllPoints = function() end
		time:SetTextColor(1, 1, 1, 1)
		time.SetVertexColor = function() end

		--time:SetShadowColor(0, 0, 0, 1)
		--time:SetShadowOffset(1, -1)
		local font = time:GetFont()
		time:SetFont(font, 11, "OUTLINE")
		time.Set = true
	end

	local num = GetPlayerBuffApplications(buffIndex)
	if num > 0 then
		if buff.count then
			if buff.count:GetText() ~= num then
				buff.count:SetText(num)
			end
		else
			local count = buff:CreateFontString(nil, "OVERLAY")
			count:SetFont(STANDARD_TEXT_FONT, 16, "THICKOUTLINE")
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

local border = function(index, filter)
	local id = GetPlayerBuff(index, "HARMFUL")
	local buff = _G["DebuffButton" .. index]
	local b = _G["DebuffButton" .. index .. "Border"]
	if b then
		b:Hide()
		b.Show = function() end
	end

	local col = DebuffTypeColor[GetPlayerBuffDispelType(id)]
	if col then
		buff.bg:SetBackdropColor(col.r, col.g, col.b, 0.6)
	else
		buff.bg:SetBackdropColor(1, 0, 0, 0.6)
	end
end

local Skin = function(button, index)
	local buff = _G[button .. index]
	local icon = _G[button .. index .. "Icon"]

	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	icon:SetPoint("TOPLEFT", 3, -3)
	icon:SetPoint("BOTTOMRIGHT", -3, 3)
	icon:SetDrawLayer("ARTWORK")

	if not buff.bg then
		local bg = CreateFrame("Button", nil, buff)
		bg:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
			insets = {left = 0, right = 0, top = 0, bottom = 0},
		})
		bg:SetBackdropColor(0, 0, 0, 0.6)
		bg:ClearAllPoints()
		bg:SetAllPoints(buff)
		bg:SetFrameLevel(1)
		bg:SetFrameStrata("BACKGROUND")
		buff.bg = bg
	end

	buff.Skinned = true
end

local f = CreateFrame("Frame")

local OnEvent = function(self, event, unit)
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
			border(i)
		end
		if not buff and not debuff then break end
	end
end

f:SetScript("OnEvent", OnEvent)
f:RegisterEvent("PLAYER_AURAS_CHANGED")

SecondsToTimeAbbrev = function(time)
	local hr, m, s, text
	if time <= 0 then text = ""
	elseif time < 3600 then
		m = floor(time / 60)
		s = mod(time, 60)
		text = (m == 0 and format("%d", s)) or format("%d:%02d", m, s)
	else
		hr = floor(time / 3600)
		m = floor(mod(time, 3600) / 60)
		text = format("%d.%2d h", hr, m)
	end
	return text
end
