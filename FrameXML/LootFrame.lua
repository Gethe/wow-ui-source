LOOTFRAME_NUMBUTTONS = 4;
NUM_GROUP_LOOT_FRAMES = 4;
MASTER_LOOT_THREHOLD = 4;
LOOT_SLOT_NONE = 0;
LOOT_SLOT_ITEM = 1;
LOOT_SLOT_MONEY = 2;
LOOT_SLOT_CURRENCY = 3;

LOOTFRAME_AUTOLOOT_DELAY = 0.3;
LOOTFRAME_AUTOLOOT_RATE = 0.35;

function LootFrame_OnLoad(self)
	self:RegisterEvent("LOOT_OPENED");
	self:RegisterEvent("LOOT_SLOT_CLEARED");
	self:RegisterEvent("LOOT_SLOT_CHANGED");
	self:RegisterEvent("LOOT_CLOSED");
	self:RegisterEvent("LOOT_READY");
	self:RegisterEvent("OPEN_MASTER_LOOT_LIST");
	self:RegisterEvent("UPDATE_MASTER_LOOT_LIST");
	--hide button bar
	ButtonFrameTemplate_HideButtonBar(self);
end

function LootFrame_OnEvent(self, event, ...)
	if ( event == "LOOT_OPENED" ) then
		local autoLoot = ...;
		if( autoLoot ) then
			LootFrame_InitAutoLootTable( self );
			LootFrame:SetScript("OnUpdate", LootFrame_OnUpdate);
			self.AutoLootDelay = LOOTFRAME_AUTOLOOT_DELAY;
		else
			self.AutoLootDelay = 0;
			self.AutoLootTable = nil;
		end

		self.page = 1;
		LootFrame_Show(self);
		if ( not self:IsShown()) then
			CloseLoot(not autoLoot);	-- The parameter tells code that we were unable to open the UI
		end
	elseif( event == "LOOT_READY" ) then
		LootFrame_InitAutoLootTable( self );
	elseif ( event == "LOOT_SLOT_CLEARED" ) then
		local arg1 = ...;
		if ( not self:IsShown() or self.AutoLootTable) then
			return;
		end

		local numLootToShow = LOOTFRAME_NUMBUTTONS;
		if ( self.numLootItems > LOOTFRAME_NUMBUTTONS ) then
			numLootToShow = numLootToShow - 1;
		end
		local slot = arg1 - ((self.page - 1) * numLootToShow);
		if ( (slot > 0) and (slot < (numLootToShow + 1)) ) then
			local button = _G["LootButton"..slot];
			if ( button ) then
				button:Hide();
			end
		end
		-- try to move second page of loot items to the first page
		local button;
		local allButtonsHidden = 1;

		for index = 1, LOOTFRAME_NUMBUTTONS do
			button = _G["LootButton"..index];
			if ( button:IsShown() ) then
				allButtonsHidden = nil;
			end
		end
		if ( allButtonsHidden and LootFrameDownButton:IsShown() ) then
			LootFrame_PageDown();
		end
		return;
	elseif ( event == "LOOT_SLOT_CHANGED" ) then
		local arg1 = ...;

		if ( not self:IsShown() ) then
			return;
		end

		local numLootToShow = LOOTFRAME_NUMBUTTONS;
		if ( self.numLootItems > LOOTFRAME_NUMBUTTONS ) then
			numLootToShow = numLootToShow - 1;
		end
		local slot = arg1 - ((self.page - 1) * numLootToShow);
		if ( (slot > 0) and (slot < (numLootToShow + 1)) ) then
			local button = _G["LootButton"..slot];
			if ( button ) then
				LootFrame_UpdateButton(slot);
			end
		end
	elseif ( event == "LOOT_CLOSED" ) then
		if( not self.AutoLootTable ) then
			LootFrame_Close();
		end
		return;
	elseif ( event == "OPEN_MASTER_LOOT_LIST" ) then
		ToggleDropDownMenu(1, nil, GroupLootDropDown, LootFrame.selectedLootButton, 0, 0);
		return;
	elseif ( event == "UPDATE_MASTER_LOOT_LIST" ) then
		MasterLooterFrame_UpdatePlayers();
	end
end

local LOOT_UPDATE_INTERVAL = 0.5;
function LootFrame_OnUpdate(self, elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed;
	if( self.AutoLootTable )then
		if( self.AutoLootDelay > 0 ) then
			self.AutoLootDelay = self.AutoLootDelay - elapsed;
			self.timeSinceUpdate = 0;
			self.AutoLootCurrentIdx = 1;
		elseif( self.timeSinceUpdate >  LOOTFRAME_AUTOLOOT_RATE ) then
			local entry = self.AutoLootTable[self.AutoLootCurrentIdx]
			if( entry and not entry.roll and not entry.locked) then
				self.AutoLootTable[self.AutoLootCurrentIdx].hide = true;
			end
			self.AutoLootCurrentIdx = self.AutoLootCurrentIdx +1;
			self.timeSinceUpdate = 0;
			if( self.AutoLootCurrentIdx > #self.AutoLootTable ) then
				self:SetScript("OnUpdate", nil);
				self.timeSinceUpdate = nil;
				self.AutoLootTable = nil;
				--close
				LootFrame_Close();
			else
				local numLootToShow = LOOTFRAME_NUMBUTTONS;
				if ( self.numLootItems > LOOTFRAME_NUMBUTTONS ) then
					numLootToShow = numLootToShow - 1;
				end
				local slot = self.AutoLootCurrentIdx - ((self.page - 1) * numLootToShow) - 1;
				if ( (slot > 0) and (slot < (numLootToShow + 1)) ) then
					local button = _G["LootButton"..slot];
					if ( button ) then
						button:Hide();
					end
				end
				-- try to move second page of loot items to the first page
				if( self.AutoLootCurrentIdx % numLootToShow == 1 ) then
					if( LootFrameDownButton:IsShown() ) then
						LootFrame_PageDown();
					end
				end
				LootFrame_Update();
			end
		end
	elseif ( self.timeSinceUpdate >= LOOT_UPDATE_INTERVAL ) then
		self:SetScript("OnUpdate", nil);
		self.timeSinceUpdate = nil;
		LootFrame_Update();
	end
end

function LootFrame_UpdateButton(index)
	local numLootItems = LootFrame.numLootItems;
	--Logic to determine how many items to show per page
	local numLootToShow = LOOTFRAME_NUMBUTTONS;
	local self = LootFrame;
	if( self.AutoLootTable ) then
		numLootItems = #self.AutoLootTable;
	end
	if ( numLootItems > LOOTFRAME_NUMBUTTONS ) then
		numLootToShow = numLootToShow - 1; -- make space for the page buttons
	end
	local button = _G["LootButton"..index];
	local slot = (numLootToShow * (LootFrame.page - 1)) + index;
	if ( slot <= numLootItems ) then
		if ( (LootSlotHasItem(slot)  or (self.AutoLootTable and self.AutoLootTable[slot]) )and index <= numLootToShow) then
			local texture, item, quantity, currencyID, quality, locked, isQuestItem, questId, isActive;
			if(self.AutoLootTable)then
				local entry = self.AutoLootTable[slot];
				if( entry.hide ) then
					button:Hide();
					return;
				else
					texture = entry.texture;
					item = entry.item;
					quantity = entry.quantity;
					quality = entry.quality;
					locked = entry.locked;
					isQuestItem = entry.isQuestItem;
					questId = entry.questId;
					isActive = entry.isActive;
				end
			else
				texture, item, quantity, currencyID, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(slot);
			end

			if ( currencyID ) then 
				item, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, item, texture, quality);
			end
			
			local text = _G["LootButton"..index.."Text"];
			if ( texture ) then
				local color = ITEM_QUALITY_COLORS[quality];
				_G["LootButton"..index.."IconTexture"]:SetTexture(texture);
				text:SetText(item);
				if( locked ) then
					SetItemButtonNameFrameVertexColor(button, 1.0, 0, 0);
					SetItemButtonTextureVertexColor(button, 0.9, 0, 0);
					SetItemButtonNormalTextureVertexColor(button, 0.9, 0, 0);
				else
					SetItemButtonNameFrameVertexColor(button, 0.5, 0.5, 0.5);
					SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0);
					SetItemButtonNormalTextureVertexColor(button, 1.0, 1.0, 1.0);
				end

				text:SetVertexColor(color.r, color.g, color.b);
				local countString = _G["LootButton"..index.."Count"];
				if ( quantity > 1 ) then
					countString:SetText(quantity);
					countString:Show();
				else
					countString:Hide();
				end
				button.slot = slot;
				button.quality = quality;
				button:Enable();
			else
				text:SetText("");
				_G["LootButton"..index.."IconTexture"]:SetTexture(nil);
				SetItemButtonNormalTextureVertexColor(button, 1.0, 1.0, 1.0);
				LootFrame:SetScript("OnUpdate", LootFrame_OnUpdate);
				button:Disable();
			end
			button:Show();
		else
			button:Hide();
		end
	else
		button:Hide();
	end
end

function LootFrame_Update()
	for index = 1, LOOTFRAME_NUMBUTTONS do
		LootFrame_UpdateButton(index);
	end
	if ( LootFrame.page == 1 ) then
		LootFrameUpButton:Hide();
		LootFramePrev:Hide();
	else
		LootFrameUpButton:Show();
		LootFramePrev:Show();
	end
	local numItemsPerPage = LOOTFRAME_NUMBUTTONS;
	if ( LootFrame.numLootItems > LOOTFRAME_NUMBUTTONS ) then
		numItemsPerPage = numItemsPerPage - 1;
	end
	if ( LootFrame.page == ceil(LootFrame.numLootItems / numItemsPerPage) or LootFrame.numLootItems == 0 ) then
		LootFrameDownButton:Hide();
		LootFrameNext:Hide();
	else
		LootFrameDownButton:Show();
		LootFrameNext:Show();
	end
end

function LootFrame_InitAutoLootTable( self )
--	if( not self.AutoLootTable )then
--		self.AutoLootTable = GetLootInfo();
--	end
end

function LootFrame_Close()
	StaticPopup_Hide("LOOT_BIND");
	HideUIPanel(LootFrame);
end

function LootFrame_PageDown()
	LootFrame.page = LootFrame.page + 1;
	LootFrame_Update();
end

function LootFrame_PageUp()
	LootFrame.page = LootFrame.page - 1;
	LootFrame_Update();
end

function LootFrame_Show(self)
	self.numLootItems = GetNumLootItems();
	if(self.AutoLootTable) then
		self.numLootItems = #self.AutoLootTable;
	end

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

	LootFrame_Update();
	LootFramePortraitOverlay:SetTexture("Interface\\TargetingFrame\\TargetDead");
end

function LootFrame_OnShow(self)
	if( self.numLootItems == 0 ) then
		PlaySound(SOUNDKIT.LOOT_WINDOW_OPEN_EMPTY);
	elseif( IsFishingLoot() ) then
		PlaySound(SOUNDKIT.FISHING_REEL_IN);
		LootFramePortraitOverlay:SetTexture("Interface\\LootFrame\\FishingLoot-Icon");
	end
end

function LootFrame_OnHide(self)
	CloseLoot();
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");
	MasterLooterFrame:Hide();

	if( self.AutoLootTable )then
		self:SetScript("OnUpdate", nil);
		self.timeSinceUpdate = nil;
		self.AutoLootTable = nil;
	end
end

function LootButton_OnClick(self, button)
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");
	MasterLooterFrame:Hide();

	LootFrame.selectedLootButton = self:GetName();
	LootFrame.selectedSlot = self.slot;
	LootFrame.selectedQuality = self.quality;
	LootFrame.selectedItemName = _G[self:GetName().."Text"]:GetText();
	LootFrame.selectedTexture = _G[self:GetName().."IconTexture"]:GetTexture();
	LootSlot(self.slot);
end

function LootItem_OnEnter(self)
	local slot = ((LOOTFRAME_NUMBUTTONS - 1) * (LootFrame.page - 1)) + self:GetID();
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
end

function GroupLootContainer_OnLoad(self)
	self.rollFrames = {};
	self.reservedSize = 100;
	GroupLootContainer_CalcMaxIndex(self);
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
	--[[local info = UIDropDownMenu_CreateInfo();
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
	UIDropDownMenu_AddButton(info);]]

	-- Removing the Request Roll option but keeping the modern Master Loot UI, so we'll just shortcut straight to that.
	MasterLooterFrame_Show();
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
	self.Name:SetText(name);
	local color = ITEM_QUALITY_COLORS[quality];
	self.Name:SetVertexColor(color.r, color.g, color.b);
	
	if (bindOnPickUp) then
		self:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } } );
		_G[self:GetName().."Corner"]:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Corner");
		_G[self:GetName().."Decoration"]:Show();
	else
		self:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } } );
		_G[self:GetName().."Corner"]:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner");
		_G[self:GetName().."Decoration"]:Hide();
	end

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
