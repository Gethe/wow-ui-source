--Readability == win
local RUNETYPE_BLOOD = 1;
local RUNETYPE_UNHOLY = 2;
local RUNETYPE_FROST = 3;
local RUNETYPE_DEATH = 4;

local CURRENT_MAX_RUNES = 0;
local MAX_RUNE_CAPACITY = 7;
local POWER_TYPE_RUNES = 5;
local RUNES_DISPLAY_MODIFIER = 10;

local runeColor = {0.8, 0.1, 1};

function RuneButton_OnLoad (self)
	self.shine = self.Textures.Shine;
	self.tooltipText = _G["COMBAT_TEXT_RUNE_DEATH"];
end

function RuneButton_Flash (self)
	self.shine:SetVertexColor(unpack(runeColor));
	RuneButton_ShineFadeIn(self.shine)
end

function RuneButton_OnEnter(self)
	if ( self.tooltipText ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		GameTooltip:SetText(self.tooltipText, 1, 1, 1);
		GameTooltip:AddLine(RUNES_TOOLTIP, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function RuneButton_OnLeave(self)
	GameTooltip:Hide();
end

function RuneFrame_OnLoad (self)
	-- Disable rune frame if not a death knight.
	local _, class = UnitClass("player");
	
	if ( class ~= "DEATHKNIGHT" ) then
		self:Hide();
		return;
	end
	
	self:RegisterEvent("RUNE_POWER_UPDATE");
	self:RegisterEvent("RUNE_TYPE_UPDATE");
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:SetScript("OnEvent", RuneFrame_OnEvent);
end

function RuneFrame_OnEvent (self, event, ...)
	if ( event == "UNIT_MAXPOWER") then
		RuneFrame_UpdateNumberOfShownRunes();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		RuneFrame_UpdateNumberOfShownRunes();
		for i=1, CURRENT_MAX_RUNES do
			RuneFrame_RunePowerUpdate(i, false);
		end
	elseif ( event == "RUNE_POWER_UPDATE") then
		local runeIndex, isEnergize = ...;
		RuneFrame_RunePowerUpdate(runeIndex, isEnergize)
		
	elseif ( event == "RUNE_TYPE_UPDATE" ) then
		local runeIndex = ...;
		if ( runeIndex and runeIndex >= 1 and runeIndex <= CURRENT_MAX_RUNES ) then
			RuneButton_Flash(_G["RuneButtonIndividual"..runeIndex]);
		end
	end
end

function RuneFrame_RunePowerUpdate(runeIndex, isEnergize)
	if runeIndex and runeIndex >= 1 and runeIndex <= CURRENT_MAX_RUNES  then 
		local runeButton = _G["RuneButtonIndividual"..runeIndex];
		local cooldown = runeButton.Cooldown;
			
		local start, duration, runeReady = GetRuneCooldown(runeIndex);
			
		if not runeReady  then
			if start then
				CooldownFrame_Set(cooldown, start, duration, true, true);
			end
			runeButton.energize:Stop();
		else
			cooldown:Hide();
			if (not isEnergize and not runeButton.energize:IsPlaying()) then 
				runeButton.shine:SetVertexColor(1, 1, 1);
				RuneButton_ShineFadeIn(runeButton.shine)
			end
		end
			
		if isEnergize  then
			runeButton.energize:Play();
		end
	else 
		assert(false, "Bad rune index")
	end
end

function RuneFrame_UpdateNumberOfShownRunes()
	CURRENT_MAX_RUNES = UnitPowerMax(RuneFrame:GetParent().unit, SPELL_POWER_RUNES);
	for i=1, MAX_RUNE_CAPACITY do
		local runeButton = _G["RuneButtonIndividual"..i];
		if(i <= CURRENT_MAX_RUNES) then
			runeButton:Show();
		else
			runeButton:Hide();
		end
		-- Shrink the runes sizes if you have all 7
		if (CURRENT_MAX_RUNES == MAX_RUNE_CAPACITY) then
			runeButton.Border:SetSize(21, 21);
			runeButton.rune:SetSize(21, 21);
			runeButton.Textures.Shine:SetSize(52, 31);
			runeButton.energize.RingScale:SetFromScale(0.6, 0.7);
			runeButton.energize.RingScale:SetToScale(0.7, 0.7);
			runeButton:SetSize(15, 15);
		else
			runeButton.Border:SetSize(24, 24);
			runeButton.rune:SetSize(24, 24);
			runeButton.Textures.Shine:SetSize(60, 35);
			runeButton.energize.RingScale:SetFromScale(0.7, 0.8);
			runeButton.energize.RingScale:SetToScale(0.8, 0.8);
			runeButton:SetSize(18, 18);
		end
	end
end

function RuneButton_ShineFadeIn(self)
	if self.shining then
		return
	end
	local fadeInfo={
	mode = "IN",
	timeToFade = 0.5,
	finishedFunc = RuneButton_ShineFadeOut,
	finishedArg1 = self,
	}
	self.shining=true;
	UIFrameFade(self, fadeInfo);
end

function RuneButton_ShineFadeOut(self)
	self.shining=false;
	UIFrameFadeOut(self, 0.5);
end