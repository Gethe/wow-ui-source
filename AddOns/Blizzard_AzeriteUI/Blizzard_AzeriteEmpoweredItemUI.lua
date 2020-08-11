AzeriteEmpoweredItemUIMixin = CreateFromMixins(CallbackRegistryMixin);

AzeriteEmpoweredItemUIMixin:GenerateCallbackEvents(
{
    "OnShow",
	"OnHide",
});

local AZERITE_EMPOWERED_FRAME_EVENTS = {
	"AZERITE_ITEM_POWER_LEVEL_CHANGED",
	"AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED",
	"PLAYER_EQUIPMENT_CHANGED",
	"SCRAPPING_MACHINE_SCRAPPING_FINISHED",
};

AZERITE_EMPOWERED_ITEM_MAX_TIERS = 5;

function AzeriteEmpoweredItemUIMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	UIPanelWindows[self:GetName()] = { area = "left", pushable = 1, xoffset = 35, yoffset = -9, bottomClampOverride = 100, checkFit = 1, showFailedFunc = function() self:OnShowFailed(); end, };

	self.BorderFrame.Bg:SetParent(self);
	self.BorderFrame.TopTileStreaks:Hide();

	self.transformTree = CreateFromMixins(TransformTreeMixin);
	self.transformTree:OnLoad();

	local root = self.transformTree:GetRoot();
	root:SetLocalScale(.5855);

	for i, rankFrame in ipairs(self.ClipFrame.BackgroundFrame.RankFrames) do
		rankFrame.Gear.transformNode = root:CreateNodeFromTexture(rankFrame.Gear);
		rankFrame.Gear.transformNode:SetLocalScale(1.05);

		rankFrame.RingBg.transformNode = root:CreateNodeFromTexture(rankFrame.RingBg);
		rankFrame.GearBg.transformNode = rankFrame.RingBg.transformNode:CreateNodeFromTexture(rankFrame.GearBg);
		rankFrame.RingLights.transformNode = rankFrame.RingBg.transformNode:CreateNodeFromTexture(rankFrame.RingLights);
	end

	local _, classFilename = UnitClass("player");
	if ( classFilename == "DRUID" ) then
		self.ClipFrame.BackgroundFrame.RankFrames[1].RingBg:SetAtlas("Azerite-TitanBG-Rank5-1Gear");
	end

	local function TierReset(framePool, frame)
		FramePool_HideAndClearAnchors(framePool, frame);
		frame:Reset();
	end
	self.tierPool = CreateFramePool("FRAME", self, "AzeriteEmpoweredItemTierTemplate", TierReset);

	local function PowerReset(transformTreeFramePool, frame)
		TransformTreeFrameNode_Reset(transformTreeFramePool, frame);
		frame:Reset();
	end
	self.powerPool = CreateTransformFrameNodePool("BUTTON", self.ClipFrame.PowerContainerFrame, "AzeriteEmpoweredItemPowerTemplate", PowerReset);
	self.azeriteItemDataSource = AzeriteEmpoweredItemDataSource:CreateEmpty();

	local startingSound = nil;
	local loopingSound = SOUNDKIT.UI_80_AZERITEARMOR_ROTATION_LOOP;
	local endingSound = SOUNDKIT.UI_80_AZERITEARMOR_ROTATIONENDCLICKS;

	local loopStartDelay = .25;
	local loopEndDelay = 0;
	local loopFadeTime = 500; -- ms
	self.loopingSoundEmitter = CreateLoopingSoundEffectEmitter(startingSound, loopingSound, endingSound, loopStartDelay, loopEndDelay, loopFadeTime);
end

function AzeriteEmpoweredItemUIMixin:OnUpdate(elapsed)
	if self.dirty then
		self.dirty = nil;
		self:Refresh();
	end

	for tierIndex, tierFrame in ipairs(self.tiersByIndex) do
		tierFrame:PerformAnimations(elapsed);
	end

	self.transformTree:ResolveTransforms();
end

function AzeriteEmpoweredItemUIMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	self:TriggerEvent(AzeriteEmpoweredItemUIMixin.Event.OnShow);
end

function AzeriteEmpoweredItemUIMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	self:Clear();

	self:TriggerEvent(AzeriteEmpoweredItemUIMixin.Event.OnHide);
end

function AzeriteEmpoweredItemUIMixin:OnEvent(event, ...)
	if event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" then
		local azeriteItemLocation, oldPowerLevel, newPowerLevel = ...;
		self:MarkDirty();
	elseif event == "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED" then
		local item = ...;
		self:MarkDirty();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:MarkDirty();
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		local equipmentSlot, hasCurrent = ...;
		if self.azeriteItemDataSource:DidEquippedItemChange(equipmentSlot) then
			self:Clear();
		end
	elseif event == "SCRAPPING_MACHINE_SCRAPPING_FINISHED" then  
		HideUIPanel(self);
	end
end

function AzeriteEmpoweredItemUIMixin:OnShowFailed()
	self:Clear();
end

function AzeriteEmpoweredItemUIMixin:OnTierAnimationStateChanged(tierFrame, animationBegin)
	if animationBegin then
		ScriptAnimationUtil.ShakeFrameRandom(self.ClipFrame.BackgroundFrame, 1, .7, .05);
	else
		self:OnTierAnimationProgress(tierFrame, nil);

		if tierFrame:IsFirstTier() and tierFrame:HasAnySelected() then
			if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_AZERITE_FIRST_POWER_LOCKED_IN) then
				local helpTipInfo = {
					text = AZERITE_TUTORIAL_FIRST_POWER_LOCKED_IN,
					buttonStyle = HelpTip.ButtonStyle.Close,
					cvarBitfield = "closedInfoFrames",
					bitfieldFlag = LE_FRAME_TUTORIAL_AZERITE_FIRST_POWER_LOCKED_IN,
					targetPoint = HelpTip.Point.RightEdgeCenter,
					offsetX = 10,
				};
				HelpTip:Show(self, helpTipInfo, tierFrame.tierSlot);
			end
		end
	end

	self:MarkDirty();
end

function AzeriteEmpoweredItemUIMixin:OnTierAnimationProgress(tierFrame, percent)
	self.ClipFrame.BackgroundFrame.KeyOverlay.Channel:UpdateTierAnimationProgress(tierFrame:GetTierIndex(), percent);
end

function AzeriteEmpoweredItemUIMixin:OnTierRevealRotationStarted(tierFrame)
	self.numTiersRevealing = (self.numTiersRevealing or 0) + 1;
	if self.numTiersRevealing == 1 then
		self:GetLoopingSoundEmitter():StartLoopingSound();
	end
end

function AzeriteEmpoweredItemUIMixin:OnTierRevealRotationStopped(tierFrame)
	self.numTiersRevealing = self.numTiersRevealing - 1;
	if self.numTiersRevealing == 0 then
		self:GetLoopingSoundEmitter():FinishLoopingSound();
		PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_ROTATIONENDS);
	end
end

function AzeriteEmpoweredItemUIMixin:CanSelectPowers()
	for tierIndex, tierFrame in ipairs(self.tiersByIndex) do
		if tierFrame:IsAnimating() then
			return false;
		end
	end
	return true;
end

function AzeriteEmpoweredItemUIMixin:GetPowerIdsForFinalSelectedTier()
	local powerIds = { }
	for tierIndex, tierFrame in ipairs(self.tiersByIndex) do
		if(not tierFrame:IsFinalTier()) then 
			table.insert(powerIds, tierFrame:GetSelectedPowerID());
		end
	end
	return powerIds;
end

function AzeriteEmpoweredItemUIMixin:IsFinalPowerSelected() 
	for tierIndex, tierFrame in ipairs(self.tiersByIndex) do
		if(tierFrame:IsFinalTier()) then 
			return tierFrame:HasAnySelected();
		end
	end
end 

function AzeriteEmpoweredItemUIMixin:IsAnyTierRevealing()
	for tierIndex, tierFrame in ipairs(self.tiersByIndex) do
		if tierFrame:IsRevealing() then
			return true;
		end
	end
	return false;
end

function AzeriteEmpoweredItemUIMixin:IsItemValid()
	return self.azeriteItemDataSource:IsValid();
end

local function HideAll(widgets)
	for i, widget in ipairs(widgets) do
		widget:Hide();
	end
end

function AzeriteEmpoweredItemUIMixin:Clear()
	StaticPopup_Hide("CONFIRM_AZERITE_EMPOWERED_BIND");
	StaticPopup_Hide("CONFIRM_AZERITE_EMPOWERED_SELECT_POWER");

	if self.oldItemGUID then
		C_Item.UnlockItemByGUID(self.oldItemGUID);
		self.oldItemGUID = nil;
	end

	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end

	self.azeriteItemDataSource:Clear();

	self.tierPool:ReleaseAll();
	self.tiersByIndex = {};
	self.powerPool:ReleaseAll();
	self.ClipFrame.BackgroundFrame.KeyOverlay.Channel:Reset();
	self:GetLoopingSoundEmitter():CancelLoopingSound();
	self.numTiersRevealing = nil;

	HideAll(self.ClipFrame.BackgroundFrame.RankFrames);
	HideAll(self.ClipFrame.BackgroundFrame.KeyOverlay.Slots);
	HideAll(self.ClipFrame.BackgroundFrame.KeyOverlay.Plugs);

	HelpTip:Hide(self, AZERITE_TUTORIAL_FIRST_POWER_LOCKED_IN);

	self:MarkDirty();

	FrameUtil.UnregisterFrameForEvents(self, AZERITE_EMPOWERED_FRAME_EVENTS);
	self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED");
end

function AzeriteEmpoweredItemUIMixin:SetToItemAtLocation(itemLocation)
	self:Clear();
	self.azeriteItemDataSource:SetSourceFromItemLocation(itemLocation);
	self:OnItemSet();
end

function AzeriteEmpoweredItemUIMixin:SetToItemLink(itemLink, overrideClassID, overrideSelectedPowersList)
	self:Clear();
	self.azeriteItemDataSource:SetSourceFromItemLink(itemLink, overrideClassID, overrideSelectedPowersList);
	self:OnItemSet();
end

function AzeriteEmpoweredItemUIMixin:OnItemSet()
	local itemValidationReason = self.azeriteItemDataSource:GetValidationInfo();
	if itemValidationReason ~= AzeriteEmpoweredItemDataSourceMixin.VALIDATION_SUCCESS then
		if itemValidationReason == AzeriteEmpoweredItemDataSourceMixin.VALIDATION_NO_PREVIEW_FOR_CLASS or AzeriteEmpoweredItemDataSourceMixin.VALIDATION_MISSING_DATA then
			UIErrorsFrame:AddExternalErrorMessage(AZERITE_PREVIEW_UNAVAILABLE_FOR_CLASS);
		end
		HideUIPanel(self);
		return;
	end

	self.PreviewItemOverlayFrame:SetShown(self.azeriteItemDataSource:IsPreviewSource());

	self.BorderFrame.TitleText:SetText("");

	local azeriteEmpoweredItem = self.azeriteItemDataSource:GetItem();
	azeriteEmpoweredItem:LockItem();
	self.itemDataLoadedCancelFunc = azeriteEmpoweredItem:ContinueWithCancelOnItemLoad(function()
		self.BorderFrame:SetPortraitToAsset(azeriteEmpoweredItem:GetItemIcon());
		self.BorderFrame.TitleText:SetText(azeriteEmpoweredItem:GetItemName());
	end);

	self.oldItemGUID = azeriteEmpoweredItem:GetItemGUID();

	FrameUtil.RegisterFrameForEvents(self, AZERITE_EMPOWERED_FRAME_EVENTS);
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player");

	local needsReveal = not self.azeriteItemDataSource:HasBeenViewed();
	self:RebuildTiers(needsReveal);
	self.azeriteItemDataSource:SetHasBeenViewed();
	if needsReveal then
		PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_FIRSTTIMEFLOURISH);
	end

	self:MarkDirty();
end

function AzeriteEmpoweredItemUIMixin:MarkDirty()
	self.dirty = true;
end

function AzeriteEmpoweredItemUIMixin:Refresh()
	if not self:IsItemValid() then
		HideUIPanel(self);
		return;
	end

	self:UpdateTiers();
end

function AzeriteEmpoweredItemUIMixin:GetLoopingSoundEmitter()
	return self.loopingSoundEmitter;
end

function AzeriteEmpoweredItemUIMixin:UpdateTiers()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	local azeriteItemPowerLevel = azeriteItemLocation and not AzeriteUtil.IsAzeriteItemLocationBankBag(azeriteItemLocation) and C_AzeriteItem.GetPowerLevel(azeriteItemLocation) or 0;

	for tierIndex, tierFrame in ipairs(self.tiersByIndex) do
		tierFrame:Update(azeriteItemPowerLevel);
	end

	self:UpdateChannelTier();
end

function AzeriteEmpoweredItemUIMixin:UpdateChannelTier()
	local bestTierIndex = nil;
	for tierIndex, tierFrame in ipairs(self.tiersByIndex) do
		if tierFrame:IsRevealing() then
			bestTierIndex = 0;
			break;
		elseif tierFrame:IsAnimating() then
			bestTierIndex = tierIndex;
		elseif not tierFrame:HasAnySelected() and not bestTierIndex then
			bestTierIndex = tierIndex - 1;
		end
	end

	if bestTierIndex then
		local selectedTierIndex = bestTierIndex > 0 and bestTierIndex or nil;
		self.ClipFrame.BackgroundFrame.KeyOverlay.Channel:SetUnlockedTier(selectedTierIndex);
	else
		self.ClipFrame.BackgroundFrame.KeyOverlay.Channel:SetUnlockedTier(#self.tiersByIndex);
	end
end

function AzeriteEmpoweredItemUIMixin:AdjustSizeForTiers(numTiers)
	if numTiers == 3 then
		self.ClipFrame.BackgroundFrame.KeyOverlay.Texture:SetAtlas("Azerite-CenterBG-3Ranks", true);
		self.ClipFrame.BackgroundFrame.KeyOverlay.Texture:SetPoint("CENTER", 3, 125);
		self.ClipFrame.BackgroundFrame.Bg:SetAtlas("Azerite-Background-3Ranks", true);

		self:SetSize(474, 484);
	elseif numTiers == 4 then
		self.ClipFrame.BackgroundFrame.KeyOverlay.Texture:SetAtlas("Azerite-CenterBG-4Ranks", true);
		self.ClipFrame.BackgroundFrame.KeyOverlay.Texture:SetPoint("CENTER", 0, 187);
		self.ClipFrame.BackgroundFrame.Bg:SetAtlas("Azerite-Background", true);
		self:SetSize(615, 628);
	elseif numTiers == 5 then
		self.ClipFrame.BackgroundFrame.KeyOverlay.Texture:SetAtlas("Azerite-CenterBG-5Ranks", true);
		self.ClipFrame.BackgroundFrame.KeyOverlay.Texture:SetPoint("CENTER", 0, 245);
		self.ClipFrame.BackgroundFrame.Bg:SetAtlas("Azerite-Background", false);
		self.ClipFrame.BackgroundFrame.Bg:SetSize(1260, 1260);
		self:SetSize(754, 764);
	end
	self.ClipFrame.BackgroundFrame.KeyOverlay.Channel:AdjustSizeForTiers(numTiers);
	UpdateUIPanelPositions(self);

	self.transformTree:GetRoot():SetLocalPosition(CreateVector2D(self.ClipFrame.BackgroundFrame:GetWidth() * .5, self.ClipFrame.BackgroundFrame:GetHeight() * .5));
end

function AzeriteEmpoweredItemUIMixin:RebuildTiers(needsReveal)
	-- This list goes from the first selectable tier to the last (outer to inner ring)
	local allTierInfo = self.azeriteItemDataSource:GetAllTierInfo();
	local numTiers = #allTierInfo;

	self:AdjustSizeForTiers(numTiers);

	for tierIndex, tierInfo in ipairs(allTierInfo) do
		local tierFrame = self.tierPool:Acquire();
		table.insert(self.tiersByIndex, tierFrame);

		local tierArtIndex = tierIndex + (AZERITE_EMPOWERED_ITEM_MAX_TIERS - numTiers);
		local rankFrame = self.ClipFrame.BackgroundFrame.RankFrames[tierArtIndex];

		local tierPlug = self.ClipFrame.BackgroundFrame.KeyOverlay.Plugs[tierArtIndex];
		local tierSlot = self.ClipFrame.BackgroundFrame.KeyOverlay.Slots[tierArtIndex];

		tierFrame:SetOwner(self, self.azeriteItemDataSource);
		tierFrame:SetVisuals(tierSlot, rankFrame, tierPlug, self.transformTree:GetRoot());

		local prereqTier = self.tiersByIndex[tierIndex - 1];
		tierFrame:SetTierInfo(tierIndex, numTiers, tierInfo, prereqTier);
		tierFrame:CreatePowers(self.powerPool);
		if needsReveal then
			tierFrame:PrepareForReveal();
		end
	end
end