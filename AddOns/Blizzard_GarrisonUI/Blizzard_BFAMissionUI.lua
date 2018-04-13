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

	PanelTemplates_SetNumTabs(self, 2);
	self:SelectTab(self:DefaultTab());
end

-- implement this to theme UI for BFA
--[[
function BFAMission:UpdateTextures()

--]]

function BFAMission:OnEventMainFrame(event, ...)
	GarrisonFollowerMission.OnEventMainFrame(self, event, ...);
end

function BFAMission:DefaultTab()
	return 1;	-- Missions
end

function BFAMission:SetupTabs()
	self.Tab1:Show();
	self.Tab2:Show();
end

function BFAMission:SetupMissionList()
	self.MissionTab.MissionList.listScroll.update = function() self.MissionTab.MissionList:Update(); end;
	HybridScrollFrame_CreateButtons(self.MissionTab.MissionList.listScroll, "OrderHallMissionListButtonTemplate", 13, -8, nil, nil, nil, -4);
	self.MissionTab.MissionList:Update();
	
	GarrisonMissionListTab_SetTab(self.MissionTab.MissionList.Tab1);
end

function BFAMission:OnShowMainFrame()
	GarrisonFollowerMission.OnShowMainFrame(self);

	self:SetupTabs();
end

function BFAMission:OnHideMainFrame()
	GarrisonFollowerMission.OnHideMainFrame(self);

	self.abilityCountersForMechanicTypes = nil;
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
	elseif (id == 2) then
		self.TitleText:SetText(WAR_FOLLOWERS);
		self.BackgroundTile:Show()
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
