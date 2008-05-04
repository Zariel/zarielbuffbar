BUFF_ROW_SPACING = 25

BuffFrame_OnUpdate = function() end

TemporaryEnchantFrame:ClearAllPoints()
TemporaryEnchantFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -30)
TemporaryEnchantFrame.SetPoint = function() end

QuestWatchFrame:ClearAllPoints()
QuestWatchFrame:SetPoint("TOPLEFT", MinimapCluster, "TOPRIGHT", 10, -5)

local print = function(str) return ChatFrame1:AddMessage(tostring(str)) end
local printf = function(str, ...) return ChatFrame1:AddMessage(tostring(str:format(...))) end

local Truncate = function(str)
	if not str then return end
	local s = ""
	for w in str:gmatch("%S+") do s = s .. w:sub(1, 1) end
	return s:sub(1, 4)
end

local AddText = function(buttonName, index, filter)
	local buffIndex = GetPlayerBuff(index, filter)
	local buffName = buttonName .. index
	local buff = _G[buffName]
	local time = _G[buffName .. "Duration"]
	local count = _G[buffName .. "Count"]

	local name = Truncate(GetPlayerBuffName(buffIndex))

	if buff.Text then
		if name and name ~= buff.Text:GetText() then
			buff.Text:SetText(name)
		end
	else
		local text = buff:CreateFontString(nil, "OVERLAY")
		text:SetFont(STANDARD_TEXT_FONT, 11)
		text:SetPoint("TOP", buff, "BOTTOM", 0, -1)
		text:SetShadowColor(0,0,0,1)
		text:SetShadowOffset(1, -1)
		text:SetText(name)
		buff.Text = text
	end

	if filter == "HARMFUL" then
		local col = DebuffTypeColor[GetPlayerBuffDispelType(id)]
		if col then
			buff.Text:SetTextColor(col.r, col.g, col.b)
		else
			buff.Text:SetTextColor(1, 0, 0)
		end
	else
		buff.Text:SetTextColor(0, 1, 0)
	end

	if time then
		time:ClearAllPoints()
		time:SetPoint("BOTTOM", buff, "TOP", 0, 1)
		time.ClearAllPoints = function() end
		time:SetTextColor(1, 1, 1, 1)
		time.SetTextColor = function() end

		time:SetShadowColor(0, 0, 0, 1)
		time:SetShadowOffset(1, -1)
		local font = time:GetFont()
		time:SetFont(font, 11)
	end

	local num = GetPlayerBuffApplications(id)
	if count and num > 0 then
		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", -2, 2)
		count:SetShadowColor(0,0,0,1)
		count:SetShadowOffset(1, -1)
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
	if unit ~= "player" or not unit then return end
	BUFF_ROW_SPACING = 25

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

f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("PLAYER_LOGIN")

OnEvent()
