UIPanelWindows["AzeriteEssenceUI"] = { area = "left", pushable = 1 };

AzeriteEssenceUIMixin = CreateFromMixins(CallbackRegistryMixin);

AzeriteEssenceUIMixin:GenerateCallbackEvents(
{
	"OnShow",
	"OnHide",
});

local ESSENCE_BUTTON_HEIGHT = 41;
local ESSENCE_HEADER_HEIGHT = 21;
local ESSENCE_BUTTON_OFFSET = 1;
local ESSENCE_LIST_PADDING = 3;

local LOCKED_FONT_COLOR = CreateColor(0.5, 0.447, 0.4);
local LOCKED_ICON_COLOR = CreateColor(.898, .804, .722);
local UNLOCK_LEVEL_TEXT_COLOR = CreateColor(0.051, 0.251, 0.373);
local CONNECTED_LINE_COLOR = CreateColor(.055, .796, .804);
local DISCONNECTED_LINE_COLOR = CreateColor(.055, .796, .804);
local LOCKED_LINE_COLOR = CreateColor(.486, .486, .486);

local HEART_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(256, 1962885);				-- Offhand_1H_HeartofAzeroth_D_01.m2
local LEARN_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(259, 2101299);				-- 	8FX_Azerite_AbsorbCurrency_Small_ImpactBase.m2
local LEARN_MODEL_SCENE_ACTOR_SETTINGS = {
	["effect"] = { startDelay = 0.79, duration = 0.769, speed = 1 },
};
local UNLOCK_SLOT_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(269, 1983548);		-- 	8FX_Azerite_Generic_NovaHigh_Base.m2
local UNLOCK_STAMINA_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(270, 1983548, 2924332);	-- 	8FX_Azerite_Generic_NovaHigh_Base.m2, CFX_Azerite_TimeLostTopaz_Major_Rank4_Cast.m2
local UNLOCK_MODEL_SCENE_ACTOR_SETTINGS = {
	["effect"] = { startDelay = 0, duration = 0.4, speed = 1 },
	["effect2"] = { startDelay = 0.4, duration = 0.6, speed = 1 },
};
local REVEAL_SLOT_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(286, 1983548, 2924332);		-- 	8FX_Azerite_Generic_NovaHigh_Base.m2, CFX_Azerite_TimeLostTopaz_Major_Rank4_Cast.m2
local REVEAL_MODEL_SCENE_ACTOR_SETTINGS = {
	["effect"] = { startDelay = 0, duration = 0.4, speed = 1 },
	["effect2"] = { startDelay = 0.4, duration = 1.2, speed = 1 },
};
local MAJOR_BLUE_GEM_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(287, 165995);		-- 	BlueGlow_High.m2
local MAJOR_PURPLE_GEM_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(288, 166008);	-- 	PurpleGlow_High.m2
local MINOR_PURPLE_GEM_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(289, 166008);	-- 	PurpleGlow_High.m2
local RANKED_MILESTONE_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(316, 1983524);	-- 	8FX_Azerite_Generic_PrecastHand.m2

local LEARN_SHAKE_DELAY = 0.869;
local LEARN_SHAKE = { { x = 0, y = -20}, { x = 0, y = 20}, { x = 0, y = -20}, { x = 0, y = 20}, { x = -9, y = -8}, { x = 8, y = 8}, { x = -3, y = -8}, { x = 9, y = 8}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, };
local LEARN_SHAKE_DURATION = 0.20;
local LEARN_SHAKE_FREQUENCY = 0.001;

local REVEAL_SHAKE_DELAY = 0.869;
local REVEAL_SHAKE = { { x = 0, y = -44}, { x = 0, y = 44}, { x = 0, y = -44}, { x = 0, y = 44}, { x = -9, y = -32}, { x = 8, y = 32}, { x = -3, y = -32}, { x = 9, y = 32}, { x = -11, y = -32}, { x = 1, y = 32}, { x = -13, y = -32}, { x = 7, y = 32}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, { x = -3, y = -1}, { x = 2, y = 2}, { x = -2, y = -3}, { x = -1, y = -1}, { x = 4, y = 2}, { x = 3, y = 4}, { x = -3, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 1}, };
local REVEAL_SHAKE_DURATION = 0.40;
local REVEAL_SHAKE_FREQUENCY = 0.001;

local REVEAL_START_DELAY = 0.9;
local REVEAL_DELAY_SECS_PER_DISTANCE = 0.0036;
local REVEAL_LINE_DURATION_SECS_PER_DISTANCE = 0.0012;
local REVEAL_SWIRL_SLOT_SCALE = 1;
local REVEAL_SWIRL_STAMINA_SCALE = 0.5;

local MAX_ESSENCE_RANK = 4;

local AZERITE_ESSENCE_FRAME_EVENTS = {
	"UI_MODEL_SCENE_INFO_UPDATED",
	"AZERITE_ESSENCE_CHANGED",
	"AZERITE_ESSENCE_ACTIVATED",
	"AZERITE_ESSENCE_ACTIVATION_FAILED",
	"AZERITE_ESSENCE_UPDATE",
	"AZERITE_ESSENCE_FORGE_OPEN",
	"AZERITE_ESSENCE_FORGE_CLOSE",
	"AZERITE_ESSENCE_MILESTONE_UNLOCKED",
	"AZERITE_ITEM_POWER_LEVEL_CHANGED",
	"AZERITE_ITEM_ENABLED_STATE_CHANGED",
};

local MILESTONE_LOCATIONS = {
	[1] = { left = 238, top = -235 },
	[2] = { left = 101, top = -270 },
	[3] = { left = 155, top = -349 },
	[4] = { left = 247, top = -375 },
	[5] = { left = 336, top = -337 },
	[6] = { left = 377, top = -250 },
	[7] = { left = 356, top = -156 },
	[8] = { left = 278, top = -99 },
	[9] = { left = 179, top = -106 },
	[10] = { left = 111, top = -174 },
	[11] = { left = 103, top = -191 },
};

local LOCKED_RUNE_ATLASES = { "heartofazeroth-slot-minor-unlearned-bottomleft", "heartofazeroth-slot-minor-unlearned-topright", "heartofazeroth-slot-minor-unlearned-3" };

function AzeriteEssenceUIMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.TopTileStreaks:Hide();
	self:SetupModelScene();
	self:SetupMilestones();
	self:RefreshPowerLevel();

	self.OrbGlass.AlphaAnim:Play();
	self.ItemModelScene.AlphaAnim:Play();
end

function AzeriteEssenceUIMixin:SetupMilestones()
	self.Milestones = { };
	self.Lines = { };

	local previousMilestoneFrame;
	local lockedRuneCount = 0;

	local milestones = C_AzeriteEssence.GetMilestones();

	for i, milestoneInfo in ipairs(milestones) do
		local template;
		if milestoneInfo.slot == Enum.AzeriteEssence.MainSlot then
			template = "AzeriteMilestoneMajorSlotTemplate";
		elseif milestoneInfo.rank then
			template = "AzeriteMilestoneRankedTemplate";
		elseif milestoneInfo.slot then
			template = "AzeriteMilestoneMinorSlotTemplate";
		else
			template = "AzeriteMilestoneStaminaTemplate";
		end

		local milestoneFrame = CreateFrame("FRAME", nil, self, template);
		milestoneFrame:SetPoint("CENTER", self.OrbBackground, "TOPLEFT", MILESTONE_LOCATIONS[i].left, MILESTONE_LOCATIONS[i].top);
		milestoneFrame:SetFrameLevel(1500);
		milestoneFrame.milestoneID = milestoneInfo.ID;
		milestoneFrame.slot = milestoneInfo.slot;
		if milestoneFrame.LockedState then
			lockedRuneCount = lockedRuneCount + 1;
			local runeAtlas = LOCKED_RUNE_ATLASES[lockedRuneCount];
			if runeAtlas then
				milestoneFrame.LockedState.Rune:SetAtlas(runeAtlas);
			end
		end

		if previousMilestoneFrame then
			local lineContainer = CreateFrame("FRAME", nil, self, "AzeriteEssenceDependencyLineTemplate");
			lineContainer:SetConnectedColor(CONNECTED_LINE_COLOR);
			lineContainer:SetDisconnectedColor(DISCONNECTED_LINE_COLOR);
			lineContainer:SetThickness(6);
			lineContainer.Background:Hide();

			local fromCenter = CreateVector2D(previousMilestoneFrame:GetCenter());
			fromCenter:ScaleBy(previousMilestoneFrame:GetEffectiveScale());

			local toCenter = CreateVector2D(milestoneFrame:GetCenter());
			toCenter:ScaleBy(milestoneFrame:GetEffectiveScale());

			toCenter:Subtract(fromCenter);

			lineContainer:CalculateTiling(toCenter:GetLength());

			lineContainer:SetEndPoints(previousMilestoneFrame, milestoneFrame);
			lineContainer:SetScrollAnimationProgressOffset(0);

			milestoneFrame.linkLine = lineContainer;
			lineContainer.fromButton = previousMilestoneFrame;
			lineContainer.toButton = milestoneFrame;
			tinsert(self.Lines, lineContainer);
		end

		tinsert(self.Milestones, milestoneFrame);
		previousMilestoneFrame = milestoneFrame;
	end
end

function AzeriteEssenceUIMixin:OnEvent(event, ...)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		self:SetupModelScene();
	elseif event == "AZERITE_ESSENCE_CHANGED" then
		local essenceID, rank = ...;
		self:RefreshSlots();
		self.EssenceList:Update();
		self.EssenceList:OnEssenceChanged(essenceID);
		AzeriteEssenceLearnAnimFrame:PlayAnim();
		if rank < MAX_ESSENCE_RANK then
			PlaySound(SOUNDKIT.UI_82_HEARTOFAZEROTH_LEARNESSENCE_ANIM);
		else
			PlaySound(SOUNDKIT.UI_82_HEARTOFAZEROTH_LEARNESSENCE_ANIM_RANK4);
		end
	elseif event == "AZERITE_ESSENCE_ACTIVATED" or event == "AZERITE_ESSENCE_ACTIVATION_FAILED" or event == "AZERITE_ESSENCE_UPDATE" then
		self:ClearNewlyActivatedEssence();
		self:RefreshSlots();
		self.EssenceList:Update();
	elseif event == "AZERITE_ESSENCE_FORGE_OPEN" or event == "AZERITE_ESSENCE_FORGE_CLOSE" then
		self:RefreshMilestones();
	elseif event == "AZERITE_ESSENCE_MILESTONE_UNLOCKED" then
		self:RefreshMilestones();
		local milestoneID = ...;
		local milestoneFrame = self:GetMilestoneFrame(milestoneID);
		if milestoneFrame then
			milestoneFrame:OnUnlocked();
		end
	elseif event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" then
		self:RefreshPowerLevel();
		self:RefreshMilestones();
	elseif event == "AZERITE_ITEM_ENABLED_STATE_CHANGED" then
		self:UpdateEnabledState();
		self:RefreshPowerLevel();
		self:RefreshMilestones();
		self:RefreshSlots();
		self.EssenceList:Update();
		self:UpdateEnabledAppearance();
	end
end

function AzeriteEssenceUIMixin:OnShow()
	-- portrait and title
	local itemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	if itemLocation then
		local item = Item:CreateFromItemLocation(itemLocation);
		item:ContinueOnItemLoad(function()
			self:SetPortraitToAsset(item:GetItemIcon());
			self:SetTitle(item:GetItemName());
		end);
	end

	FrameUtil.RegisterFrameForEvents(self, AZERITE_ESSENCE_FRAME_EVENTS);

	self:RefreshPowerLevel();
	self:RefreshMilestones();
	self:UpdateEnabledAppearance();

	PlaySound(SOUNDKIT.UI_82_HEARTOFAZEROTH_WINDOW_OPEN);

	self:TriggerEvent(AzeriteEssenceUIMixin.Event.OnShow);
end

function AzeriteEssenceUIMixin:OnHide()
	if C_AzeriteEssence:IsAtForge() then
		C_AzeriteEssence:CloseForge();
		CloseAllBags(self);
	end

	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end

	if self.numRevealsPlaying then
		self:CancelReveal();
	end
	self.shouldPlayReveal = nil;

	FrameUtil.UnregisterFrameForEvents(self, AZERITE_ESSENCE_FRAME_EVENTS);

	self:ClearNewlyActivatedEssence();

	-- clean up anims
	self.ActivationGlow.Anim:Stop();
	self.ActivationGlow:SetAlpha(0);
	AzeriteEssenceLearnAnimFrame:StopAnim();

	PlaySound(SOUNDKIT.UI_82_HEARTOFAZEROTH_WINDOW_CLOSE);

	self:TriggerEvent(AzeriteEssenceUIMixin.Event.OnHide);
end

function AzeriteEssenceUIMixin:UpdateEnabledState()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	self.isAzeriteItemEnabled = azeriteItemLocation and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItemLocation) or false;
end

function AzeriteEssenceUIMixin:IsAzeriteItemEnabled()
	if self.isAzeriteItemEnabled == nil then
		self:UpdateEnabledState();
	end

	return self.isAzeriteItemEnabled;
end

function AzeriteEssenceUIMixin:UpdateEnabledAppearance()
	local isEnabled = self:IsAzeriteItemEnabled();

	self.DisabledFrame:SetShown(not isEnabled);
	self.OrbRing:SetDesaturated(not isEnabled);
	self.ItemModelScene:SetDesaturation(isEnabled and 0 or 1);
	self.ItemModelScene:SetPaused(not isEnabled);

	for index, starFrame in ipairs(self.StarsAnimations) do
		starFrame.Anim:SetPlaying(isEnabled);
	end
end

function AzeriteEssenceUIMixin:OnMouseUp(mouseButton)
	if mouseButton == "LeftButton" or mouseButton == "RightButton" then
		C_AzeriteEssence.ClearPendingActivationEssence();
	end
end

function AzeriteEssenceUIMixin:TryShow()
	if C_AzeriteEssence.CanOpenUI() then
		ShowUIPanel(AzeriteEssenceUI);
		return true;
	end
	return false;
end

function AzeriteEssenceUIMixin:ShouldOpenBagsOnShow()
	return C_AzeriteEssence.GetNumUnlockedEssences() > 0;
end

function AzeriteEssenceUIMixin:OnEssenceActivated(essenceID, slotFrame)
	self:SetNewlyActivatedEssence(essenceID, slotFrame.milestoneID);

	self.ActivationGlow.Anim:Stop();
	self.ActivationGlow.Anim:Play();

	if self:ShouldPlayReveal() then
		self.revealInProgress = true;
		PlaySound(SOUNDKIT.UI_82_HEARTOFAZEROTH_SLOTFIRSTESSENCE);
		slotFrame:PlayRevealEffect();
		ScriptAnimationUtil.ShakeFrame(self:GetParent(), REVEAL_SHAKE, REVEAL_SHAKE_DURATION, REVEAL_SHAKE_FREQUENCY);
		C_Timer.After(REVEAL_START_DELAY,
			function()
				self:PlayReveal();
			end
		);
	else
		local soundID = SOUNDKIT.UI_82_HEARTOFAZEROTH_SLOTESSENCE;
		if slotFrame:IsMajorSlot() then
			local essenceInfo = C_AzeriteEssence.GetEssenceInfo(essenceID);
			if essenceInfo.rank == MAX_ESSENCE_RANK  then
				soundID = SOUNDKIT.UI_82_HEARTOFAZEROTH_SLOTMAJORESSENCE_RANK4;
			end
		end
		PlaySound(soundID);
	end

	self:RefreshSlots();
	C_AzeriteEssence.ClearPendingActivationEssence();
end

function AzeriteEssenceUIMixin:RefreshPowerLevel()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	if azeriteItemLocation then
		local level = C_AzeriteItem.GetPowerLevel(azeriteItemLocation);
		self.PowerLevelBadgeFrame.Label:SetText(level);
		self.PowerLevelBadgeFrame:Show();
		self.powerLevel = level;
	else
		self.PowerLevelBadgeFrame:Hide();
		self.powerLevel = 0;
	end
end

function AzeriteEssenceUIMixin:MeetsPowerLevel(level)
	return level <= self.powerLevel;
end

function AzeriteEssenceUIMixin:OnEnterPowerLevelBadgeFrame()
	local itemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	if itemLocation then
		local item = Item:CreateFromItemLocation(itemLocation);
		self.itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
			GameTooltip:SetOwner(self.PowerLevelBadgeFrame, "ANCHOR_RIGHT", -7, -6);
			GameTooltip_SetTitle(GameTooltip, item:GetItemName(), item:GetItemQualityColor().color);
			GameTooltip_AddColoredLine(GameTooltip, string.format(HEART_OF_AZEROTH_LEVEL, self.powerLevel), WHITE_FONT_COLOR);
			GameTooltip:Show();
		end);
	end
end

function AzeriteEssenceUIMixin:OnLeavePowerLevelBadgeFrame()
	GameTooltip:Hide();
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
end

function AzeriteEssenceUIMixin:RefreshMilestones()
	for i, milestoneFrame in ipairs(self.Milestones) do
		-- Main slot is always present
		if self:ShouldPlayReveal() and (not milestoneFrame.slot or not milestoneFrame:IsMajorSlot()) then
			milestoneFrame:Hide();
		else
			milestoneFrame:Show();
			milestoneFrame:Refresh();
		end
	end

	for i, lineContainer in ipairs(self.Lines) do
		if self:ShouldPlayReveal() then
			lineContainer:Hide();
		else
			lineContainer:Show();
			lineContainer:Refresh();
		end
	end
end

function AzeriteEssenceUIMixin:RefreshSlots()
	for i, slotButton in ipairs(self.Slots) do
		slotButton:Refresh();
	end
end

function AzeriteEssenceUIMixin:GetSlotFrame(slot)
	for _, slotFrame in ipairs(self.Slots) do
		if slotFrame.slot == slot then
			return slotFrame;
		end
	end
	return nil;
end

function AzeriteEssenceUIMixin:GetMilestoneFrame(milestoneID)
	for _, milestoneFrame in ipairs(self.Milestones) do
		if milestoneFrame.milestoneID == milestoneID then
			return milestoneFrame;
		end
	end
	return nil;
end

function AzeriteEssenceUIMixin:SetupModelScene()
	local forceUpdate = true;
	StaticModelInfo.SetupModelScene(self.ItemModelScene, HEART_MODEL_SCENE_INFO, forceUpdate);
end

function AzeriteEssenceUIMixin:SetNewlyActivatedEssence(essenceID, milestoneID)
	self.newlyActivatedEssenceID = essenceID;
	self.newlyActivatedEssenceMilestoneID = milestoneID;
end

function AzeriteEssenceUIMixin:GetNewlyActivatedEssence()
	return self.newlyActivatedEssenceID, self.newlyActivatedEssenceMilestoneID;
end

function AzeriteEssenceUIMixin:HasNewlyActivatedEssence()
	return self.newlyActivatedEssenceID ~= nil;
end

function AzeriteEssenceUIMixin:ClearNewlyActivatedEssence()
	self.newlyActivatedEssenceID = nil;
	self.newlyActivatedEssenceMilestoneID = nil;
end

function AzeriteEssenceUIMixin:GetSlotEssences()
	local slotEssences = { };
	for i, slotFrame in ipairs(self.Slots) do
		local essenceID = self:GetEffectiveEssence(slotFrame.milestoneID);
		if essenceID then
			slotEssences[essenceID] = slotFrame.slot;
		end
	end
	return slotEssences;
end

function AzeriteEssenceUIMixin:GetEffectiveEssence(milestoneID)
	if not milestoneID then
		return nil;
	end

	local newlyActivatedEssenceID, newlyActivatedEssenceMilestoneID = self:GetNewlyActivatedEssence();
	if milestoneID == newlyActivatedEssenceMilestoneID then
		return newlyActivatedEssenceID;
	end

	local essenceID = C_AzeriteEssence.GetMilestoneEssence(milestoneID);
	if essenceID == newlyActivatedEssenceID then
		return nil;
	else
		return essenceID;
	end
end

function AzeriteEssenceUIMixin:ShouldPlayReveal()
	if self.shouldPlayReveal == nil then
		self.shouldPlayReveal = C_AzeriteEssence:HasNeverActivatedAnyEssences();
	end
	return self.shouldPlayReveal;
end

function AzeriteEssenceUIMixin:IsRevealInProgress()
	return not not self.revealInProgress;
end

function AzeriteEssenceUIMixin:PlayReveal()
	if not self.revealSwirlPool then
		self.numRevealsPlaying = 0;
		self.revealSwirlPool = CreateFramePool("FRAME", self, "PowerSwirlAnimationTemplate");

		local previousFrame;
		local totalDistance = 0;
		for i, milestoneFrame in ipairs(self.Milestones) do
			if previousFrame then
				local delay = totalDistance * REVEAL_DELAY_SECS_PER_DISTANCE;
				local distance = RegionUtil.CalculateDistanceBetween(previousFrame, milestoneFrame);
				milestoneFrame:BeginReveal(delay);
				self:ApplyRevealSwirl(milestoneFrame, delay);
				milestoneFrame.linkLine:BeginReveal(delay, distance);
				self.numRevealsPlaying = self.numRevealsPlaying + 1;
				totalDistance = totalDistance + distance;
			end
			previousFrame = milestoneFrame;
		end

		PlaySound(SOUNDKIT.UI_82_HEARTOFAZEROTH_NODESREVEAL);
	end
end

function AzeriteEssenceUIMixin:ApplyRevealSwirl(milestoneFrame, delay)
	local swirlFrame = self.revealSwirlPool:Acquire();
	swirlFrame:SetAllPoints(milestoneFrame);
	swirlFrame:SetFrameLevel(milestoneFrame:GetFrameLevel() + 1);
	swirlFrame:SetScale(milestoneFrame.slot and REVEAL_SWIRL_SLOT_SCALE or REVEAL_SWIRL_STAMINA_SCALE);
	swirlFrame.timer = C_Timer.NewTimer(delay,
		function()
			swirlFrame:Show();
			swirlFrame.SelectedAnim:Play();
		end
	);
end

function AzeriteEssenceUIMixin:CancelReveal()
	for i, milestoneFrame in ipairs(self.Milestones) do
		milestoneFrame:CancelReveal();
	end

	for i, lineContainer in ipairs(self.Lines) do
		lineContainer:CancelReveal();
	end

	for swirlFrame in self.revealSwirlPool:EnumerateActive() do
		if swirlFrame.timer then
			swirlFrame.timer:Cancel();
		end
		swirlFrame.SelectedAnim:Stop();
	end
	self.revealSwirlPool:ReleaseAll();

	self.numRevealsPlaying = nil;
	self.revealInProgress = false;
end

function AzeriteEssenceUIMixin:OnSwirlAnimationFinished()
	self.numRevealsPlaying = self.numRevealsPlaying - 1;
	if self.numRevealsPlaying == 0 then
		self.numRevealsPlaying = nil;
		self.revealSwirlPool:ReleaseAll();
		self.shouldPlayReveal = false;
		self.revealInProgress = false;
		self:RefreshMilestones();
	end
end

AzeriteEssenceDependencyLineMixin = CreateFromMixins(PowerDependencyLineMixin);

function AzeriteEssenceDependencyLineMixin:SetDisconnected()
	self.FillScroll1:SetVertexColor(self.disconnectedColor:GetRGB());
	self.FillScroll2:SetVertexColor(self.disconnectedColor:GetRGB());
	PowerDependencyLineMixin.SetDisconnected(self);
end

function AzeriteEssenceDependencyLineMixin:Refresh()
	local isAzeriteItemEnabled = self:GetParent():IsAzeriteItemEnabled();

	if self.toButton.unlocked and isAzeriteItemEnabled then
		self:SetState(PowerDependencyLineMixin.LINE_STATE_CONNECTED);
		self:SetAlpha(0.2);
	else
		if self.fromButton.unlocked and self.toButton.canUnlock and isAzeriteItemEnabled then
			self:SetDisconnectedColor(DISCONNECTED_LINE_COLOR);
			self:SetState(PowerDependencyLineMixin.LINE_STATE_DISCONNECTED);
			self:SetAlpha(0.08);
		else
			self:SetDisconnectedColor(LOCKED_LINE_COLOR);
			self:SetState(PowerDependencyLineMixin.LINE_STATE_DISCONNECTED);
			self:SetAlpha(0.08);
		end
	end
end

function AzeriteEssenceDependencyLineMixin:BeginReveal(delay, distance)
	self:Show();
	self:SetState(PowerDependencyLineMixin.LINE_STATE_CONNECTED);
	PowerDependencyLineMixin.BeginReveal(self, delay, distance * REVEAL_LINE_DURATION_SECS_PER_DISTANCE);
end

function AzeriteEssenceDependencyLineMixin:CancelReveal()
	self.RevealAnim:Stop();
end

function AzeriteEssenceDependencyLineMixin:OnRevealFinished()
	self:Refresh();
end

AzeriteEssenceListMixin  = { };

function AzeriteEssenceListMixin:OnLoad()
	self.ScrollBar.doNotHide = true;
	self.update = function() self:Refresh(); end
	self.dynamic = function(...) return self:CalculateScrollOffset(...); end
	HybridScrollFrame_CreateButtons(self, "AzeriteEssenceButtonTemplate", 4, -ESSENCE_LIST_PADDING, "TOPLEFT", "TOPLEFT", 0, -ESSENCE_BUTTON_OFFSET, "TOP", "BOTTOM");
	self.HeaderButton:SetParent(self.ScrollChild);

	self:RegisterEvent("VARIABLES_LOADED");
	self.collapsed = GetCVarBool("otherRolesAzeriteEssencesHidden");

	self:CheckAndSetUpLearnEffect();
end

function AzeriteEssenceListMixin:OnShow()
	self:Update();
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:RegisterEvent("PENDING_AZERITE_ESSENCE_CHANGED");
end

function AzeriteEssenceListMixin:OnHide()
	self:CleanUpLearnEssence();
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:UnregisterEvent("PENDING_AZERITE_ESSENCE_CHANGED");
	C_AzeriteEssence.ClearPendingActivationEssence();
end

function AzeriteEssenceListMixin:OnEvent(event)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		self.LearnEssenceModelScene.effect = nil;
	elseif event == "PENDING_AZERITE_ESSENCE_CHANGED" then
		self:Refresh();
	elseif event == "VARIABLES_LOADED" then
		self.collapsed = GetCVarBool("otherRolesAzeriteEssencesHidden");
		self:Refresh();
	end
end

function AzeriteEssenceListMixin:Update()
	self:CacheAndSortEssences();
	self:Refresh();
end

function AzeriteEssenceListMixin:SetPendingEssence(essenceID)
	local essenceInfo = C_AzeriteEssence.GetEssenceInfo(essenceID);
	if essenceInfo and essenceInfo.unlocked and essenceInfo.valid then
		C_AzeriteEssence.SetPendingActivationEssence(essenceID);
		PlaySound(SOUNDKIT.UI_82_HEARTOFAZEROTH_SELECTESSENCE);
	end
end

local function SortComparison(entry1, entry2)
	if ( entry1.valid ~= entry2.valid ) then
		return entry1.valid;
	end
	if ( entry1.unlocked ~= entry2.unlocked ) then
		return entry1.unlocked;
	end
	if ( entry1.rank ~= entry2.rank ) then
		return entry1.rank > entry2.rank;
	end
	return strcmputf8i(entry1.name, entry2.name) < 0;
end

function AzeriteEssenceListMixin:CacheAndSortEssences()
	self.essences = C_AzeriteEssence.GetEssences();
	if not self.essences then
		return;
	end

	table.sort(self.essences, SortComparison);

	self.headerIndex = nil;
	for i, essenceInfo in ipairs(self.essences) do
		if not essenceInfo.valid then
			self.headerIndex = i;
			local headerInfo = { name = "Header", isHeader = true };
			tinsert(self.essences, i, headerInfo);
			break;
		end
	end
end

function AzeriteEssenceListMixin:CheckAndSetUpLearnEffect()
	local scene = self.LearnEssenceModelScene;
	if not scene.effect then
		local forceUpdate = true;
		local stopAnim = true;
		scene.effect = StaticModelInfo.SetupModelScene(scene, LEARN_MODEL_SCENE_INFO, forceUpdate, stopAnim);
	end
end

function AzeriteEssenceListMixin:GetNumViewableEssences()
	if not self:ShouldShowInvalidEssences() and self.headerIndex then
		return self.headerIndex;
	else
		return #self:GetCachedEssences();
	end
end

function AzeriteEssenceListMixin:ToggleHeader()
	self.collapsed = not self.collapsed;
	SetCVar("otherRolesAzeriteEssencesHidden", self.collapsed);
	self:Refresh();
end

function AzeriteEssenceListMixin:ForceOpenHeader()
	self.collapsed = false;
end

function AzeriteEssenceListMixin:ShouldShowInvalidEssences()
	return not self.collapsed;
end

function AzeriteEssenceListMixin:HasHeader()
	return self.headerIndex ~= nil;
end

function AzeriteEssenceListMixin:GetHeaderIndex()
	return self.headerIndex;
end

function AzeriteEssenceListMixin:GetCachedEssences()
	return self.essences or {};
end

function AzeriteEssenceListMixin:OnEssenceChanged(essenceID)
	if self.learnEssenceButton then
		return;
	end

	-- locate the appropriate button
	local essences = self:GetCachedEssences();
	local headerIndex = self:GetHeaderIndex();
	for index, essenceInfo in ipairs(essences) do
		if essenceInfo.ID == essenceID then
			-- open the header if closed and the essence is invalid
			if headerIndex and index > headerIndex and not self:ShouldShowInvalidEssences() then
				self:ForceOpenHeader();
			end
			-- scroll to the essence
			local getHeightFunc = function(index)
				if index == headerIndex then
					return ESSENCE_HEADER_HEIGHT + ESSENCE_BUTTON_OFFSET;
				else
					return ESSENCE_BUTTON_HEIGHT + ESSENCE_BUTTON_OFFSET;
				end
			end
			HybridScrollFrame_ScrollToIndex(self, index, getHeightFunc);
			-- find the button
			for i, button in ipairs(self.buttons) do
				if button.essenceID == essenceID then
					self.learnEssenceButton = button;
					break;
				end
			end
			break;
		end
	end

	if self.learnEssenceButton then
		-- disable the scrollbar
		ScrollBar_Disable(self.scrollBar);
		-- play glow
		self.learnEssenceButton.Glow.Anim:Play();
		self.learnEssenceButton.Glow2.Anim:Play();
		self.learnEssenceButton.Glow3.Anim:Play();
		-- scene
		local scene = self.LearnEssenceModelScene;
		scene:SetPoint("CENTER", self.learnEssenceButton);
		self:CheckAndSetUpLearnEffect();
		scene:ShowAndAnimateActors(LEARN_MODEL_SCENE_ACTOR_SETTINGS);
		C_Timer.After(2.969, function() self:CleanUpLearnEssence(); end);
	end
end

function AzeriteEssenceListMixin:CleanUpLearnEssence()
	if not self.learnEssenceButton then
		return;
	end

	self.learnEssenceButton.Glow.Anim:Stop();
	self.learnEssenceButton.Glow2.Anim:Stop();
	self.learnEssenceButton.Glow3.Anim:Stop();
	self.learnEssenceButton.Glow:SetAlpha(0);
	self.learnEssenceButton.Glow2:SetAlpha(0);
	self.learnEssenceButton.Glow3:SetAlpha(0);
	self.learnEssenceButton = nil;

	self.LearnEssenceModelScene:Hide();
	self:Refresh();
end

function AzeriteEssenceListMixin:CalculateScrollOffset(offset)
	local usedHeight = 0;
	local essences = self:GetCachedEssences();
	for i = 1, self:GetNumViewableEssences() do
		local essence = essences[i];
		local height;
		if essence.isHeader then
			height = ESSENCE_HEADER_HEIGHT + ESSENCE_BUTTON_OFFSET;
		else
			height = ESSENCE_BUTTON_HEIGHT + ESSENCE_BUTTON_OFFSET;
		end
		if ( usedHeight + height >= offset ) then
			return i - 1, offset - usedHeight;
		else
			usedHeight = usedHeight + height;
		end
	end
	return 0, 0;
end

function AzeriteEssenceListMixin:Refresh()
	local essences = self:GetCachedEssences();
	local numEssences = self:GetNumViewableEssences();

	local parent = self:GetParent();
	local isAzeriteItemEnabled = parent:IsAzeriteItemEnabled();
	local slotEssences = parent:GetSlotEssences();
	local pendingEssenceID = C_AzeriteEssence.GetPendingActivationEssence();

	local hasUnlockedEssence = false;

	self.HeaderButton:Hide();
	local offset = HybridScrollFrame_GetOffset(self);

	local totalHeight = numEssences * (ESSENCE_BUTTON_HEIGHT + ESSENCE_BUTTON_OFFSET) + ESSENCE_LIST_PADDING * 2;
	if self:HasHeader() then
		totalHeight = totalHeight + ESSENCE_HEADER_HEIGHT - ESSENCE_BUTTON_HEIGHT;
	end

	for i, button in ipairs(self.buttons) do
		local index = offset + i;
		if index <= numEssences then
			local essenceInfo = essences[index];
			if essenceInfo.isHeader then
				button:SetHeight(ESSENCE_HEADER_HEIGHT);
				button:Hide();
				self.HeaderButton:SetPoint("BOTTOM", button, 0, 0);
				self.HeaderButton:Show();
				if self:ShouldShowInvalidEssences() then
					self.HeaderButton.ExpandedIcon:Show();
					self.HeaderButton.CollapsedIcon:Hide();
				else
					self.HeaderButton.ExpandedIcon:Hide();
					self.HeaderButton.CollapsedIcon:Show();
				end
			else
				button:SetHeight(ESSENCE_BUTTON_HEIGHT);
				button.Icon:SetTexture(essenceInfo.icon);
				button.Name:SetText(essenceInfo.name);
				local activatedMarker;
				if essenceInfo.unlocked then
					local color = isAzeriteItemEnabled and  ITEM_QUALITY_COLORS[essenceInfo.rank + 1] or LOCKED_FONT_COLOR;	-- min shown quality is uncommon
					button.Name:SetTextColor(color.r, color.g, color.b);
					button.Icon:SetDesaturated(not essenceInfo.valid or not isAzeriteItemEnabled);
					button.Icon:SetVertexColor((isAzeriteItemEnabled and HIGHLIGHT_FONT_COLOR or LOCKED_ICON_COLOR):GetRGB());
					button.IconCover:SetShown(not isAzeriteItemEnabled);
					button.Background:SetAtlas("heartofazeroth-list-item");
					button.Background:SetDesaturated(not isAzeriteItemEnabled);
					local essenceSlot = slotEssences[essenceInfo.ID];
					if essenceSlot then
						if essenceSlot == Enum.AzeriteEssence.MainSlot then
							activatedMarker = button.ActivatedMarkerMain;
						else
							activatedMarker = button.ActivatedMarkerPassive;
						end
					end
					hasUnlockedEssence = true;
				else
					button.Name:SetTextColor(LOCKED_FONT_COLOR:GetRGB());
					button.Icon:SetDesaturated(true);
					button.Icon:SetVertexColor(LOCKED_FONT_COLOR:GetRGB());
					button.IconCover:Show();
					button.Background:SetAtlas("heartofazeroth-list-item-uncollected");
					button.Background:SetDesaturated(not isAzeriteItemEnabled);
				end
				button.PendingGlow:SetShown(essenceInfo.ID == pendingEssenceID and isAzeriteItemEnabled);
				button.essenceID = essenceInfo.ID;
				button.rank = essenceInfo.rank;
				button:Show();

				local desaturation = (not isAzeriteItemEnabled) and 1 or 0;

				for _, marker in ipairs(button.ActivatedMarkers) do
					marker:SetShown(marker == activatedMarker);
					marker:DesaturateHierarchy(desaturation);
				end
			end
		else
			button:Hide();
		end
	end

	HybridScrollFrame_Update(self, totalHeight, self:GetHeight());
	self:UpdateMouseOverTooltip();

	parent.RightInset.Background:SetDesaturated(not isAzeriteItemEnabled);

	if parent:ShouldPlayReveal() and not parent:IsRevealInProgress() then
		ScrollBar_Disable(self.scrollBar);
		if hasUnlockedEssence then
			local helpTipInfo = {
				text = AZERITE_ESSENCE_TUTORIAL_FIRST_ESSENCE,
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeCenter,
				offsetY = -12,
			};
			HelpTip:Show(self, helpTipInfo, self.buttons[1].Icon);
		else
			HelpTip:Hide(self, AZERITE_ESSENCE_TUTORIAL_FIRST_ESSENCE);
		end
	else
		HelpTip:Hide(self, AZERITE_ESSENCE_TUTORIAL_FIRST_ESSENCE);
	end
end

function AzeriteEssenceListMixin:UpdateMouseOverTooltip()
	for i, button in ipairs(self.buttons) do
		-- need to check shown for when mousing over button covered by header
		if button:IsMouseOver() and button:IsShown() then
			button:OnEnter();
			return;
		end
	end
end

AzeriteEssenceButtonMixin  = { };

function AzeriteEssenceButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetAzeriteEssence(self.essenceID, self.rank);
	GameTooltip:Show();
end

function AzeriteEssenceButtonMixin:OnClick(mouseButton)
	if mouseButton == "LeftButton" then
		local linkedToChat = false;
		if ( IsModifiedClick("CHATLINK") ) then
			linkedToChat = HandleModifiedItemClick(C_AzeriteEssence.GetEssenceHyperlink(self.essenceID, self.rank));
		end
		if ( not linkedToChat ) then
			self:GetParent():GetParent():SetPendingEssence(self.essenceID);
		end
	elseif mouseButton == "RightButton" then
		C_AzeriteEssence.ClearPendingActivationEssence();
	end
end

AzeriteMilestoneBaseMixin = { };

function AzeriteMilestoneBaseMixin:OnLoad()
	if self.isDraggable then
		self:RegisterForDrag("LeftButton");
	end
	self.SwirlContainer:SetScale(self.swirlScale);
end

function AzeriteMilestoneBaseMixin:OnEvent(event, ...)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		self.EffectsModelScene.primaryEffect = nil;
		self.EffectsModelScene.secondaryEffect = nil;
		if self.slot or self.rank then
			local forceUpdate = true;
			self:UpdateModelScenes(forceUpdate);
		end
	end
end

function AzeriteMilestoneBaseMixin:OnShow()
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function AzeriteMilestoneBaseMixin:OnHide()
	self:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function AzeriteMilestoneBaseMixin:OnMouseUp(mouseButton)
	if mouseButton == "LeftButton" then
		if self.canUnlock and C_AzeriteEssence.IsAtForge() then
			C_AzeriteEssence.UnlockMilestone(self.milestoneID);
		end
	end
end

function AzeriteMilestoneBaseMixin:OnEnter()
	local spellID = C_AzeriteEssence.GetMilestoneSpell(self.milestoneID);
	if not spellID then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local spell = Spell:CreateFromSpellID(spellID);
	spell:ContinueWithCancelOnSpellLoad(function()
		if GameTooltip:GetOwner() == self then
			local wrapText = true;
			GameTooltip_SetTitle(GameTooltip, spell:GetSpellName());
			GameTooltip_AddColoredLine(GameTooltip, spell:GetSpellDescription(), NORMAL_FONT_COLOR, wrapText);
			if not self.unlocked then
				self:AddStateToTooltip(AZERITE_ESSENCE_LOCKED_MILESTONE_LEVEL, AZERITE_ESSENCE_UNLOCK_MILESTONE);
			end
			GameTooltip:Show();
		end
	end);
end

function AzeriteMilestoneBaseMixin:OnLeave()
	if self.UnlockedState then
		self.UnlockedState.HighlightRing:Hide();
		if self.isDraggable then
			self.UnlockedState.DragHighlight:Hide();
		end
	end
	GameTooltip:Hide();
end

function AzeriteMilestoneBaseMixin:ShowStateFrame(stateFrame)
	if not self.StateFrames then
		return;
	end
	for i, frame in ipairs(self.StateFrames) do
		frame:SetShown(frame == stateFrame);
	end
end

function AzeriteMilestoneBaseMixin:CheckAndSetUpUnlockEffect()
	local scene = self.EffectsModelScene;
	if not scene.primaryEffect then
		local forceUpdate = true;
		local stopAnim = true;
		local sceneInfo = self.slot and UNLOCK_SLOT_MODEL_SCENE_INFO or UNLOCK_STAMINA_MODEL_SCENE_INFO;
		scene.primaryEffect, scene.secondaryEffect = StaticModelInfo.SetupModelScene(scene, sceneInfo, forceUpdate, stopAnim);
	end
end

function AzeriteMilestoneBaseMixin:OnUnlocked()
	self:CheckAndSetUpUnlockEffect();
	local scene = self.EffectsModelScene;
	if scene.primaryEffect then
		scene:ShowAndAnimateActors(UNLOCK_MODEL_SCENE_ACTOR_SETTINGS, function() scene:Hide(); end);
		C_Timer.After(.4,
			function()
				self.SwirlContainer:Show();
				self.SwirlContainer.SelectedAnim:Play();
			end
		);
		if GameTooltip:GetOwner() == self then
			self:OnEnter();
		end
	end

	if self.slot then
		PlaySound(SOUNDKIT.UI_82_HEARTOFAZEROTH_UNLOCKESSENCESLOT);
	else
		PlaySound(SOUNDKIT.UI_82_HEARTOFAZEROTH_UNLOCKSTAMINANODE);
	end
end

function AzeriteMilestoneBaseMixin:CheckAndSetUpRevealEffect()
	local scene = self.EffectsModelScene;
	if not scene.primaryEffect then
		scene:SetSize(2000, 2000);
		local forceUpdate = true;
		local stopAnim = true;
		scene.primaryEffect, scene.secondaryEffect = StaticModelInfo.SetupModelScene(scene, REVEAL_SLOT_MODEL_SCENE_INFO, forceUpdate, stopAnim);
	end
end

function AzeriteMilestoneBaseMixin:PlayRevealEffect()
	self:CheckAndSetUpRevealEffect();

	local scene = self.EffectsModelScene;
	if scene.primaryEffect then
		scene:ShowAndAnimateActors(REVEAL_MODEL_SCENE_ACTOR_SETTINGS, function() scene:Hide(); end);
	end
end

function AzeriteMilestoneBaseMixin:BeginReveal(delay)
	self:Show();
	self:Refresh();
	self.RevealAnim.Start:SetEndDelay(delay);
	self.RevealAnim:Play();
end

function AzeriteMilestoneBaseMixin:CancelReveal(delay)
	self.RevealAnim:Stop();
	self:SetAlpha(1);
end

function AzeriteMilestoneBaseMixin:ShouldShowUnlockState()
	if C_AzeriteEssence.IsAtForge() then
		return self.canUnlock;
	else
		return self:GetParent():MeetsPowerLevel(self.requiredLevel)
	end
end

function AzeriteMilestoneBaseMixin:UpdateMilestoneInfo()
	local milestoneInfo = C_AzeriteEssence.GetMilestoneInfo(self.milestoneID);

	self.unlocked = milestoneInfo.unlocked;
	self.canUnlock = milestoneInfo.canUnlock;
	self.requiredLevel = milestoneInfo.requiredLevel;
	self.rank = milestoneInfo.rank;
end

function AzeriteMilestoneBaseMixin:AddStateToTooltip(requiredLevelString, returnToForgeString)
	local wrapText = true;
	if C_AzeriteEssence.IsAtForge() then
		if self.canUnlock then
			GameTooltip_AddColoredLine(GameTooltip, AZERITE_CLICK_TO_SELECT, GREEN_FONT_COLOR, wrapText);
		elseif self:GetParent():MeetsPowerLevel(self.requiredLevel) then
			GameTooltip_AddColoredLine(GameTooltip, AZERITE_MILESTONE_NO_ACTIVE_LINKS, RED_FONT_COLOR, wrapText);
		else
			GameTooltip_AddColoredLine(GameTooltip, string.format(requiredLevelString, self.requiredLevel), DISABLED_FONT_COLOR, wrapText);
		end
	else
		if self:ShouldShowUnlockState() then
			GameTooltip_AddColoredLine(GameTooltip, returnToForgeString, RED_FONT_COLOR, wrapText);
		else
			GameTooltip_AddColoredLine(GameTooltip, string.format(requiredLevelString, self.requiredLevel), DISABLED_FONT_COLOR, wrapText);
		end
	end
end

function AzeriteMilestoneBaseMixin:IsMajorSlot()
	return self.isMajorSlot;
end

AzeriteMilestoneSlotMixin = CreateFromMixins(AzeriteMilestoneBaseMixin);

function AzeriteMilestoneSlotMixin:OnLoad()
	self.UnlockedState.EmptyGlow.Anim:Play();
	AzeriteMilestoneBaseMixin.OnLoad(self);
end

function AzeriteMilestoneSlotMixin:OnDragStart()
	local spellID = C_AzeriteEssence.GetMilestoneSpell(self.milestoneID);
	if spellID then
		PickupSpell(spellID);
	end
end

function AzeriteMilestoneSlotMixin:UpdateModelScenes(forceUpdate)
	if not self.unlocked then
		return;
	end

	local isAzeriteItemEnabled = self:GetParent():IsAzeriteItemEnabled();

	if forceUpdate then
		self.UnlockedState.PurpleGemModelScene.forceUpdate = true;
		if self:IsMajorSlot() then
			self.UnlockedState.BlueGemModelScene.forceUpdate = true;
		end
	end

	if self:GetParent():GetEffectiveEssence(self.milestoneID) then
		local purpleGemModelSceneInfo = MINOR_PURPLE_GEM_MODEL_SCENE_INFO;
		if self:IsMajorSlot() then
			purpleGemModelSceneInfo = MAJOR_PURPLE_GEM_MODEL_SCENE_INFO;
			local scene = self.UnlockedState.BlueGemModelScene;
			scene:Show();
			scene.forceUpdate = not StaticModelInfo.SetupModelScene(scene, MAJOR_BLUE_GEM_MODEL_SCENE_INFO, scene.forceUpdate);
			scene:SetDesaturation(isAzeriteItemEnabled and 0 or 1);
			scene:SetPaused(not isAzeriteItemEnabled);
		end
		local scene = self.UnlockedState.PurpleGemModelScene;
		scene:Show();
		scene.forceUpdate = not StaticModelInfo.SetupModelScene(scene, purpleGemModelSceneInfo, scene.forceUpdate);
		scene:SetDesaturation(isAzeriteItemEnabled and 0 or 1);
		scene:SetPaused(not isAzeriteItemEnabled);
	else
		if self:IsMajorSlot() then
			self.UnlockedState.BlueGemModelScene:Hide();
		end
		self.UnlockedState.PurpleGemModelScene:Hide();
	end
end

function AzeriteMilestoneSlotMixin:Refresh()
	self:UpdateMilestoneInfo();

	local isAzeriteItemEnabled = self:GetParent():IsAzeriteItemEnabled();
	local desaturation = (not isAzeriteItemEnabled) and 1 or 0

	if self.unlocked then
		if self:IsMajorSlot() and self:GetParent():ShouldPlayReveal() then
			self:CheckAndSetUpRevealEffect();
		end
		self:ShowStateFrame(self.UnlockedState);
		local essenceID = self:GetParent():GetEffectiveEssence(self.milestoneID);
		local icon;
		if essenceID then
			local essenceInfo = C_AzeriteEssence.GetEssenceInfo(essenceID);
			icon = essenceInfo and essenceInfo.icon or nil;
		end

		local stateFrame = self.UnlockedState;
		if icon then
			stateFrame.Icon:SetTexture(icon);
			stateFrame.Icon:Show();
			stateFrame.EmptyIcon:Hide();
			stateFrame.EmptyGlow:Hide();
		else
			stateFrame.Icon:Hide();
			stateFrame.EmptyIcon:Show();
			stateFrame.EmptyGlow:Show();
		end

		stateFrame:DesaturateHierarchy(desaturation);
	else
		if not self:IsMajorSlot() then
			self:CheckAndSetUpUnlockEffect();
		end
		if self:ShouldShowUnlockState() then
			self:ShowStateFrame(self.AvailableState);
			self.AvailableState:DesaturateHierarchy(desaturation);
			if C_AzeriteEssence.IsAtForge() then
				self.AvailableState.GlowAnim:Stop();

				if isAzeriteItemEnabled then
					self.AvailableState.ForgeGlowAnim:Play();
				end
			else
				self.AvailableState.ForgeGlowAnim:Stop();

				if isAzeriteItemEnabled then
					self.AvailableState.GlowAnim:Play();
				end
			end
		else
			self:ShowStateFrame(self.LockedState);
			self.LockedState:DesaturateHierarchy(desaturation);
			self.LockedState.UnlockLevelText:SetText(self.requiredLevel);
			self.LockedState.UnlockLevelText:SetTextColor((isAzeriteItemEnabled and UNLOCK_LEVEL_TEXT_COLOR or LOCKED_FONT_COLOR):GetRGB())
		end
	end

	self:UpdateModelScenes();
end

function AzeriteMilestoneSlotMixin:OnMouseUp(button)
	if button == "LeftButton" then
		if IsModifiedClick("CHATLINK") then
			local essenceID = C_AzeriteEssence.GetMilestoneEssence(self.milestoneID);
			if essenceID then
				local essenceInfo = C_AzeriteEssence.GetEssenceInfo(essenceID);
				if essenceInfo then
					if HandleModifiedItemClick(C_AzeriteEssence.GetEssenceHyperlink(essenceInfo.ID, essenceInfo.rank)) then
						return;
					end
				end
			end
		end
		if C_AzeriteEssence.HasPendingActivationEssence() then
			if self.unlocked then
				if self:GetParent():HasNewlyActivatedEssence() then
					UIErrorsFrame:AddMessage(ERR_CANT_DO_THAT_RIGHT_NOW, RED_FONT_COLOR:GetRGBA());
				else
					-- check for animation only, let it go either way for error messages
					local pendingEssenceID = C_AzeriteEssence.GetPendingActivationEssence();
					if C_AzeriteEssence.CanActivateEssence(pendingEssenceID, self.milestoneID) then
						self:GetParent():OnEssenceActivated(pendingEssenceID, self);
						if GameTooltip:GetOwner() == self then
							GameTooltip:Hide();
						end
					end
					C_AzeriteEssence.ActivateEssence(pendingEssenceID, self.milestoneID);
				end
			end
		elseif self.canUnlock then
			C_AzeriteEssence.UnlockMilestone(self.milestoneID);
		end
	end
end

function AzeriteMilestoneSlotMixin:OnEnter()
	if self:IsMajorSlot() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, 0);
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -10, -5);
	end

	local essenceID = C_AzeriteEssence.GetMilestoneEssence(self.milestoneID);
	if essenceID then
		GameTooltip:SetAzeriteEssenceSlot(self.slot);
		SharedTooltip_SetBackdropStyle(GameTooltip, GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM);

		if C_AzeriteEssence.HasPendingActivationEssence() then
			local pendingEssenceID = C_AzeriteEssence.GetPendingActivationEssence();
			if C_AzeriteEssence.CanActivateEssence(pendingEssenceID, self.milestoneID) then
				self.UnlockedState.HighlightRing:Show();
			end
		elseif self.isDraggable then
			local spellID = C_AzeriteEssence.GetMilestoneSpell(self.milestoneID);
			if spellID then
				self.UnlockedState.DragHighlight:Show();
			end
		end
	else
		local wrapText = true;
		if not self.unlocked then
			GameTooltip_SetTitle(GameTooltip, AZERITE_ESSENCE_PASSIVE_SLOT);
			self:AddStateToTooltip(AZERITE_ESSENCE_LOCKED_SLOT_LEVEL, AZERITE_ESSENCE_UNLOCK_SLOT);
		else
			if self:IsMajorSlot() then
				GameTooltip_SetTitle(GameTooltip, AZERITE_ESSENCE_EMPTY_MAIN_SLOT);
				GameTooltip_AddColoredLine(GameTooltip, AZERITE_ESSENCE_EMPTY_MAIN_SLOT_DESC, NORMAL_FONT_COLOR, wrapText);
			else
				GameTooltip_SetTitle(GameTooltip, AZERITE_ESSENCE_EMPTY_PASSIVE_SLOT);
				GameTooltip_AddColoredLine(GameTooltip, AZERITE_ESSENCE_EMPTY_PASSIVE_SLOT_DESC, NORMAL_FONT_COLOR, wrapText);
			end
		end
	end
	GameTooltip:Show();
end

AzeriteMilestoneStaminaMixin = CreateFromMixins(AzeriteMilestoneBaseMixin);

function AzeriteMilestoneStaminaMixin:Refresh()
	self:UpdateMilestoneInfo();

	local isAzeriteItemEnabled = self:GetParent():IsAzeriteItemEnabled();

	if self.unlocked then
		self.Icon:SetAtlas("heartofazeroth-node-on");
	else
		self.Icon:SetAtlas("heartofazeroth-node-off");
		self:CheckAndSetUpUnlockEffect();
	end

	self.Icon:SetDesaturated(not isAzeriteItemEnabled);

	if not self.unlocked and self:ShouldShowUnlockState() then
		if C_AzeriteEssence.IsAtForge() then
			self.GlowAnim:Stop();

			if isAzeriteItemEnabled then
				self.ForgeGlowAnim:Play();
			end
		else
			self.ForgeGlowAnim:Stop();

			if isAzeriteItemEnabled then
				self.GlowAnim:Play();
			end
		end
	else
		self.GlowAnim:Stop();
		self.ForgeGlowAnim:Stop();
	end
end

AzeriteMilestoneRankedMixin = CreateFromMixins(AzeriteMilestoneBaseMixin);

function AzeriteMilestoneRankedMixin:Refresh()
	self:UpdateMilestoneInfo();

	if not self.unlocked and self.canUnlock then
		self.needsUnlock = true;
	end

	if not self.unlocked and not self.canUnlock then
		self:ShowStateFrame(self.LockedState);
		self.LockedState.UnlockLevelText:SetText(self.requiredLevel);
	else
		self:ShowStateFrame(self.AvailableState);
		self.AvailableState.RankText:SetText(self.rank);
		local spellName, spellTexture = AzeriteEssenceUtil.GetMilestoneSpellInfo(self.milestoneID);
		self.AvailableState.Icon:SetTexture(spellTexture);

		if self:ShouldShowUnlockState() then
			self:CheckAndSetUpUnlockEffect();
			if C_AzeriteEssence.IsAtForge() then
				self.AvailableState.GlowAnim:Stop();
				self.AvailableState.ForgeGlowAnim:Play();
			else
				self.AvailableState.ForgeGlowAnim:Stop();
				self.AvailableState.GlowAnim:Play();
			end
		else
			self.AvailableState.GlowAnim:Stop();
			self.AvailableState.ForgeGlowAnim:Stop();
		end
	end

	self:UpdateModelScenes();
end

function AzeriteMilestoneRankedMixin:UpdateModelScenes(forceUpdate)
	if not self.needsUnlock and self.unlocked then
		local scene = self.EffectsModelScene;
		if not scene.activeEffect or forceUpdate then
			scene:SetFrameLevel(self.AvailableState:GetFrameLevel() - 1);
			scene.activeEffect = StaticModelInfo.SetupModelScene(scene, RANKED_MILESTONE_MODEL_SCENE_INFO, forceUpdate);
		end
	end
end

function AzeriteMilestoneRankedMixin:CheckAndSetUpUnlockEffect()
	local scene = self.EffectsModelScene;
	if not scene.unlockEffect then
		local forceUpdate = true;
		local stopAnim = true;
		self.EffectsModelScene:SetFrameLevel(self.AvailableState:GetFrameLevel() + 1);
		scene.unlockEffect = StaticModelInfo.SetupModelScene(scene, REVEAL_SLOT_MODEL_SCENE_INFO, forceUpdate, stopAnim);
	end
end

function AzeriteMilestoneRankedMixin:OnUnlocked()
	self:CheckAndSetUpUnlockEffect();

	local scene = self.EffectsModelScene;
	if scene.unlockEffect then
		local onUnlockDoneFunc = function()
			self.needsUnlock = false;
			self:Refresh();
		end;
		scene:ShowAndAnimateActors(REVEAL_MODEL_SCENE_ACTOR_SETTINGS, onUnlockDoneFunc);
		ScriptAnimationUtil.ShakeFrame(self:GetParent():GetParent(), REVEAL_SHAKE, REVEAL_SHAKE_DURATION, REVEAL_SHAKE_FREQUENCY);
	end

	PlaySound(SOUNDKIT.UI_82_HEARTOFAZEROTH_UNLOCKSTAMINANODE);
end

AzeriteEssenceLearnAnimFrameMixin = { };

function AzeriteEssenceLearnAnimFrameMixin:OnLoad()
	self:SetPoint("CENTER", AzeriteEssenceUI:GetSlotFrame(Enum.AzeriteEssence.MainSlot));
end

function AzeriteEssenceLearnAnimFrameMixin:PlayAnim()
	if not AzeriteEssenceUI:IsShown() then
		return;
	end

	self.Anim:Stop();

	local runeIndex = random(1, 16);
	local runeAtlas = "heartofazeroth-animation-rune"..runeIndex;
	local useAtlasSize = true;

	for i, texture in ipairs(self.Textures) do
		texture:SetAlpha(0);
		if texture.isRune then
			texture:SetAtlas(runeAtlas, useAtlasSize);
		end
	end

	self:Show();
	self.Anim:Play();

	C_Timer.After(LEARN_SHAKE_DELAY,
		function()
			ScriptAnimationUtil.ShakeFrame(self:GetParent(), LEARN_SHAKE, LEARN_SHAKE_DURATION, LEARN_SHAKE_FREQUENCY);
		end
	);
end

function AzeriteEssenceLearnAnimFrameMixin:StopAnim()
	self:Hide();
end