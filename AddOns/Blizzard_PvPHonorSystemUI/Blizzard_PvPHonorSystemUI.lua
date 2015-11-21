function HonorLevelUpBanner_OnLoad(self)
	self:RegisterEvent("HONOR_LEVEL_UPDATE");
	self.currentLevel = UnitHonorLevel("player");
end

function HonorLevelUpBanner_OnEvent(self, event, ...)
	if (event == "HONOR_LEVEL_UPDATE") then
		local level = UnitHonorLevel("player");
		if (level > self.currentLevel) then
			self.Title:SetText(HONOR_LEVEL_LABEL:format(level));
			self.TitleFlash:SetText(HONOR_LEVEL_LABEL:format(level));
			self:Show();
			self.Anim:Play();
			self.currentLevel = level;
		end
	end
end

function PrestigeLevelUpBanner_OnLoad(self)
	self:RegisterEvent("HONOR_PRESTIGE_UPDATE");
end

function PrestigeLevelUpBanner_OnEvent(self, event, ...)
	if (event == "HONOR_PRESTIGE_UPDATE") then
		local prestige = UnitPrestige("player");
		local factionGroup = UnitFactionGroup("player");
		local texture = GetPrestigeInfo(prestige);
		self.Text1:SetText(PRESTIGE_LEVEL_LABEL:format(prestige));
		self.Text2:SetText(_G["PRESTIGE_LEVEL_"..prestige]);
		self.Level:SetText(prestige);
		self.IconPlate:SetAtlas("titleprestige-prestigeiconplate-"..factionGroup);
		self.IconPlate2:SetAtlas("titleprestige-prestigeiconplate-"..factionGroup);
		self.IconPlate3:SetAtlas("titleprestige-prestigeiconplate-"..factionGroup);
		self.Icon:SetTexture(texture);
		self.Icon2:SetTexture(texture);
		self.Icon3:SetTexture(texture);
		self:Show();
		self.Anim:Play();
	end
end