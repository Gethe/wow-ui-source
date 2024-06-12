
function RuneButton_OnLoad (self)
	self.fill = _G[self:GetName().."Fill"];
	self.shine = _G[self:GetName().."ShineTexture"];
	self.colorOrb = _G[self:GetName().."RuneColorGlow"];
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
			local runeButton = _G["Rune"..i];
			if runeButton then
				RuneButton_Update(runeButton, i, true);
			end
		end
	elseif ( event == "RUNE_POWER_UPDATE" ) then
		local runeIndex, isEnergize = ...;
		if runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES  then 
			local runeButton = _G["Rune"..runeIndex];
			local cooldown = _G[runeButton:GetName().."Cooldown"];
			
			local start, duration, runeReady = GetRuneCooldown(runeIndex);
			
			if not runeReady  then
				if start then
					CooldownFrame_Set(cooldown, start, duration, 1, true);
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
			RuneButton_Update(_G["Rune"..runeIndex], runeIndex);
		end
	end
end