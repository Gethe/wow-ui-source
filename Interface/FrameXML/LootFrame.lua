LOOTFRAME_NUMBUTTONS = 5;
NUM_GROUP_LOOT_FRAMES = 4;
MASTER_LOOT_THREHOLD = 4;
LOOT_SLOT_NONE = 0;
LOOT_SLOT_ITEM = 1;
LOOT_SLOT_MONEY = 2;
LOOT_SLOT_CURRENCY = 3;

local LOOTFRAME_BASEHEIGHT = 290;
local LOOTFRAME_BASEWIDTH = 220;

local LOOTFRAME_BUTTONHEIGHT = 46;
local LOOTFRAME_SCROLLBARWIDTH = 16;

local LOOTFRAME_PAD = 6;
local LOOTFRAME_SPACING = 2;

function LootFrame_OnLoad(self)
	self:RegisterEvent("LOOT_OPENED");
	self:RegisterEvent("LOOT_SLOT_CLEARED");
	self:RegisterEvent("LOOT_SLOT_CHANGED");
	self:RegisterEvent("LOOT_CLOSED");
	self:RegisterEvent("OPEN_MASTER_LOOT_LIST");
	self:RegisterEvent("UPDATE_MASTER_LOOT_LIST");

	local Pad = LOOTFRAME_PAD;
	local Spacing = LOOTFRAME_SPACING;
	local view = CreateScrollBoxListLinearView(Pad, Pad, Pad, Pad, Spacing);
		
	local function Initializer(button, elementData)
		LootButton_Update(button);
	end

	view:SetElementInitializer("LootButtonTemplate", Initializer);

	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.ScrollBox:SetShadowsFrameLevel(self.ScrollBox.ScrollTarget:GetFrameLevel() + 15);
	self.ScrollBox:SetShadowsScale(0.2);
	self.ScrollBox:GetUpperShadowTexture():SetTexCoord(0, 1, 1, 0);
	self.ScrollBox:GetUpperShadowTexture():SetPoint("TOPLEFT", 30, 0);
	self.ScrollBox:GetUpperShadowTexture():SetPoint("TOPRIGHT", -30, 0);
	self.ScrollBox:GetLowerShadowTexture():SetPoint("BOTTOMLEFT", 30, 0);
	self.ScrollBox:GetLowerShadowTexture():SetPoint("BOTTOMRIGHT", -30, 0);
end

function LootFrame_OnEvent(self, event, ...)
	if ( event == "LOOT_OPENED" ) then
		local autoLoot, isFromItem = ...;

		self.isAutoLoot = autoLoot;

		LootFrame_Show(self);
		if ( not self:IsShown()) then
			CloseLoot(not autoLoot);	-- The parameter tells code that we were unable to open the UI
		else
			if ( isFromItem ) then
				PlaySound(SOUNDKIT.UI_CONTAINER_ITEM_OPEN);
			end
		end
	elseif ( event == "LOOT_SLOT_CLEARED" ) then
		local arg1 = ...;
		if ( not self:IsShown() ) then
			return;
		end

		local button = self.ScrollBox:FindFrameByPredicate(function(frame)
			return frame:GetElementData().index == arg1;
		end);
		if button then
			if self.isAutoLoot then
				button.AutoLootAnim:Play();
			else
				button:Hide();
			end
		end
	elseif ( event == "LOOT_SLOT_CHANGED" ) then
		local arg1 = ...;

		if ( not self:IsShown() ) then
			return;
		end
		
		LootFrame_Update();
	elseif ( event == "LOOT_CLOSED" ) then
		LootFrame_Close();
	elseif ( event == "OPEN_MASTER_LOOT_LIST" ) then
		ToggleDropDownMenu(1, nil, GroupLootDropDown, LootFrame.selectedLootButton, 0, 0);
	elseif ( event == "UPDATE_MASTER_LOOT_LIST" ) then
		MasterLooterFrame_UpdatePlayers();
	end
end

local LOOT_UPDATE_INTERVAL = 0.5;
function LootFrame_OnUpdate(self, elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed;
	if ( self.timeSinceUpdate >= LOOT_UPDATE_INTERVAL ) then
		self:SetScript("OnUpdate", nil);
		self.timeSinceUpdate = nil;
		LootFrame_Update();
	end
end

function LootButton_Update(button)
	local numLootItems = LootFrame.numLootItems;
	local self = LootFrame;

	local slot = button:GetElementData().index;
	if ( not LootSlotHasItem(slot) ) then
		if not self.isAutoLoot then
			button:Hide();
		end
		return;
	end

	local texture, item, quantity, currencyID, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(slot);

	if ( currencyID ) then 
		item, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, item, texture, quality);
	end

	local slotType = GetLootSlotType(slot);
	local isMoney = slotType == LOOT_SLOT_MONEY;

	local text = isMoney and button.MoneyText or button.Text;
	local hiddenText = isMoney and button.Text or button.MoneyText;
	hiddenText:SetText("");
	button.QualityText:SetShown(not isMoney);
	button.QualityFrame:SetShown(not isMoney);
	if ( texture ) then
		local color = ITEM_QUALITY_COLORS[quality];
		SetItemButtonQuality(button.Item, quality, GetLootSlotLink(slot));
		button.Item.icon:SetTexture(texture);
		text:SetText(item);
		button.QualityText:SetText(_G["ITEM_QUALITY"..quality.."_DESC"]);
		button.NameFrame:SetVertexColor(color.r, color.g, color.b);
		if( locked ) then
			SetItemButtonTextureVertexColor(button.Item, 0.9, 0, 0);
			SetItemButtonNormalTextureVertexColor(button.Item, 0.9, 0, 0);
		else
			SetItemButtonTextureVertexColor(button.Item, 1.0, 1.0, 1.0);
			SetItemButtonNormalTextureVertexColor(button.Item, 1.0, 1.0, 1.0);
		end

		local questTexture = button.IconQuestTexture;
		if ( questId and not isActive ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
			questTexture:Show();
		elseif ( questId or isQuestItem ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
			questTexture:Show();
		else
			questTexture:Hide();
		end

		text:SetVertexColor(color.r, color.g, color.b);
		local countString = button.Item.Count;
		if ( quantity > 1 ) then
			countString:SetText(quantity);
			countString:Show();
		else
			countString:Hide();
		end
		button.slot = slot;
		button.quality = quality;
		button.Item:Enable();
	else
		text:SetText("");
		button.QualityText:SetText("");
		button.Item.icon:SetTexture(nil);
		SetItemButtonNormalTextureVertexColor(button.Item, 1.0, 1.0, 1.0);
		LootFrame:SetScript("OnUpdate", LootFrame_OnUpdate);
		button.Item:Disable();
	end
	button.AutoLootAnim:Stop();
	button.ShownAnim:Play();
	button:Show();
end

function LootFrame_Update(retainScrollPosition)
	local numLootItems = LootFrame.numLootItems;

	local dataProvider = CreateDataProviderByIndexCount(numLootItems);

	LootFrame.ScrollBox:SetDataProvider(dataProvider, retainScrollPosition == nil and ScrollBoxConstants.RetainScrollPosition or retainScrollPosition);
end

function LootFrame_Close()
	LootFrame.ShowAnim:Stop();
	LootFrame.HideAnim:Play(false);
end

function LootFrame_Show(self)
	self.numLootItems = GetNumLootItems();

	if ( GetCVar("lootUnderMouse") == "1" ) then
		self:Show();
		-- position loot window under mouse cursor
		local x, y = GetCursorPosition();
		x = x / self:GetEffectiveScale();
		y = y / self:GetEffectiveScale();

		local posX = x - 175;
		local posY = y + 25;

		if (self.numLootItems > 0) then
			posX = x - 40;
			posY = y + 55;
			posY = posY + 40;
		end

		if( posY < 350 ) then
			posY = 350;
		end

		self:ClearAllPoints();
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", posX, posY);
		self:GetCenter();
		self:Raise();
	else
		ShowUIPanel(self);
	end

	local showScrollBar = self.numLootItems > LOOTFRAME_NUMBUTTONS;
	if (showScrollBar) then
		self:SetHeight(LOOTFRAME_BASEHEIGHT);
		self:SetWidth(LOOTFRAME_BASEWIDTH + LOOTFRAME_SCROLLBARWIDTH);
	else
		local fitToHeight = LOOTFRAME_BASEHEIGHT - ((LOOTFRAME_BUTTONHEIGHT + LOOTFRAME_SPACING) * (LOOTFRAME_NUMBUTTONS - self.numLootItems));
		self:SetHeight(fitToHeight);
		self:SetWidth(LOOTFRAME_BASEWIDTH);
	end
	self.ScrollBar:SetShown(showScrollBar);
	self.ScrollBox:SetWidth(LOOTFRAME_BASEWIDTH - LOOTFRAME_PAD);

	LootFrame_Update(ScrollBoxConstants.DiscardScrollPosition);
	
	LootFrame.HideAnim:Stop();
	LootFrame.ShowAnim:Play(true);
end

function LootFrame_OnShow(self)
	if( self.numLootItems == 0 ) then
		PlaySound(SOUNDKIT.LOOT_WINDOW_OPEN_EMPTY);
	elseif( IsFishingLoot() ) then
		PlaySound(SOUNDKIT.FISHING_REEL_IN);
	end
end

function LootFrame_OnHide(self)
	CloseLoot();
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");
	MasterLooterFrame:Hide();
end

function LootButton_OnClick(self, button)
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");
	MasterLooterFrame:Hide();

	LootFrame.selectedLootButton = self:GetName();
	LootFrame.selectedSlot = self.slot;
	LootFrame.selectedQuality = self.quality;
	LootFrame.selectedItemName = self.Text:GetText();
	LootFrame.selectedTexture = self.Item.icon:GetTexture();
	LootSlot(self.slot);
end

function LootItem_OnEnter(self)
	local slot = self:GetElementData().index;
	local slotType = GetLootSlotType(slot);
	if ( slotType == LOOT_SLOT_ITEM ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetLootItem(slot);
		CursorUpdate(self);
	end
	if ( slotType == LOOT_SLOT_CURRENCY ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetLootCurrency(slot);
		CursorUpdate(self);
	end
	self.HighlightNameFrame:Show();
end

function LootItem_OnLeave(self)
	self.HighlightNameFrame:Hide();
end

function LootItem_OnMouseDown(self)
	self.PushedNameFrame:Show();
end

function LootItem_OnMouseUp(self)
	self.PushedNameFrame:Hide();
end

function GroupLootContainer_OnLoad(self)
	self.rollFrames = {};
	self.reservedSize = 100;
	GroupLootContainer_CalcMaxIndex(self);

	local alertSystem = AlertFrame:AddExternallyAnchoredSubSystem(self);
	AlertFrame:SetSubSystemAnchorPriority(alertSystem, 30);
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

function GroupLootContainer_RemoveFrame(self, frame)
	local idx = nil;
	for k, v in pairs(self.rollFrames) do
		if ( v == frame ) then
			idx = k;
			break;
		end
	end

	if ( idx ) then
		self.rollFrames[idx] = nil;
		if ( idx == self.maxIndex ) then
			GroupLootContainer_CalcMaxIndex(self);
		end
	end
	frame:Hide();
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
	else
		self:Hide();
	end
end

function GroupLootDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, nil, "MENU");
	self.initialize = GroupLootDropDown_Initialize;
end

function GroupLootDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.isTitle = 1;
	info.text = MASTER_LOOTER;
	info.fontObject = GameFontNormalLeft;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;
	info.text = ASSIGN_LOOT;
	info.func = MasterLooterFrame_Show;
	UIDropDownMenu_AddButton(info);
	info.text = REQUEST_ROLL;
	info.func = function() DoMasterLootRoll(LootFrame.selectedSlot); end;
	UIDropDownMenu_AddButton(info);
end

function GroupLootFrame_OpenNewFrame(id, rollTime)
	local frame;
	for i=1, NUM_GROUP_LOOT_FRAMES do
		frame = _G["GroupLootFrame"..i];
		if ( not frame:IsShown() ) then
			frame.rollID = id;
			frame.rollTime = rollTime;
			frame.Timer:SetMinMaxValues(0, rollTime);
			GroupLootContainer_AddFrame(GroupLootContainer, frame);
			return;
		end
	end
end

function GroupLootFrame_EnableLootButton(button)
	button:Enable();
	button:SetAlpha(1.0);
	SetDesaturation(button:GetNormalTexture(), false);
end

function GroupLootFrame_DisableLootButton(button)
	button:Disable();
	button:SetAlpha(0.35);
	SetDesaturation(button:GetNormalTexture(), true);
end

function GroupLootFrame_OnShow(self)
	local texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired = GetLootRollItemInfo(self.rollID);
	if (name == nil) then
		GroupLootContainer_RemoveFrame(GroupLootContainer, self);
		return;
	end

	self.IconFrame.Icon:SetTexture(texture);
	self.IconFrame.Border:SetAtlas(LOOT_BORDER_BY_QUALITY[quality] or LOOT_BORDER_BY_QUALITY[Enum.ItemQuality.Uncommon]);
	self.Name:SetText(name);
	local color = ITEM_QUALITY_COLORS[quality];
	self.Name:SetVertexColor(color.r, color.g, color.b);
	self.Border:SetVertexColor(color.r, color.g, color.b);
	if ( count > 1 ) then
		self.IconFrame.Count:SetText(count);
		self.IconFrame.Count:Show();
	else
		self.IconFrame.Count:Hide();
	end

	if ( canNeed ) then
		GroupLootFrame_EnableLootButton(self.NeedButton);
		self.NeedButton.reason = nil;
	else
		GroupLootFrame_DisableLootButton(self.NeedButton);
		self.NeedButton.reason = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonNeed];
	end
	if ( canGreed) then
		GroupLootFrame_EnableLootButton(self.GreedButton);
		self.GreedButton.reason = nil;
	else
		GroupLootFrame_DisableLootButton(self.GreedButton);
		self.GreedButton.reason = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonGreed];
	end
	if ( canDisenchant) then
		GroupLootFrame_EnableLootButton(self.DisenchantButton);
		self.DisenchantButton.reason = nil;
	else
		GroupLootFrame_DisableLootButton(self.DisenchantButton);
		self.DisenchantButton.reason = format(_G["LOOT_ROLL_INELIGIBLE_REASON"..reasonDisenchant], deSkillRequired);
	end
	self.Timer:SetFrameLevel(self:GetFrameLevel() - 1);
end

function GroupLootFrame_OnEvent(self, event, ...)
	if ( event == "CANCEL_LOOT_ROLL" ) then
		local arg1 = ...;
		if ( arg1 == self.rollID ) then
			GroupLootContainer_RemoveFrame(GroupLootContainer, self);
			StaticPopup_Hide("CONFIRM_LOOT_ROLL", self.rollID);
		end
	end
end

function GroupLootFrame_OnUpdate(self, elapsed)
	local left = GetLootRollTimeLeft(self:GetParent().rollID);
	local min, max = self:GetMinMaxValues();
	if ( (left < min) or (left > max) ) then
		left = min;
	end
	self:SetValue(left);
end

function BonusRollFrame_StartBonusRoll(spellID, text, duration, currencyID, currencyCost, difficultyID)
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
					local itemID = GetItemInfoInstant(self.rewardLink);
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
	GameTooltip_SetTitle(GameTooltip, BONUS_ROLL_TOOLTIP_TITLE);
	GameTooltip_AddNormalLine(GameTooltip, BONUS_ROLL_TOOLTIP_TEXT);

	if ( self:IsLinkDataAvailable() ) then
		GameTooltip_AddInstructionLine(GameTooltip, BONUS_ROLL_TOOLTIP_ENCOUNTER_JOURNAL_LINK);
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
		specialization = GetSpecializationInfo(GetSpecialization());
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
	local rollType, roll, isCurrency, showFactionBG, lootSource, lessAwesome, isUpgraded, wonRoll, showRatedBG;
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

local function MasterLooterPlayerSort(pInfo1, pInfo2)
	if ( pInfo1.class == pInfo2.class ) then
		return pInfo1.name < pInfo2.name;
	else
		return pInfo1.class < pInfo2.class;
	end
end

function MasterLooterFrame_OnHide(self)
	for playerFrame in pairs(buttonsToHide) do
		playerFrame:Hide();
	end
	wipe(buttonsToHide);
end

function MasterLooterFrame_Show()
	local itemFrame = MasterLooterFrame.Item;
	itemFrame.ItemName:SetText(LootFrame.selectedItemName);
	itemFrame.Icon:SetTexture(LootFrame.selectedTexture);
	local colorInfo = ITEM_QUALITY_COLORS[LootFrame.selectedQuality];
	itemFrame.IconBorder:SetVertexColor(colorInfo.r, colorInfo.g, colorInfo.b);
	itemFrame.ItemName:SetVertexColor(colorInfo.r, colorInfo.g, colorInfo.b);

	MasterLooterFrame:Show();
	MasterLooterFrame_UpdatePlayers();
	MasterLooterFrame:SetPoint("TOPLEFT", DropDownList1, 0, 0);

	CloseDropDownMenus();
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

function MasterLooterPlayerFrame_OnClick(self)
	MasterLooterFrame.slot = LootFrame.selectedSlot;
	MasterLooterFrame.candidateId = self.id;
	if ( LootFrame.selectedQuality >= MASTER_LOOT_THREHOLD ) then
		StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex..LootFrame.selectedItemName..FONT_COLOR_CODE_CLOSE, self.Name:GetText(), "LootWindow");
	else
		MasterLooterFrame_GiveMasterLoot();
	end
end

function MasterLooterFrame_GiveMasterLoot()
	GiveMasterLoot(MasterLooterFrame.slot, MasterLooterFrame.candidateId);
	MasterLooterFrame:Hide();
end
