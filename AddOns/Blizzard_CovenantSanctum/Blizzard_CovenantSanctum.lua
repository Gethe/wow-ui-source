CovenantSanctumMixin = {};

local TAB_UPGRADES = 1;
local TAB_FOUNDATIONS = 2;

function CovenantSanctumMixin:OnLoad()
	PanelTemplates_SetNumTabs(self, 2);
	
	local attributes = 
	{ 
		area = "center",
		pushable = 0,
		allowOtherPanels = 1,
	};
	RegisterUIPanel(CovenantSanctumFrame, attributes);	
end

local CovenantSanctumEvents = {
	"COVENANT_SANCTUM_INTERACTION_ENDED",
};

function CovenantSanctumMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CovenantSanctumEvents);

	local treeID = C_Garrison.GetCurrentGarrTalentTreeID();
	local treeInfo = C_Garrison.GetTalentTreeInfo(treeID);
	NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, treeInfo.textureKit);

	self:SetTab(TAB_UPGRADES);
end

function CovenantSanctumMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CovenantSanctumEvents);

	C_CovenantSanctumUI.EndInteraction();
end

function CovenantSanctumMixin:OnEvent(event, ...)
	if event == "COVENANT_SANCTUM_INTERACTION_ENDED" then
		HideUIPanel(self);
	end
end

function CovenantSanctumMixin:SetTab(tabID)
	PanelTemplates_SetTab(self, tabID);

	self.UpgradesTab:SetShown(tabID == TAB_UPGRADES);
	self.FoundationsTab:SetShown(tabID == TAB_FOUNDATIONS);
end