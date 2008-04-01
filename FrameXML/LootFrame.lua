LOOTFRAME_NUMBUTTONS = 4;
NUM_GROUP_LOOT_FRAMES = 4;

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
		if ( not this:IsVisible() ) then
			CloseLoot(1);	-- The parameter tells code that we were unable to open the UI
		end
		return;
	end
	if ( event == "LOOT_SLOT_CLEARED" ) then
		if ( not this:IsVisible() ) then
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
	for index = 1, LOOTFRAME_NUMBUTTONS, 1 do
		button = getglobal("LootButton"..index);
		local slot = (numLootToShow * (LootFrame.page - 1)) + index;
		if ( slot <= numLootItems ) then	
			if ( (LootSlotIsItem(slot) or LootSlotIsCoin(slot)) and index <= numLootToShow ) then
				texture, item, quantity, quality = GetLootSlotInfo(slot);
				color = ITEM_QUALITY_COLORS[quality];
				getglobal("LootButton"..index.."IconTexture"):SetTexture(texture);
				getglobal("LootButton"..index.."Text"):SetText(item);
				getglobal("LootButton"..index.."Text"):SetVertexColor(color.r, color.g, color.b);

				countString = getglobal("LootButton"..index.."Count");
				if ( quantity > 1 ) then
					countString:SetText(quantity);
					countString:Show();
				else
					countString:Hide();
				end
				button:SetSlot(slot);
				button.slot = slot;
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
end

function LootFrameItem_OnClick(button)
	if ( button == "LeftButton" ) then
		if ( IsShiftKeyDown() ) then
			if ( ChatFrameEditBox:IsVisible() ) then
				ChatFrameEditBox:Insert(GetLootSlotLink(this:GetID()));
			end
		end
	end
	LootFrame.selectedLootButton = this:GetName();
	LootFrame.selectedSlot = this.slot;
end

function GroupLootDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, GroupLootDropDown_Initialize, "MENU");
end

function GroupLootDropDown_Initialize()
	local candidate, info;
	
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		local lastIndex = UIDROPDOWNMENU_MENU_VALUE + 5 - 1;
		for i=UIDROPDOWNMENU_MENU_VALUE, lastIndex do
			candidate = GetMasterLootCandidate(i);
			if ( candidate ) then
				-- Add candidate button
				info = {};
				info.text = candidate;
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
		info = {};
		info.text = GIVE_LOOT;
		info.notCheckable = 1;
		info.isTitle = 1;
		UIDropDownMenu_AddButton(info);
		for i=1, 40, 5 do
			for j=i, i+4 do
				candidate = GetMasterLootCandidate(j);
				if ( candidate ) then
					-- Add raid group
					info = {};
					info.text = GROUP.." "..ceil(i/5);
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
				info = {};
				info.text = candidate;
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
	GiveMasterLoot(LootFrame.selectedSlot, this.value);
end

function GroupLootFrame_OpenNewFrame(id)
	local frame;
	for i=1, NUM_GROUP_LOOT_FRAMES do
		frame = getglobal("GroupLootFrame"..i);
		if ( not frame:IsVisible() ) then
			frame.rollID = id;
			frame:Show();
			return;
		end
	end
end

function GroupLootFrame_OnShow()
	local texture, name, count, quality = GetLootRollItemInfo(this.rollID);
	getglobal("GroupLootFrame"..this:GetID().."IconFrameIcon"):SetTexture(texture);
	getglobal("GroupLootFrame"..this:GetID().."Name"):SetText(name);
	local color = ITEM_QUALITY_COLORS[quality];
	getglobal("GroupLootFrame"..this:GetID().."Name"):SetVertexColor(color.r, color.g, color.b);
end

function GroupLootFrame_OnEvent()
	if ( event == "CANCEL_LOOT_ROLL" ) then
		if ( arg1 == this.rollID ) then
			this:Hide();
		end
	end
end

function GroupLootFrame_OnUpdate()
	if ( this:IsVisible() ) then
		local left = GetLootRollTimeLeft(this:GetParent().rollID);
		local min, max = this:GetMinMaxValues();
		if ( (left < min) or (left > max) ) then
			left = min;
		end
		this:SetValue(left);
	end
end