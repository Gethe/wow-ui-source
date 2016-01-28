
OrderHallMission = { }

function OrderHallMission:UpdateCurrency()
end

function OrderHallMission:OnLoad()
	self.followerTypeID = LE_FOLLOWER_TYPE_GARRISON_7_0;
	self:OnLoadMainFrame();
end

function OrderHallMission:OnShow()
	SetMissionFrame(self);
	self:OnShowMainFrame();
	AdventureMapMixin.OnShow(self.MissionTab);
end

function OrderHallMission:OnHide()
	self:OnHideMainFrame();
	AdventureMapMixin.OnHide(self.MissionTab);
	SetMissionFrame(nil);
end

function OrderHallMission:SelectTab(id)
	if (GarrisonMissionFrame.MissionTab.MissionPage:IsShown()) then
		GarrisonMissionFrame.MissionTab.MissionPage.CloseButton:Click();
		GarrisonMissionFrame:Hide();
	end
	GarrisonFollowerMission.SelectTab(self, id);
	if (id == 1) then
		self.TitleText:SetText(ORDER_HALL_MISSIONS);
		self.FollowerList:Hide();
	else
		self.TitleText:SetText(ORDER_HALL_FOLLOWERS);
	end
end

function OrderHallMission:SetupMissionList()
end

function OrderHallMission:CheckCompleteMissions(onShow)
	-- go to the right tab if window is being open
	if ( onShow ) then
		self:SelectTab(1);
	end
end

function OrderHallMission:CloseMission()
	-- TODO: Can this be moved to GarrisonFollowerMission?
	GarrisonMission.CloseMission(self);
	self.FollowerList:Hide();
end


OrderHallMissionAdventureMapMixin = { }

function AdventureMapMixin:SetupTitle()
end

function OrderHallMissionAdventureMapMixin:EvaluateLockReasons()
	if next(self.lockReasons) then
		-- TODO overlay frame

	else
		-- TODO overlay frame

	end
end

-- Don't call C_AdventureMap.Close here because we may be simply switching tabs. We call that method in OrderHallMission:OnHide() instead.
function OrderHallMissionAdventureMapMixin:OnShow()
end

function OrderHallMissionAdventureMapMixin:OnHide()
end


OrderHallFollowerTabMixin = { }

function OrderHallFollowerTabMixin:IsSpecializationAbility(followerInfo, ability)
	if (followerInfo.isTroop) then
		return false;
	end
	if (followerInfo.abilities[1] ~= nil and followerInfo.abilities[1] == ability) then
		return true;
	end

	return false;
end

function OrderHallFollowerTabMixin:IsEquipmentAbility(followerInfo, ability)
	return ability.isTrait;
end

function OrderHallFollowerTabMixin:UpdateValidSpellHighlightOnEquipmentFrame(equipmentFrame, followerID, followerInfo)
	local ability = equipmentFrame.ability;
	if ( followerInfo and followerInfo.isCollected 
		and followerInfo.status ~= GARRISON_FOLLOWER_WORKING and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION 
		and ability and SpellCanTargetGarrisonFollowerAbility(followerID, ability.id) ) then
		equipmentFrame.ValidSpellHighlight:Show();
	else
		equipmentFrame.ValidSpellHighlight:Hide();
	end
end

function OrderHallFollowerTabMixin:UpdateValidSpellHighlight(followerID, followerInfo, hideCounters)
	GarrisonFollowerTabMixin.UpdateValidSpellHighlight(self, followerID, followerInfo, hideCounters);
	self:UpdateValidSpellHighlightOnAbilityFrame(self.AbilitiesFrame.Specialization, followerID, followerInfo, hideCounters);
	for i=1, #self.AbilitiesFrame.Equipment do
		self:UpdateValidSpellHighlightOnEquipmentFrame(self.AbilitiesFrame.Equipment[i], followerID, followerInfo, true);
	end

end


function OrderHallFollowerTabMixin:ShowFollower(followerID, followerList)

	local lastUpdate = self.lastUpdate;
	local followerInfo = C_Garrison.GetFollowerInfo(followerID);

	if (followerInfo) then
		self.followerID = followerID;
		self.NoFollowersLabel:Hide();
		self.PortraitFrame:Show();
		self.Model:SetAlpha(0);
		GarrisonMission_SetFollowerModel(self.Model, followerInfo.followerID, followerInfo.displayID);
		if (followerInfo.displayHeight) then
			self.Model:SetHeightFactor(followerInfo.displayHeight);
		end
		if (followerInfo.displayScale) then
			self.Model:InitializeCamera(followerInfo.displayScale);
		end		
	else
		self.followerID = nil;
		self.NoFollowersLabel:Show();
		followerInfo = { };
		followerInfo.quality = 1;
		followerInfo.abilities = { };
		self.PortraitFrame:Hide();
		self.Model:ClearModel();
	end

	GarrisonFollowerPageModelUpgrade_Update(self.Model.UpgradeFrame);
	local missionFrame = self:GetParent();

	missionFrame:SetFollowerPortrait(self.PortraitFrame, followerInfo);
	self.Name:SetText(followerInfo.name);
	local color = ITEM_QUALITY_COLORS[followerInfo.quality];	
	self.Name:SetVertexColor(color.r, color.g, color.b);
	self.ClassSpec:SetText(followerInfo.className);
	self.Class:SetAtlas(followerInfo.classAtlas);

	self.XPLabel:Hide();
	self.XPBar:Hide();
	self.XPText:Hide();
	self.XPText:SetText("");
	self.ItemWeapon:Hide();
	self.ItemArmor:Hide();
	self.ItemAverageLevel.Level:Hide();
	self.Source:Hide();


	GarrisonTruncationFrame_Check(self.Name);

	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		self.QualityFrame:Show();
		self.QualityFrame.Text:SetText(_G["ITEM_QUALITY"..followerInfo.quality.."_DESC"]);
	else
		self.QualityFrame:Hide();
	end

	if (not followerInfo.abilities) then
		followerInfo.abilities = C_Garrison.GetFollowerAbilities(followerID);
	end
	local lastAbilityAnchor, lastSpecializationAnchor;
	local numCounters = 0;
	local numAbilities = 0;
	local numEquipment = 0;

	for i=1, #followerInfo.abilities do
		local ability = followerInfo.abilities[i];

		local abilityFrame;
		if (self:IsSpecializationAbility(followerInfo, ability)) then
			abilityFrame = self.AbilitiesFrame.Specialization;
		elseif (self:IsEquipmentAbility(followerInfo, ability)) then
			numEquipment = numEquipment + 1;
			abilityFrame = self.AbilitiesFrame.Equipment[numEquipment];
		else
			numAbilities = numAbilities + 1;
			abilityFrame = self.AbilitiesFrame.Abilities[numAbilities];
		
			if ( not abilityFrame ) then
				abilityFrame = CreateFrame("Frame", nil, self.AbilitiesFrame, "GarrisonFollowerPageAbilityTemplate");
				self.AbilitiesFrame.Abilities[numAbilities] = abilityFrame;
			end
		end

		abilityFrame.followerTypeID = followerInfo.followerTypeID;

		if ( self:IsEquipmentAbility(followerInfo, ability) ) then
			abilityFrame.abilityID = ability.id;
			abilityFrame.followerTypeID = followerInfo.followerTypeID
			if (ability.icon) then
				abilityFrame.Icon:SetTexture(ability.icon);
				abilityFrame.Icon:Show();
				if (not hideCounters) then
					for id, counter in pairs(ability.counters) do
						equipment.Counter.Icon:SetTexture(counter.icon);
						equipment.Counter.tooltip = counter.name;
						equipment.Counter.mainFrame = mainFrame;
						equipment.Counter.info = counter;
						equipment.Counter:Show();
							
						break;
					end
				end
					
				if (followerInfo.isCollected and GarrisonFollowerAbilities_IsNew(lastUpdate, followerID, ability.id, GARRISON_FOLLOWER_ABILITY_TYPE_ABILITY)) then
					abilityFrame.EquipAnim:Play();
				else
					GarrisonShipEquipment_StopAnimations(abilityFrame);
				end
			else
				abilityFrame.Icon:Hide();
			end
		else
			if ( followerInfo.isCollected and GarrisonFollowerAbilities_IsNew(lastUpdate, followerInfo.followerID, ability.id, GARRISON_FOLLOWER_ABILITY_TYPE_TRAIT) ) then			
				if ( ability.temporary ) then
					abilityFrame.LargeAbilityFeedbackGlowAnim:Play();
					PlaySoundKitID(51324);
				else
					abilityFrame.IconButton.Icon:SetAlpha(0);
					abilityFrame.IconButton.OldIcon:SetAlpha(1);
					abilityFrame.AbilityOverwriteAnim:Play();		
				end
			else
				GarrisonFollowerPageAbility_StopAnimations(abilityFrame);
			end
			abilityFrame.Name:SetText(ability.name);
			abilityFrame.IconButton.Icon:SetTexture(ability.icon);
			abilityFrame.IconButton.abilityID = ability.id;
			abilityFrame.ability = ability;

		    local hasCounters = false;
		    if ( ability.counters and not ability.isTrait and not self.isLandingPage and not abilityFrame.hideCounters ) then
			    for id, counter in pairs(ability.counters) do
				    numCounters = numCounters + 1;
				    local counterFrame = self.AbilitiesFrame.Counters[numCounters];
				    if ( not counterFrame ) then
					    counterFrame = CreateFrame("Frame", nil, self.AbilitiesFrame, "GarrisonMissionMechanicTemplate");
					    self.AbilitiesFrame.Counters[numCounters] = counterFrame;
				    end
				    counterFrame.mainFrame = self:GetParent();
				    counterFrame.Icon:SetTexture(counter.icon);
				    counterFrame.tooltip = counter.name;
				    counterFrame:ClearAllPoints();
				    if ( hasCounters ) then			
					    counterFrame:SetPoint("LEFT", self.AbilitiesFrame.Counters[numCounters - 1], "RIGHT", 10, 0);
				    else
					    counterFrame:SetPoint("LEFT", abilityFrame.CounterString, "RIGHT", 2, -2);
				    end
				    counterFrame:Show();
				    counterFrame.info = counter;
				    counterFrame.followerTypeID = followerInfo.followerTypeID;
				    hasCounters = true;
			    end
			end
			if ( hasCounters ) then
				abilityFrame.CounterString:Show();
			else
				abilityFrame.CounterString:Hide();
			end

			if ( self.isLandingPage ) then
				abilityFrame.Category:SetText("");
				abilityFrame.Name:SetFontObject("GameFontHighlightMed2");
				abilityFrame.Name:ClearAllPoints();
				abilityFrame.Name:SetPoint("LEFT", abilityFrame.IconButton, "RIGHT", 8, 0);
				abilityFrame.Name:SetWidth(150);
			else
				local categoryText = "";
				if ( ability.isTrait ) then
					if ( ability.temporary ) then
						categoryText = GARRISON_TEMPORARY_CATEGORY_FORMAT:format(ability.category or "");
					else
						categoryText = ability.category or "";
					end
				end
				abilityFrame.Category:SetText(categoryText);
				abilityFrame.Name:SetFontObject("GameFontNormalLarge2");
				abilityFrame.Name:ClearAllPoints();
				if (hasCounters) then
					abilityFrame.Name:SetPoint("TOPLEFT", abilityFrame.IconButton, "TOPRIGHT", 8, 0);
				else
					abilityFrame.Name:SetPoint("LEFT", abilityFrame.IconButton, "RIGHT", 8, 0);
				end
				abilityFrame.Name:SetWidth(240);
			end
		end

		-- anchor ability
		if ( abilityFrame.isSpecialization ) then
			lastSpecializationAnchor = GarrisonFollowerPage_AnchorAbility(abilityFrame, lastSpecializationAnchor, self.AbilitiesFrame.SpecializationLabel, self.isLandingPage);
		elseif ( not ability.isTrait ) then
			lastAbilityAnchor = GarrisonFollowerPage_AnchorAbility(abilityFrame, lastAbilityAnchor, self.AbilitiesFrame.AbilitiesText, self.isLandingPage);
		end
		abilityFrame:Show();
	end
	followerList:UpdateValidSpellHighlight(followerID, followerInfo);

	-- Specialization Ability
	self.AbilitiesFrame.Specialization:SetShown(lastSpecializationAnchor ~= nil);
	self.AbilitiesFrame.SpecializationLabel:SetShown(lastSpecializationAnchor ~= nil);

	if ( lastSpecializationAnchor ) then
		self.AbilitiesFrame.Specialization:SetPoint("TOP", self.AbilitiesText, "BOTTOM");
	end

	-- Abilities
	self.AbilitiesFrame.AbilitiesText:SetShown( lastAbilityAnchor ~= nil);
	self.AbilitiesFrame.EquipmentSlotsLabel:SetShown( numEquipment > 0 );
	for i = numAbilities + 1, #self.AbilitiesFrame.Abilities do
		self.AbilitiesFrame.Abilities[i]:Hide();
	end
	for i = numCounters + 1, #self.AbilitiesFrame.Counters do
		self.AbilitiesFrame.Counters[i]:Hide();
	end

	-- Equipment
	for i = numEquipment + 1, #self.AbilitiesFrame.Equipment do
		self.AbilitiesFrame.Equipment[i]:Hide();
	end

	-- Zone Support
	local zoneSupportSpellIDs = { C_Garrison.GetFollowerZoneSupportAbilities(followerID) };
	local hasZoneSupport = #zoneSupportSpellIDs ~= 0;

	for i = 1, #zoneSupportSpellIDs do
		local _, _, texture = GetSpellInfo(zoneSupportSpellIDs[i]);
		self.AbilitiesFrame.ZoneSupport[i]:Show();
		self.AbilitiesFrame.ZoneSupport[i].iconTexture:SetTexture(texture);
		self.AbilitiesFrame.ZoneSupport[i].spellID = zoneSupportSpellIDs[i];
		self.AbilitiesFrame.ZoneSupport[i].selection:SetShown(followerInfo.zoneSupportSpellID == zoneSupportSpellIDs[i]);
		self.AbilitiesFrame.ZoneSupport[i].followerID = followerID;
	end
	self.AbilitiesFrame.ZoneSupportLabel:SetShown(hasZoneSupport);
	self.AbilitiesFrame.ZoneSupportDescriptionLabel:SetShown(hasZoneSupport);

	for i = #zoneSupportSpellIDs + 1, #self.AbilitiesFrame.ZoneSupport do
		self.AbilitiesFrame.ZoneSupport[i]:Hide();
	end

	self.lastUpdate = self:IsShown() and GetTime() or nil;
end

function OrderHallFollowerTabMixin:UpdateZoneSupportSpell(spellID)
	for i = 1, #self.AbilitiesFrame.ZoneSupport do
		self.AbilitiesFrame.ZoneSupport[i].selection:SetShown(spellID == self.AbilitiesFrame.ZoneSupport[i].spellID);
	end
end


OrderHallFollowerZoneSupportMixin = { }

function OrderHallFollowerZoneSupportMixin:OnEnter()
	if ( self.spellID ) then
		GameTooltip:SetOwner(self);
		GameTooltip:SetSpellByID(self.spellID);
		GameTooltip:Show();
	end
end

function OrderHallFollowerZoneSupportMixin:OnLeave()
	GameTooltip:Hide();
end

function OrderHallFollowerZoneSupportMixin:OnClick()
	if (C_Garrison.ChangeZoneSupportSpellForFollower(self.followerID, self.spellID)) then
		self:GetParent():GetParent():UpdateZoneSupportSpell(self.spellID);
	end
end

OrderHallFollowerEquipmentMixin = { }
function OrderHallFollowerEquipmentMixin:OnEnter()
	if (self.abilityID) then
		GarrisonFollowerAbilityTooltip:ClearAllPoints();
		GarrisonFollowerAbilityTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT");
		GarrisonFollowerAbilityTooltip_Show(self.abilityID, LE_FOLLOWER_TYPE_SHIPYARD_6_2);
	end
end

function OrderHallFollowerEquipmentMixin:OnLeave()
	GarrisonFollowerAbilityTooltip:Hide();
end