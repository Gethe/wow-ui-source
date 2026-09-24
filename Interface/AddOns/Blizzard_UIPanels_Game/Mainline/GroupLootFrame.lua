local NUM_GROUP_LOOT_FRAMES = 4;

local MAX_NUM_GAMEPAD_LOOT_ITEMS = 4;

local groupLootFrameEvents =
{
	"CANCEL_LOOT_ROLL",
	"CANCEL_ALL_LOOT_ROLLS",
	"MAIN_SPEC_NEED_ROLL",
}

function GroupLootContainer_OnLoad(self)
	self.rollFrames = {};
	self.waitingRolls = {};
	self.reservedSize = 100;
	GroupLootContainer_CalcMaxIndex(self);

	local alertSystem = AlertFrame:AddExternallyAnchoredSubSystem(self);
	AlertFrame:SetSubSystemAnchorPriority(alertSystem, 30);

	EventRegistry:RegisterFrameEventAndCallback("CANCEL_ALL_LOOT_ROLLS", function()
		self.waitingRolls = {};
	end, self);

	local function InitGamepad()
		GroupLootContainer_InitGamepad(self);
	end
	local function UninitGamepad()
		GroupLootContainer_UninitGamepad(self);
	end

	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(InitGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(UninitGamepad, self));
end

function GroupLootContainer_InitGamepad(self)
	GroupLootContainer_RemoveAllRolls(self);

	if self:IsVisible() then
		self:Hide();
	end
end

function GroupLootContainer_UninitGamepad(self)
	GroupLootContainer_RemoveAllRolls(self);
	GroupLootContainer_RefreshRolls(self);
end

function GroupLootContainer_CalcMaxIndex(self)
	local maxIdx = 0;
	for k, v in pairs(self.rollFrames) do
		maxIdx = max(maxIdx, k);
	end
	self.maxIndex = maxIdx;
end

function GroupLootContainer_AddFrame(self, frame)
	local idx = self.maxIndex + 1;
	for i=1, self.maxIndex do
		if ( not self.rollFrames[i] ) then
			idx = i;
			break;
		end
	end
	self.rollFrames[idx] = frame;

	if ( idx > self.maxIndex ) then
		self.maxIndex = idx;
	end

	GroupLootContainer_Update(self);
	frame:Show();
end

function GroupLootContainer_RemoveFrame(self, frame, cancellingAll)
	local idx = nil;
	for k, v in pairs(self.rollFrames) do
		if ( v == frame ) then
			idx = k;
			break;
		end
	end

	frame:Hide();
	if ( idx ) then
		self.rollFrames[idx] = nil;
		if ( idx == self.maxIndex ) then
			GroupLootContainer_CalcMaxIndex(self);
		end

		if #self.waitingRolls > 0 and not cancellingAll then
			local newRoll = self.waitingRolls[1];
			table.remove(self.waitingRolls, 1);
			GroupLootContainer_AddRoll(newRoll.rollID, newRoll.rollTime);
		end
	end
	GroupLootContainer_Update(self);
end

function GroupLootContainer_ReplaceFrame(self, oldFrame, newFrame)
	for k, v in pairs(self.rollFrames) do
		if ( v == oldFrame ) then
			v:Hide();
			self.rollFrames[k] = newFrame;
			GroupLootContainer_Update(self);
			newFrame:Show();
			return true;
		end
	end
	return false;	--Didn't find a frame to replace.
end

function GroupLootContainer_Update(self)
	if InputUtil.IsGamepadUIEnabled() then
		return;
	end

	local lastIdx = nil;

	for i=1, self.maxIndex do
		local frame = self.rollFrames[i];
		if ( frame ) then
			frame:ClearAllPoints();
			frame:SetPoint("CENTER", self, "BOTTOM", 0, self.reservedSize * (i-1 + 0.5));
			lastIdx = i;
		end
	end

	if ( lastIdx ) then
		self:SetHeight(self.reservedSize * lastIdx);
		self:Show();
		self.layoutParent:Layout();
	else
		self:Hide();
	end
end

function GroupLootContainer_RemoveAllRolls(self)
	GroupLootContainer.waitingRolls = {};

	if self.rollFrames then
		for idx, curFrame in pairs(self.rollFrames) do
			GroupLootFrame_Remove(curFrame, false);
		end
	end
end

function GroupLootContainer_RefreshRolls()
	local pendingLootRollIDs = GetActiveLootRollIDs();
	for i=1, #pendingLootRollIDs do
		GroupLootContainer_AddRoll(pendingLootRollIDs[i], C_Loot.GetLootRollDuration(pendingLootRollIDs[i]));
	end
end

function GroupLootContainer_AddRoll(rollID, rollTime)
	if not GroupLootContainer_OpenNewFrame(rollID, rollTime) then
		table.insert(GroupLootContainer.waitingRolls, { rollID = rollID, rollTime = rollTime });
	end
end

function GroupLootContainer_OpenNewFrame(rollID, rollTime)
	for i=1, NUM_GROUP_LOOT_FRAMES do
		local frame = _G["GroupLootFrame"..i];
		if ( not frame:IsShown() ) then
			frame.rollID = rollID;
			frame.rollTime = rollTime;
			frame.Timer:SetMinMaxValues(0, rollTime);
			GroupLootContainer_AddFrame(GroupLootContainer, frame);
			return true;
		end
	end
	return false;
end

function GroupLootFrame_EnableLootButton(button)
	button:Enable();
	button:SetAlpha(1.0);
	button:GetNormalTexture():SetDesaturated(false);
end

function GroupLootFrame_DisableLootButton(button)
	button:Disable();
	button:SetAlpha(0.35);
	button:GetNormalTexture():SetDesaturated(true);
end

local function MasterLooterPlayerSort(pInfo1, pInfo2)
	if ( pInfo1.class == pInfo2.class ) then
		return pInfo1.name < pInfo2.name;
	else
		return pInfo1.class < pInfo2.class;
	end
end

function GroupLootFrame_OnLoad(self)
	local function OpenMenu()
		MenuUtil.CreateContextMenu(LootFrame.selectedLootFrame, function(owner, rootDescription)
			rootDescription:SetTag("MENU_GROUP_LOOT");
			rootDescription:CreateTitle(MASTER_LOOTER);
			rootDescription:CreateButton(ASSIGN_LOOT, function()
				MasterLooterFrame_Show();
			end);
			rootDescription:CreateButton(REQUEST_ROLL, function()
				DoMasterLootRoll(LootFrame.selectedSlot);
			end);
		end);
	end

	local function GenerateAssignLootMenu(_owner, rootDescription, contextData)
		rootDescription:SetTag("MENU_GROUP_LOOT");
		rootDescription:AddMenuAcquiredCallback(function(menuFrame)
			if GameTooltip:IsShown() then
				GameTooltip:ClearAllPoints();
				GameTooltip:SetPoint("LEFT", menuFrame, "RIGHT");
			end
		end);
		rootDescription:AddMenuReleasedCallback(function(menuFrame)
			if GameTooltip:IsOwned(menuFrame) then
				GameTooltip:Hide();
				GameTooltip:ClearAllPoints();
			end
		end);

		rootDescription:CreateTitle(MASTER_LOOTER);

		local assignLootMenuButton = rootDescription:CreateButton(ASSIGN_LOOT);

		local isRaid = IsInRaid();
		local assignLootClassButton;
		local currentClass;

		-- group master loot is assign->name
		-- raid master loot is assign->class->name
		for _, curPlayer in ipairs(contextData.playerInfo) do
			if isRaid and curPlayer.class ~= currentClass then
				currentClass = curPlayer.class;
				assignLootClassButton = assignLootMenuButton:CreateButton(curPlayer.class, function() end);
				assignLootClassButton:AddInitializer(function(button)
					local color = RAID_CLASS_COLORS[curPlayer.className];
					if color then
						button.fontString:SetTextColor(color.r, color.g, color.b);
					end
				end);
			end

			-- Attach group player list to Assign Loot, or raid players to their class.
			local playerListFrame = assignLootMenuButton;
			if isRaid and assignLootClassButton then
				playerListFrame = assignLootClassButton;
			end

			local assignLootPlayerButton = playerListFrame:CreateButton(curPlayer.name, GenerateClosure(MasterLooterFrame_SelectLootRecipient, curPlayer.index, curPlayer.name));
			assignLootPlayerButton:AddInitializer(function(button)
				local color = RAID_CLASS_COLORS[curPlayer.className];
				if color then
					button.fontString:SetTextColor(color.r, color.g, color.b);
				end
			end);
		end

		rootDescription:CreateButton(REQUEST_ROLL, function()
			DoMasterLootRoll(LootFrame.selectedSlot);
		end);
	end

	local function OpenAssignLootMenu()
		local playerInfo = {};
		-- fetch info on loot candidates as playerInfo and sort
		for i = 1, MAX_RAID_MEMBERS do
			local name, class, className = GetMasterLootCandidate(LootFrame.selectedSlot, i);
			if name then
				tinsert(playerInfo, { index = i, name = name, class = class, className = className });
			end
		end
		table.sort(playerInfo, MasterLooterPlayerSort);

		local contextData =
		{
			playerInfo = playerInfo,
			selectedItemLink = LootFrame.selectedItemLink,
		};

		local menu = MenuUtil.CreateContextMenu(LootFrame.selectedLootFrame, GenerateAssignLootMenu, contextData);
		LootFrame.contextMenu = menu;
		menu:HookScript("OnHide", function()
			if LootFrame.contextMenu == menu then
				LootFrame.contextMenu = nil;
			end
		end);

		menu:ClearAllPoints();
		menu:SetPoint("LEFT", LootFrame.selectedLootFrame, "RIGHT");

		if contextData.selectedItemLink then
			GameTooltip:SetOwner(menu, "ANCHOR_NONE");
			GameTooltip:ClearAllPoints();
			GameTooltip:SetPoint("LEFT", menu, "RIGHT");
			GameTooltip_SuppressAutomaticCompareItem(GameTooltip);
			GameTooltip:SetHyperlink(contextData.selectedItemLink);
			GameTooltip:Show();
		end
	end

	-- Requires retest if/when this feature is reenabled
	if InputUtil.IsGamepadUIEnabled() then
		EventRegistry:RegisterFrameEventAndCallback("OPEN_MASTER_LOOT_LIST", OpenAssignLootMenu, self);
	else
		EventRegistry:RegisterFrameEventAndCallback("OPEN_MASTER_LOOT_LIST", OpenMenu, self);
	end
end

function GroupLootFrame_SetupItemDisplay(self)
	if not self.rollID then
		return false;
	end

	local texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired, canTransmog = GetLootRollItemInfo(self.rollID);
	if name == nil then
		return false;
	end

	self.IconFrame.Icon:SetTexture(texture);
	self.IconFrame.Border:SetAtlas(ColorManager.GetAtlasDataForLootBorderItemQuality(quality) or ColorManager.GetAtlasDataForLootBorderItemQuality(Enum.ItemQuality.Uncommon));
	self.Name:SetText(name);

	local colorData = ColorManager.GetColorDataForItemQuality(quality);
	if colorData then
		self.Name:SetVertexColor(colorData.r, colorData.g, colorData.b);
		self.Border:SetVertexColor(colorData.r, colorData.g, colorData.b);
	end

	if count > 1 then
		self.IconFrame.Count:SetText(count);
		self.IconFrame.Count:Show();
	else
		self.IconFrame.Count:Hide();
	end

	if canNeed then
		GroupLootFrame_EnableLootButton(self.LootButtonContainer.NeedButton);
		self.LootButtonContainer.NeedButton.reason = nil;
	else
		GroupLootFrame_DisableLootButton(self.LootButtonContainer.NeedButton);
		self.LootButtonContainer.NeedButton.reason = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonNeed];
	end

	if canTransmog then
		self.LootButtonContainer.TransmogButton:Show();
		self.LootButtonContainer.GreedButton:Hide();
	else
		self.LootButtonContainer.TransmogButton:Hide();
		self.LootButtonContainer.GreedButton:Show();
		if canGreed then
			GroupLootFrame_EnableLootButton(self.LootButtonContainer.GreedButton);
			self.LootButtonContainer.GreedButton.reason = nil;
		else
			GroupLootFrame_DisableLootButton(self.LootButtonContainer.GreedButton);
			self.LootButtonContainer.GreedButton.reason = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonGreed];
		end
	end

	self.Timer:SetFrameLevel(self:GetFrameLevel() - 1);

	self.canNeed = canNeed;
	self.canGreed = canGreed;
	self.canTransmog = canTransmog;

	return true;
end

function GroupLootFrame_OnShow(self)
	if not GroupLootFrame_SetupItemDisplay(self) then
		if not InputUtil.IsGamepadUIEnabled() then
			GroupLootContainer_RemoveFrame(GroupLootContainer, self);
		end

		return;
	end

	FrameUtil.RegisterFrameForEvents(self, groupLootFrameEvents);
end

function GroupLootFrame_OnHide(self)
	GroupLootFrame_StopNeedAnimation(self);

	self.canNeed = nil;
	self.canGreed = nil;
	self.canTransmog = nil;

	if (InputUtil.IsGamepadUIEnabled()) then
		GamepadMode.FrameControlsManager:FrameHidden(self);
	end

	FrameUtil.UnregisterFrameForEvents(self, groupLootFrameEvents);
end

function GroupLootFrame_Remove(self, cancellingAll)
	if self:IsShown() then
		GroupLootContainer_RemoveFrame(GroupLootContainer, self, cancellingAll);
		StaticPopup_Hide("CONFIRM_LOOT_ROLL", self.rollID);
	end
end

function GroupLootFrame_OnEvent(self, event, ...)
	if event == "CANCEL_LOOT_ROLL" then
		local arg1 = ...;
		if arg1 == self.rollID then
			GroupLootFrame_Remove(self);
		end
	elseif event == "CANCEL_ALL_LOOT_ROLLS" then
		local cancellingAll = true;
		GroupLootFrame_Remove(self, cancellingAll);
	elseif event == "MAIN_SPEC_NEED_ROLL" then
		local rollID, roll, isWinning = ...;
		if rollID == self.rollID then
			GroupLootFrame_StartNeedAnimation(self, roll, isWinning);
		end
	end
end

function GroupLootFrame_OnUpdate(self, elapsed)
	if not self.rollID then
		return;
	end

	if self.NeedRollAnim.Animation:IsPlaying() then
		return;
	end

	local left = GetLootRollTimeLeft(self.rollID);
	local min, max = self.Timer:GetMinMaxValues();
	if ( (left < min) or (left > max) ) then
		left = min;
	end
	self.Timer:SetValue(left);
end

function GroupLootFrame_StartNeedAnimation(self, roll, isWinning)
	self.Timer:SetValue(0);
	for _, button in ipairs(self.LootButtonContainer.LootButtons) do
		button:Hide();
	end

	PlaySound(isWinning and SOUNDKIT.UI_NEED_ROLL_POSITIVE or SOUNDKIT.UI_NEED_ROLL_NEGATIVE);

	self.NeedRollAnim:Show();
	local color = isWinning and GREEN_FONT_COLOR or RED_FONT_COLOR;
	self.NeedRollAnim.RollNumber:SetText(color:WrapTextInColorCode(roll));
	self.NeedRollAnim.Animation:Restart();

	self.NeedRollAnimFinishedCallback = C_FunctionContainers.CreateCallback(function() GroupLootFrame_Remove(self); end);
	C_Timer.After(5, self.NeedRollAnimFinishedCallback);
end

function GroupLootFrame_StopNeedAnimation(self)
	for _, button in ipairs(self.LootButtonContainer.LootButtons) do
		button:Show();
	end

	self.NeedRollAnim:Hide();
	self.NeedRollAnim.Animation:Stop();
	if self.NeedRollAnimFinishedCallback then
		self.NeedRollAnimFinishedCallback:Cancel();
		self.NeedRollAnimFinishedCallback = nil;
	end
end

function GroupLootFrameIconFrame_OnEnter(self)
	local tooltipOwner = self;
	if InputUtil.IsGamepadUIEnabled() then
		tooltipOwner = self:GetParent();
	end

	GameTooltip:SetOwner(tooltipOwner, "ANCHOR_RIGHT");
	GameTooltip:SetLootRollItem(self:GetParent().rollID);
	CursorUpdate(self);
end

function BonusRollFrame_StartBonusRoll(spellID, text, duration, currencyID, currencyCost, difficultyID, displayItemID, itemContext, treasureContextLevel)
	local frame = BonusRollFrame;

	if ( frame:IsShown() and frame.spellID == spellID ) then
		return;
	end

	-- No valid currency data--use the fall back.
	if ( currencyID == 0 ) then
		currencyID = BONUS_ROLL_REQUIRED_CURRENCY;
	end

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
	local count = currencyInfo.quantity;
	local icon = currencyInfo.iconFileID;
	if ( count == 0 ) then
		return;
	end

	--Stop any animations that might still be playing
	frame.StartRollAnim:Stop();

	frame.state = "prompt";
	frame.spellID = spellID;
	frame.endTime = time() + duration;
	frame.remaining = duration;
	frame.CurrentCountFrame.currencyID = currencyID;
	frame.difficultyID = difficultyID;
	frame.PromptFrame.EncounterJournalLinkButton.displayItemID = displayItemID;
	frame.PromptFrame.EncounterJournalLinkButton.itemContext = itemContext;
	frame.PromptFrame.EncounterJournalLinkButton.treasureContextLevel = treasureContextLevel;

	-- If a specific item has been provided for the bonus roll show the icon for that item, otherwise show the generic bonus roll icon.
	frame.PromptFrame.Icon:SetAtlas("BonusLoot-Chest", TextureKitConstants.IgnoreAtlasSize);

	if displayItemID and displayItemID ~= 0 then
		local item = Item:CreateFromItemID(displayItemID);
		item:ContinueOnItemLoad(function()
			if frame.PromptFrame.EncounterJournalLinkButton.displayItemID == displayItemID then
				local itemIcon = select(10, C_Item.GetItemInfo(displayItemID));
				if itemIcon then
					frame.PromptFrame.Icon:SetTexture(itemIcon);
				end
			end
		end);
	end

	local instanceID, encounterID = GetJournalInfoForSpellConfirmation(spellID);
	frame.instanceID = instanceID;
	frame.encounterID = encounterID;

	local numRequired = currencyCost;
	frame.PromptFrame.InfoFrame.Cost:SetFormattedText(BONUS_ROLL_COST, numRequired, icon);
	frame.CurrentCountFrame.Text:SetFormattedText(BONUS_ROLL_CURRENT_COUNT, count, icon);
	frame.PromptFrame.Timer:SetMinMaxValues(0, duration);
	frame.PromptFrame.Timer:SetValue(duration);
	frame.PromptFrame.RollButton:Enable();
	frame.PromptFrame:Show();
	frame.PromptFrame:SetAlpha(1);
	frame.RollingFrame:Hide();

	local specID = GetLootSpecialization();
	if ( specID and specID > 0 ) then
		local id, name, description, texture, role, class = GetSpecializationInfoByID(specID);
		frame.SpecIcon:SetTexture(texture);
		frame.SpecIcon:Show();
		frame.SpecRing:Show();
	else
		frame.SpecIcon:Hide();
		frame.SpecRing:Hide();
	end

	GroupLootContainer_AddFrame(GroupLootContainer, frame);
end

function BonusRollFrame_CloseBonusRoll()
	local frame = BonusRollFrame;
	if ( frame.state == "prompt" ) then
		GroupLootContainer_RemoveFrame(GroupLootContainer, frame);
	end
end

function BonusRollFrame_OnLoad(self)
	self:RegisterEvent("BONUS_ROLL_STARTED");
	self:RegisterEvent("BONUS_ROLL_FAILED");
	self:RegisterEvent("BONUS_ROLL_RESULT");
	self:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED");
	self:RegisterEvent("BONUS_ROLL_DEACTIVATE");
	self:RegisterEvent("BONUS_ROLL_ACTIVATE");
end

function BonusRollFrame_OnEvent(self, event, ...)
	if ( event == "BONUS_ROLL_FAILED" ) then
		self.state = "finishing";
		self.rewardType = nil;
		self.rewardLink = nil;
		self.rewardQuantity = nil;
		self.rewardSpecID = nil;
		self.RollingFrame.LootSpinner:Hide();
		self.RollingFrame.LootSpinnerFinal:Hide();
		self.FinishRollAnim:Play();
	elseif ( event == "BONUS_ROLL_STARTED" ) then
		self.state = "rolling";
		self.animFrame = 0;
		self.animTime = 0;
		PlaySound(SOUNDKIT.UI_BONUS_LOOT_ROLL_START);
		--Make sure we don't keep playing the sound ad infinitum.
		if ( self.rollSound ) then
			StopSound(self.rollSound);
		end
		local _, soundHandle = PlaySound(SOUNDKIT.UI_BONUS_LOOT_ROLL_LOOP);
		self.rollSound = soundHandle;
		self.RollingFrame.LootSpinner:Show();
		self.RollingFrame.LootSpinnerFinal:Hide();
		self.LootSpinnerBG:Show();
		self.IconBorder:Show();
		self.StartRollAnim:Play();
	elseif ( event == "BONUS_ROLL_RESULT" ) then
		local rewardType, rewardLink, rewardQuantity, rewardSpecID,_,_, currencyID, isSecondaryResult, isCorrupted = ...;
		self.state = "slowing";
		self.rewardType = rewardType;
		self.rewardLink = rewardLink;
		self.rewardQuantity = rewardQuantity;
		self.rewardSpecID = rewardSpecID;
		self.currencyID = currencyID;
		self.isSecondaryResult = isSecondaryResult;
		self.isCorrupted = isCorrupted;
		self.StartRollAnim:Finish();
	elseif ( event == "PLAYER_LOOT_SPEC_UPDATED" ) then
		local specID = GetLootSpecialization();
		if ( specID and specID > 0 ) then
			local id, name, description, texture, role, class = GetSpecializationInfoByID(specID);
			self.SpecIcon:SetTexture(texture);
			self.SpecIcon:Show();
			self.SpecRing:Show();
		else
			self.SpecIcon:Hide();
			self.SpecRing:Hide();
		end
	elseif ( event == "BONUS_ROLL_DEACTIVATE" ) then
		self.PromptFrame.RollButton:Disable();
	elseif ( event == "BONUS_ROLL_ACTIVATE" ) then
		if ( self.state == "prompt" ) then
			self.PromptFrame.RollButton:Enable();
		end
	end
end

local finalAnimFrame = {
	item = 2,
	currency = 6,
	money = 6,
	artifact_power = 6,
	coin = 6,
}

local finalTextureTexCoords = {
	item = {0.59570313, 0.62597656, 0.875, 0.9921875},
	currency = {0.56347656, 0.59375, 0.875, 0.9921875},
	money = {0.56347656, 0.59375, 0.875, 0.9921875},
	artifact_power = {0.56347656, 0.59375, 0.875, 0.9921875},
	coin = {0.56347656, 0.59375, 0.875, 0.9921875},
}

local QUARTERMASTER_COIN_ID = 163827;

function BonusRollFrame_OnUpdate(self, elapsed)
	if ( self.state == "prompt" ) then
		self.remaining = self.remaining - elapsed;
		self.PromptFrame.Timer:SetValue(max(0, self.remaining));
	elseif ( self.state == "rolling" ) then
		self.animTime = self.animTime + elapsed;
		if ( self.animTime > 0.05 ) then
			BonusRollFrame_AdvanceLootSpinnerAnim(self);
		end
	elseif ( self.state == "slowing" ) then
		self.animTime = self.animTime + elapsed;
		if ( self.animFrame == finalAnimFrame[self.rewardType] ) then
			self.state = "finishing";
			if ( self.rollSound ) then
				StopSound(self.rollSound);
			end
			self.rollSound = nil;
			PlaySound(SOUNDKIT.UI_BONUS_LOOT_ROLL_END);
			self.RollingFrame.LootSpinner:Hide();
			local rewardType = self.rewardType;
			if( self.currencyID == C_CurrencyInfo.GetAzeriteCurrencyID() ) then
				self.RollingFrame.LootSpinnerFinalText:SetText(BONUS_ROLL_REWARD_ARTIFACT_POWER);
			else
				if self.isSecondaryResult and self.rewardType == "item" then
					local itemID = C_Item.GetItemInfoInstant(self.rewardLink);
					if itemID == QUARTERMASTER_COIN_ID then
						rewardType = "coin";
					end
				end
				self.RollingFrame.LootSpinnerFinalText:SetText(_G["BONUS_ROLL_REWARD_"..string.upper(rewardType)]);
			end
			self.RollingFrame.LootSpinnerFinal:Show();
			self.RollingFrame.LootSpinnerFinal:SetTexCoord(unpack(finalTextureTexCoords[rewardType]));
			self.FinishRollAnim:Play();
		elseif ( self.animTime > 0.1 ) then --Slow it down
			BonusRollFrame_AdvanceLootSpinnerAnim(self);
		end
	end
end

function GetBonusRollEncounterJournalLinkDifficulty()
	if ( not BonusRollFrame.difficultyID ) then
		local _, _, instanceDifficulty = GetInstanceInfo();
		if ( instanceDifficulty == 0 ) then
			-- We have no difficulty so we don't know what to open.
			return nil;
		else
			return instanceDifficulty;
		end
	end

	return BonusRollFrame.difficultyID;
end

EncounterJournalLinkButtonMixin = {};

function EncounterJournalLinkButtonMixin:IsLinkDataAvailable()
	if ( BonusRollFrame.instanceID and BonusRollFrame.instanceID ~= 0 ) then
		local difficultyID = GetBonusRollEncounterJournalLinkDifficulty();
		-- Mythic+ doesn't yet have all the itemContext info available
		--that we need to properly show item tooltips
		if ( difficultyID ~= nil and difficultyID ~= DifficultyUtil.ID.DungeonChallenge) then
			return true;
		end
	end
	return false;
end

function EncounterJournalLinkButtonMixin:OnShow()
	local tutorialClosed = GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BONUS_ROLL_ENCOUNTER_JOURNAL_LINK);
	if not tutorialClosed and self:IsLinkDataAvailable() then
		local helpTipInfo = {
			text = ENCOUNTER_JOURNAL_LINK_BUTTON_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_BONUS_ROLL_ENCOUNTER_JOURNAL_LINK,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			offsetY = -14,
		};
		HelpTip:Show(self:GetParent(), helpTipInfo);
	end
end

function EncounterJournalLinkButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	-- If a specific item has been provided for the bonus roll show the tooltip for that item, otherwise show the generic bonus roll tooltip.
	if self.displayItemID and self.displayItemID ~= 0 then
		local treasureContextLevel = self.treasureContextLevel and self.treasureContextLevel > 0 and self.treasureContextLevel or nil;
		GameTooltip:SetItemByID(self.displayItemID, nil, self.itemContext, treasureContextLevel);
	else
		GameTooltip_SetTitle(GameTooltip, BONUS_ROLL_TOOLTIP_TITLE);
		GameTooltip_AddNormalLine(GameTooltip, BONUS_ROLL_TOOLTIP_TEXT);

		if self:IsLinkDataAvailable() then
			GameTooltip_AddInstructionLine(GameTooltip, BONUS_ROLL_TOOLTIP_ENCOUNTER_JOURNAL_LINK);
		end
	end

	GameTooltip:Show();
end

function EncounterJournalLinkButtonMixin:OnClick()
	local difficultyID = GetBonusRollEncounterJournalLinkDifficulty();
	if ( not self:IsLinkDataAvailable()) then
		return;
	end

	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BONUS_ROLL_ENCOUNTER_JOURNAL_LINK, true);
	HelpTip:HideAll(BonusRollFrame.PromptFrame);

	EncounterJournal_LoadUI();

	local specialization = GetLootSpecialization();
	if ( specialization == 0 ) then
		specialization = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization());
	end
	EncounterJournal_SetClassAndSpecFilter(EncounterJournal, select(3, UnitClass("player")), specialization);
	-- EncounterJournal_OpenJournal takes an itemID but only checks if it exists, not what it is.
	local forceClickLootTab = 0;
	EncounterJournal_OpenJournal(difficultyID, BonusRollFrame.instanceID, BonusRollFrame.encounterID, nil, nil, forceClickLootTab);
end

function BonusRollFrame_AdvanceLootSpinnerAnim(self)
	self.animTime = 0;
	self.animFrame = (self.animFrame + 1) % 8;
	local top = floor(self.animFrame / 4) * 0.5;
	local left = (self.animFrame % 4) * 0.25;
	self.RollingFrame.LootSpinner:SetTexCoord(left, left + 0.25, top, top + 0.5);
end

function BonusRollFrame_OnShow(self)
	self.LootSpinnerBG:Hide();
	self.IconBorder:Hide();
	self.PromptFrame.Timer:SetFrameLevel(self:GetFrameLevel() - 1);
	self.BlackBackgroundHoist:SetFrameLevel(self.PromptFrame.Timer:GetFrameLevel() - 1);
	--Update the remaining time in case we were hidden for some reason
	if ( self.state == "prompt" ) then
		self.remaining = self.endTime - time();
	end
end

function BonusRollFrame_OnHide(self)
	--Make sure we don't keep playing the sound ad infinitum.
	if ( self.rollSound ) then
		StopSound(self.rollSound);
	end
	self.rollSound = nil;
end

function BonusRollFrame_FinishedFading(self)
	local rollType, roll, isCurrency, showFactionBG, lootSource, lessAwesome, isUpgraded, wonRoll, showRatedBG; -- luacheck: ignore 221 (variable is never set)
	isCurrency = false;
	if ( self.rewardType == "item" or self.rewardType == "artifact_power" ) then
		wonRoll = self.rewardType == "item";
		GroupLootContainer_ReplaceFrame(GroupLootContainer, self, BonusRollLootWonFrame);
		LootWonAlertFrame_SetUp(BonusRollLootWonFrame, self.rewardLink, self.rewardQuantity, rollType, roll, self.rewardSpecID, isCurrency, showFactionBG, lootSource, lessAwesome, isUpgraded, self.isCorrupted, wonRoll, showRatedBG, self.isSecondaryResult);
		AlertFrame:AddAlertFrame(BonusRollLootWonFrame);
	elseif ( self.rewardType == "money" ) then
		GroupLootContainer_ReplaceFrame(GroupLootContainer, self, BonusRollMoneyWonFrame);
		MoneyWonAlertFrame_SetUp(BonusRollMoneyWonFrame, self.rewardQuantity);
		LootMoneyNotify(self.rewardQuantity, true);
		AlertFrame:AddAlertFrame(BonusRollMoneyWonFrame);
	elseif ( self.rewardType == "currency" ) then
		isCurrency = true;
		wonRoll = true;
		GroupLootContainer_ReplaceFrame(GroupLootContainer, self, BonusRollLootWonFrame);
		LootWonAlertFrame_SetUp(BonusRollLootWonFrame, self.rewardLink, self.rewardQuantity, rollType, roll, self.rewardSpecID, isCurrency, showFactionBG, lootSource, lessAwesome, isUpgraded, self.isCorrupted, wonRoll, showRatedBG, self.isSecondaryResult);
		AlertFrame:AddAlertFrame(BonusRollLootWonFrame);
	else
		GroupLootContainer_RemoveFrame(GroupLootContainer, self);
	end
end

function BonusRollLootWonFrame_OnLoad(self)
	self:SetAlertContainer(AlertFrame);
end

function BonusRollMoneyWonFrame_OnLoad(self)
	self:SetAlertContainer(AlertFrame);
end

-------------------------------------------------------------------
-- Master Looter
-------------------------------------------------------------------

local buttonsToHide = { };

local function MasterLooterFrame_InitializeGamepad(self)
	self.HighlightFrame:Show();
	self.CloseButton:Hide();
end

local function MasterLooterFrame_UninitializeGamepad(self)
	self.HighlightFrame:Hide();
	self.CloseButton:Show();
end

function MasterLooterFrame_OnLoad(self)
	self.TitleContainer.TitleText:SetText(ASSIGN_LOOT);

	self:SetScript("OnEvent", function(self, event, ...)
		if event == "UPDATE_MASTER_LOOT_LIST" then
			MasterLooterFrame_UpdatePlayers();
		end
	end);

	local function OnLootFrameHide()
		MasterLooterFrame:Hide();
	end
	EventRegistry:RegisterCallback("LootFrame.Hide", OnLootFrameHide, self);

	local function OnLootFrameItemLooted()
		MasterLooterFrame:Hide();
	end
	EventRegistry:RegisterCallback("LootFrame.ItemLooted", OnLootFrameItemLooted, self);

	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(MasterLooterFrame_InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(MasterLooterFrame_UninitializeGamepad, self));
end

function MasterLooterFrame_OnHide(self)
	for playerFrame in pairs(buttonsToHide) do
		playerFrame:Hide();
	end
	wipe(buttonsToHide);

	if InputUtil.IsGamepadUIEnabled() then
		local contextMenu = LootFrame.contextMenu;
		GamepadMode.FrameControlsManager:FrameHidden(self);
		if contextMenu and contextMenu:IsShown() then
			GamepadMode.FrameControlsManager:UnsuspendFrame();
		end
	end
end

function MasterLooterFrame_Show()
	local itemFrame = MasterLooterFrame.Item;
	itemFrame.ItemName:SetText(LootFrame.selectedItemName);
	itemFrame.Icon:SetTexture(LootFrame.selectedTexture);

	local colorData = ColorManager.GetColorDataForItemQuality(LootFrame.selectedQuality);
	if colorData then
		itemFrame.IconBorder:SetVertexColor(colorData.r, colorData.g, colorData.b);
		itemFrame.ItemName:SetVertexColor(colorData.r, colorData.g, colorData.b);
	end

	MasterLooterFrame:Show();
	MasterLooterFrame_UpdatePlayers();

	if InputUtil.IsGamepadUIEnabled() then
		MasterLooterFrame:ClearAllPoints();
		local contextMenu = LootFrame.contextMenu;
		if contextMenu and contextMenu:IsShown() then
			MasterLooterFrame:SetPoint("TOPLEFT", contextMenu, "TOPRIGHT");
		else
			MasterLooterFrame:SetPoint("TOPLEFT", LootFrame.selectedLootFrame, "TOPRIGHT");
		end

		-- This show event was triggered by a micro menu, which will attempt to close itself and return focus to the previous frame,
		-- so we want to prevent the automatic re-focus event and then inform gamepad that the master loot frame should receive focus.
		GamepadMode.FrameControlsManager:SuspendFrame();
		GamepadMode.FrameControlsManager:FrameShown(MasterLooterFrame, false);
	else
		MasterLooterFrame:ClearAllPoints();
		MasterLooterFrame:SetPoint("TOPLEFT", LootFrame.selectedLootFrame, 0, 0);
	end
end

function MasterLooterFrame_UpdatePlayers()
	local playerInfo = { };
	for i = 1, MAX_RAID_MEMBERS do
		local name, class, className = GetMasterLootCandidate(LootFrame.selectedSlot, i);
		if ( name ) then
			local pInfo = { };
			pInfo["index"] = i;
			pInfo["name"] = name;
			pInfo["class"] = class;
			pInfo["className"] = className;
			tinsert(playerInfo, pInfo);
		end
	end
	table.sort(playerInfo, MasterLooterPlayerSort);

	local numColumns = ceil(#playerInfo / 10);
	numColumns = max(numColumns, 2);
	local numRows = ceil(#playerInfo / numColumns);
	local row = 0;
	local column = 0;
	local shownButtons = { };
	for i = 1, MAX_RAID_MEMBERS do
		if ( playerInfo[i] ) then
			row = row + 1;
			if ( row > numRows ) then
				row = 1;
				column = column + 1;
			end
			local buttonIndex = column * 10 + row;
			local playerFrame = MasterLooterFrame["player"..buttonIndex];
			-- create button if needed
			if ( not playerFrame ) then
				playerFrame = CreateFrame("BUTTON", nil, MasterLooterFrame, "MasterLooterPlayerTemplate");
				MasterLooterFrame["player"..buttonIndex] = playerFrame;
				if ( row == 1 ) then
					playerFrame:SetPoint("LEFT", MasterLooterFrame["player"..(buttonIndex - 10)], "RIGHT", 4, 0);
				else
					playerFrame:SetPoint("TOP", MasterLooterFrame["player"..(buttonIndex - 1)], "BOTTOM", 0, 0);
				end
				if ( mod(row, 2) == 0 ) then
					playerFrame.Bg:SetColorTexture(0, 0, 0, 0);
				end
			end
			-- set up button
			playerFrame.id = playerInfo[i].index;
			playerFrame.Name:SetText(playerInfo[i].name);
			local color = RAID_CLASS_COLORS[playerInfo[i].className];
			playerFrame.Name:SetTextColor(color.r, color.g, color.b);
			playerFrame:Show();
			if ( buttonsToHide[playerFrame] ) then
				buttonsToHide[playerFrame] = nil;
			end
			shownButtons[playerFrame] = 1;
			if (playerFrame.Name:IsTruncated()) then
				playerFrame.tooltip = playerInfo[i].name;
			else
				playerFrame.tooltip = nil;
			end
		else
			break;
		end
	end
	MasterLooterFrame:SetWidth(numColumns * 102 + 12);
	MasterLooterFrame:SetHeight(numRows * 23 + 63);
	for playerFrame in pairs(buttonsToHide) do
		playerFrame:Hide();
	end
	buttonsToHide = shownButtons;
end

function MasterLooterFrame_SelectLootRecipient(candidateId, candidateName)
	MasterLooterFrame.slot = LootFrame.selectedSlot;
	MasterLooterFrame.candidateId = candidateId;
	if ( LootFrame.selectedQuality >= Constants.LootConsts.MasterLootQualityThreshold ) then
		local textArg1 = LootFrame.selectedItemName;
		local colorData = ColorManager.GetColorDataForItemQuality(LootFrame.selectedQuality);
		if colorData then
			textArg1 = colorData.hex..LootFrame.selectedItemName..FONT_COLOR_CODE_CLOSE;
		end

		StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", textArg1, candidateName, "LootWindow");
	else
		MasterLooterFrame_GiveMasterLoot();
	end
end

function MasterLooterPlayerButton_OnEnter(self)
	self.Highlight:Show();
	if (self.tooltip) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
end

function MasterLooterPlayerButton_OnLeave(self)
	self.Highlight:Hide();
	if GameTooltip:IsOwned(self) then
		GameTooltip_Hide();
	end
end

function MasterLooterPlayerButton_OnMouseDown(self)
	self.Name:SetPoint("LEFT", 11, -1);
end

function MasterLooterPlayerButton_OnMouseUp(self)
	self.Name:SetPoint("LEFT", 10, 0);
end

function MasterLooterPlayerButton_OnClick(self)
	MasterLooterFrame_SelectLootRecipient(self.id, self.Name:GetText());
end

function MasterLooterFrame_GiveMasterLoot()
	GiveMasterLoot(MasterLooterFrame.slot, MasterLooterFrame.candidateId);
	MasterLooterFrame:Hide();
end

-------------------------------------------------------------------
-- Gamepad Group Loot Roll Frame
-------------------------------------------------------------------

local SCROLL_BOX_PAD = 7;
local SCROLL_BOX_SPACING = 8;
local GAMEPAD_GROUP_LOOT_FRAME_BASE_HEIGHT = 45;
local GAMEPAD_GROUP_LOOT_ITEM_HEIGHT = 67;

-- Matches the need-roll animation length played on the roll card (GroupLootFrame_StartNeedAnimation).
local GamepadGroupLootNeedRollAnimDuration = 5;

local GameplayGroupLootEvents =
{
	"START_LOOT_ROLL",
	"PLAYER_ENTERING_WORLD",
	"CANCEL_LOOT_ROLL",
	"CANCEL_ALL_LOOT_ROLLS",
	"MAIN_SPEC_NEED_ROLL",
};

function ToggleLootRollFrame()
	GamepadGroupLootRollFrame:SetShown(not GamepadGroupLootRollFrame:IsShown());
end

GamepadGroupLootRollFrameMixin = {};

local function ClampSelectedRollIndex(self)
	local numWaitingRolls = 0;

	if self.waitingRolls then
		numWaitingRolls = #self.waitingRolls;
	end

	if numWaitingRolls == 0 then
		self.selectedRollIndex = nil;
		return;
	end

	if not self.selectedRollIndex then
		self.selectedRollIndex = 1;
	elseif self.selectedRollIndex < 1 then
		self.selectedRollIndex = 1;
	elseif self.selectedRollIndex > numWaitingRolls then
		self.selectedRollIndex = numWaitingRolls;
	end
end

local function GetSelectedRollID(self)
	ClampSelectedRollIndex(self);

	local selectedIdx = self.selectedRollIndex;
	if not selectedIdx then
		return nil;
	end

	local ret = nil;
	if #self.waitingRolls >= selectedIdx then
		ret = self.waitingRolls[selectedIdx].rollID;
	end

	return ret;
end

function GamepadGroupLootRollFrameMixin:DoFullRefresh()
	local dataProvider = CreateDataProvider();
	local numDisplayedRolls = 0;

	for i, data in ipairs(self.waitingRolls) do
		if i > MAX_NUM_GAMEPAD_LOOT_ITEMS then
			break;
		end

		dataProvider:Insert({rollID = data.rollID, rollTime = data.rollTime});
		numDisplayedRolls = numDisplayedRolls + 1;
	end

	self:SetHeight(GAMEPAD_GROUP_LOOT_FRAME_BASE_HEIGHT + numDisplayedRolls * (GAMEPAD_GROUP_LOOT_ITEM_HEIGHT + SCROLL_BOX_SPACING));

	local scrollPercentage = self.ScrollBox:GetScrollPercentage();
	self.ScrollBox:SetDataProvider(dataProvider);
	self.ScrollBox:SetScrollPercentage(scrollPercentage);
end

function GamepadGroupLootRollFrameMixin:GetSelectedElement()
	local selectedRollID = GetSelectedRollID(self);
	if not selectedRollID then
		return nil;
	end

	local dataProviderSize = self.ScrollBox:GetDataProviderSize();
	for i = 1, dataProviderSize do
		local elementData = self.ScrollBox:FindElementData(i);
		if elementData and elementData.rollID == selectedRollID then
			self.ScrollBox:ScrollToElementDataIndex(i, nil, nil, true);
			return self.ScrollBox:FindFrame(elementData);
		end
	end

	return nil;
end

function GamepadGroupLootRollFrameMixin:FocusGamepad()
	SmartNavigation:SetScrollFrameForFrame(self, self.ScrollBox);
	SmartNavigation:SetTargetButtonForFrame(self, self:GetSelectedElement());
end

-- Smart nav creates the panel info while focusing this frame, so seed the selection before it picks a button itself.
function GamepadGroupLootRollFrameMixin:OnSmartNavPanelInfoAdded(panelInfo)
	SmartNavigation:SetTargetButtonForFrame(self, self:GetSelectedElement());
end

function GamepadGroupLootRollFrameMixin:CanSelectRelativeRoll(offset)
	ClampSelectedRollIndex(self);

	if not self.selectedRollIndex then
		return false;
	end

	local nextIndex = self.selectedRollIndex + offset;
	return nextIndex >= 1 and nextIndex <= #self.waitingRolls;
end

function GamepadGroupLootRollFrameMixin:SelectRelativeRoll(offset)
	if not self:CanSelectRelativeRoll(offset) then
		return;
	end
	
	self:UnfocusGamepad();

	self.selectedRollIndex = self.selectedRollIndex + offset;
	self:FocusGamepad();
end

function GamepadGroupLootRollFrameMixin:InitRegions()
	self.TitleContainer.TitleText:SetText(LOOT_ROLLS);
end

function GamepadGroupLootRollFrameMixin:InitScrollBox()
	local view = CreateScrollBoxListLinearView(SCROLL_BOX_PAD, SCROLL_BOX_PAD, SCROLL_BOX_PAD, SCROLL_BOX_PAD, SCROLL_BOX_SPACING);

	local function Initializer(frame, elementData)
		frame.rollID = elementData.rollID;
		frame.rollTime = elementData.rollTime;
		frame.rollListFrame = self;
		frame.Timer:SetMinMaxValues(0, elementData.rollTime);

		if not frame.gamepadFooter then
			GamepadGroupLootFrame_SetupGamepad(frame);
		end

		GroupLootFrame_SetupItemDisplay(frame);
	end

	view:SetElementFactory(function(factory, elementData)
		factory("GamepadGroupLootRollFrameTemplate", Initializer);
	end);

	view:SetElementExtentCalculator(function(dataIndex, elementData)
		return GAMEPAD_GROUP_LOOT_ITEM_HEIGHT;
	end);

	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function GamepadGroupLootRollFrameMixin:OnDragStart()
	self:StartMoving();
end

function GamepadGroupLootRollFrameMixin:OnDragStop()
	self:StopMovingOrSizing();
end

function GamepadGroupLootRollFrameMixin:OnEvent(event, ...)
	if event == "START_LOOT_ROLL" then
		local rollID, rollTime = ...;
		if rollID and rollTime then
			self:AddRoll(rollID, rollTime);

			if not self:IsShown() then
				-- OnShow refreshes the list and restores focus.
				self:Show();
			else
				self:UnfocusGamepad();
				self:DoFullRefresh();
				self:FocusGamepad();
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self.waitingRolls = {};
		self.selectedRollIndex = nil;

		self:RehydrateLootRolls();

		if self:GetNumWaitingRolls() > 0 and not self:IsShown() then
			self:Show();
		end
	elseif event == "CANCEL_LOOT_ROLL" then
		local rollID = ...;
		self:RemoveRoll(rollID);
	elseif event == "CANCEL_ALL_LOOT_ROLLS" then
		self:RemoveAllRolls();
	elseif event == "MAIN_SPEC_NEED_ROLL" then
		local rollID, roll, isWinning = ...;
		-- Play the need animation on the matching card, then remove the roll once the animation has finished.
		local card = self.ScrollBox:FindFrameByPredicate(function(frame)
			return frame.rollID == rollID;
		end);
		if card then
			GroupLootFrame_StartNeedAnimation(card, roll, isWinning);
		end
		C_Timer.After(GamepadGroupLootNeedRollAnimDuration, function()
			self:RemoveRoll(rollID);
		end);
	end
end

function GamepadGroupLootRollFrameMixin:OnHide()
	GamepadMode.FrameControlsManager:FrameHidden(self);
	SmartNavigation:SetScrollFrameForFrame(self, nil);

	self.ScrollBox:RemoveDataProvider();
end

function GamepadGroupLootFrame_SetupGamepad(self)
	SmartNavigation_MarkFrameFocusable(self);
	SmartNavigation_SetCustomCursorAnchorPointForFrame(self, CreateAnchor("RIGHT", self, "LEFT", 14, 0));

	local function CanNeed()
		return self.canNeed;
	end

	local function CanGreed()
		return self.canGreed;
	end

	local function CanTransmog()
		return self.canTransmog;
	end

	local function SimulatePassClick()
		RollOnLoot(self.rollID, 0);
	end

	local function SimulateNeedClick()
		if self.canNeed then
			RollOnLoot(self.rollID, 1);
		end
	end
	
	local function SimulateGreedOrTransmogClick(down)
		if not down then
			return;
		end

		if CanGreed() then
			RollOnLoot(self.rollID, 2);
		elseif CanTransmog() then
			RollOnLoot(self.rollID, 4);
		end
	end

	local function CanSelectPreviousRoll()
		return self.rollListFrame and self.rollListFrame:CanSelectRelativeRoll(-1);
	end

	local function CanSelectNextRoll()
		return self.rollListFrame and self.rollListFrame:CanSelectRelativeRoll(1);
	end

	local function SelectPreviousRoll()
		if self.rollListFrame then
			self.rollListFrame:SelectRelativeRoll(-1);
		end
	end

	local function SelectNextRoll()
		if self.rollListFrame then
			self.rollListFrame:SelectRelativeRoll(1);
		end
	end

	local passAction = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, SimulatePassClick, PASS);
	local needAction = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, SimulateNeedClick, NEED);
	needAction:AddCondition(CanNeed);

	local greedAction = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, SimulateGreedOrTransmogClick, GREED);
	greedAction:SetButtonEventsHandled(GAMEPAD_BUTTON_ANY_DOWN_OR_UP);
	greedAction:AddCondition(CanGreed);

	local transmogAction = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, SimulateGreedOrTransmogClick, TRANSMOGRIFICATION);
	transmogAction:SetButtonEventsHandled(GAMEPAD_BUTTON_ANY_DOWN_OR_UP);
	transmogAction:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	transmogAction:AddCondition(CanTransmog);

	local previousRollAction = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD_TOP, SelectPreviousRoll, nil);
	previousRollAction:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.NEVER);
	previousRollAction:AddCondition(CanSelectPreviousRoll);

	local nextRollAction = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD_BOTTOM, SelectNextRoll, nil);
	nextRollAction:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.NEVER);
	nextRollAction:AddCondition(CanSelectNextRoll);

	local footerParent = self.rollListFrame;
	self.gamepadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(footerParent, "GroupLootFrameFooter");
	self.gamepadFooter:SetAnchorOffsets(3, 0);
	self.gamepadFooter:AddPromptedBinding(passAction);
	self.gamepadFooter:AddPromptedBinding(needAction);
	self.gamepadFooter:AddPromptedBinding(greedAction);
	self.gamepadFooter:AddPromptedBinding(transmogAction);
	self.gamepadFooter:AddPromptedBinding(previousRollAction);
	self.gamepadFooter:AddPromptedBinding(nextRollAction);
	self.gamepadFooter:Finalize();

	local function ShowSelectedRollTooltip()
		if self.rollID then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetLootRollItem(self.rollID);
			GameTooltip:Show();
		end
	end

	local function FocusEnter()
		ShowSelectedRollTooltip();
		self.gamepadFooter:ShowAndActivateBindings();
	end

	local function FocusExit()
		GameTooltip:Hide();
		ResetCursor();
		self.gamepadFooter:HideAndDeactivateBindings();
	end

	self.FocusEnter = FocusEnter;
	self.FocusExit = FocusExit;
end

local function GamepadGroupLootFrame_RegisterForTransitions(self)
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function GamepadGroupLootRollFrameMixin:OnLoad()
	self.waitingRolls = {};
	self.selectedRollIndex = 1;

	self:InitRegions();
	self:InitScrollBox();

	SmartNavigation:SetSmartNavPanelInfoAddedCallback(self, GenerateClosure(self.OnSmartNavPanelInfoAdded, self));

	GamepadGroupLootFrame_RegisterForTransitions(self);

	self.ScrollBar:Hide();
end

function GamepadGroupLootRollFrameMixin:OnShow()
	GamepadMode.FrameControlsManager:AddToFrameGroup(self, "NeedGreed");
	GamepadMode.FrameControlsManager:SkipGamepadAutoFocus(self);

	-- Populate the list before the frame controls manager runs its focus pass, otherwise there are no roll cards to select.
	self:DoFullRefresh();

	GamepadMode.FrameControlsManager:FrameShown(self, true);

	self:FocusGamepad();
end

function GamepadGroupLootRollFrameMixin:UnfocusGamepad()
	SmartNavigation:SetScrollFrameForFrame(self, nil);

	if self.focusedRollFrame and self.focusedRollFrame.UnfocusGamepad then
		self.focusedRollFrame:UnfocusGamepad();
		self.focusedRollFrame = nil;
	end

	GameTooltip:Hide();
	ResetCursor();
end

function GamepadGroupLootRollFrameMixin:InitializeGamepad()
	self.waitingRolls = {};
	self.selectedRollIndex = 1;

	FrameUtil.RegisterFrameForEvents(self, GameplayGroupLootEvents);

	self:RehydrateLootRolls();

	if self:GetNumWaitingRolls() > 0 and not self:IsShown() then
		self:Show();
	end
end

function GamepadGroupLootRollFrameMixin:UninitializeGamepad()
	FrameUtil.UnregisterFrameForEvents(self, GameplayGroupLootEvents);

	self:RemoveAllRolls();

	if self:IsVisible() then
		self:Hide();
	end
end

function GamepadGroupLootRollFrameMixin:AddRoll(rollID, rollTime)
	table.insert(self.waitingRolls, { rollID = rollID, rollTime = rollTime });
	ClampSelectedRollIndex(self);
end

function GamepadGroupLootRollFrameMixin:RemoveRoll(rollID)
	for i, data in ipairs(self.waitingRolls) do
		if data.rollID == rollID then
			table.remove(self.waitingRolls, i);

			-- select previous element.  ClampSelectedRollIndex handles underflow from 1
			self.selectedRollIndex = i - 1;

			break;
		end
	end
	ClampSelectedRollIndex(self);

	if self:GetNumWaitingRolls() == 0 then
		self:Hide();
		return;
	end

	if self:IsShown() then
		self:UnfocusGamepad();
		self:DoFullRefresh();
		self:FocusGamepad();
	end
end

function GamepadGroupLootRollFrameMixin:RemoveAllRolls()
	self.waitingRolls = {};
	self.selectedRollIndex = nil;
	self:Hide();
end

function GamepadGroupLootRollFrameMixin:GetNumWaitingRolls()
	return #self.waitingRolls;
end

function GamepadGroupLootRollFrameMixin:RehydrateLootRolls()
	local pendingLootRollIDs = GetActiveLootRollIDs();
	for i=1, #pendingLootRollIDs do
		self:AddRoll(pendingLootRollIDs[i], C_Loot.GetLootRollDuration(pendingLootRollIDs[i]));
	end
end
