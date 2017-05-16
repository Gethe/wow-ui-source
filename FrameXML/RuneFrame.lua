--Readability == win
local RUNETYPE_BLOOD = 1;
local RUNETYPE_UNHOLY = 2;
local RUNETYPE_FROST = 3;
local RUNETYPE_DEATH = 4;

local CURRENT_MAX_RUNES = 0;
local MAX_RUNE_CAPACITY = 7;
local POWER_TYPE_RUNES = 5;
local RUNES_DISPLAY_MODIFIER = 10;

local RUNE_KEY_BY_SPEC = {
	[1] = "Blood",
	[2] = "Frost",
	[3] = "Unholy",
};

local CD_EDGE_BY_SPEC = {
	[1] = "BloodUnholy",
	[2] = "Frost",
	[3] = "BloodUnholy",
};

RuneButtonMixin = {};

function RuneButtonMixin:OnEnter()
	if ( self.tooltipText ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		GameTooltip:SetText(self.tooltipText, 1, 1, 1);
		GameTooltip:AddLine(RUNES_TOOLTIP, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

RuneFrameMixin = {};

function RuneFrameMixin:OnLoad()
	-- Disable rune frame if not a death knight.
	local _, class = UnitClass("player");

	if ( class ~= "DEATHKNIGHT" ) then
		self:Hide();
		return;
	end

	self:RegisterEvent("RUNE_POWER_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:SetScript("OnEvent", self.OnEvent);

	self.runeIndexes = {};
	for i = 1, #self.Runes do
		tinsert(self.runeIndexes, i); 
	end
	
	self.runesOnCooldown = {};
end

function RuneFrameMixin:OnEvent(event, ...)
	if ( event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_ENTERING_WORLD" ) then
		self:UpdateRunes(true);
	elseif ( event == "RUNE_POWER_UPDATE") then
		C_Timer.After(.2, function() self:UpdateRunes() end);
	end
end

local function RuneComparison(runeAIndex, runeBIndex)
	local runeAStart, runeADuration, runeARuneReady = GetRuneCooldown(runeAIndex);
	local runeBStart, runeBDuration, runeBRuneReady = GetRuneCooldown(runeBIndex);

	if (runeARuneReady ~= runeBRuneReady) then
		return runeARuneReady;
	end

	if (runeAStart ~= runeBStart) then
		return runeAStart < runeBStart;
	end

	return runeAIndex < runeBIndex;
end

function RuneFrameMixin:UpdateRunes(isSpecChange)
	local specIndex = GetSpecialization();
	table.sort(self.runeIndexes, RuneComparison);

	for index, runeIndex in ipairs(self.runeIndexes) do
		local runeButton = self.Runes[index];
		local cooldown = runeButton.Cooldown;

		if (isSpecChange) then
			cooldown:SetSwipeTexture("Interface\\PlayerFrame\\DK-"..RUNE_KEY_BY_SPEC[specIndex].."-Rune-CDFill");
			cooldown:SetEdgeTexture("Interface\\PlayerFrame\\DK-"..CD_EDGE_BY_SPEC[specIndex].."-Rune-CDSpark");
		end

		local start, duration, runeReady = GetRuneCooldown(runeIndex);

		if not runeReady  then
			if start then
				cooldown:SetCooldown(start, duration);
				self.runesOnCooldown[index] = runeIndex;
			end
			runeButton.Rune:SetAtlas("DK-Rune-CD");
			runeButton.energize:Stop();
		else
			runeButton.Rune:SetAtlas("DK-"..RUNE_KEY_BY_SPEC[specIndex].."-Rune-Ready");
			if (self.runesOnCooldown[index]) then
				local _, _, runeReadyNow = GetRuneCooldown(self.runesOnCooldown[index]);
				if (runeReadyNow) then
					runeButton.energize:Play();
					self.runesOnCooldown[index] = nil;
				end
			end
			cooldown:Hide();
		end
	end
end

