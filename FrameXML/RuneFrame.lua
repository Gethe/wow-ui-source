--Readability == win
local RUNETYPE_BLOOD = 1;
local RUNETYPE_UNHOLY = 2;
local RUNETYPE_FROST = 3;
local RUNETYPE_DEATH = 4;

local MAX_RUNES = 6;


local iconTextures = {};
iconTextures[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood";
iconTextures[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy";
iconTextures[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost";
iconTextures[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death";

local runeTextures = {
	[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Blood-Off.tga",
	[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Death-Off.tga",
	[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Frost-Off.tga",
	[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Chromatic-Off.tga",
}



local runeEnergizeTextures = {
	[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\Deathknight-Energize-Blood",
	[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\Deathknight-Energize-Unholy",
	[RUNETYPE_FROST] = "Interface\\PlayerFrame\\Deathknight-Energize-Frost",
	[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\Deathknight-Energize-White",
}

local runeColors = {
	[RUNETYPE_BLOOD] = {1, 0, 0},
	[RUNETYPE_UNHOLY] = {0, 0.5, 0},
	[RUNETYPE_FROST] = {0, 1, 1},
	[RUNETYPE_DEATH] = {0.8, 0.1, 1},
}
runeMapping = {
	[1] = "BLOOD",
	[2] = "UNHOLY",
	[3] = "FROST",
	[4] = "DEATH",
}

function RuneButton_OnLoad (self)
	self.fill = _G[self:GetName().."Fill"];
	self.shine = _G[self:GetName().."ShineTexture"];
	self.colorOrb = _G[self:GetName().."RuneColorGlow"];
end

function RuneButton_Update (self, rune, dontFlash)
	local runeType = GetRuneType(rune);
	
	if ( (not dontFlash) and (runeType) and (runeType ~= self.rune.runeType)) then
		self.shine:SetVertexColor(unpack(runeColors[runeType]));
		RuneButton_ShineFadeIn(self.shine)
	end
	
	self.colorOrb:SetTexture(runeEnergizeTextures[runeType]);
	
	if (runeType) then
		self.rune:SetTexture(iconTextures[runeType]);
		self.rune:Show();
		self.rune.runeType = runeType;
		self.tooltipText = _G["COMBAT_TEXT_RUNE_"..runeMapping[runeType]];
	else
		self.rune:Hide();
		self.tooltipText = nil;
	end

end

function RuneButton_OnEnter(self)
	if ( self.tooltipText ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltipText);
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
	end
	
	self:RegisterEvent("RUNE_POWER_UPDATE");
	self:RegisterEvent("RUNE_TYPE_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	self:SetScript("OnEvent", RuneFrame_OnEvent);
end

function RuneFrame_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		for i=1,MAX_RUNES do
			local runeButton = _G["RuneButtonIndividual"..i];
			if runeButton then
				RuneButton_Update(runeButton, i, true);
			end
		end
	elseif ( event == "RUNE_POWER_UPDATE" ) then
		local runeIndex, isEnergize = ...;
		if runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES  then 
			local runeButton = _G["RuneButtonIndividual"..runeIndex];
			local cooldown = _G[runeButton:GetName().."Cooldown"];
			
			local start, duration, runeReady = GetRuneCooldown(runeIndex);
			
			if not runeReady  then
				if start then
					CooldownFrame_SetTimer(cooldown, start, duration, 1);
				end
				runeButton.energize:Stop();
			else
				cooldown:Hide();
				runeButton.shine:SetVertexColor(1, 1, 1);
				RuneButton_ShineFadeIn(runeButton.shine)
			end
			
			if isEnergize  then
				runeButton.energize:Play();
			end
		else 
			assert(false, "Bad rune index")
		end
	elseif ( event == "RUNE_TYPE_UPDATE" ) then
		local runeIndex = ...;
		if ( runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES ) then
			RuneButton_Update(_G["RuneButtonIndividual"..runeIndex], runeIndex);
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