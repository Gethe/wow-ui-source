CHARACTERFRAME_SUBFRAMES = { "PaperDollFrame", "ReputationFrame", "TokenFrame" };
CHARACTERFRAME_EXPANDED_WIDTH = 540;

local NUM_CHARACTERFRAME_TABS = 3;
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
					CharacterFrame_ShowSubFrame(tab);
				end
			else
				CharacterFrame_ShowSubFrame(tab);
				ShowUIPanel(CharacterFrame);
			end
		end
	end
end

function CharacterFrame_ShowSubFrame (frameName)
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value ~= frameName ) then
			_G[value]:Hide();	
		end	
	end 
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			_G[value]:Show()
		end	
	end 
end

function CharacterFrameTab_OnClick (self, button)
	local name = self:GetName();
	
	if ( name == "CharacterFrameTab1" ) then
		ToggleCharacter("PaperDollFrame");
	elseif ( name == "CharacterFrameTab2" ) then
		ToggleCharacter("ReputationFrame");	
	elseif ( name == "CharacterFrameTab3" ) then
		ToggleCharacter("TokenFrame");	
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function CharacterFrame_OnLoad (self)
	PortraitFrameTemplateMixin.OnLoad(self);

	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("PLAYER_PVP_RANK_CHANGED");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	ButtonFrameTemplate_HideButtonBar(self);
	self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", PANEL_DEFAULT_WIDTH + PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_OFFSET);
	self.TitleText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	SetTextStatusBarTextPrefix(PlayerFrameHealthBar, HEALTH);
	SetTextStatusBarTextPrefix(PlayerFrameManaBar, MANA);
	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, NUM_CHARACTERFRAME_TABS);
	PanelTemplates_SetTab(self, 1);
	
	self.TitleText:SetMaxLines(1);
	self.TitleText:SetHeight(13);
end

function CharacterFrame_UpdatePortrait()
	local masteryIndex = GetSpecialization();
	if (masteryIndex == nil) then
		local _, class = UnitClass("player");
		CharacterFramePortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
		CharacterFramePortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
	else
		local _, _, _, icon = GetSpecializationInfo(masteryIndex);
		CharacterFramePortrait:SetTexCoord(0, 1, 0, 1);
		SetPortraitToTexture(CharacterFramePortrait, icon);	
	end
end

function CharacterFrame_OnEvent (self, event, ...)
	if ( not self:IsShown() ) then
		return;
	end
	
	local arg1 = ...;
	if ( event == "UNIT_NAME_UPDATE" ) then
		if ( arg1 == "player" ) then
			CharacterFrameTitleText:SetText(UnitPVPName("player"));
		end
		return;
	elseif ( event == "PLAYER_PVP_RANK_CHANGED" ) then
		CharacterFrameTitleText:SetText(UnitPVPName("player"));
	elseif ( event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" ) then
		CharacterFrame_UpdatePortrait();
	end
end

function CharacterFrame_OnShow (self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	CharacterFrame_UpdatePortrait();
	UpdateMicroButtons();
	PlayerFrameHealthBar.showNumeric = true;
	PlayerFrameManaBar.showNumeric = true;
	PlayerFrameAlternateManaBar.showNumeric = true;
	MonkStaggerBar.showNumeric = true;
	PetFrameHealthBar.showNumeric = true;
	PetFrameManaBar.showNumeric = true;
	ShowTextStatusBarText(PlayerFrameHealthBar);
	ShowTextStatusBarText(PlayerFrameManaBar);
	ShowTextStatusBarText(PlayerFrameAlternateManaBar);
	ShowTextStatusBarText(MonkStaggerBar);
	ShowTextStatusBarText(PetFrameHealthBar);
	ShowTextStatusBarText(PetFrameManaBar);
	StatusTrackingBarManager:SetTextLocked(true);
	
	MicroButtonPulseStop(CharacterMicroButton);	--Stop the button pulse
end

function CharacterFrame_OnHide (self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();
	PlayerFrameHealthBar.showNumeric = nil;
	PlayerFrameManaBar.showNumeric = nil;
	PlayerFrameAlternateManaBar.showNumeric = nil;
	MonkStaggerBar.showNumeric = nil;
	PetFrameHealthBar.showNumeric = nil;
	PetFrameManaBar.showNumeric = nil;
	HideTextStatusBarText(PlayerFrameHealthBar);
	HideTextStatusBarText(PlayerFrameManaBar);
	HideTextStatusBarText(PlayerFrameAlternateManaBar);
	HideTextStatusBarText(MonkStaggerBar);
	HideTextStatusBarText(PetFrameHealthBar);
	HideTextStatusBarText(PetFrameManaBar);
	StatusTrackingBarManager:SetTextLocked(false);
	PaperDollFrame.currentSideBar = nil;
end

function CharacterFrame_Collapse()
	CharacterFrame:SetWidth(PANEL_DEFAULT_WIDTH);
	CharacterFrame.Expanded = false;
	for i = 1, #PAPERDOLL_SIDEBARS do
		_G[PAPERDOLL_SIDEBARS[i].frame]:Hide();
	end
	CharacterFrameInsetRight:Hide();
	UpdateUIPanelPositions(CharacterFrame);
	PaperDollFrame_SetLevel();
end

function CharacterFrame_Expand()
	CharacterFrame:SetWidth(CHARACTERFRAME_EXPANDED_WIDTH);
	CharacterFrame.Expanded = true;
	if (PaperDollFrame:IsShown() and PaperDollFrame.currentSideBar) then
		PaperDollFrame.currentSideBar:Show();
	else
		CharacterStatsPane:Show();
	end
	PaperDollFrame_UpdateSidebarTabs();
	CharacterFrameInsetRight:Show();
	UpdateUIPanelPositions(CharacterFrame);
	PaperDollFrame_SetLevel();
end

local function CompareFrameSize(frame1, frame2)
	return frame1:GetWidth() > frame2:GetWidth();
end
local CharTabtable = {}; 
function CharacterFrame_TabBoundsCheck(self)
	if ( string.sub(self:GetName(), 1, 17) ~= "CharacterFrameTab" ) then
		return;
	end
	
	for i=1, NUM_CHARACTERFRAME_TABS do
		_G["CharacterFrameTab"..i.."Text"]:SetWidth(0);
		PanelTemplates_TabResize(_G["CharacterFrameTab"..i], 0, nil, 36, 88);
	end
	
	local diff = _G["CharacterFrameTab"..NUM_CHARACTERFRAME_TABS]:GetRight() - CharacterFrame:GetRight();
	
	if ( diff > 0 and CharacterFrameTab3:IsShown() ) then
		--Find the biggest tab
		for i=1, NUM_CHARACTERFRAME_TABS do
			CharTabtable[i]=_G["CharacterFrameTab"..i];
		end
		table.sort(CharTabtable, CompareFrameSize);
		
		local i=1;
		while ( diff > 0 and i <= NUM_CHARACTERFRAME_TABS) do
			local tabText = _G[CharTabtable[i]:GetName().."Text"]
			local change = min(10, diff);
			diff = diff - change;
			tabText:SetWidth(0);
			PanelTemplates_TabResize(CharTabtable[i], -change, nil, 36-change, 88);
			i = i+1;
		end
	end
end
