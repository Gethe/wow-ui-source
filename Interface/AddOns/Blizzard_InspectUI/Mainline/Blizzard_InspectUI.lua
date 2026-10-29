
INSPECTFRAME_SUBFRAMES = { "InspectPaperDollFrame", "InspectPVPFrame", "InspectGuildFrame" };

INSPECTPAPERDOLLFRAME_SLOTS = {
	"InspectHeadSlot",
	"InspectNeckSlot",
	"InspectShoulderSlot",
	"InspectBackSlot",
	"InspectChestSlot",
	"InspectShirtSlot",
	"InspectTabardSlot",
	"InspectWristSlot",
	"InspectHandsSlot",
	"InspectWaistSlot",
	"InspectLegsSlot",
	"InspectFeetSlot",
	"InspectFinger0Slot",
	"InspectFinger1Slot",
	"InspectTrinket0Slot",
	"InspectTrinket1Slot",
	"InspectMainHandSlot",
	"InspectSecondaryHandSlot",
};

INSPECTED_UNIT = nil;

UIPanelWindows["InspectFrame"] = { area = "left", pushable = 0, };

InspectFrameMixin = {};

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

function InspectFrameMixin:OnLoad()
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("INSPECT_READY");
	self.unit = nil;
	INSPECTED_UNIT = nil;

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 3);
	PanelTemplates_SetTab(self, 1);
	self:GetTitleText():SetFontObject("GameFontHighlight");
end

function InspectFrameMixin:OnEvent(event, ...)
	if event == "INSPECT_READY" then
		local unit = ...;
		if (self.unit and (UnitGUID(self.unit) == unit)) then
			ShowUIPanel(self);
			self:UpdateTabs();
		end
	end

	if not self:IsShown() then
		return;
	end

	if event == "PLAYER_TARGET_CHANGED" or event == "GROUP_ROSTER_UPDATE" then
		if event == "PLAYER_TARGET_CHANGED" and self.unit == "target" or
			event == "GROUP_ROSTER_UPDATE" and self.unit ~= "target" then
			-- Just hide the InspectFrame when the unit changes.  This hides the bug that occurs when you click on targets too quickly and the server drops the inspect data when flooded with inspect requests.
			HideUIPanel(self);
		end
	elseif event == "UNIT_NAME_UPDATE" then
		local unit = ...;
		if unit == self.unit then
			self:SetTitle(GetUnitName(self.unit, true));
		end
	elseif event == "UNIT_PORTRAIT_UPDATE" then
		local unit = ...;
		if unit == self.unit then
			self:SetPortraitToUnit(self.unit);
		end
	elseif event == "PORTRAITS_UPDATED" then
		self:SetPortraitToUnit(self.unit);
	end
end

function InspectFrameMixin:UnitChanged()
	local unit = self.unit;
	NotifyInspect(unit);
	InspectPaperDollFrame:OnShow();
	self:SetPortraitToUnit(unit);
	self:SetTitle(GetUnitName(unit, true));
	self:UpdateTabs();
	if InspectPVPFrame:IsShown() then
		InspectPVPFrame_OnShow();
	end
end

function InspectFrameMixin:OnShow()
	if ( not self.unit ) then
		return;
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	self:SetPortraitToUnit(self.unit);
	self:SetTitle(GetUnitName(self.unit, true));
end

function InspectFrameMixin:OnHide()
	self.unit = nil;
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

	-- Clear the player being inspected
	if not PlayerSpellsFrame or not PlayerSpellsFrame:IsInspecting() then
		ClearInspectPlayer();
	end
end

function InspectFrameMixin:OnUpdate()
end

function InspectSwitchTabs(newID)
	local newFrame = _G[INSPECTFRAME_SUBFRAMES[newID]];
	local oldFrame = _G[INSPECTFRAME_SUBFRAMES[PanelTemplates_GetSelectedTab(InspectFrame)]];
	oldFrame:Hide();
	PanelTemplates_SetTab(InspectFrame, newID);
	newFrame:Show();
end

function InspectFrameTab_OnClick(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	InspectSwitchTabs(self:GetID());
end

function InspectFrameMixin:UpdateTabs()
	if not self.unit then
		return;
	end

	-- Guild tab
	local _, _, guildName = C_PaperDollInfo.GetInspectGuildInfo(self.unit);
	if guildName and guildName ~= "" then
		PanelTemplates_EnableTab(self, 3);
	else
		PanelTemplates_DisableTab(self, 3);
		if ( PanelTemplates_GetSelectedTab(self) == 3 ) then
			InspectSwitchTabs(1);
		end
	end
end
