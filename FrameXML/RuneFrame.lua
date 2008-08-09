--Readability == win
local FirstTime = true;
local RUNETYPE_BLOOD = 1;
local RUNETYPE_DEATH = 2;
local RUNETYPE_FROST = 3;
local RUNETYPE_CHROMATIC = 4;

local iconTextures = {};
iconTextures[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood";
iconTextures[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy";
iconTextures[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost";
iconTextures[RUNETYPE_CHROMATIC] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death";

local runeTextures = {
	[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Blood-Off.tga",
	[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Death-Off.tga",
	[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Frost-Off.tga",
	[RUNETYPE_CHROMATIC] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Chromatic-Off.tga",
}

function RuneButton_OnLoad (self)
	RuneFrame_AddRune(RuneFrame, self);
	
	self.rune = getglobal(self:GetName().."Rune");
	self.fill = getglobal(self:GetName().."Fill");
	RuneButton_Update(self);
end

function RuneButton_OnUpdate (self, elapsed)
	-- Constants that aren't used elsewhere and are actually constant are happiest inside their functions ;)
	--local RUNE_HEIGHT = 18;
	--local MIN_RUNE_ALPHA = .4
	
	local cooldown = getglobal(self:GetName().."Cooldown");
	local start, duration, runeReady = GetRuneCooldown(self:GetID());
	
	local displayCooldown = (runeReady and 0) or 1;
	
	CooldownFrame_SetTimer(cooldown, start, duration, displayCooldown);
	
	if ( ( GetTime()-start >= duration ) ) then
		RuneButton_ShineFadeIn(getglobal(self:GetName().."Shine"))
	end
	-- if ( not enable ) then
		-- self.fill:SetHeight(RUNE_HEIGHT * ((GetTime() - start)/duration));
		-- self.fill:SetTexCoord(0, 1, (1 - ((GetTime() - start)/duration)), 1);
		-- self.fill:SetAlpha(math.max(MIN_RUNE_ALPHA, (GetTime() - start)/duration));
	-- else
	
	if ( runeReady ) then
		-- self.fill:SetHeight(RUNE_HEIGHT);
		-- self.fill:SetTexCoord(0, 1, 0, 1);
		-- self.fill:SetAlpha(1);
		self:SetScript("OnUpdate", nil);
	end
end

function RuneButton_Update (self, rune)
	rune = rune or self:GetID();
	local runeType = GetRuneType(rune);
	
	if (runeType) then
		self.rune:SetTexture(iconTextures[runeType]);
		-- self.fill:SetTexture(iconTextures[runeType]);
		self.rune:Show();
		-- self.fill:Show();
	else
		self.rune:Hide();
		-- self.fill:Hide();
	end
end

function RuneFrame_OnLoad (self)
	-- Disable rune frame if not a death knight.
	local _, class = UnitClass("player");
	
	if ( class ~= "DEATHKNIGHT" ) then
		self:Hide();
	end
	
	self:RegisterEvent("RUNE_POWER_UPDATE");
	self:RegisterEvent("RUNE_TYPE_UPDATE");
	self:RegisterEvent("RUNE_REGEN_UPDATE");
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
			RuneButton_Update(self.runes[rune], rune);
		end
	elseif ( event == "RUNE_POWER_UPDATE" ) then
		local rune, usable = ...;
		if ( not usable and rune and self.runes[rune] ) then
			self.runes[rune]:SetScript("OnUpdate", RuneButton_OnUpdate);
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

function RuneFrame_FixRunes	(runeFrame)	--We want to swap where frost and unholy appear'
	local temp;
	
	temp = runeFrame.runes[3];
	runeFrame.runes[3] = runeFrame.runes[5];
	runeFrame.runes[5] = temp;
	
	temp = runeFrame.runes[4];
	runeFrame.runes[4] = runeFrame.runes[6];
	runeFrame.runes[6] = temp;
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