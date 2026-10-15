
ScribeCurrencyFrameMixin = {};

local getScribeCurrencyIcon = TalentFrameUtil.GenerateTreeCurrencyDisplayCallback(14, 14);

function ScribeCurrencyFrameMixin:Setup(currencyInfo)
	local quantity = currencyInfo and currencyInfo.quantity or 0;
	local displayText = currencyInfo and (quantity .. " " .. getScribeCurrencyIcon(currencyInfo)) or quantity;
	self.UnspentPointsCount:SetText(displayText);
	self.traitCurrencyID = currencyInfo and currencyInfo.traitCurrencyID;
end

function ScribeCurrencyFrameMixin:OnEnter()
	if not self.traitCurrencyID then
		return;
	end

	local currencyTypesID = select(3, C_Traits.GetTraitCurrencyInfo(self.traitCurrencyID));
	if not currencyTypesID then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetCurrencyByID(currencyTypesID);
	GameTooltip:Show();
end

ScribeFrameMixin = {};

local SCRIBE_FRAME_EVENTS = {
	"SCRIBE_CLASS_CHANGED",
	"TRAIT_SYSTEM_NPC_CLOSED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
};

local TRAIT_CONFIG_EVENTS = {
	"TRAIT_CONFIG_UPDATED",
};

local SCRIBE_FRAME_UNIT_EVENTS = {
	"UNIT_SPELLCAST_INTERRUPTED",
	"UNIT_SPELLCAST_FAILED",
	"UNIT_SPELLCAST_STOP",
};

local INDEX_TO_CLASS = {
	[1] = Enum.ScribeClassID.Witch,
	[2] = Enum.ScribeClassID.Slayer,
	[3] = Enum.ScribeClassID.Inquisitor,
};

function ScribeFrameMixin:OnLoad()
	self:SetTitle(SCRIBE_FRAME_TITLE);

	self.classCardFramePool = CreateFramePool("Frame", self, "ScribeClassCardTemplate");

	local firstClassCard;
	local lastClassCard;
	for i = 1, #INDEX_TO_CLASS do
		local classCard = self.classCardFramePool:Acquire();
		if i == 1 then
			firstClassCard = classCard;
			classCard:SetPoint("TOPLEFT", self, "TOPLEFT", 7, -71);
		else
			classCard:SetPoint("TOPLEFT", lastClassCard, "TOPRIGHT", 1, 0);
		end


		classCard:Init(INDEX_TO_CLASS[i]);
		classCard:Show();

		if i ~= #INDEX_TO_CLASS then
			local divTexture = self.BorderOverlay:CreateTexture(nil, "OVERLAY");
			divTexture:SetAtlas("Talebound-Vendor-Filigree-Bar", TextureKitConstants.UseAtlasSize);
			divTexture:SetPoint("TOP", classCard, "TOPRIGHT", 0, 0);
			divTexture:SetPoint("BOTTOM", classCard, "BOTTOMRIGHT", 0, 0);
			divTexture:Show();
		end

		lastClassCard = classCard;
	end

	local borderTexture = self.BorderOverlay:CreateTexture(nil, "BORDER");
	borderTexture:SetAtlas("Talebound-Vendor-Filigree-Frame");
	borderTexture:SetPoint("TOPLEFT", firstClassCard, "TOPLEFT", -5, 6);
	borderTexture:SetPoint("BOTTOMRIGHT", lastClassCard, "BOTTOMRIGHT", 5, -6);
	borderTexture:Show();

	FrameUtil.RegisterFrameForEvents(self, SCRIBE_FRAME_EVENTS);
	FrameUtil.RegisterFrameForUnitEvents(self, SCRIBE_FRAME_UNIT_EVENTS, "player");

	EventRegistry:RegisterCallback("ScribeFrame.SetUILocked", self.SetUILocked, self);

	self:SetCurrClassID(C_ScribeUI.GetCurrClassID());
end

function ScribeFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, TRAIT_CONFIG_EVENTS);
	self:SetCurrClassID(C_ScribeUI.GetCurrClassID());
	self:UpdateTreeCurrencyInfo();

	if CanAutoSetGamePadCursorControl(true) then
		SetGamePadCursorControl(true);
	end

	UpdateMicroButtons();
end

function ScribeFrameMixin:OnHide()
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.TraitSystem);
	FrameUtil.UnregisterFrameForEvents(self, TRAIT_CONFIG_EVENTS);

	if CanAutoSetGamePadCursorControl(false) then
		SetGamePadCursorControl(false);
	end

	UpdateMicroButtons();
end

function ScribeFrameMixin:OnEvent(event, ...)
	if event == "SCRIBE_CLASS_CHANGED" then
		local scribeClassID = ...;
		self:SetCurrClassID(scribeClassID);

		self:UpdateTreeCurrencyInfo();
		self:SetUILocked(false);
	elseif event == "TRAIT_SYSTEM_NPC_CLOSED" then
		HideUIPanel(self);
	elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		self:UpdateTreeCurrencyInfo();
	elseif event == "TRAIT_CONFIG_UPDATED" then
		local updatedConfigID = ...;
		for classCard in self.classCardFramePool:EnumerateActive() do
			if classCard.TalentTree:GetConfigID() == updatedConfigID then
				classCard.TalentTree:UpdateTraitTree();
				classCard:UpdateStatusBar();
			end
		end
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_STOP" then
		local cancelledSpellID = select(3, ...);
		if cancelledSpellID and self.isUILocked and IsSpecializationActivateSpell(cancelledSpellID) then
			self:SetUILocked(false);
		end
	end
end

function ScribeFrameMixin:SetCurrClassID(classID)
	self.currClassID = classID;
	self:UpdateClassFrames();
	self:UpdateDisplayOnly();
end

function ScribeFrameMixin:SetUILocked(locked, activatingClassID)
	self.isUILocked = locked;
	self.activatingClassID = locked and activatingClassID or nil;
	self.DisabledOverlay:SetShown(locked);
	self.LoadingSpinner:SetShown(locked);

	for classCard in self.classCardFramePool:EnumerateActive() do
		classCard:SetUILocked(locked);

		if locked then
			if classCard:GetClassID() == activatingClassID then
				classCard.PreviewHoverController:SetControllerEnabled(false);
				classCard.ClassInfoOverlay:Hide();
			end
		else
			local isSelected = classCard:GetClassID() == self.currClassID;
			classCard:UpdateActivateClassButtonShown();
			classCard.PreviewHoverController:SetControllerEnabled(not isSelected);
		end
	end
end

function ScribeFrameMixin:SetDisplayOnly(displayOnly)
	self.displayOnly = displayOnly;

	self:UpdateDisplayOnly();
end

function ScribeFrameMixin:UpdateDisplayOnly()
	for classCard in self.classCardFramePool:EnumerateActive() do
		classCard:SetDisplayOnly(self.displayOnly);
	end
end

function ScribeFrameMixin:IsDisplayOnly()
	return self.displayOnly;
end

function ScribeFrameMixin:UpdateClassFrames()
	for classCard in self.classCardFramePool:EnumerateActive() do
		classCard:SetSelected(classCard:GetClassID() == self.currClassID);
	end
end

function ScribeFrameMixin:GetSharedTreeCurrencyInfo()
	for classCard in self.classCardFramePool:EnumerateActive() do
		local talentTree = classCard.TalentTree;
		local configID = talentTree:GetConfigID();
		local treeID = talentTree:GetTalentTreeID();
		if configID and treeID then
			local excludeStagedChanges = false;
			local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configID, treeID, excludeStagedChanges);
			if treeCurrencyInfo and treeCurrencyInfo[1] then
				return treeCurrencyInfo[1];
			end
		end
	end
	return nil;
end

function ScribeFrameMixin:UpdateTreeCurrencyInfo()
	local currencyInfo = self:GetSharedTreeCurrencyInfo();
	local showCurrency = currencyInfo ~= nil;
	if showCurrency then
		self.Currency:Setup(currencyInfo);
	end
	self.Currency:SetShown(showCurrency);
end
