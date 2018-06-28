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
	local bfaGarrisonStyleData =
	{
		Horde =
		{
			TitleScrollOffset = -2,
			TitleColor = CreateColor(0.192, 0.051, 0.008, 1),

			titleSrollLeft = "HordeFrame_Title-End-2",
			titleSrollRight = "HordeFrame_Title-End",
			titleScollMiddle = "_HordeFrame_Title-Tile",

			TopperOffset = -34,
			Topper = "HordeFrame-Header",
			topperBehindFrame = false,

			closeButtonBorder = "HordeFrame_ExitBorder",
			closeButtonBorderX = -1,
			closeButtonBorderY = 1,
			closeButtonX = 4,
			closeButtonY = 4,

			BackgroundTile = "ClassHall_InfoBoxMission-BackgroundTile",

			Top = "_HordeFrameTile-Top",
			Bottom = "_HordeFrameTile-Top",
			Left = "!HordeFrameTile-Left",
			Right = "!HordeFrameTile-Left",
			TopLeft = "HordeFrame-Corner-TopLeft",
			TopRight = "HordeFrame-Corner-TopLeft",
			BottomLeft = "HordeFrame-Corner-TopLeft",
			BottomRight = "HordeFrame-Corner-TopLeft",

			TabLeft = "HordeFrame_ParchmentHeader-End-2",
			TabRight = "HordeFrame_ParchmentHeader-End",
			TabMiddle = "_HordeFrame_ParchmentHeader-Mid",
			TabSelectLeft = "HordeFrame_ParchmentHeaderSelect-End-2",
			TabSelectRight = "HordeFrame_ParchmentHeaderSelect-End",
			TabSelectMiddle = "_HordeFrame_ParchmentHeaderSelect-Mid",

			SearchLeft = "HordeFrame_ParchmentHeader-End-2",
			SearchRight = "HordeFrame_ParchmentHeader-End",
			SearchMiddle = "_HordeFrame_ParchmentHeader-Mid",

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
			TitleScrollOffset = -5,
			TitleColor = CreateColor(0.008, 0.051, 0.192, 1),

			titleSrollLeft = "AllianceFrame_Title-End-2",
			titleSrollRight = "AllianceFrame_Title-End",
			titleScollMiddle = "_AllianceFrame_Title-Tile",

			TopperOffset = -29,
			Topper = "AllianceFrame-Header",
			topperBehindFrame = false,

			closeButtonBorder = "AllianceFrame_ExitBorder",
			closeButtonBorderX = 0,
			closeButtonBorderY = -1,
			closeButtonX = 4,
			closeButtonY = 4,

			BackgroundTile = "UI-Frame-Alliance-BackgroundTile",

			Top = "_AllianceFrameTile-Top",
			Bottom = "_AllianceFrameTile-Top",
			Left = "!AllianceFrameTile-Left",
			Right = "!AllianceFrameTile-Left",
			TopLeft = "AllianceFrameCorner-TopLeft",
			TopRight = "AllianceFrameCorner-TopLeft",
			BottomLeft = "AllianceFrameCorner-TopLeft",
			BottomRight = "AllianceFrameCorner-TopLeft",

			TabLeft = "AllianceFrame_ParchmentHeader-End",
			TabRight = "AllianceFrame_ParchmentHeader-End-2",
			TabMiddle = "_AllianceFrame_ParchmentHeader-Mid",
			TabSelectLeft = "AllianceFrame_ParchmentHeaderSelect-End-2",
			TabSelectRight = "AllianceFrame_ParchmentHeaderSelect-End",
			TabSelectMiddle = "_AllianceFrame_ParchmentHeaderSelect-Mid",

			SearchLeft = "AllianceFrame_ParchmentHeader-End",
			SearchRight = "AllianceFrame_ParchmentHeader-End-2",
			SearchMiddle = "_AllianceFrame_ParchmentHeader-Mid",

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

	local function SetupTitleText(self, styleData)
		self.Topper:SetPoint("BOTTOM", self.Top, "TOP", 0, styleData.TopperOffset);
		self.Topper:SetAtlas(styleData.Topper, true);

		if styleData.topperBehindFrame then
			self.Topper:SetDrawLayer("BACKGROUND", -7);
		else
			self.Topper:SetDrawLayer("ARTWORK", 2);
		end

		self.TitleScroll.ScrollLeft:SetAtlas(styleData.titleSrollLeft);
		self.TitleScroll.ScrollRight:SetAtlas(styleData.titleSrollRight);
		self.TitleScroll.ScrollMiddle:SetAtlas(styleData.titleScollMiddle);

		self.TitleScroll:SetPoint("BOTTOM", self.Topper, "BOTTOM", 0, styleData.TitleScrollOffset);
		self.TitleText.layoutIndex = 1;
		self.TitleText:SetParent(self.TitleScroll); -- Reusing existing title text label from base template
		self.TitleText:ClearAllPoints();
		self.TitleText:SetPoint("CENTER", self.TitleScroll, "CENTER", 0, 1);

		if styleData.TitleColor then
			self.TitleText:SetTextColor(styleData.TitleColor:GetRGBA())
		end

		self.TitleText:SetShadowOffset(0, 0);
	end

	local function SetupMissionTab(tab, styleData)
		tab.Left:SetAtlas(styleData.TabLeft, true);
		tab.Right:SetAtlas(styleData.TabRight, true);
		tab.Middle:SetAtlas(styleData.TabMiddle, true);

		tab.SelectedLeft:SetAtlas(styleData.TabSelectLeft, true);
		tab.SelectedRight:SetAtlas(styleData.TabSelectRight, true);
		tab.SelectedMid:SetAtlas(styleData.TabSelectMiddle, true);

		tab.SelectedRight:SetTexCoord(0, 1, 0, 1);
		tab.Right:SetTexCoord(0, 1, 0, 1);
	end

	local function SetupMissionList(self, styleData)
		SetupMissionTab(self.MissionTab.MissionList.Tab1, styleData);
		SetupMissionTab(self.MissionTab.MissionList.Tab2, styleData);
	end

	local function SetupFollowerList(self, styleData)
		self.FollowerList.HeaderLeft:SetAtlas(styleData.SearchLeft, true);
		self.FollowerList.HeaderRight:SetAtlas(styleData.SearchRight, true);
		self.FollowerList.HeaderMid:SetAtlas(styleData.SearchMiddle, true);

		self.FollowerList.HeaderRight:SetTexCoord(0, 1, 0, 1);
	end

	local function SetupBorder(self, styleData)
		self.Bottom:SetTexCoord(0, 1, 1, 0);

		self.Top:SetAtlas(styleData.Top, true);
		self.Bottom:SetAtlas(styleData.Bottom, true);
		self.Left:SetAtlas(styleData.Left, true);
		self.Right:SetAtlas(styleData.Right, true);

		self.GarrCorners.TopLeftGarrCorner:SetAtlas(styleData.TopLeft, true);
		self.GarrCorners.TopRightGarrCorner:SetAtlas(styleData.TopRight, true);
		self.GarrCorners.BottomLeftGarrCorner:SetAtlas(styleData.BottomLeft, true);
		self.GarrCorners.BottomRightGarrCorner:SetAtlas(styleData.BottomRight, true);

		styleData.SetupNineSlice(self);
		self.BackgroundTile:SetAtlas(styleData.BackgroundTile);

		self.CloseButton:ClearAllPoints();
		self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", styleData.closeButtonX, styleData.closeButtonY);
		self.CloseButton:SetFrameLevel(self.GarrCorners:GetFrameLevel() + 2);

		self.CloseButtonBorder:SetAtlas(styleData.closeButtonBorder, true);
		self.CloseButtonBorder:SetParent(self.CloseButton);
		self.CloseButtonBorder:SetPoint("CENTER", self.CloseButton, "CENTER", styleData.closeButtonBorderX, styleData.closeButtonBorderY);
	end

	local function SetupScoutingMap(self)
		-- Resize scouting map scroll frame to fit with edge pieces.
		self.MapTab.ScrollContainer:SetPoint("LEFT", self.Left, "RIGHT", -17, 0);
		self.MapTab.ScrollContainer:SetPoint("TOP", self.Top, "BOTTOM", 0, 17);
		self.MapTab.ScrollContainer:SetPoint("RIGHT", self.Right, "LEFT", 17, 0);
		self.MapTab.ScrollContainer:SetPoint("BOTTOM", self.Bottom, "TOP", 0, -17);
	end

	local function SetupTabs(self)
		self.Tab1:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, -33);
	end

	function BFAMission:UpdateTextures()
		OrderHallMission.UpdateTextures(self);

		local factionGroup = UnitFactionGroup("player");
		local styleData = bfaGarrisonStyleData[factionGroup];

		HideBorderTrim(self);
		SetupScoutingMap(self);
		SetupTabs(self);
		SetupTitleText(self, styleData);
		SetupMissionList(self, styleData);
		SetupFollowerList(self, styleData);
		SetupBorder(self, styleData);
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

function BFAMission:SetTitleText(text)
	self.TitleText:SetText(text);
	self.TitleScroll:MarkDirty();
end

function BFAMission:SelectTab(id)
	if (self:GetMissionPage():IsShown()) then
		self:GetMissionPage().CloseButton:Click();
	end
	GarrisonFollowerMission.SelectTab(self, id);
	if (id == 1) then
		self:SetTitleText(WAR_MISSIONS);
		self.FollowerList:Hide();
		self.BackgroundTile:Show()
		self.MapTab:Hide();
	elseif (id == 2) then
		self:SetTitleText(WAR_FOLLOWERS);
		self.BackgroundTile:Show()
		self.MapTab:Hide();
	else
		self:SetTitleText(ADVENTURE_MAP_TITLE);
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
