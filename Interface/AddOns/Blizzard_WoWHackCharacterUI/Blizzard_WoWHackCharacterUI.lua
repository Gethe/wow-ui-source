
WoWHackCharacterUIMixin = {};

local CHARACTER_ATTRIBUTE_SHEET_UNIT_EVENTS = {
	"UNIT_AURA",
	"UNIT_MODEL_CHANGED",
	"UNIT_PORTRAIT_UPDATE",
	"PLAYER_SPECIALIZATION_CHANGED",
};

function WoWHackCharacterUIMixin:OnLoad()
	self.ModelScene.ControlFrame:SetModelScene(self.ModelScene);

	local attributes = {
		area = "center",
		whileDead = 1,
		pushable = 0,
		allowOtherPanels = 1,
		checkFit = 1,
		checkFitExtraWidth = 200,
		checkFitExtraHeight = 140,
	};

	RegisterUIPanel(self, attributes);

	self:SetTitle(WOWHACK_CHARACTER_PANEL_TITLE);
end

function WoWHackCharacterUIMixin:OnShow()
	FrameUtil.RegisterFrameForUnitEvents(self, CHARACTER_ATTRIBUTE_SHEET_UNIT_EVENTS, "player");

	self:UpdatePlayerInfo();
	self:UpdatePortrait();
	self:UpdateModel();

	UpdateMicroButtons();
end

function WoWHackCharacterUIMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CHARACTER_ATTRIBUTE_SHEET_UNIT_EVENTS);

	UpdateMicroButtons();
end

function WoWHackCharacterUIMixin:OnEvent(event, ...)
	if event == "UNIT_AURA" or event == "UNIT_MODEL_CHANGED" then
		self:UpdateModel();
	elseif event == "UNIT_PORTRAIT_UPDATE" then
		self:UpdatePortrait();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:UpdatePlayerInfo();
	end
end

function WoWHackCharacterUIMixin:UpdatePlayerInfo()
	self.PlayerInfo.PlayerName.Name:SetText(UnitName("player"));

	local specIndex = C_SpecializationInfo.GetSpecialization();
	local specName = specIndex and select(2, C_SpecializationInfo.GetSpecializationInfo(specIndex)) or nil;
	self.PlayerInfo.PlayerName.SpecName:SetText(specName or "");
	self.PlayerInfo.PlayerName.SpecName:SetShown(specName ~= nil);
end

function WoWHackCharacterUIMixin:ApplyAuraVisualKits(actor, activeSpellVisualKitIDs)
	if not actor then
		return;
	end

	for _, spellVisualKitID in ipairs(activeSpellVisualKitIDs or {}) do
		actor:SetSpellVisualKit(spellVisualKitID);
	end
end

function WoWHackCharacterUIMixin:UpdateModel()
	local actor = ModelSceneUtil.SetUpCharacterSheetScene(self.ModelScene);
	if not actor then
		return;
	end

	local activeSpellVisualKitIDs = C_WoWHackAppearance.GetPlayerAuraSpellVisualKitIDs();
	self:ApplyAuraVisualKits(actor, activeSpellVisualKitIDs);
end

function WoWHackCharacterUIMixin:UpdatePortrait()
	SetPortraitTexture(self:GetPortrait(), "player");
end
