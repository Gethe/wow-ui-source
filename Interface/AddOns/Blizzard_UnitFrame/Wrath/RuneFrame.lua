
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

function RuneFrame_FixRunes	(runeFrame)	--We want to swap where frost and unholy appear'
	local temp;
	
	temp = runeFrame.runes[3];
	runeFrame.runes[3] = runeFrame.runes[5];
	runeFrame.runes[5] = temp;
	
	temp = runeFrame.runes[4];
	runeFrame.runes[4] = runeFrame.runes[6];
	runeFrame.runes[6] = temp;
end