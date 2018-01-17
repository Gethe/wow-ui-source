AlliedRacesFrameMixin = { }; 

function AlliedRacesFrameMixin:UpdatedBannerColor(bannerColor)
	self.Banner:SetVertexColor(bannerColor:GetRGB()); 
end

function AlliedRacesFrameMixin:SetFrameText(name, description)
	self.TitleText:SetText(name);
	self.RaceInfoFrame.AlliedRacesRaceName:SetText(name);
	self.RaceInfoFrame.ScrollFrame.Child.RaceDescriptionText:SetText(description);
end

function AlliedRacesFrameMixin:SetupObjectiveBulletPool(achievementID, criteriaIndex)
	local objectivesFrame = self.RaceInfoFrame.ScrollFrame.Child.ObjectivesFrame;
	local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(achievementID, criteriaIndex);
	
	if (criteriaString and criteriaString ~= "") then
		local bulletFrame = self.bulletPool:Acquire(); 
		bulletFrame:SetWidth(objectivesFrame:GetWidth());
		bulletFrame.Text:SetWidth(objectivesFrame:GetWidth() - 36);
		bulletFrame.Text:SetText(criteriaString);
		
		if (criteriaIndex == 1) then
			if (objectivesFrame.HeaderButton) then
				bulletFrame:SetPoint("TOPLEFT", objectivesFrame.HeaderButton, "BOTTOMLEFT", 13, -9);
			else
				bulletFrame:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 13, -30);
			end
		else
			bulletFrame:SetPoint("TOP", self.lastBullet, "BOTTOM", 0, -(self.lastBullet.Text:GetHeight() - 12));
		end
		
		bulletFrame.Bullet:SetShown(not completed); 
		bulletFrame.Check:SetShown(completed);
		bulletFrame:Show();
		return bulletFrame;
	end
	return nil;
end

function AlliedRacesFrameMixin:SetupAbilityPool(index, racialAbility)
	local childFrame = self.RaceInfoFrame.ScrollFrame.Child;
	local abilityButton = self.abilityPool:Acquire(); 
	
	if (index == 1) then
		abilityButton:SetPoint("TOPLEFT", childFrame.RaceDescriptionText, "BOTTOMLEFT", -7, -10);
	else
		abilityButton:SetPoint("TOP", self.lastAbility, "BOTTOM", 0, -9);
	end
	
	abilityButton.Text:SetText(racialAbility.name);
	abilityButton.Icon:SetTexture(racialAbility.icon); 
	abilityButton.abilityName = racialAbility.name;
	abilityButton.abilityDescription = racialAbility.description;
	abilityButton:Show();
	
	return abilityButton;
end

function AlliedRacesFrameMixin:UpdateObjectivesFrame(achievementID)
	local objectivesFrame = self.RaceInfoFrame.ScrollFrame.Child.ObjectivesFrame;
	local textLeftAnchor = objectivesFrame.HeaderButton.ExpandedIcon;
	local textRightAnchor = objectivesFrame.HeaderButton.AbilityIcon;

	objectivesFrame.HeaderButton.Title:SetTextColor(PAPER_FRAME_EXPANDED_COLOR:GetRGB());
	objectivesFrame.HeaderButton.Title:SetText(ALLIED_RACE_UNLOCK_TEXT);
	
	local id, achievementName, points, achievementCompleted, month, day, year, description, flags, iconpath = GetAchievementInfo(achievementID);

	local numCriteria = GetAchievementNumCriteria(achievementID);	
	self.bulletPool:ReleaseAll(); 
	
	for criteriaIndex = 1, numCriteria do
		local bullet = self:SetupObjectiveBulletPool(achievementID, criteriaIndex);
		if(bullet) then
			self.lastBullet = bullet; 
		end
	end
	
	objectivesFrame:SetPoint("TOPLEFT", self.lastAbility, "BOTTOMLEFT", 4, -14); 
	self:SetDescriptionWithBullets(objectivesFrame, description);
end

function AlliedRacesFrameMixin:SetDescriptionWithBullets(objectivesFrame, description)
	objectivesFrame.DescriptionBG:SetPoint("TOPLEFT", objectivesFrame.HeaderButton, "BOTTOMLEFT", 1, 0);
	objectivesFrame.DescriptionBG:SetPoint("BOTTOMRIGHT", self.lastBullet, -13, -(self.lastBullet.Text:GetHeight() - 12));
	objectivesFrame.DescriptionBG:Show();
	objectivesFrame.DescriptionBGBottom:Show();
end

function AlliedRacesFrameMixin:RacialAbilitiesData(raceID)
	local racialAbilities = C_AlliedRaces.GetAllRacialAbilitiesFromID(raceID); 
	
	if(not racialAbilities) then
		return; 
	end
	
	self.abilityPool:ReleaseAll(); 
	for i, ability in ipairs(racialAbilities) do 
		self.lastAbility = self:SetupAbilityPool(i, ability);
	end
end

function AlliedRacesFrameMixin:LoadRaceData(raceID)
	local raceInfo = C_AlliedRaces.GetRaceInfoByID(raceID);
	
	if( not raceInfo) then
		return;
	end
	
	self:SetModelFrameBackground(raceInfo.modelBackgroundAtlas);
	if (UnitSex("player") == 2) then
		self:UpdateModel(raceInfo.maleModelID);
		self.ModelFrame.AlliedRacesMaleButton:SetChecked(true);
		self.ModelFrame.AlliedRacesFemaleButton:SetChecked(false);
	else
		self:UpdateModel(raceInfo.femaleModelID);
		self.ModelFrame.AlliedRacesMaleButton:SetChecked(false);
		self.ModelFrame.AlliedRacesFemaleButton:SetChecked(true);
	end
	self.ModelFrame.AlliedRacesFemaleButton.FemaleModelID = raceInfo.femaleModelID; 
	self.ModelFrame.AlliedRacesMaleButton.MaleModelID = raceInfo.maleModelID; 
	
	local fileString = raceInfo.raceFileString;
	fileString = strupper(fileString); 
	
	self:SetFrameText(raceInfo.name, _G["RACE_INFO_"..fileString]);
	self:UpdateFramePortrait(raceInfo.crestAtlas);
	self:UpdatedBannerColor(raceInfo.bannerColor);
	self:RacialAbilitiesData(raceID);
	self:UpdateObjectivesFrame(raceInfo.achievementID); 
end

function AlliedRacesFrameMixin:OnShow()
	self.Inset:Hide(); 	
end

function AlliedRacesFrameMixin:UpdateFramePortrait(portraitAtlas)
	self.portrait:SetAtlas(portraitAtlas, false);
end

function AlliedRacesFrameMixin:SetModelFrameBackground(backgroundAtlas)
	self.ModelFrame.ModelBackground:SetAtlas(backgroundAtlas, true); 
end

function AlliedRacesFrameMixin:UpdateModel(modelID)
	self.ModelFrame:SetDisplayInfo(modelID);
end

function AlliedRacesFrameMixin:OnLoad()
	self.abilityPool = CreateFramePool("BUTTON", self.RaceInfoFrame.ScrollFrame.Child, "AlliedRaceAbilityTemplate");
	self.bulletPool = CreateFramePool("FRAME", self.RaceInfoFrame.ScrollFrame.Child, "AlliedRaceOverviewBulletsTemplate");
	self:RegisterEvent("ALLIED_RACE_CLOSE");
	self.TopTileStreaks:Hide();
	self.RaceInfoFrame.AlliedRacesRaceName:SetFontObjectsToTry("Fancy32Font", "Fancy30Font", "Fancy27Font", "Fancy24Font", "Fancy24Font", "Fancy18Font", "Fancy16Font");
end

function AlliedRacesFrameMixin:OnEvent(self, event, ...)
	if (event == "ALLIED_RACE_CLOSE") then
		HideUIPanel(self);
	end
end

function AlliedRacesFrameMixin:OnHide()
	C_AlliedRaces.ClearAlliedRaceDetailsGiver();
end