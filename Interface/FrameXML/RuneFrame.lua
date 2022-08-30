--Readability == win
local FirstTime = true;
local RUNETYPE_BLOOD = 1;
local RUNETYPE_FROST = 2;
local RUNETYPE_UNHOLY = 3;
local RUNETYPE_DEATH = 4;

local iconTextures = {};
iconTextures[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood";
iconTextures[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost";
iconTextures[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy";
iconTextures[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death";

local runeTextures = {
	[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Blood-Off.tga",
	[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Frost-Off.tga",
	[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Death-Off.tga",
	[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Chromatic-Off.tga",
}

local runeColors = {
	[RUNETYPE_BLOOD] = {1, 0, 0},
	[RUNETYPE_FROST] = {0, 1, 1},
	[RUNETYPE_UNHOLY] = {0, 0.5, 0},
	[RUNETYPE_DEATH] = {0.8, 0.1, 1},
}
runeMapping = {
	[1] = "BLOOD",
	[2] = "FROST",
	[3] = "UNHOLY",
	[4] = "DEATH",
}

function RuneButton_OnLoad (self)
	RuneFrame_AddRune(RuneFrame, self);
	
	self.rune = _G[self:GetName().."Rune"];
	self.fill = _G[self:GetName().."Fill"];
	self.shine = _G[self:GetName().."ShineTexture"];

	RuneButton_Update(self);
end

function RuneButton_OnUpdate (self, elapsed, ...)
	
	local cooldown = _G[self:GetName().."Cooldown"];
	local index = self:GetID();

	local start, duration, runeReady = GetRuneCooldown(index); 
	
	local displayCooldown = (runeReady and 0) or 1;
	
	if ( displayCooldown and start and start > 0 and duration and duration > 0) then
		CooldownFrame_Set(cooldown, start, duration, displayCooldown, true);
	end
;

	if ( runeReady ) then
		self:SetScript("OnUpdate", nil);
		
	end
end

function RuneButton_Update (self, rune, dontFlash)
	rune = rune or self:GetID();
	local runeType = GetRuneType(rune);

	if ( (not dontFlash) and (runeType) and (runeType ~= self.rune.runeType)) then 
		self.shine:SetVertexColor(unpack(runeColors[runeType]));
		RuneButton_ShineFadeIn(self.shine)
	end
	
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
	
	self.runes = {};
	
end

function RuneFrame_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( FirstTime ) then
			RuneFrame_FixRunes(self);
			FirstTime = false;
		end
		for rune in next, self.runes do
			RuneButton_Update(self.runes[rune], rune, true);
		end
	elseif ( event == "RUNE_POWER_UPDATE" ) then
		local rune, usable= ...;
		if ( not usable and rune and self.runes[rune] ) then
			self.runes[rune]:SetScript("OnUpdate", RuneButton_OnUpdate);
		elseif ( usable and rune and self.runes[rune] ) then
			self.runes[rune].shine:SetVertexColor(1, 1, 1);
			RuneButton_ShineFadeIn(self.runes[rune].shine)

			self:SetScript("OnUpdate", nil);
		end
	elseif ( event == "RUNE_TYPE_UPDATE" ) then		
		local rune = ...;
		if ( rune ) then
			RuneButton_Update(self.runes[rune], rune);
		end
	end
end

function RuneFrame_AddRune (runeFrame, rune)
	tinsert(runeFrame.runes, rune);
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

function RuneFrame_FixRunes	(runeFrame)	--We want to swap where frost and unholy appear'
	local temp;
	
	temp = runeFrame.runes[3];
	runeFrame.runes[3] = runeFrame.runes[5];
	runeFrame.runes[5] = temp;
	
	temp = runeFrame.runes[4];
	runeFrame.runes[4] = runeFrame.runes[6];
	runeFrame.runes[6] = temp;
end