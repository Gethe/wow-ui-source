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

local function GetRuneKeyBySpec(specIndex)
	return RUNE_KEY_BY_SPEC[specIndex] or "Base";
end

local CD_EDGE_BY_SPEC = {
	[1] = "BloodUnholy",
	[2] = "Frost",
	[3] = "BloodUnholy",
};

local function GetCDEdgeBySpec(specIndex)
	return CD_EDGE_BY_SPEC[specIndex] or "BloodUnholy";
end

RuneButtonMixin = {};

function RuneButtonMixin:OnEnter()
	if ( self.tooltipText ) then
		GameTooltip:SetOwner(self:GetParent(), "ANCHOR_BOTTOMRIGHT");
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
	self.spentAnimsActive = 0;
end

function RuneFrameMixin:OnEvent(event, ...)
	if ( event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_ENTERING_WORLD" ) then
		self:UpdateRunes(true);
	elseif ( event == "RUNE_POWER_UPDATE") then
		self:UpdateRunes();
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

function RuneFrameMixin:IsAnimatingRunesSpent()
	return self.spentAnimsActive > 0;
end

function RuneFrameMixin:OnSpentAnimStarted()
	self.spentAnimsActive = self.spentAnimsActive + 1;
end

function RuneFrameMixin:OnSpentAnimStopped()
	self.spentAnimsActive = self.spentAnimsActive - 1;
	if self.spentAnimsActive == 0 then
		self:UpdateRunes(false);
	end
end

function RuneFrameMixin:UpdateRunes(isSpecChange)
	local specIndex = GetSpecialization();
	table.sort(self.runeIndexes, RuneComparison);

	if not isSpecChange and GetCVarBool("enableRuneSpentAnim") then
		local numRunes = 0;
		local previousNumRunes = 0;
		for index, runeIndex in ipairs(self.runeIndexes) do
			local _, _, runeReady = GetRuneCooldown(runeIndex);
			if runeReady then
				numRunes = numRunes + 1;
			end
			
			if not self.runesOnCooldown[index] then
				previousNumRunes = previousNumRunes + 1;
			end
		end
		
		if numRunes < previousNumRunes then
			local flashTime = tonumber(GetCVar("runeSpentFlashTime")) or 0.15;
			local fadeTime = tonumber(GetCVar("runeSpentFadeTime")) or 0.1;
			for i = 1, previousNumRunes - numRunes do
				local index = numRunes + i;
				self.Runes[index].energize:Stop();
				self.Runes[index].spent.RuneFlash:SetDuration(flashTime);
				self.Runes[index].spent.RuneFade:SetStartDelay(flashTime);
				self.Runes[index].spent.RuneFade:SetDuration(fadeTime);
				self.Runes[index].spent:Play();
			end
		end
	end
	
	for index, runeIndex in ipairs(self.runeIndexes) do
		local runeButton = self.Runes[index];
		local cooldown = runeButton.Cooldown;

		if (isSpecChange) then
			cooldown:SetSwipeTexture("Interface\\PlayerFrame\\DK-"..GetRuneKeyBySpec(specIndex).."-Rune-CDFill");
			cooldown:SetEdgeTexture("Interface\\PlayerFrame\\DK-"..GetCDEdgeBySpec(specIndex).."-Rune-CDSpark");
		end

		local start, duration, runeReady = GetRuneCooldown(runeIndex);

		if not runeReady then
			self.runesOnCooldown[index] = runeIndex;
			if not self:IsAnimatingRunesSpent() then
				if start then
					cooldown:SetCooldown(start, duration);
				end
				runeButton.Rune:SetAlpha(0);
				runeButton.energize:Stop();
			end
		else
			if not runeButton.spent:IsPlaying() then
				runeButton.Rune:SetAtlas("DK-"..GetRuneKeyBySpec(specIndex).."-Rune-Ready");
				if (self.runesOnCooldown[index]) then
					local _, _, runeReadyNow = GetRuneCooldown(self.runesOnCooldown[index]);
					if (runeReadyNow) then
						runeButton.energize.RuneFade:SetDuration(tonumber(GetCVar("runeFadeTime")) or 0.2);
						runeButton.energize:Play();
						self.runesOnCooldown[index] = nil;
					end
				else
					runeButton.Rune:SetAlpha(1);
				end

				cooldown:Hide();
			end
		end
	end
end

