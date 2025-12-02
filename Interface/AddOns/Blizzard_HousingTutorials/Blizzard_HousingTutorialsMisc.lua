
local HousingTutorialsItemAcquisitionMixin = CreateFromMixins(BagTutorialBaseMixin);

function HousingTutorialsItemAcquisitionMixin:Init()
	local itemAcquisitionTutorialSystem = "TutorialItemAcquisition";

	local helpTipInfos = {
		[BagTutorialHelpTipKeys.OpenBagsInfo] = {
			text = HOUSING_OPEN_BAGS_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.None,
			targetPoint = HelpTip.Point.TopEdgeRight,
			alignment = HelpTip.Alignment.Right,
			offsetX = -45,
			system = itemAcquisitionTutorialSystem,
		},
	
		[BagTutorialHelpTipKeys.ItemInfo] = {
			text = HOUSING_USE_ITEM_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			alignment = HelpTip.Alignment.Center,
			system = itemAcquisitionTutorialSystem,
			callbackArg = self,
			onAcknowledgeCallback = self.AcknowledgeTutorial,
		},
	}

	BagTutorialBaseMixin.Init(
		self,
		helpTipInfos,
		itemAcquisitionTutorialSystem,
		HOUSING_TUTORIAL_CVAR_BITFIELD,
		Enum.FrameTutorialAccount.HousingItemAcquisition
	);

	EventRegistry:RegisterFrameEventAndCallback("HOUSE_DECOR_ADDED_TO_CHEST", function(itemGUID)
		self:AcknowledgeTutorial();
	end, self);
end

function HousingTutorialsItemAcquisitionMixin:IsValidItem(itemHyperlink)
	local _name, _enchantLink, _displayQuality, _itemLevel, _requiredLevel, _className, _subclassName, _isStackable, _inventoryType, _iconFile, _sellPrice, itemClassID, itemSubclassID, _boundState, _expansionID, _itemSetID, _isTradeskill = C_Item.GetItemInfo(itemHyperlink);

	local housingItemClass = Enum.ItemClass.Housing;
	local decorItemSubClass = Enum.ItemHousingSubclass.Decor; 
	return itemClassID == housingItemClass and itemSubclassID == decorItemSubClass;
end

function HousingTutorialsItemAcquisitionMixin:IsComplete()
	return C_CVar.GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingItemAcquisition);
end

if C_CVar.GetCVarBool("housingTutorialsEnabled") and not C_CVar.GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingItemAcquisition) then
	CreateAndInitFromMixin(HousingTutorialsItemAcquisitionMixin):BeginInitialState();
end

HousingTutorialsNewPipMixin = {};

function HousingTutorialsNewPipMixin:Init()
	EventRegistry:RegisterCallback("HousingDashboard.Toggled", self.OnHousingDashboardToggled, self);

	HousingMicroButton.NotificationOverlay:Show();
end

function HousingTutorialsNewPipMixin:OnHousingDashboardToggled()
	if HousingDashboardFrame:IsShown() then
		HousingMicroButton.NotificationOverlay:Hide();
		C_CVar.SetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingNewPip, true);
	end
end

if not C_CVar.GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingNewPip) and C_CVar.GetCVarBool("housingTutorialsEnabled") then
	CreateAndInitFromMixin(HousingTutorialsNewPipMixin);
end

HOUSING_TUTORIALS_HOUSE_TELEPORT_EVENTS = {
	"PLAYER_HOUSE_LIST_UPDATED",
};

HousingTutorialsHouseTeleportWatcherMixin = {};

function HousingTutorialsHouseTeleportWatcherMixin:StartWatching()
	for _i, event in ipairs(HOUSING_TUTORIALS_HOUSE_TELEPORT_EVENTS) do
		Dispatcher:RegisterEvent(event, self);
	end

	EventRegistry:RegisterCallback("HousingMicroButton.Shown", self.OnHousingMicroButtonShown, self);
	EventRegistry:RegisterCallback("HousingUpgradeFrame.Shown", self.OnHousingUpgradeFrameShown, self);
	EventRegistry:RegisterCallback("HousingUpgradeFrame.Hidden", self.OnHousingUpgradeFrameHidden, self);

	-- Force us to query for owned houses on StartWatching
	C_Housing.GetPlayerOwnedHouses();
end

function HousingTutorialsHouseTeleportWatcherMixin:StopWatching()
	Dispatcher:UnregisterAll(self);

	EventRegistry:UnregisterCallback("HousingMicroButton.Shown", self);
	EventRegistry:UnregisterCallback("HousingUpgradeFrame.Shown", self);
	EventRegistry:UnregisterCallback("HousingUpgradeFrame.Hidden", self);
end

function HousingTutorialsHouseTeleportWatcherMixin:PLAYER_HOUSE_LIST_UPDATED(...)
	local houseInfoList = ...;
	if #houseInfoList > 0 then
		self:InitTutorial();
	end
end

function HousingTutorialsHouseTeleportWatcherMixin:InitTutorial()
	if HousingMicroButton and HousingMicroButton:IsEnabled() and HousingMicroButton:IsShown() and not C_CVar.GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingTeleportButton) then
		if not self.teleportTutorial then
			self.teleportTutorial = CreateAndInitFromMixin(HousingTutorialsHouseTeleportMixin);
		end

		self.teleportTutorial:BeginInitialState();
	end
end

function HousingTutorialsHouseTeleportWatcherMixin:OnHousingMicroButtonShown()
	if self.teleportTutorial then
		local teleportButton = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HousingTeleportToHouseTutorial.TeleportButton);
		if teleportButton and not teleportButton:IsVisible() then
			self.teleportTutorial:BeginState(HousingTutorialStates.TeleportToHouseTutorial.MicroButton);
		end
	end
end

function HousingTutorialsHouseTeleportWatcherMixin:OnHousingUpgradeFrameShown()
	if self.teleportTutorial then
		local teleportButtonHelpTipInfo = self.teleportTutorial.helpTipInfos[HousingTutorialStates.TeleportToHouseTutorial.TeleportButton];
		teleportButtonHelpTipInfo.parent = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HousingTeleportToHouseTutorial.TeleportButton);
		self.teleportTutorial:BeginState(HousingTutorialStates.TeleportToHouseTutorial.TeleportButton);
	end
end

function HousingTutorialsHouseTeleportWatcherMixin:OnHousingUpgradeFrameHidden()
	if self.teleportTutorial then
		self.teleportTutorial:BeginState(HousingTutorialStates.TeleportToHouseTutorial.MicroButton);
	end
end

local HousingTutorialsHouseTeleportWatcher = CreateFromMixins(HousingTutorialsHouseTeleportWatcherMixin);

HousingTutorialsHouseTeleportMixin = CreateFromMixins(HelpTipStateMachineBasedTutorialMixin);

function HousingTutorialsHouseTeleportMixin:Init()
	self.helpTipInfos = HousingTutorialData.HousingTeleportToHouseTutorial.HousingHouseTeleportHelpTipInfos;
	
	local microButtonHelpTipInfo = self.helpTipInfos[HousingTutorialStates.TeleportToHouseTutorial.MicroButton]
	microButtonHelpTipInfo.parent = BagsBar;
	microButtonHelpTipInfo.relativeRegion = HousingTutorialUtil.GetFrameFromData(HousingTutorialData.HousingTeleportToHouseTutorial.HousingMicroButton);
	
	local teleportButtonHelpTipInfo = self.helpTipInfos[HousingTutorialStates.TeleportToHouseTutorial.TeleportButton];
	teleportButtonHelpTipInfo.onAcknowledgeCallback = function()
		self:AcknowledgeTutorial();
		HousingTutorialsHouseTeleportWatcher:StopWatching();
	end
	
	HelpTipStateMachineBasedTutorialMixin.Init(
		self,
		self.helpTipInfos,
		HousingTutorialHelpTipSystems.TeleportToHouse,
		HousingTutorialStates.TeleportToHouseTutorial,
		HousingTutorialStates.TeleportToHouseTutorial.MicroButton,
		HOUSING_TUTORIAL_CVAR_BITFIELD,
		Enum.FrameTutorialAccount.HousingTeleportButton
	);
end

if C_CVar.GetCVarBool("housingTutorialsEnabled") and not C_CVar.GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingTeleportButton) then
	HousingTutorialsHouseTeleportWatcher:StartWatching();
end
