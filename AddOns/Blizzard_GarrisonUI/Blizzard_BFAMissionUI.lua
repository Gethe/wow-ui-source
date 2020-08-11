---------------------------------------------------------------------------------
--- Garrison Follower Options				                                  ---
---------------------------------------------------------------------------------

-- These are follower options that depend on this AddOn being loaded, and so they can't be set in GarrisonBaseUtils.
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_8_0].missionFollowerSortFunc =  GarrisonFollowerList_PrioritizeSpecializationAbilityMissionSort;
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_8_0].missionFollowerInitSortFunc = GarrisonFollowerList_InitializePrioritizeSpecializationAbilityMissionSort;

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
			TitleScrollOffset = 6,
			TitleColor = CreateColor(0.192, 0.051, 0.008, 1),

			titleScrollLeft = "HordeFrame_Title-End-2",
			titleScrollRight = "HordeFrame_Title-End",
			titleScrollMiddle = "_HordeFrame_Title-Tile",

			TopperOffset = -34,
			Topper = "HordeFrame-Header",

			closeButtonBorder = "HordeFrame_ExitBorder",
			closeButtonBorderX = -1,
			closeButtonBorderY = 1,
			closeButtonX = 4,
			closeButtonY = 4,

			nineSliceLayout = "BFAMissionHorde",

			BackgroundTile = "ClassHall_InfoBoxMission-BackgroundTile",

			TabLeft = "HordeFrame_ParchmentHeader-End-2",
			TabRight = "HordeFrame_ParchmentHeader-End-2",
			TabMiddle = "_HordeFrame_ParchmentHeader-Mid",
			TabSelectLeft = "HordeFrame_ParchmentHeaderSelect-End-2",
			TabSelectRight = "HordeFrame_ParchmentHeaderSelect-End-2",
			TabSelectMiddle = "_HordeFrame_ParchmentHeaderSelect-Mid",

			SearchLeft = "HordeFrame_ParchmentHeader-End-2",
			SearchRight = "HordeFrame_ParchmentHeader-End",
			SearchMiddle = "_HordeFrame_ParchmentHeader-Mid",
		},

		Alliance =
		{
			TitleScrollOffset = -5,
			TitleColor = CreateColor(0.008, 0.051, 0.192, 1),

			titleScrollLeft = "AllianceFrame_Title-End-2",
			titleScrollRight = "AllianceFrame_Title-End",
			titleScrollMiddle = "_AllianceFrame_Title-Tile",

			TopperOffset = -29,
			Topper = "AllianceFrame-Header",

			closeButtonBorder = "AllianceFrame_ExitBorder",
			closeButtonBorderX = 0,
			closeButtonBorderY = -1,
			closeButtonX = 4,
			closeButtonY = 4,

			nineSliceLayout = "BFAMissionAlliance",

			BackgroundTile = "UI-Frame-Alliance-BackgroundTile",

			TabLeft = "AllianceFrame_ParchmentHeader-End-2",
			TabRight = "AllianceFrame_ParchmentHeader-End-2",
			TabMiddle = "_AllianceFrame_ParchmentHeader-Mid",
			TabSelectLeft = "AllianceFrame_ParchmentHeaderSelect-End-2",
			TabSelectRight = "AllianceFrame_ParchmentHeaderSelect-End-2",
			TabSelectMiddle = "_AllianceFrame_ParchmentHeaderSelect-Mid",

			SearchLeft = "AllianceFrame_ParchmentHeader-End",
			SearchRight = "AllianceFrame_ParchmentHeader-End-2",
			SearchMiddle = "_AllianceFrame_ParchmentHeader-Mid",
		},
	};

	local function SetupTitleText(self, styleData)
		self.OverlayElements.Topper:SetPoint("BOTTOM", self.Top, "TOP", 0, styleData.TopperOffset);
		self.OverlayElements.Topper:SetAtlas(styleData.Topper, true);

		self.TitleScroll.ScrollLeft:SetAtlas(styleData.titleScrollLeft);
		self.TitleScroll.ScrollRight:SetAtlas(styleData.titleScrollRight);
		self.TitleScroll.ScrollMiddle:SetAtlas(styleData.titleScrollMiddle);

		self.TitleScroll:SetPoint("BOTTOM", self.OverlayElements.Topper, "BOTTOM", 0, styleData.TitleScrollOffset);
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
		tab.Middle:SetHorizTile(false);

		tab.SelectedLeft:SetAtlas(styleData.TabSelectLeft, true);
		tab.SelectedRight:SetAtlas(styleData.TabSelectRight, true);
		tab.SelectedMid:SetAtlas(styleData.TabSelectMiddle, true);
		tab.SelectedMid:SetHorizTile(false);
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
		self.GarrCorners:Hide();
		self.Bottom:SetTexCoord(0, 1, 1, 0);

		local nineSliceLayout = NineSliceUtil.GetLayout(styleData.nineSliceLayout);
		NineSliceUtil.ApplyLayout(self, nineSliceLayout);
		self.BackgroundTile:SetAtlas(styleData.BackgroundTile);

		self.CloseButton:ClearAllPoints();
		self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", styleData.closeButtonX, styleData.closeButtonY);
		self.CloseButton:SetFrameLevel(self.GarrCorners:GetFrameLevel() + 2);

		self.OverlayElements.CloseButtonBorder:SetAtlas(styleData.closeButtonBorder, true);
		self.OverlayElements.CloseButtonBorder:SetParent(self.CloseButton);
		self.OverlayElements.CloseButtonBorder:SetPoint("CENTER", self.CloseButton, "CENTER", styleData.closeButtonBorderX, styleData.closeButtonBorderY);
	end

	local function SetupScoutingMap(self)
		-- Resize scouting map scroll frame to fit with edge pieces.
		self.MapTab.ScrollContainer:SetPoint("LEFT", self.Left, "RIGHT", -17, 0);
		self.MapTab.ScrollContainer:SetPoint("TOP", self.Top, "BOTTOM", 0, 17);
		self.MapTab.ScrollContainer:SetPoint("RIGHT", self.Right, "LEFT", 17, 0);
		self.MapTab.ScrollContainer:SetPoint("BOTTOM", self.Bottom, "TOP", 0, -17);
	end

	local function SetupTabOffset(self)
		self.Tab1.xOffset = 7;
		self.Tab1.yOffset = -33;
	end

	function BFAMission:GetNineSlicePiece(pieceName)
		if pieceName == "TopLeftCorner" then
			return self.TopLeftCorner;
		elseif pieceName == "TopRightCorner" then
			return self.TopRightCorner;
		elseif pieceName == "BottomLeftCorner" then
			return self.BotLeftCorner;
		elseif pieceName == "BottomRightCorner" then
			return self.BotRightCorner;
		elseif pieceName == "TopEdge" then
			return self.TopBorder;
		elseif pieceName == "BottomEdge" then
			return self.BottomBorder;
		elseif pieceName == "LeftEdge" then
			return self.LeftBorder;
		elseif pieceName == "RightEdge" then
			return self.RightBorder;
		end
	end

	function BFAMission:UpdateTextures()
		OrderHallMission.UpdateTextures(self);

		local factionGroup = UnitFactionGroup("player");
		local styleData = bfaGarrisonStyleData[factionGroup];

		SetupScoutingMap(self);
		SetupTabOffset(self);
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

function BFAMission:ShouldShowMissionsAndFollowersTabs()
	-- If we don't have any followers or we are not at a mission npc, hide followers and missions tabs
	return C_Garrison.GetNumFollowers(self.followerTypeID) > 0 and C_Garrison.IsAtGarrisonMissionNPC();
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
		GarrisonMissionStage_SetBack(completeDialog.BorderFrame.Stage, "BFA-mission-complete-background-"..factionGroup);
		GarrisonMissionStage_SetMid(completeDialog.BorderFrame.Stage, nil);
		GarrisonMissionStage_SetFore(completeDialog.BorderFrame.Stage, nil);

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

---------------------------------------------------------------------------------
-- BFA Mission Page
---------------------------------------------------------------------------------
BFAFollowerMissionPageMixin = { }

function BFAFollowerMissionPageMixin:SetCounters(followers, enemies, missionID)
	OrderHallFollowerMissionPageMixin.SetCounters(self, followers, enemies, missionID);

	--Handling UI for Environment Mechanics being countered
	if ( not C_Garrison.IsEnvironmentCountered(missionID) ) then
		self.Stage.MissionEnvIcon.CrossLeft:Hide();
		self.Stage.MissionEnvIcon.CrossRight:Hide();
		
		if ( self.environment ) then
			if ( not self.Stage.MissionEnvIcon.EnvironmentHighlight:IsPlaying() ) then
				self.Stage.MissionEnvIcon.EnvironmentHighlight:Play();
			end
		else 
			self.Stage.MissionEnvIcon.EnvironmentHighlight:Stop();
		end
	elseif ( not self.Stage.MissionEnvIcon.CrossLeft:IsShown()) then
		self.Stage.MissionEnvIcon.CrossLeft:Show();
		self.Stage.MissionEnvIcon.CrossRight:Show();
		self.Stage.MissionEnvIcon.EnvironmentHighlight:Stop();
		self.Stage.MissionEnvIcon.Countered:Play();
	end
end

function BFAFollowerMissionPageMixin:GenerateSuccessTooltip(tooltipAnchor)
	if ( self.environment and not C_Garrison.IsEnvironmentCountered(self.missionInfo.missionID) ) then
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("BOTTOMLEFT", tooltipAnchor, "BOTTOMRIGHT", 10, 0);
		GameTooltip:SetOwner(tooltipAnchor, "ANCHOR_PRESERVE");
		GameTooltip_AddNormalLine(GameTooltip, GARRISON_MISSION_CHANCE_TOOLTIP_HEADER);
		local missionID = tooltipAnchor:GetParent():GetParent().missionInfo.missionID;
		GameTooltip_AddColoredLine(GameTooltip, string.format(GARRISON_MISSION_PERCENT_CHANCE, C_Garrison.GetMissionSuccessChance(missionID)), HIGHLIGHT_FONT_COLOR);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddNormalLine(GameTooltip, tooltipAnchor:GetParent().tooltipText, true, true);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		local missionDeploymentInfo = C_Garrison.GetMissionDeploymentInfo(self.missionInfo.missionID);
		if ( missionDeploymentInfo.environment ) then
			GameTooltip_AddNormalLine(GameTooltip, missionDeploymentInfo.environment);
			GameTooltip_AddColoredLine(GameTooltip, missionDeploymentInfo.environmentDesc, HIGHLIGHT_FONT_COLOR, true);
		end
		GameTooltip:Show();
	else
		GarrisonMissionPageMixin.GenerateSuccessTooltip(self, tooltipAnchor);
	end
end