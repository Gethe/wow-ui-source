CHARACTERFRAME_SUBFRAMES = { "PaperDollFrame", "PetPaperDollFrame", "ReputationFrame", "TokenFrame" };
CHARACTERFRAME_EXPANDED_WIDTH = 540;


local characterFrameDisplayInfo = {
	["Default"] = {
		title = UnitPVPName("player"),
		titleColor = HIGHLIGHT_FONT_COLOR,
		width = PANEL_DEFAULT_WIDTH, -- Dynamically updated by CharacterFrameMixin:Expand()/CharacterFrameMixin:Collapse();
	},
	["PetPaperDollFrame"] = {
		title = UnitPVPName("pet"),
		titleColor = HIGHLIGHT_FONT_COLOR,
		width = PANEL_DEFAULT_WIDTH, -- Dynamically updated by CharacterFrameMixin:Expand()/CharacterFrameMixin:Collapse();
	},
	["ReputationFrame"] = {
		title = REPUTATION,
		titleColor = NORMAL_FONT_COLOR,
		width = 400,
	},
	["TokenFrame"] = {
		title = CURRENCY,
		titleColor = NORMAL_FONT_COLOR,
		width = 338,
	},
};

local NUM_CHARACTERFRAME_TABS = 4;
function ToggleCharacter (tab, onlyShow)
	local subFrame = _G[tab];
	if ( subFrame ) then
		if (not subFrame.hidden) then
			PanelTemplates_SetTab(CharacterFrame, subFrame:GetID());
			if ( CharacterFrame:IsShown() ) then
				if ( subFrame:IsShown() ) then
					if ( not onlyShow ) then
						HideUIPanel(CharacterFrame);
					end
				else
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
					CharacterFrame:ShowSubFrame(tab);
				end
			else
				CharacterFrame:ShowSubFrame(tab);
				ShowUIPanel(CharacterFrame);
			end
			CharacterFrame:RefreshDisplay();
		end
	end
end

CharacterFrameMixin = {};

function CharacterFrameMixin:ShowSubFrame(frameName)
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value ~= frameName ) then
			_G[value]:Hide();	
		end	
	end 
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			_G[value]:Show()
			self.activeSubframe = frameName;
		end	
	end 
end

local CharacterFrameEvents = {
	"UNIT_NAME_UPDATE",
	"PLAYER_PVP_RANK_CHANGED",
	"PREVIEW_TALENT_POINTS_CHANGED",
	"PLAYER_TALENT_UPDATE",
	"ACTIVE_TALENT_GROUP_CHANGED",
	"UNIT_PORTRAIT_UPDATE",
	"PORTRAITS_UPDATED"
}

function CharacterFrameMixin:OnLoad()
	ButtonFrameTemplate_HideButtonBar(self);
	self.TitleText:SetMaxLines(1);
	self.TitleText:SetHeight(13);

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, NUM_CHARACTERFRAME_TABS);
	PanelTemplates_SetTab(self, 1);

	-- Scrolling
	local view = CreateScrollBoxLinearView();
	CharacterStatsPane.ScrollBox:Init(view);
	ScrollUtil.RegisterScrollBoxWithScrollBar(CharacterStatsPane.ScrollBox, CharacterStatsPane.ScrollBar);
end

function CharacterFrameMixin:UpdatePortrait()
	local masteryIndex = GetPrimaryTalentTree();
	if (masteryIndex == nil) then
		local _, class = UnitClass("player");
		CharacterFramePortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
		CharacterFramePortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
	else
		local _, _, _, icon = GetTalentTabInfo(masteryIndex);
		CharacterFramePortrait:SetTexCoord(0, 1, 0, 1);
		SetPortraitToTexture(CharacterFramePortrait, icon);	
	end
end

function CharacterFrameMixin:UpdateTitle()
	local displayInfo = characterFrameDisplayInfo[self.activeSubframe] or characterFrameDisplayInfo["Default"];
	CharacterFrameTitleText:SetTextColor(displayInfo.titleColor.r, displayInfo.titleColor.g, displayInfo.titleColor.b);
	CharacterFrameTitleText:SetText(displayInfo.title);
end

function CharacterFrameMixin:UpdateSize()
	local oldWidth = self:GetWidth();

	local displayInfo = characterFrameDisplayInfo[self.activeSubframe] or characterFrameDisplayInfo["Default"];
	self:SetWidth(displayInfo.width);

	local useStaticInsetSize = (self.activeSubframe == "PaperDollFrame" or self.activeSubframe == "PetPaperDollFrame");
	if useStaticInsetSize then
		-- PaperDollFrame always wants the same sized inset regardless of the CharacterFrame width...
		self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", PANEL_DEFAULT_WIDTH + PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_OFFSET);
	else
		-- ...while other subframes want their inset to update based on the CharacterFrame width
		self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -6, PANEL_INSET_BOTTOM_OFFSET);
	end

	if oldWidth ~= displayInfo.width then
		UpdateUIPanelPositions(self);
	end
end

function CharacterFrameMixin:RefreshDisplay()
	CharacterFrame:UpdateSize();
	CharacterFrame:UpdateTabBounds();
	CharacterFrame:UpdatePortrait();
	CharacterFrame:UpdateTitle();
end

function CharacterFrameMixin:OnEvent (event, ...)
	if ( not self:IsShown() ) then
		return;
	end
	
	local arg1 = ...;
	if ( event == "UNIT_NAME_UPDATE" ) then
		if ( arg1 == "player" and not PetPaperDollFrame:IsShown()) then
			characterFrameDisplayInfo["Default"].title = UnitPVPName("player");
			self:UpdateTitle();
		end
		return;
	elseif ( event == "PLAYER_PVP_RANK_CHANGED" ) then
		if (not PetPaperDollFrame:IsShown()) then
			characterFrameDisplayInfo["Default"].title = UnitPVPName("player");
			self:UpdateTitle();
		end
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if ( unit == "player" ) then
			self:UpdatePortrait();
		end
	elseif ( event == "PORTRAITS_UPDATED" or event == "PREVIEW_TALENT_POINTS_CHANGED" or event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" ) then
		self:UpdatePortrait();
	end
end

local function CompareFrameSize(frame1, frame2)
	return frame1:GetWidth() > frame2:GetWidth();
end
local CharTabtable = {}; 
function CharacterFrameMixin:UpdateTabBounds()
	if CharacterFrameTab4:IsShown() then
		local diff = (CharacterFrameTab4:GetRight() or 0) - (self:GetRight() or 0);

		if diff > 0 then
			for i=1, NUM_CHARACTERFRAME_TABS do
				CharTabtable[i]=_G["CharacterFrameTab"..i];
			end
			table.sort(CharTabtable, CompareFrameSize);

			local i=1;
			while ( diff > 0 and i <= NUM_CHARACTERFRAME_TABS) do
				local tabText = _G[CharTabtable[i]:GetName().."Text"];
				local change = min(10, diff);
				diff = diff - change;
				tabText:SetWidth(0);
				PanelTemplates_TabResize(CharTabtable[i], -change, nil, 36-change, 88);
				i = i+1;
			end
		end
	end
end

function CharacterFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CharacterFrameEvents);
	characterFrameDisplayInfo["Default"].title = UnitPVPName("player");

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	UpdateMicroButtons();

	PlayerFrameHealthBar.showNumeric = true;
	PlayerFrameManaBar.showNumeric = true;
	PlayerFrameAlternateManaBar.showNumeric = true;
	MainMenuExpBar.showNumeric = true;
	PetFrameHealthBar.showNumeric = true;
	PetFrameManaBar.showNumeric = true;
	ShowTextStatusBarText(PlayerFrameHealthBar);
	ShowTextStatusBarText(PlayerFrameManaBar);
	ShowTextStatusBarText(PlayerFrameAlternateManaBar);
	ShowTextStatusBarText(MainMenuExpBar);
	ShowTextStatusBarText(PetFrameHealthBar);
	ShowTextStatusBarText(PetFrameManaBar);

	ShowWatchedReputationBarText();
	
	MicroButtonPulseStop(CharacterMicroButton);	--Stop the button pulse
	EventRegistry:TriggerEvent("CharacterFrame.Show");
end

function CharacterFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CharacterFrameEvents);

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();

	PlayerFrameHealthBar.showNumeric = nil;
	PlayerFrameManaBar.showNumeric = nil;
	PlayerFrameAlternateManaBar.showNumeric = nil;
	MainMenuExpBar.showNumeric =nil;
	PetFrameHealthBar.showNumeric = nil;
	PetFrameManaBar.showNumeric = nil;
	HideTextStatusBarText(PlayerFrameHealthBar);
	HideTextStatusBarText(PlayerFrameManaBar);
	HideTextStatusBarText(PlayerFrameAlternateManaBar);
	HideTextStatusBarText(MainMenuExpBar);
	HideTextStatusBarText(PetFrameHealthBar);
	HideTextStatusBarText(PetFrameManaBar);

	HideWatchedReputationBarText();

	PaperDollFrame.currentSideBar = nil;
	EventRegistry:TriggerEvent("CharacterFrame.Hide");
end

function CharacterFrameMixin:Collapse()
	self.Expanded = false;
	characterFrameDisplayInfo["Default"].width = PANEL_DEFAULT_WIDTH;
	characterFrameDisplayInfo["PetPaperDollFrame"].width = PANEL_DEFAULT_WIDTH;
	CharacterFrameExpandButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
	CharacterFrameExpandButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down");
	CharacterFrameExpandButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled");
	for i = 1, #PAPERDOLL_SIDEBARS do
		GetPaperDollSideBarFrame(i):Hide();
	end
	self.InsetRight:Hide();
	PaperDollFrame_SetLevel();
	self:RefreshDisplay();
end

function CharacterFrameMixin:Expand()
	self.Expanded = true;
	characterFrameDisplayInfo["Default"].width = CHARACTERFRAME_EXPANDED_WIDTH;
	characterFrameDisplayInfo["PetPaperDollFrame"].width = CHARACTERFRAME_EXPANDED_WIDTH;
	CharacterFrameExpandButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
	CharacterFrameExpandButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
	CharacterFrameExpandButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled");
	if (PaperDollFrame:IsShown() and PaperDollFrame.currentSideBar) then
		PaperDollFrame.currentSideBar:Show();
	else
		CharacterStatsPane:Show();
	end
	PaperDollFrame_UpdateSidebarTabs();
	self.InsetRight:Show();
	PaperDollFrame_SetLevel();
	self:RefreshDisplay();
end

CharacterFrameTabButtonMixin = {};

function CharacterFrameTabButtonMixin:OnClick(button)
	PanelTemplates_Tab_OnClick(self, CharacterFrame);
	
	local name = self:GetName();
	if ( name == "CharacterFrameTab1" ) then
		ToggleCharacter("PaperDollFrame");
	elseif ( name == "CharacterFrameTab2" ) then
		ToggleCharacter("PetPaperDollFrame");
	elseif ( name == "CharacterFrameTab3" ) then
		ToggleCharacter("ReputationFrame");
	elseif ( name == "CharacterFrameTab4" ) then
		ToggleCharacter("TokenFrame");
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end