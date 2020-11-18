AlliedRacesFrameMixin = { };

function AlliedRacesFrameMixin:UpdatedBannerColor(bannerColor)
	self.Banner:SetVertexColor(bannerColor:GetRGB());
end

function AlliedRacesFrameMixin:SetFrameText(name, description)
	self:SetTitle(name);
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

	self:SetPortraitAtlasRaw(raceInfo.crestAtlas);
	self:UpdatedBannerColor(raceInfo.bannerColor);
	self:RacialAbilitiesData(raceID);
	self.RaceInfoFrame.ScrollFrame.Child.ObjectivesFrame:SetAchievements(raceInfo.achievementIds);
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