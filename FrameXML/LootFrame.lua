LOOTFRAME_NUMBUTTONS = 4;
NUM_GROUP_LOOT_FRAMES = 4;
MASTER_LOOT_THREHOLD = 4;

function LootFrame_OnLoad(self)
	self:RegisterEvent("LOOT_OPENED");
	self:RegisterEvent("LOOT_SLOT_CLEARED");
	self:RegisterEvent("LOOT_SLOT_CHANGED");
	self:RegisterEvent("LOOT_CLOSED");
	self:RegisterEvent("OPEN_MASTER_LOOT_LIST");
	self:RegisterEvent("UPDATE_MASTER_LOOT_LIST");
end

function LootFrame_OnEvent(self, event, ...)
	if ( event == "LOOT_OPENED" ) then
		local autoLoot = ...;
		
		self.page = 1;
		LootFrame_Show(self);
		if ( not self:IsShown()) then
			CloseLoot(autoLoot == 0);	-- The parameter tells code that we were unable to open the UI
		end
	elseif ( event == "LOOT_SLOT_CLEARED" ) then
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
		StaticPopup_Hide("LOOT_BIND");
		HideUIPanel(self);
		return;
	elseif ( event == "OPEN_MASTER_LOOT_LIST" ) then
		ToggleDropDownMenu(1, nil, GroupLootDropDown, LootFrame.selectedLootButton, 0, 0);
		return;
	elseif ( event == "UPDATE_MASTER_LOOT_LIST" ) then
		UIDropDownMenu_Refresh(GroupLootDropDown);
	end
end

function LootFrame_UpdateButton(index)
	local numLootItems = LootFrame.numLootItems;
	--Logic to determine how many items to show per page
	local numLootToShow = LOOTFRAME_NUMBUTTONS;
	if ( numLootItems > LOOTFRAME_NUMBUTTONS ) then
		numLootToShow = numLootToShow - 1;
	end
	
	local button = _G["LootButton"..index];
		local slot = (numLootToShow * (LootFrame.page - 1)) + index;
		if ( slot <= numLootItems ) then	
			if ( (LootSlotIsItem(slot) or LootSlotIsCoin(slot)) and index <= numLootToShow ) then
				local texture, item, quantity, quality, locked = GetLootSlotInfo(slot);
				local color = ITEM_QUALITY_COLORS[quality];
				_G["LootButton"..index.."IconTexture"]:SetTexture(texture);
				local text = _G["LootButton"..index.."Text"];
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

function LootFrame_PageDown()
	LootFrame.page = LootFrame.page + 1;
	LootFrame_Update();
end

function LootFrame_PageUp()
	LootFrame.page = LootFrame.page - 1;
	LootFrame_Update();
end

function LootFrame_Show(self)
	ShowUIPanel(self);
	self.numLootItems = GetNumLootItems();
	
	if ( GetCVar("lootUnderMouse") == "1" ) then
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
	end
	
	LootFrame_Update();
	LootFramePortraitOverlay:SetTexture("Interface\\TargetingFrame\\TargetDead");
end

function LootFrame_OnShow(self)
	if( self.numLootItems == 0 ) then
		PlaySound("LOOTWINDOWOPENEMPTY");
	elseif( IsFishingLoot() ) then
		PlaySound("FISHING REEL IN");
		LootFramePortraitOverlay:SetTexture("Interface\\LootFrame\\FishingLoot-Icon");
	end
end

function LootFrame_OnHide()
	CloseLoot();
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");
end

function LootButton_OnClick(self, button)
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");
	
	LootFrame.selectedLootButton = self:GetName();
	LootFrame.selectedSlot = self.slot;
	LootFrame.selectedQuality = self.quality;
	LootFrame.selectedItemName = _G[self:GetName().."Text"]:GetText();

	LootSlot(self.slot);
end

function LootItem_OnEnter(self)
	local slot = ((LOOTFRAME_NUMBUTTONS - 1) * (LootFrame.page - 1)) + self:GetID();
	if ( LootSlotIsItem(slot) ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetLootItem(slot);
		CursorUpdate(self);
	end
end

function GroupLootDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, GroupLootDropDown_Initialize, "MENU");
end

function GroupLootDropDown_Initialize()
	local candidate;
	local info = UIDropDownMenu_CreateInfo();
	
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		local lastIndex = UIDROPDOWNMENU_MENU_VALUE + 5 - 1;
		for i=UIDROPDOWNMENU_MENU_VALUE, lastIndex do
			candidate = GetMasterLootCandidate(i);
			if ( candidate ) then
				-- Add candidate button
				info.text = candidate;
				info.fontObject = GameFontNormalLeft;
				info.value = i;
				info.notCheckable = 1;
				info.func = GroupLootDropDown_GiveLoot;
				UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
		return;
	end
	
	if ( GetNumRaidMembers() > 0 ) then
		-- In a raid
		info.isTitle = 1;
		info.text = GIVE_LOOT;
		info.fontObject = GameFontNormalLeft;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);

		for i=1, 40, 5 do
			for j=i, i+4 do
				candidate = GetMasterLootCandidate(j);
				if ( candidate ) then
					-- Add raid group
					info.isTitle = nil;
					info.text = GROUP.." "..ceil(i/5);
					info.fontObject = GameFontNormalLeft;
					info.hasArrow = 1;
					info.notCheckable = 1;
					info.value = j;
					info.func = nil;
					UIDropDownMenu_AddButton(info);
					break;
				end
			end
		end
	else
		-- In a party
		for i=1, MAX_PARTY_MEMBERS+1, 1 do
			candidate = GetMasterLootCandidate(i);
			if ( candidate ) then
				-- Add candidate button
				info.text = candidate;
				info.fontObject = GameFontNormalLeft;
				info.value = i;
				info.notCheckable = 1;
				info.value = i;
				info.func = GroupLootDropDown_GiveLoot;
				UIDropDownMenu_AddButton(info);
			end
		end
	end
end

function GroupLootDropDown_GiveLoot(self)
	if ( LootFrame.selectedQuality >= MASTER_LOOT_THREHOLD ) then
		local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex..LootFrame.selectedItemName..FONT_COLOR_CODE_CLOSE, self:GetText());
		if ( dialog ) then
			dialog.data = self.value;
		end
	else
		GiveMasterLoot(LootFrame.selectedSlot, self.value);
	end
	CloseDropDownMenus();
end

function GroupLootFrame_OpenNewFrame(id, rollTime)
	local frame;
	for i=1, NUM_GROUP_LOOT_FRAMES do
		frame = _G["GroupLootFrame"..i];
		if ( not frame:IsShown() ) then
			frame.rollID = id;
			frame.rollTime = rollTime;
			_G["GroupLootFrame"..i.."Timer"]:SetMinMaxValues(0, rollTime);
			frame:Show();
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
	AlertFrame_FixAnchors();
	local texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired = GetLootRollItemInfo(self.rollID);
	if (name == nil) then
		self:Hide();
		return;
	end
	if ( bindOnPickUp ) then
		self:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } } );
		_G[self:GetName().."Corner"]:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Corner");
		_G[self:GetName().."Decoration"]:Show();
	else 
		self:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } } );
		_G[self:GetName().."Corner"]:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner");
		_G[self:GetName().."Decoration"]:Hide();
	end
	
	local id = self:GetID();
	_G["GroupLootFrame"..id.."IconFrameIcon"]:SetTexture(texture);
	_G["GroupLootFrame"..id.."Name"]:SetText(name);
	local color = ITEM_QUALITY_COLORS[quality];
	_G["GroupLootFrame"..id.."Name"]:SetVertexColor(color.r, color.g, color.b);
	if ( count > 1 ) then
		_G["GroupLootFrame"..id.."IconFrameCount"]:SetText(count);
		_G["GroupLootFrame"..id.."IconFrameCount"]:Show();
	else
		_G["GroupLootFrame"..id.."IconFrameCount"]:Hide();
	end
	
	if ( canNeed ) then
		GroupLootFrame_EnableLootButton(self.needButton);
		self.needButton.reason = nil;
	else
		GroupLootFrame_DisableLootButton(self.needButton);
		self.needButton.reason = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonNeed];
	end
	if ( canGreed) then
		GroupLootFrame_EnableLootButton(self.greedButton);
		self.greedButton.reason = nil;
	else
		GroupLootFrame_DisableLootButton(self.greedButton);
		self.greedButton.reason = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonGreed];
	end
	if ( canDisenchant) then
		GroupLootFrame_EnableLootButton(self.disenchantButton);
		self.disenchantButton.reason = nil;
	else
		GroupLootFrame_DisableLootButton(self.disenchantButton);
		self.disenchantButton.reason = format(_G["LOOT_ROLL_INELIGIBLE_REASON"..reasonDisenchant], deSkillRequired);
	end
end

function GroupLootFrame_OnHide (self)
	AlertFrame_FixAnchors();
end

function GroupLootFrame_OnEvent(self, event, ...)
	if ( event == "CANCEL_LOOT_ROLL" ) then
		local arg1 = ...;
		if ( arg1 == self.rollID ) then
			self:Hide();
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
