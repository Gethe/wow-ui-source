--Readability == win
local RUNETYPE_BLOOD = 1;
local RUNETYPE_DEATH = 2;
local RUNETYPE_FROST = 3;
local RUNETYPE_CHROMATIC = 4;

local iconTextures = {};
iconTextures[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood-On.tga";
iconTextures[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death-On.tga";
iconTextures[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost-On.tga";
iconTextures[RUNETYPE_CHROMATIC] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Chromatic-On.tga";

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
	local RUNE_HEIGHT = 18;
	local MIN_RUNE_ALPHA = .4
	
	local cooldown = getglobal(self:GetName().."Cooldown");
	local start, duration, runeReady = GetRuneCooldown(self:GetID());
	
	local displayCooldown = (runeReady and 0) or 1;
	
	CooldownFrame_SetTimer(cooldown, start, duration, displayCooldown);
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
