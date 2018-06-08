---------------------------------------------------------------------------------
--- Garrison Follower Options				                                  ---
---------------------------------------------------------------------------------

-- These are follower options that depend on this AddOn being loaded, and so they can't be set in GarrisonBaseUtils.
GarrisonFollowerOptions[LE_FOLLOWER_TYPE_GARRISON_8_0].missionFollowerSortFunc =  GarrisonFollowerList_PrioritizeSpecializationAbilityMissionSort;
GarrisonFollowerOptions[LE_FOLLOWER_TYPE_GARRISON_8_0].missionFollowerInitSortFunc = GarrisonFollowerList_InitializePrioritizeSpecializationAbilityMissionSort;

---------------------------------------------------------------------------------
-- BFA Mission Frame
---------------------------------------------------------------------------------

BFAMission = { }

local function SetupMaterialFrame(materialFrame, currency, currencyTexture)
	materialFrame.currencyType = currency;
	materialFrame.Icon:SetTexture(currencyTexture);
	materialFrame.Icon:SetSize(18, 18);
	materialFrame.Icon:SetPoint("RIGHT", materialFrame, "RIGHT", -14, 0);
end

function BFAMission:OnLoadMainFrame()
	self:UpdateTextures();

	PanelTemplates_SetNumTabs(self, 3);
	self:SelectTab(self:DefaultTab());
end

-- implement this to theme UI for BFA
--[[
function BFAMission:UpdateTextures()

--]]

function BFAMission:OnEventMainFrame(event, ...)
	if (event == "ADVENTURE_MAP_CLOSE") then
		self.CloseButton:Click();
	else
		GarrisonFollowerMission.OnEventMainFrame(self, event, ...);
	end
end

function BFAMission:DefaultTab()
	do return 3 end -- scouting map for beta end
	return 1;	-- Missions
end

function BFAMission:SetupTabs()
	self.Tab1:Show();
	self.Tab2:Show();
	self.Tab3:Show();
end

function BFAMission:SetupMissionList()
	self.MissionTab.MissionList.listScroll.update = function() self.MissionTab.MissionList:Update(); end;
	HybridScrollFrame_CreateButtons(self.MissionTab.MissionList.listScroll, "OrderHallMissionListButtonTemplate", 13, -8, nil, nil, nil, -4);
	self.MissionTab.MissionList:Update();
	
	GarrisonMissionListTab_SetTab(self.MissionTab.MissionList.Tab1);
end

function BFAMission:OnShowMainFrame()
	GarrisonFollowerMission.OnShowMainFrame(self);
	AdventureMapMixin.OnShow(self.MapTab);

	self:RegisterEvent("ADVENTURE_MAP_CLOSE");

	self:SetupTabs();
end

function BFAMission:OnHideMainFrame()
	GarrisonFollowerMission.OnHideMainFrame(self);
	AdventureMapMixin.OnHide(self.MapTab);

	self.abilityCountersForMechanicTypes = nil;

	self:UnregisterEvent("ADVENTURE_MAP_CLOSE");
end

function BFAMission:EscapePressed()
	if self:GetMissionPage() and self:GetMissionPage():IsVisible() then
		self:GetMissionPage().CloseButton:Click();
		return true;
	end

	return false;
end

function BFAMission:SelectTab(id)
	if (self:GetMissionPage():IsShown()) then
		self:GetMissionPage().CloseButton:Click();
	end
	GarrisonFollowerMission.SelectTab(self, id);
	if (id == 1) then
		self.TitleText:SetText(WAR_MISSIONS);
		self.FollowerList:Hide();
		self.BackgroundTile:Show()
		self.MapTab:Hide();
	elseif (id == 2) then
		self.TitleText:SetText(WAR_FOLLOWERS);
		self.BackgroundTile:Show()
		self.MapTab:Hide();
	else
		self.TitleText:SetText(ADVENTURE_MAP_TITLE);
		self.FollowerList:Hide();
		self.MapTab:Show();
		self.BackgroundTile:Hide()
	end
end

function BFAMission:SetupCompleteDialog()
	local completeDialog = self:GetCompleteDialog();
	if (completeDialog) then

		completeDialog.BorderFrame.Model.Title:SetText(BFA_MISSION_REPORT);

		local factionGroup = UnitFactionGroup("player");
		completeDialog.BorderFrame.Stage.LocBack:SetAtlas("BFA-mission-complete-background-"..factionGroup);
		completeDialog.BorderFrame.Stage.LocBack:SetTexCoord(0, 1, 0, 1);
		completeDialog.BorderFrame.Stage.LocMid:Hide();
		completeDialog.BorderFrame.Stage.LocFore:Hide();

		local neutralChestDisplayID = 71671;
		self.MissionComplete.BonusRewards.ChestModel:SetDisplayInfo(neutralChestDisplayID);
	end
end

function BFAMission:GetMissionPage()
	return self.MissionTab.MissionPage;
end


function BFAMission:OnClickMission(missionInfo)
	return GarrisonFollowerMission.OnClickMission(self, missionInfo);
end

function BFAMission:ShowMissionStage(missionInfo)
	GarrisonFollowerMission.ShowMissionStage(self, missionInfo);
end

function BFAMission:ShowMission(missionInfo)
	GarrisonFollowerMission.ShowMission(self, missionInfo);
end

function BFAMission:UpdateMissionData(missionPage)
	GarrisonFollowerMission.UpdateMissionData(self, missionPage);
end

function BFAMission:CheckTutorials(advance)
end
