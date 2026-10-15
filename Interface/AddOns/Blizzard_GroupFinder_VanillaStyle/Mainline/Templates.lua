-------------------------------------------------------
----------LFGVanillaTabButtonMixin
-------------------------------------------------------
LFGVanillaTabButtonMixin = {};
function LFGVanillaTabButtonMixin:OnLoad()
	self.selectedTextY = 4;
	LowerFrameLevel(self);
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function LFGVanillaTabButtonMixin:OnShow()
	PanelTemplates_TabResize(self, 0);
end

function LFGVanillaTabButtonMixin:OnClick()
	local tabIndex = self.tabIndex or 1;
	LFGParentFrame_SetActiveTab(tabIndex);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function LFGVanillaTabButtonMixin:OnEnterTemp()
	-- override tooltip creation
end

function LFGVanillaTabButtonMixin:OnLeave()
	GameTooltip:Hide();
end


-- List Variant
LFGVanillaListTabButtonMixin = CreateFromMixins(LFGVanillaTabButtonMixin);
function LFGVanillaListTabButtonMixin:OnEnterTemp()
	if (C_LFGList.HasActiveEntryInfo()) then
		GameTooltip_AddNewbieTip(self, MicroButtonTooltipText(LFG_LIST_EDIT, "TOGGLELFGTAB"), 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_LFG_LIST_EDIT, 1);
	else
		GameTooltip_AddNewbieTip(self, MicroButtonTooltipText(LFG_LIST_TAB_1, "TOGGLELFGTAB"), 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_LFG_LIST_TAB_1, 1);
	end
end


-- Browser Variant
LFGVanillaBrowserTabButtonMixin = CreateFromMixins(LFGVanillaTabButtonMixin);
function LFGVanillaBrowserTabButtonMixin:OnEnterTemp()
	GameTooltip_AddNewbieTip(self, MicroButtonTooltipText(LFG_LIST_TAB_2, "TOGGLELFMTAB"), 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_LFG_LIST_TAB_2, 1);
end


-- Who List Variant
LFGVanillaWhoListTabButtonMixin = CreateFromMixins(LFGVanillaTabButtonMixin);
function LFGVanillaWhoListTabButtonMixin:OnEnterTemp()
	GameTooltip_AddNewbieTip(self, MicroButtonTooltipText(LFG_LIST_TAB_3, "TOGGLELFMTAB"), 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_LFG_LIST_TAB_2, 1);
end
