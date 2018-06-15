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

do
	local bfaGarrisonAtlas =
	{
		Horde =
		{
			TopperOffset = -37,
			Topper = "HordeFrame-Header",
			Top = "_HordeFrameTile-Top",
			Bottom = "_HordeFrameTile-Bottom",
			Left = "!HordeFrameTile-Left",
			Right = "!HordeFrameTile-Left",
			TopLeft = "HordeFrame-Corner-TopLeft",
			TopRight = "HordeFrame-Corner-TopLeft",
			BottomLeft = "HordeFrame-Corner-TopLeft",
			BottomRight = "HordeFrame-Corner-TopLeft",

			SetupNineSlice = function(self)
				local border = AnchorUtil.CreateNineSlice(self.GarrCorners);
				border:SetTopLeftCorner(self.GarrCorners.TopLeftGarrCorner, -6, 6);
				border:SetTopRightCorner(self.GarrCorners.TopRightGarrCorner, 6, 6);
				border:SetBottomLeftCorner(self.GarrCorners.BottomLeftGarrCorner, -6, -6);
				border:SetBottomRightCorner(self.GarrCorners.BottomRightGarrCorner, 6, -6);
				border:SetTopEdge(self.Top);
				border:SetLeftEdge(self.Left);
				border:SetRightEdge(self.Right);
				border:SetBottomEdge(self.Bottom);
				border:Apply();
			end,
		},

		Alliance =
		{
			TopperOffset = -40,
			Topper = "AllianceFrame-Header",
			Top = "_AllianceFrameTile-Top",
			Bottom = "_AllianceFrameTile-Bottom",
			Left = "!AllianceFrameTile-Left",
			Right = "!AllianceFrameTile-Left",
			TopLeft = "AllianceFrameCorner-TopLeft",
			TopRight = "AllianceFrameCorner-TopLeft",
			BottomLeft = "AllianceFrameCorner-TopLeft",
			BottomRight = "AllianceFrameCorner-TopLeft",

			SetupNineSlice = function(self)
				local border = AnchorUtil.CreateNineSlice(self.GarrCorners);
				border:SetTopLeftCorner(self.GarrCorners.TopLeftGarrCorner, 0, 0);
				border:SetTopRightCorner(self.GarrCorners.TopRightGarrCorner, 0, 0);
				border:SetBottomLeftCorner(self.GarrCorners.BottomLeftGarrCorner, 0, 0);
				border:SetBottomRightCorner(self.GarrCorners.BottomRightGarrCorner, 0, 0);
				border:SetTopEdge(self.Top, -73, 0, 73, 0);
				border:SetLeftEdge(self.Left, 0, 73, 0, -73);
				border:SetRightEdge(self.Right, 0, 73, 0, -73);
				border:SetBottomEdge(self.Bottom, -73, 0, 73, 0);
				border:Apply();
			end,
		},
	};

	local function HideBorderTrim(self)
		self.TopLeftCorner:Hide();
		self.TopRightCorner:Hide();
		self.BotLeftCorner:Hide();
		self.BotRightCorner:Hide();
		self.TopBorder:Hide();
		self.BottomBorder:Hide();
		self.LeftBorder:Hide();
		self.RightBorder:Hide();
	end

	function BFAMission:UpdateTextures()
		OrderHallMission.UpdateTextures(self);

		HideBorderTrim(self);

		-- Resize scouting map scroll frame to fit with edge pieces.
		self.MapTab.ScrollContainer:SetPoint("LEFT", self.Left, "RIGHT", -17, 0);
		self.MapTab.ScrollContainer:SetPoint("TOP", self.Top, "BOTTOM", 0, 17);
		self.MapTab.ScrollContainer:SetPoint("RIGHT", self.Right, "LEFT", 17, 0);
		self.MapTab.ScrollContainer:SetPoint("BOTTOM", self.Bottom, "TOP", 0, -17);

		-- Custom close button needs to sit on top of corner pieces because they're closer to the edge
		self.CloseButton:SetFrameLevel(self.GarrCorners:GetFrameLevel() + 1);

		-- Tabs need adjustment because of the border adjustment...
		BFAMissionFrameTab1:SetPoint("BOTTOMLEFT", BFAMissionFrame, "BOTTOMLEFT", 7, -33);

		-- Create flavor art piece
		if not self.Topper then
			self.Topper = self:CreateTexture(nil, "BACKGROUND", nil, 2);
		end

		local factionGroup = UnitFactionGroup("player");
		local atlases = bfaGarrisonAtlas[factionGroup];

		self.Topper:SetPoint("BOTTOM", self.Top, "TOP", 0, atlases.TopperOffset);
		self.Topper:SetAtlas(atlases.Topper, true);
		self.Top:SetAtlas(atlases.Top, true);
		self.Bottom:SetAtlas(atlases.Bottom, true);
		self.Left:SetAtlas(atlases.Left, true);
		self.Right:SetAtlas(atlases.Right, true);

		self.GarrCorners.TopLeftGarrCorner:SetAtlas(atlases.TopLeft, true);
		self.GarrCorners.TopRightGarrCorner:SetAtlas(atlases.TopRight, true);
		self.GarrCorners.BottomLeftGarrCorner:SetAtlas(atlases.BottomLeft, true);
		self.GarrCorners.BottomRightGarrCorner:SetAtlas(atlases.BottomRight, true);

		atlases.SetupNineSlice(self);
	end
end

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
