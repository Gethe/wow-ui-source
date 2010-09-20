
INSPECTFRAME_SUBFRAMES = { "InspectPaperDollFrame", "InspectPVPFrame", "InspectTalentFrame", "InspectGuildFrame" };

UIPanelWindows["InspectFrame"] = { area = "left", pushable = 0, };

function InspectFrame_Show(unit)
	HideUIPanel(InspectFrame);
	if ( CanInspect(unit, true) ) then
		NotifyInspect(unit);
		InspectFrame.unit = unit;
		InspectSwitchTabs(1);
		ShowUIPanel(InspectFrame);
		InspectFrame_UpdateTabs();
	end
end

function InspectFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self.unit = nil;

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 4);
	PanelTemplates_SetTab(self, 1);
	self.TitleText:SetFontObject("GameFontHighlight");
end

function InspectFrame_OnEvent(self, event, ...)
	if ( not self:IsShown() ) then
		return;
	end
	if ( event == "PLAYER_TARGET_CHANGED" or event == "PARTY_MEMBERS_CHANGED" ) then
		if ( (event == "PLAYER_TARGET_CHANGED" and self.unit == "target") or
		     (event == "PARTY_MEMBERS_CHANGED" and self.unit ~= "target") ) then
			if ( CanInspect(self.unit) ) then
				InspectFrame_UnitChanged(self);
			else
				HideUIPanel(InspectFrame);
			end
		end
		return;
	elseif ( event == "UNIT_NAME_UPDATE" ) then
		local arg1 = ...;
		if ( arg1 == self.unit ) then
			InspectFrameTitleText:SetText(UnitName(arg1));
		end
		return;
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local arg1 = ...;
		if ( arg1 == self.unit ) then
			SetPortraitTexture(InspectFramePortrait, arg1);
		end
		return;
	end
end

function InspectFrame_UnitChanged(self)
	local unit = self.unit;
	NotifyInspect(unit);
	InspectPaperDollFrame_OnShow(self);
	SetPortraitTexture(InspectFramePortrait, unit);
	InspectFrameTitleText:SetText(UnitName(unit));
	InspectFrame_UpdateTabs();
	if ( InspectPVPFrame:IsShown() ) then
		InspectPVPFrame_OnShow();
	end
end

function InspectFrame_OnShow(self)
	if ( not self.unit ) then
		return;
	end
	PlaySound("igCharacterInfoOpen");	
	SetPortraitTexture(InspectFramePortrait, self.unit);
	InspectFrameTitleText:SetText(UnitName(self.unit));
end

function InspectFrame_OnHide(self)
	self.unit = nil;
	PlaySound("igCharacterInfoClose");

	-- Clear the player being inspected
	ClearInspectPlayer();

	-- in the InspectTalentFrame_Update function, a default talent tab is selected smartly if there is no tab selected
	-- it actually ends up feeling natural to have this behavior happen every time the frame is shown
	PanelTemplates_SetTab(InspectTalentFrame, nil);
end

function InspectFrame_OnUpdate(self)
	if ( not UnitIsVisible(self.unit) ) then
		HideUIPanel(InspectFrame);
	end
end		

function InspectSwitchTabs(newID)
	local newFrame = _G[INSPECTFRAME_SUBFRAMES[newID]];
	local oldFrame = _G[INSPECTFRAME_SUBFRAMES[PanelTemplates_GetSelectedTab(InspectFrame)]];
	if ( newFrame ) then
		if ( oldFrame ) then
			oldFrame:Hide();
		end
		PanelTemplates_SetTab(InspectFrame, newID);
		ShowUIPanel(InspectFrame);
		newFrame:Show();
	end
end

function InspectFrameTab_OnClick(self)
	PlaySound("igCharacterInfoTab");
	InspectSwitchTabs(self:GetID());
end

function InspectFrame_UpdateTabs()
	if ( not InspectFrame.unit ) then
		return;
	end
	
	-- Talent tab
	local level = UnitLevel(InspectFrame.unit);
	if ( level > 0 and level < 10 ) then
		PanelTemplates_DisableTab(InspectFrame, 3);
		if ( PanelTemplates_GetSelectedTab(InspectFrame) == 3 ) then
			InspectSwitchTabs(1);
		end
	else
		PanelTemplates_EnableTab(InspectFrame, 3);
		InspectTalentFrame_UpdateTabs();
	end
	
	-- Guild tab
	local guildName = GetGuildInfo(InspectFrame.unit);
	if ( guildName and guildName ~= "" ) then
		PanelTemplates_EnableTab(InspectFrame, 4);
	else
		PanelTemplates_DisableTab(InspectFrame, 4);
		if ( PanelTemplates_GetSelectedTab(InspectFrame) == 4 ) then
			InspectSwitchTabs(1);
		end	
	end
end
