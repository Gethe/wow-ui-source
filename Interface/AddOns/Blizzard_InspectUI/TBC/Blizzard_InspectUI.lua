INSPECTFRAME_SUBFRAMES = { "InspectPaperDollFrame", "InspectPVPFrame", "InspectTalentFrame", "InspectGuildFrame" };

INSPECTED_UNIT = nil;

local TALENTFRAME_TABINDEX = 3;
local GUILDFRAME_TABINDEX = 4;

function InspectFrame_Show(unit)
	HideUIPanel(InspectFrame);
	if ( CanInspect(unit, true) ) then
		INSPECTED_UNIT = unit;
		NotifyInspect(unit);
		InspectFrame.unit = unit;
		InspectSwitchTabs(1);
	else
		INSPECTED_UNIT = nil;
	end
end

function InspectFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("INSPECT_READY");
	self.unit = nil;
	INSPECTED_UNIT = nil;

	-- Tab Handling code
	if(ClassicExpansionAtMost(LE_EXPANSION_WRATH_OF_THE_LICH_KING)) then
		PanelTemplates_SetNumTabs(self, TALENTFRAME_TABINDEX);
		InspectFrameTab4:Hide();
	else
		PanelTemplates_SetNumTabs(self, GUILDFRAME_TABINDEX);
	end
	PanelTemplates_SetTab(self, 1);
end

function InspectFrame_OnEvent(self, event, ...)
	if(event == "INSPECT_READY") then
		local unit = ...;
		if (InspectFrame.unit and (UnitGUID(InspectFrame.unit) == unit)) then
			ShowUIPanel(InspectFrame);
			InspectFrame_UpdateTabs();
		end
	end

	if ( not self:IsShown() ) then
		return;
	end

	if ( event == "PLAYER_TARGET_CHANGED" or event == "GROUP_ROSTER_UPDATE" ) then
		if ( (event == "PLAYER_TARGET_CHANGED" and self.unit == "target") or
		     (event == "GROUP_ROSTER_UPDATE" and self.unit ~= "target") ) then
			HideUIPanel(InspectFrame);
		end
	elseif ( event == "UNIT_NAME_UPDATE" ) then
		local unit = ...;
		if ( unit == self.unit ) then
			InspectNameText:SetText(GetUnitName(self.unit, true));
		end
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if unit == self.unit then
			SetPortraitTexture(InspectFramePortrait, self.unit);
		end	
	elseif ( event == "PORTRAITS_UPDATED" ) then
		SetPortraitTexture(InspectFramePortrait, self.unit);
	end
end

function InspectFrame_UnitChanged(self)
	local unit = self.unit;
	NotifyInspect(unit);
	InspectPaperDollFrame_OnShow(self);
	SetPortraitTexture(InspectFramePortrait, unit);
	InspectNameText:SetText(GetUnitName(unit, true));
	InspectFrame_UpdateTabs();
	if ( InspectPVPFrame:IsShown() ) then
		InspectPVPFrame_OnShow();
	end
end

function InspectFrame_OnShow(self)
	if ( not self.unit ) then
		return;
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);	
	SetPortraitTexture(InspectFramePortrait, self.unit);
	InspectNameText:SetText(GetUnitName(self.unit, true));
end

function InspectFrame_OnHide(self)
	self.unit = nil;
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

	-- Clear the player being inspected
	ClearInspectPlayer();

	if(ClassicExpansionAtLeast(LE_EXPANSION_MISTS_OF_PANDARIA)) then
		-- in the InspectTalentFrame_Update function, a default talent tab is selected smartly if there is no tab selected
		-- it actually ends up feeling natural to have this behavior happen every time the frame is shown
		PanelTemplates_SetTab(InspectTalentFrame, nil);
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
		newFrame:Show();
	end
end

function InspectFrameTab_OnClick(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	InspectSwitchTabs(self:GetID());
end

function InspectFrame_UpdateTabs()
	if ( not InspectFrame.unit ) then
		return;
	end
	local level = UnitLevel(InspectFrame.unit);
	if ( level > 0 and level < 10 ) then
		PanelTemplates_DisableTab(InspectFrame, TALENTFRAME_TABINDEX);
		if ( PanelTemplates_GetSelectedTab(InspectFrame) == TALENTFRAME_TABINDEX ) then
			InspectSwitchTabs(1);
		end
	else
		PanelTemplates_EnableTab(InspectFrame, TALENTFRAME_TABINDEX);
		if(ClassicExpansionAtMost(LE_EXPANSION_CATACLYSM)) then
			InspectTalentFrame_UpdateTabs();
		end
	end

	-- Guild tab
	if(ClassicExpansionAtLeast(LE_EXPANSION_CATACLYSM)) then
		local _, _, guildName = C_PaperDollInfo.GetInspectGuildInfo(InspectFrame.unit);
		if ( guildName and guildName ~= "" ) then
			PanelTemplates_EnableTab(InspectFrame, GUILDFRAME_TABINDEX);
		else
			PanelTemplates_DisableTab(InspectFrame, GUILDFRAME_TABINDEX);
			if ( PanelTemplates_GetSelectedTab(InspectFrame) == GUILDFRAME_TABINDEX ) then
				InspectSwitchTabs(1);
			end
		end
	end
end
