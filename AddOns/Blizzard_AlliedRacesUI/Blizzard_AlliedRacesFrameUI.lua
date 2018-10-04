AlliedRacesFrameMixin = { };

function AlliedRacesFrameMixin:UpdatedBannerColor(bannerColor)
	self.Banner:SetVertexColor(bannerColor:GetRGB());
end

function AlliedRacesFrameMixin:SetFrameText(name, description)
	PortraitFrameTemplate_SetTitle(self, name);
	self.RaceInfoFrame.AlliedRacesRaceName:SetText(name);
	self.RaceInfoFrame.ScrollFrame.Child.RaceDescriptionText:SetText(description);
end

function AlliedRacesFrameMixin:SetupAbilityPool(index, racialAbility)
	local childFrame = self.RaceInfoFrame.ScrollFrame.Child;
	local abilityButton = self.abilityPool:Acquire();

	if (index == 1) then
		abilityButton:SetPoint("TOPLEFT", childFrame.RacialTraitsLabel, "BOTTOMLEFT", -7, -19);
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
	objectivesFrame.contentHeight = 0;
	objectivesFrame.lastBullet = nil;

	local id, achievementName, points, achievementCompleted, month, day, year, description, flags, iconpath = GetAchievementInfo(achievementID);

	local numCriteria = GetAchievementNumCriteria(achievementID);
	self.bulletPool:ReleaseAll();

	for criteriaIndex = 1, numCriteria do
		local bulletFrame = self.bulletPool:Acquire();
		bulletFrame:SetUp(achievementID, criteriaIndex, objectivesFrame);
	end

	objectivesFrame:SetHeight(objectivesFrame.contentHeight + 43);	-- total of header height plus top and bottom padding
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

	self.raceID = raceID;
	self:SetModelFrameBackground(raceInfo.modelBackgroundAtlas);
	if (UnitSex("player") == 2) then
		self:UpdateModel(raceInfo.maleModelID);
		self.ModelFrame.AlliedRacesMaleButton:SetChecked(true);
		self.ModelFrame.AlliedRacesFemaleButton:SetChecked(false);
		self:SetRaceNameForGender("male");
	else
		self:UpdateModel(raceInfo.femaleModelID);
		self.ModelFrame.AlliedRacesMaleButton:SetChecked(false);
		self.ModelFrame.AlliedRacesFemaleButton:SetChecked(true);
		self:SetRaceNameForGender("female");
	end
	self.ModelFrame.AlliedRacesFemaleButton.FemaleModelID = raceInfo.femaleModelID;
	self.ModelFrame.AlliedRacesFemaleButton.raceName = raceInfo.femaleName;
	self.ModelFrame.AlliedRacesMaleButton.MaleModelID = raceInfo.maleModelID;
	self.ModelFrame.AlliedRacesFemaleButton.raceName = raceInfo.maleName;

	PortraitFrameTemplate_SetPortraitAtlasRaw(self, raceInfo.crestAtlas);
	self:UpdatedBannerColor(raceInfo.bannerColor);
	self:RacialAbilitiesData(raceID);
	self:UpdateObjectivesFrame(raceInfo.achievementID);
end

function AlliedRacesFrameMixin:SetRaceNameForGender(gender)
	local raceInfo = C_AlliedRaces.GetRaceInfoByID(self.raceID);
	if not raceInfo then
		return;
	end

	local raceName;
	if gender == "female" then
		raceName = raceInfo.femaleName;
	else
		raceName = raceInfo.maleName;
	end

	local fileString = raceInfo.raceFileString;
	fileString = strupper(fileString);

	self:SetFrameText(raceName, _G["RACE_INFO_"..fileString]);
end

function AlliedRacesFrameMixin:OnShow()
	self.Inset:Hide();
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

function AlliedRacesFrameMixin:OnEvent(event, ...)
	if (event == "ALLIED_RACE_CLOSE") then
		HideUIPanel(self);
	end
end

function AlliedRacesFrameMixin:OnHide()
	C_AlliedRaces.ClearAlliedRaceDetailsGiver();
end

AlliedRacesBulletFrameMixin = { };

function AlliedRacesBulletFrameMixin:SetUp(achievementID, criteriaIndex, objectivesFrame)
	local BULLET_SPACING = 14;
	local TEXT_ANCHOR_POINT_X = 27;		-- from XML
	local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(achievementID, criteriaIndex);
	if (criteriaString and criteriaString ~= "") then
		self.achievementID = achievementID;
		self.criteriaIndex = criteriaIndex;

		self.Text:SetText(criteriaString);

		if (not objectivesFrame.lastBullet) then
			self:SetPoint("TOPLEFT", objectivesFrame.HeaderBackground, "BOTTOMLEFT", 13, -6);
		else
			self:SetPoint("TOPLEFT", objectivesFrame.lastBullet, "BOTTOMLEFT", 0, -BULLET_SPACING);
		end
		objectivesFrame.lastBullet = self;

		local textHeight = self.Text:GetHeight();
		self:SetSize(self.Text:GetStringWidth() + TEXT_ANCHOR_POINT_X, textHeight);
		objectivesFrame.contentHeight = objectivesFrame.contentHeight + textHeight + BULLET_SPACING;

		if completed then
			self.Text:SetTextColor(GREEN_FONT_COLOR:GetRGB());
		else
			self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		end
		self.Dash:SetShown(not completed);
		self.Check:SetShown(completed);
		self:Show();
	end
end

function AlliedRacesBulletFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local criteriaString, criteriaType, criteriaCompleted, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(self.achievementID, self.criteriaIndex);

	if criteriaCompleted then
		-- check if the criteria is an achievement to use its completion date, otherwise try main achievement in case it's all complete
		local achievementID = self.achievementID;
		if AchievementUtil.IsCriteriaAchievementEarned(self.achievementID, self.criteriaIndex) then
			achievementID = assetID;
		end
		local id, name, points, achievementCompleted, month, day, year = GetAchievementInfo(achievementID);
		if achievementCompleted then
			local completionDate = FormatShortDate(day, month, year);
			GameTooltip_AddColoredLine(GameTooltip, CRITERIA_COMPLETED_DATE:format(completionDate), HIGHLIGHT_FONT_COLOR);
		else
			GameTooltip_AddColoredLine(GameTooltip, CRITERIA_COMPLETED, HIGHLIGHT_FONT_COLOR);
		end
	else
		GameTooltip_SetTitle(GameTooltip, CRITERIA_NOT_COMPLETED, DISABLED_FONT_COLOR);
	end

	GameTooltip_AddColoredLine(GameTooltip, CLICK_FOR_MORE_INFO, GREEN_FONT_COLOR);
	GameTooltip:Show();
end

function AlliedRacesBulletFrameMixin:OnLeave()
	GameTooltip:Hide();
end

function AlliedRacesBulletFrameMixin:OnMouseUp()
	local criteriaString, criteriaType, criteriaCompleted, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(self.achievementID, self.criteriaIndex);
	-- check if it's rep-related
	local CHECK_CRITERIA_ACHIEVEMENT = true;
	if AchievementUtil.IsCriteriaReputationGained(self.achievementID, self.criteriaIndex, CHECK_CRITERIA_ACHIEVEMENT) then
		if not ReputationFrame:IsVisible() then
			ToggleCharacter("ReputationFrame");
		end
	else
		-- see if it's an achievement, otherwise use main achievement
		if AchievementUtil.IsCriteriaAchievementEarned(self.achievementID, self.criteriaIndex) then
			OpenAchievementFrameToAchievement(assetID);
		else
			OpenAchievementFrameToAchievement(self.achievementID);
		end
	end
end