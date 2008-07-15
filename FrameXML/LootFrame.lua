LOOTFRAME_NUMBUTTONS = 4;
NUM_GROUP_LOOT_FRAMES = 4;
MASTER_LOOT_THREHOLD = 4;

function LootFrame_OnLoad()
	this:RegisterEvent("LOOT_OPENED");
	this:RegisterEvent("LOOT_SLOT_CLEARED");
	this:RegisterEvent("LOOT_CLOSED");
	this:RegisterEvent("OPEN_MASTER_LOOT_LIST");
	this:RegisterEvent("UPDATE_MASTER_LOOT_LIST");
end

function LootFrame_OnEvent(event)
	if ( event == "LOOT_OPENED" ) then
		this.page = 1;
		ShowUIPanel(this);
		local autoLoot = arg1;
		if ( not this:IsShown()) then
			CloseLoot(autoLoot == 0);	-- The parameter tells code that we were unable to open the UI
		end
	end

	if ( event == "LOOT_SLOT_CLEARED" ) then
		if ( not this:IsShown() ) then
			return;
		end

		local numLootToShow = LOOTFRAME_NUMBUTTONS;
		if ( this.numLootItems > LOOTFRAME_NUMBUTTONS ) then
			numLootToShow = numLootToShow - 1;
		end
		local slot = arg1 - ((this.page - 1) * numLootToShow);
		if ( (slot > 0) and (slot < (numLootToShow + 1)) ) then
			local button = getglobal("LootButton"..slot);
			if ( button ) then
				button:Hide();
			end
		end
		-- try to move second page of loot items to the first page
		local button;
		local allButtonsHidden = 1;

		for index = 1, LOOTFRAME_NUMBUTTONS do
			button = getglobal("LootButton"..index);
			if ( button:IsShown() ) then
				allButtonsHidden = nil;
			end
		end
		if ( allButtonsHidden and LootFrameDownButton:IsShown() ) then
			LootFrame_PageDown();
		end
		return;
	end
	if ( event == "LOOT_CLOSED" ) then
		StaticPopup_Hide("LOOT_BIND");
		HideUIPanel(this);
		return;
	end
	if ( event == "OPEN_MASTER_LOOT_LIST" ) then
		ToggleDropDownMenu(1, nil, GroupLootDropDown, LootFrame.selectedLootButton, 0, 0);
		return;
	end
	if ( event == "UPDATE_MASTER_LOOT_LIST" ) then
		UIDropDownMenu_Refresh(GroupLootDropDown);
	end
end

function LootFrame_Update()
	local numLootItems = LootFrame.numLootItems;
	--Logic to determine how many items to show per page
	local numLootToShow = LOOTFRAME_NUMBUTTONS;
	if ( numLootItems > LOOTFRAME_NUMBUTTONS ) then
		numLootToShow = numLootToShow - 1;
	end
	local texture, item, quantity, quality;
	local button, countString, color;
	for index = 1, LOOTFRAME_NUMBUTTONS do
		button = getglobal("LootButton"..index);
		local slot = (numLootToShow * (LootFrame.page - 1)) + index;
		if ( slot <= numLootItems ) then	
			if ( (LootSlotIsItem(slot) or LootSlotIsCoin(slot)) and index <= numLootToShow ) then
				texture, item, quantity, quality, locked = GetLootSlotInfo(slot);
				color = ITEM_QUALITY_COLORS[quality];
				getglobal("LootButton"..index.."IconTexture"):SetTexture(texture);
				local text = getglobal("LootButton"..index.."Text");
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
				countString = getglobal("LootButton"..index.."Count");
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
	if ( LootFrame.page == 1 ) then
		LootFrameUpButton:Hide();
		LootFramePrev:Hide();
	else
		LootFrameUpButton:Show();
		LootFramePrev:Show();
	end
	if ( LootFrame.page == ceil(LootFrame.numLootItems / numLootToShow) or LootFrame.numLootItems == 0 ) then
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

function LootFrame_OnShow()
	this.numLootItems = GetNumLootItems();
	
	if ( GetCVar("lootUnderMouse") == "1" ) then
		-- position loot window under mouse cursor		
		local x, y = GetCursorPosition();
		x = x / this:GetEffectiveScale();
		y = y / this:GetEffectiveScale();

		local posX = x - 175;
		local posY = y + 25;
		
		if (this.numLootItems > 0) then
			posX = x - 40;
			posY = y + 55;
			posY = posY + 40;
		end

		if( posY < 350 ) then
			posY = 350;
		end

		this:ClearAllPoints();
		this:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", posX, posY);
		this:GetCenter();
		this:Raise();
	end
	
	LootFrame_Update();
	LootFramePortraitOverlay:SetTexture("Interface\\TargetingFrame\\TargetDead");
	if( this.numLootItems == 0 ) then
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

function LootButton_OnClick(button)
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");
	
	LootFrame.selectedLootButton = this:GetName();
	LootFrame.selectedSlot = this.slot;
	LootFrame.selectedQuality = this.quality;
	LootFrame.selectedItemName = getglobal(this:GetName().."Text"):GetText();

	LootSlot(this.slot);
end

function LootItem_OnEnter()
	local slot = ((LOOTFRAME_NUMBUTTONS - 1) * (LootFrame.page - 1)) + this:GetID();
	if ( LootSlotIsItem(slot) ) then
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
		GameTooltip:SetLootItem(slot);
		CursorUpdate();
	end
end

function GroupLootDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, GroupLootDropDown_Initialize, "MENU");
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
				info.textHeight = 12;
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
		info.textHeight = 12;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);

		for i=1, 40, 5 do
			for j=i, i+4 do
				candidate = GetMasterLootCandidate(j);
				if ( candidate ) then
					-- Add raid group
					info.isTitle = nil;
					info.text = GROUP.." "..ceil(i/5);
					info.textHeight = 12;
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
				info.textHeight = 12;
				info.value = i;
				info.notCheckable = 1;
				info.value = i;
				info.func = GroupLootDropDown_GiveLoot;
				UIDropDownMenu_AddButton(info);
			end
		end
	end
end

function GroupLootDropDown_GiveLoot()
	if ( LootFrame.selectedQuality >= MASTER_LOOT_THREHOLD ) then
		local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex..LootFrame.selectedItemName..FONT_COLOR_CODE_CLOSE, this:GetText());
		if ( dialog ) then
			dialog.data = this.value;
		end
	else
		GiveMasterLoot(LootFrame.selectedSlot, this.value);
	end
	CloseDropDownMenus();
end

function GroupLootFrame_OpenNewFrame(id, rollTime)
	local frame;
	for i=1, NUM_GROUP_LOOT_FRAMES do
		frame = getglobal("GroupLootFrame"..i);
		if ( not frame:IsShown() ) then
			frame.rollID = id;
			frame.rollTime = rollTime;
			getglobal("GroupLootFrame"..i.."Timer"):SetMinMaxValues(0, rollTime);
			frame:Show();
			return;
		end
	end
end

function GroupLootFrame_OnShow()
	local texture, name, count, quality, bindOnPickUp = GetLootRollItemInfo(this.rollID);
	
	if ( bindOnPickUp ) then
		this:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } } );
		getglobal(this:GetName().."Corner"):SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Corner");
		getglobal(this:GetName().."Decoration"):Show();
	else 
		this:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } } );
		getglobal(this:GetName().."Corner"):SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner");
		getglobal(this:GetName().."Decoration"):Hide();
	end
	
	getglobal("GroupLootFrame"..this:GetID().."IconFrameIcon"):SetTexture(texture);
	getglobal("GroupLootFrame"..this:GetID().."Name"):SetText(name);
	local color = ITEM_QUALITY_COLORS[quality];
	getglobal("GroupLootFrame"..this:GetID().."Name"):SetVertexColor(color.r, color.g, color.b);
end

function GroupLootFrame_OnEvent()
	if ( event == "CANCEL_LOOT_ROLL" ) then
		if ( arg1 == this.rollID ) then
			this:Hide();
			StaticPopup_Hide("CONFIRM_LOOT_ROLL", this.rollID);
		end
	end
end

function GroupLootFrame_OnUpdate()
	local left = GetLootRollTimeLeft(this:GetParent().rollID);
	local min, max = this:GetMinMaxValues();
	if ( (left < min) or (left > max) ) then
		left = min;
	end
	this:SetValue(left);
end
