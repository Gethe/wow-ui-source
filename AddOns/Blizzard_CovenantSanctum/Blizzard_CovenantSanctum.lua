CovenantSanctumMixin = {};

local TAB_UPGRADES = 1;
local TAB_RENOWN = 2;

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

	self:SetTab(TAB_UPGRADES);
	-- todo: get actual level
	self.LevelFrame.Level:SetFormattedText(COVENANT_SANCTUM_LEVEL, 1);
end

function CovenantSanctumMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CovenantSanctumEvents);

	C_CovenantSanctumUI.EndInteraction();
end

function CovenantSanctumMixin:OnEvent(event, ...)
	if event == "COVENANT_SANCTUM_INTERACTION_STARTED" then
		self:SetCovenantInfo();
		ShowUIPanel(self);
	elseif event == "COVENANT_SANCTUM_INTERACTION_ENDED" then
		HideUIPanel(self);
	end
end

function CovenantSanctumMixin:SetTab(tabID)
	PanelTemplates_SetTab(self, tabID);

	self.UpgradesTab:SetShown(tabID == TAB_UPGRADES);
	self.RenownTab:SetShown(tabID == TAB_RENOWN);
end

function CovenantSanctumMixin:SetCovenantInfo()
	local treeID = C_Garrison.GetCurrentGarrTalentTreeID();
	if treeID ~= self.treeID then
		self.treeID = treeID;
		local treeInfo = C_Garrison.GetTalentTreeInfo(treeID);
		self.textureKit = treeInfo.textureKit;
		NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, treeInfo.textureKit);

		local atlas = "CovenantSanctum-Level-Border-%s";
		local useAtlasSize = true;
		self.LevelFrame.Background:SetAtlas(atlas:format(treeInfo.textureKit), useAtlasSize);
	end
end

function CovenantSanctumMixin:GetTreeID()
	return self.treeID;
end

function CovenantSanctumMixin:GetTextureKit()
	return self.textureKit;
end