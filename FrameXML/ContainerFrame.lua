NUM_CONTAINER_FRAMES = 12;
NUM_BAG_FRAMES = 4;
MAX_CONTAINER_ITEMS = 36;
NUM_CONTAINER_COLUMNS = 4;
ROWS_IN_BG_TEXTURE = 6;
MAX_BG_TEXTURES = 2;
BG_TEXTURE_HEIGHT = 512;
CONTAINER_WIDTH = 192;
CONTAINER_SPACING = 0;
VISIBLE_CONTAINER_SPACING = 3;
CONTAINER_OFFSET_Y = 70;
CONTAINER_OFFSET_X = 0;
CONTAINER_SCALE = 0.90;

function ContainerFrame_OnLoad()
	this:RegisterEvent("BAG_UPDATE");
	this:RegisterEvent("BAG_CLOSED");
	this:RegisterEvent("BAG_OPEN");
	this:RegisterEvent("BAG_UPDATE_COOLDOWN");
	this:RegisterEvent("ITEM_LOCK_CHANGED");
	this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
	ContainerFrame1.bagsShown = 0;
	ContainerFrame1.bags = {};
end

function ContainerFrame_OnEvent()
	if ( event == "BAG_UPDATE" ) then
		if ( this:IsShown() and this:GetID() == arg1 ) then
 			ContainerFrame_Update(this);
		end
	elseif ( event == "BAG_CLOSED" ) then
		if ( this:GetID() == arg1 ) then
			this:Hide();
		end
	elseif ( event == "BAG_OPEN" ) then
		if ( this:GetID() == arg1 ) then
			this:Show();
		end
	elseif ( event == "ITEM_LOCK_CHANGED" or event == "BAG_UPDATE_COOLDOWN" or event == "UPDATE_INVENTORY_ALERTS" ) then
		if ( this:IsShown() ) then
			ContainerFrame_Update(this);
		end
	end
end

function ToggleBag(id)
	if ( IsOptionFrameOpen() ) then
		return;
	end
	
	local size = GetContainerNumSlots(id);
	if ( size > 0 or id == KEYRING_CONTAINER ) then
		local containerShowing;
		for i=1, NUM_CONTAINER_FRAMES, 1 do
			local frame = getglobal("ContainerFrame"..i);
			if ( frame:IsShown() and frame:GetID() == id ) then
				containerShowing = i;
				frame:Hide();
			end
		end
		if ( not containerShowing ) then
			ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), size, id);
		end
	end
end

function ToggleBackpack()
	if ( IsOptionFrameOpen() ) then
		return;
	end
	
	if ( IsBagOpen(0) ) then
		for i=1, NUM_CONTAINER_FRAMES, 1 do
			local frame = getglobal("ContainerFrame"..i);
			if ( frame:IsShown() ) then
				frame:Hide();
			end
		end
	else
		ToggleBag(0);
	end
end

function ContainerFrame_OnHide()
	if ( this:GetID() == 0 ) then
		MainMenuBarBackpackButton:SetChecked(0);
	else
		local bagButton = getglobal("CharacterBag"..(this:GetID() - 1).."Slot");
		if ( bagButton ) then
			bagButton:SetChecked(0);
		else
			-- If its a bank bag then update its highlight
			
			UpdateBagButtonHighlight(this:GetID()); 
		end
	end
	ContainerFrame1.bagsShown = ContainerFrame1.bagsShown - 1;
	-- Remove the closed bag from the list and collapse the rest of the entries
	local index = 1;
	while ContainerFrame1.bags[index] do
		if ( ContainerFrame1.bags[index] == this:GetName() ) then
			local tempIndex = index;
			while ContainerFrame1.bags[tempIndex] do
				if ( ContainerFrame1.bags[tempIndex + 1] ) then
					ContainerFrame1.bags[tempIndex] = ContainerFrame1.bags[tempIndex + 1];
				else
					ContainerFrame1.bags[tempIndex] = nil;
				end
				tempIndex = tempIndex + 1;
			end
		end
		index = index + 1;
	end
	updateContainerFrameAnchors();

	if ( this:GetID() == KEYRING_CONTAINER ) then
		UpdateMicroButtons();
		PlaySound("KeyRingClose");
	else
		PlaySound("igBackPackClose");
	end
end

function ContainerFrame_OnShow()
	if ( this:GetID() == 0 ) then
		MainMenuBarBackpackButton:SetChecked(1);
	elseif ( this:GetID() <= NUM_BAG_SLOTS ) then 
		local button = getglobal("CharacterBag"..(this:GetID() - 1).."Slot");
		if ( button ) then
			button:SetChecked(1);
		end
	else
		UpdateBagButtonHighlight(this:GetID());
	end
	ContainerFrame1.bagsShown = ContainerFrame1.bagsShown + 1;
	if ( this:GetID() == KEYRING_CONTAINER ) then
		UpdateMicroButtons();
		PlaySound("KeyRingOpen");
	else
		PlaySound("igBackPackOpen");
	end
end

function OpenBag(id)
	if ( not CanOpenPanels() ) then
		if ( UnitIsDead("player") ) then
			NotWhileDeadError();
		end
		return;
	end

	local size = GetContainerNumSlots(id);
	if ( size > 0 ) then
		local containerShowing;
		for i=1, NUM_CONTAINER_FRAMES, 1 do
			local frame = getglobal("ContainerFrame"..i);
			if ( frame:IsShown() and frame:GetID() == id ) then
				containerShowing = i;
			end
		end
		if ( not containerShowing ) then
			ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), size, id);
		end
	end
end

function CloseBag(id)
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = getglobal("ContainerFrame"..i);
		if ( containerFrame:IsShown() and (containerFrame:GetID() == id) ) then
			containerFrame:Hide();
			return;
		end
	end
end

function IsBagOpen(id)
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = getglobal("ContainerFrame"..i);
		if ( containerFrame:IsShown() and (containerFrame:GetID() == id) ) then
			return i;
		end
	end
	return nil;
end

function OpenBackpack()
	if ( not CanOpenPanels() ) then
		if ( UnitIsDead("player") ) then
			NotWhileDeadError();
		end
		return;
	end

	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = getglobal("ContainerFrame"..i);
		if ( containerFrame:IsShown() and (containerFrame:GetID() == 0) ) then
			ContainerFrame1.backpackWasOpen = 1;
			return;
		else
			ContainerFrame1.backpackWasOpen = nil;
		end
	end

	if ( not ContainerFrame1.backpackWasOpen ) then
		ToggleBackpack();
	end
end

function CloseBackpack()
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = getglobal("ContainerFrame"..i);
		if ( containerFrame:IsShown() and (containerFrame:GetID() == 0) and (ContainerFrame1.backpackWasOpen == nil) ) then
			containerFrame:Hide();
			return;
		end
	end
end

function ContainerFrame_GetOpenFrame()
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = getglobal("ContainerFrame"..i);
		if ( not frame:IsShown() ) then
			return frame;
		end
		-- If all frames open return the last frame
		if ( i == NUM_CONTAINER_FRAMES ) then
			frame:Hide();
			return frame;
		end
	end
end

function ContainerFrame_Update(frame)
	local id = frame:GetID();
	local name = frame:GetName();
	local texture, itemCount, locked, quality, readable;
	for j=1, frame.size, 1 do
		local itemButton = getglobal(name.."Item"..j);
		
		texture, itemCount, locked, quality, readable = GetContainerItemInfo(id, itemButton:GetID());
		
		SetItemButtonTexture(itemButton, texture);
		SetItemButtonCount(itemButton, itemCount);

		SetItemButtonDesaturated(itemButton, locked, 0.5, 0.5, 0.5);
		
		if ( texture ) then
			ContainerFrame_UpdateCooldown(id, itemButton);
			itemButton.hasItem = 1;
		else
			getglobal(name.."Item"..j.."Cooldown"):Hide();
			itemButton.hasItem = nil;
		end

		itemButton.readable = readable;
		--local normalTexture = getglobal(name.."Item"..j.."NormalTexture");
		--if ( quality and quality ~= -1) then
		--	local color = getglobal("ITEM_QUALITY".. quality .."_COLOR");
		--	normalTexture:SetVertexColor(color.r, color.g, color.b);
		--else
		--	normalTexture:SetVertexColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
		--end
		local showSell = nil;
		if ( GameTooltip:IsOwned(itemButton) ) then
			if ( texture ) then
				local hasCooldown, repairCost = GameTooltip:SetBagItem(itemButton:GetParent():GetID(),itemButton:GetID());
				--[[if ( hasCooldown ) then
					itemButton.updateTooltip = TOOLTIP_UPDATE_TIME;
				else
					itemButton.updateTooltip = nil;
				end
				]]
				if ( InRepairMode() and (repairCost > 0) ) then
					GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1);
					SetTooltipMoney(GameTooltip, repairCost);
					GameTooltip:Show();
				elseif ( MerchantFrame:IsShown() and not locked) then
					showSell = 1;
				end
			else
				GameTooltip:Hide();
			end
			if ( showSell ) then
				ShowContainerSellCursor(itemButton:GetParent():GetID(), itemButton:GetID());
			elseif ( readable ) then
				ShowInspectCursor();
			else
				ResetCursor();
			end
		end
	end
end

function ContainerFrame_UpdateCooldown(container, button)
	local cooldown = getglobal(button:GetName().."Cooldown");
	local start, duration, enable = GetContainerItemCooldown(container, button:GetID());
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
	if ( duration > 0 and enable == 0 ) then
		SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4);
	end
end

function ContainerFrame_GenerateFrame(frame, size, id)
	frame.size = size;
	local name = frame:GetName();
	local bgTextureTop = getglobal(name.."BackgroundTop");
	local bgTextureMiddle = getglobal(name.."BackgroundMiddle1");
	local bgTextureBottom = getglobal(name.."BackgroundBottom");
	local columns = NUM_CONTAINER_COLUMNS;
	local rows = ceil(size / columns);
	-- if size = 0 then its the backpack
	if ( id == 0 ) then
		getglobal(name.."MoneyFrame"):Show();
		-- Set Backpack texture
		bgTextureTop:SetTexture("Interface\\ContainerFrame\\UI-BackpackBackground");
		bgTextureTop:SetHeight(256);
		bgTextureTop:SetTexCoord(0, 1, 0, 1);
		
		-- Hide unused textures
		for i=1, MAX_BG_TEXTURES do
			getglobal(name.."BackgroundMiddle"..i):Hide();
		end
		bgTextureBottom:Hide();
		frame:SetHeight(240);
	else
		-- Not the backpack
		-- Set whether or not its a bank bag
		local bagTextureSuffix = "";
		if ( id > NUM_BAG_FRAMES ) then
			bagTextureSuffix = "-Bank";
		elseif ( id == KEYRING_CONTAINER ) then
			bagTextureSuffix = "-Keyring";
		end
		-- Set textures
		bgTextureTop:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components"..bagTextureSuffix);
		for i=1, MAX_BG_TEXTURES do
			getglobal(name.."BackgroundMiddle"..i):SetTexture("Interface\\ContainerFrame\\UI-Bag-Components"..bagTextureSuffix);
			getglobal(name.."BackgroundMiddle"..i):Hide();
		end
		bgTextureBottom:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components"..bagTextureSuffix);
		-- Hide the moneyframe since its not the backpack
		getglobal(name.."MoneyFrame"):Hide();	
		
		local bgTextureCount, height;
		local rowHeight = 41;
		-- Subtract one, since the top texture contains one row already
		local remainingRows = rows-1;

		-- See if the bag needs the texture with two slots at the top
		local isPlusTwoBag;
		if ( mod(size,columns) == 2 ) then
			isPlusTwoBag = 1;
		end

		-- Bag background display stuff
		if ( isPlusTwoBag ) then
			bgTextureTop:SetTexCoord(0, 1, 0.189453125, 0.330078125);
			bgTextureTop:SetHeight(72);
		else
			if ( rows == 1 ) then
				-- If only one row chop off the bottom of the texture
				bgTextureTop:SetTexCoord(0, 1, 0.00390625, 0.16796875);
				bgTextureTop:SetHeight(86);
			else
				bgTextureTop:SetTexCoord(0, 1, 0.00390625, 0.18359375);
				bgTextureTop:SetHeight(94);
			end
		end
		-- Calculate the number of background textures we're going to need
		bgTextureCount = ceil(remainingRows/ROWS_IN_BG_TEXTURE);
		
		local middleBgHeight = 0;
		-- If one row only special case
		if ( rows == 1 ) then
			bgTextureBottom:SetPoint("TOP", bgTextureMiddle:GetName(), "TOP", 0, 0);
			bgTextureBottom:Show();
			-- Hide middle bg textures
			for i=1, MAX_BG_TEXTURES do
				getglobal(name.."BackgroundMiddle"..i):Hide();
			end
		else
			-- Try to cycle all the middle bg textures
			local firstRowPixelOffset = 9;
			local firstRowTexCoordOffset = 0.353515625;
			for i=1, bgTextureCount do
				bgTextureMiddle = getglobal(name.."BackgroundMiddle"..i);
				if ( remainingRows > ROWS_IN_BG_TEXTURE ) then
					-- If more rows left to draw than can fit in a texture then draw the max possible
					height = ( ROWS_IN_BG_TEXTURE*rowHeight ) + firstRowTexCoordOffset;
					bgTextureMiddle:SetHeight(height);
					bgTextureMiddle:SetTexCoord(0, 1, firstRowTexCoordOffset, ( height/BG_TEXTURE_HEIGHT + firstRowTexCoordOffset) );
					bgTextureMiddle:Show();
					remainingRows = remainingRows - ROWS_IN_BG_TEXTURE;
					middleBgHeight = middleBgHeight + height;
				else
					-- If not its a huge bag
					bgTextureMiddle:Show();
					height = remainingRows*rowHeight-firstRowPixelOffset;
					bgTextureMiddle:SetHeight(height);
					bgTextureMiddle:SetTexCoord(0, 1, firstRowTexCoordOffset, ( height/BG_TEXTURE_HEIGHT + firstRowTexCoordOffset) );
					middleBgHeight = middleBgHeight + height;
				end
			end
			-- Position bottom texture
			bgTextureBottom:SetPoint("TOP", bgTextureMiddle:GetName(), "BOTTOM", 0, 0);
			bgTextureBottom:Show();
		end
		-- Set the frame height
		frame:SetHeight(bgTextureTop:GetHeight()+bgTextureBottom:GetHeight()+middleBgHeight);	
	end
	frame:SetWidth(CONTAINER_WIDTH);
	frame:SetID(id);
	getglobal(frame:GetName().."PortraitButton"):SetID(id);
	
	--Special case code for keyrings
	if ( id == KEYRING_CONTAINER ) then
		getglobal(frame:GetName().."Name"):SetText(KEYRING);
		SetPortraitToTexture(frame:GetName().."Portrait", "Interface\\ContainerFrame\\KeyRing-Bag-Icon");
	else
		getglobal(frame:GetName().."Name"):SetText(GetBagName(id));
		SetBagPortaitTexture(getglobal(frame:GetName().."Portrait"), id);
	end
	
	for j=1, size, 1 do
		local index = size - j + 1;
		local itemButton =getglobal(name.."Item"..j);
		itemButton:SetID(index);
		-- Set first button
		if ( j == 1 ) then
			-- Anchor the first item differently if its the backpack frame
			if ( id == 0 ) then
				itemButton:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", -12, 30);
			else
				itemButton:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", -12, 9);
			end
			
		else
			if ( mod((j-1), columns) == 0 ) then
				itemButton:SetPoint("BOTTOMRIGHT", name.."Item"..(j - columns), "TOPRIGHT", 0, 4);	
			else
				itemButton:SetPoint("BOTTOMRIGHT", name.."Item"..(j - 1), "BOTTOMLEFT", -5, 0);	
			end
		end

		local texture, itemCount, locked, quality, readable = GetContainerItemInfo(id, index);
		SetItemButtonTexture(itemButton, texture);
		SetItemButtonCount(itemButton, itemCount);
		SetItemButtonDesaturated(itemButton, locked, 0.5, 0.5, 0.5);

		if ( texture ) then
			ContainerFrame_UpdateCooldown(id, itemButton);
			itemButton.hasItem = 1;
		else
			getglobal(name.."Item"..j.."Cooldown"):Hide();
			itemButton.hasItem = nil;
		end
		
		itemButton.readable = readable;
		itemButton:Show();
	end
	for j=size + 1, MAX_CONTAINER_ITEMS, 1 do
		getglobal(name.."Item"..j):Hide();
	end
	
	-- Add the bag to the baglist
	ContainerFrame1.bags[ContainerFrame1.bagsShown + 1] = frame:GetName();
	updateContainerFrameAnchors();
	frame:Show();
end

function updateContainerFrameAnchors()
	-- Adjust the start anchor for bags depending on the multibars
	local shrinkFrames, frame;
	local xOffset = CONTAINER_OFFSET_X;
	local yOffset = CONTAINER_OFFSET_Y;
	local screenHeight = GetScreenHeight();
	local containerScale = CONTAINER_SCALE;
	local freeScreenHeight = screenHeight - yOffset;
	local index = 1;
	local column = 0;
	local uiScale = 1;
	if ( GetCVar("useUiScale") == "1" ) then
		uiScale = GetCVar("uiscale") + 0;
		if ( uiScale > containerScale ) then
			containerScale = uiScale * containerScale;
		end
	end
	while ContainerFrame1.bags[index] do
		frame = getglobal(ContainerFrame1.bags[index]);
		frame:SetScale(1);
		-- freeScreenHeight determines when to start a new column of bags
		if ( index == 1 ) then
			-- First bag
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, yOffset );
		elseif ( freeScreenHeight < frame:GetHeight() ) then
			-- Start a new column
			column = column + 1;
			freeScreenHeight = screenHeight - yOffset;
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -(column * CONTAINER_WIDTH) - xOffset, yOffset );
		else
			-- Anchor to the previous bag
			frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING);	
		end
		if ( frame:GetLeft() < ( BankFrame:GetRight() - 45 ) ) then 
			if ( frame:GetTop() > ( BankFrame:GetBottom() + 50 ) ) then
				shrinkFrames = 1;
				break;
			end
		end
		freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING;
		index = index + 1;
	end
	if ( shrinkFrames ) then
		screenHeight = screenHeight / containerScale;
		xOffset = xOffset / containerScale; 
		yOffset = yOffset / containerScale; 
		freeScreenHeight = screenHeight - yOffset;
		index = 1;
		column = 0;
		while ContainerFrame1.bags[index] do
			frame = getglobal(ContainerFrame1.bags[index]);
			frame:SetScale(containerScale);
			if ( index == 1 ) then
				-- First bag
				frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, yOffset );
			elseif ( freeScreenHeight < frame:GetHeight() ) then
				-- Start a new column
				column = column + 1;
				freeScreenHeight = screenHeight - yOffset;
				frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -(column * CONTAINER_WIDTH) - xOffset, yOffset );
			else
				-- Anchor to the previous bag
				frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING);	
			end
			freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING;
			index = index + 1;
		end
	end
	-- This is used to position the unit tooltip
	--[[
	local oldContainerPosition = OPEN_CONTAINER_POSITION;
	if ( index == 1 ) then
		DEFAULT_TOOLTIP_POSITION = -13;
	else
		DEFAULT_TOOLTIP_POSITION = -((column + 1) * CONTAINER_WIDTH) - xOffset;
	end
	if ( DEFAULT_TOOLTIP_POSITION ~= oldContainerPosition and GameTooltip.default and GameTooltip:IsShown() ) then
		GameTooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", DEFAULT_TOOLTIP_POSITION, 64);
	end
	]]
end

function ContainerFrameItemButton_OnLoad()
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	this:RegisterForDrag("LeftButton");

	this.SplitStack = function(button, split)
		SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
	end
end

function ContainerFrameItemButton_OnClick(button, ignoreModifiers)
	if ( button == "LeftButton" ) then
		if ( IsControlKeyDown() and not ignoreModifiers ) then
			DressUpItemLink(GetContainerItemLink(this:GetParent():GetID(), this:GetID()));
		elseif ( IsShiftKeyDown() and not ignoreModifiers ) then
			if ( ChatFrameEditBox:IsShown() ) then
				ChatFrameEditBox:Insert(GetContainerItemLink(this:GetParent():GetID(), this:GetID()));
			else
				local texture, itemCount, locked = GetContainerItemInfo(this:GetParent():GetID(), this:GetID());
				if ( not locked ) then
					this.SplitStack = function(button, split)
						SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
					end
					OpenStackSplitFrame(this.count, this, "BOTTOMRIGHT", "TOPRIGHT");
				end
			end
		else
			PickupContainerItem(this:GetParent():GetID(), this:GetID());
			StackSplitFrame:Hide();
		end
	else
		if ( IsControlKeyDown() and not ignoreModifiers ) then
			return;
		elseif ( IsShiftKeyDown() and MerchantFrame:IsShown() and not ignoreModifiers ) then
			this.SplitStack = function(button, split)
				SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
				MerchantItemButton_OnClick("LeftButton");
			end
			OpenStackSplitFrame(this.count, this, "BOTTOMRIGHT", "TOPRIGHT");
		elseif ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 2 ) then
			-- Don't sell the item if the buyback tab is selected
			return;
		else
			UseContainerItem(this:GetParent():GetID(), this:GetID());
			StackSplitFrame:Hide();
		end
	end
end

function ContainerFrameItemButton_OnEnter(button)
	if ( not button ) then
		button = this;
	end

	local x;
	x = button:GetRight();
	if ( x >= ( GetScreenWidth() / 2 ) ) then
		GameTooltip:SetOwner(button, "ANCHOR_LEFT");
	else
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
	end

	-- Keyring specific code
	if ( this:GetParent():GetID() == KEYRING_CONTAINER ) then
		GameTooltip:SetInventoryItem("player", KeyRingButtonIDToInvSlotID(this:GetID()));
		CursorUpdate();
		return;
	end

	local hasCooldown, repairCost = GameTooltip:SetBagItem(button:GetParent():GetID(),button:GetID());
	
	--[[
	Commented out to make dressup cursor work.
	if ( hasCooldown ) then
		button.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		button.updateTooltip = nil;
	end
	]]
	if ( InRepairMode() and (repairCost and repairCost > 0) ) then
		GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	elseif ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 ) then
		ShowContainerSellCursor(button:GetParent():GetID(),button:GetID());
	elseif ( this.readable or (IsControlKeyDown() and button.hasItem) ) then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function ContainerFrameItemButton_OnUpdate(elapsed)
	--[[
	Might hurt performance, but need to always update the cursor now
	if ( not this.updateTooltip ) then
		return;
	end

	this.updateTooltip = this.updateTooltip - elapsed;
	if ( this.updateTooltip > 0 ) then
		return;
	end
	]]
	if ( GameTooltip:IsOwned(this) ) then
		ContainerFrameItemButton_OnEnter();
	end
end

function OpenAllBags(forceOpen)
	if ( not UIParent:IsVisible() ) then
		return;
	end
	
	local bagsOpen = 0;
	local totalBags = 1;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = getglobal("ContainerFrame"..i);
		local bagButton = getglobal("CharacterBag"..(i -1).."Slot");
		if ( (i <= NUM_BAG_FRAMES) and GetContainerNumSlots(bagButton:GetID() - CharacterBag0Slot:GetID() + 1) > 0) then		
			totalBags = totalBags + 1;
		end
		if ( containerFrame:IsShown() ) then
			containerFrame:Hide();
			if ( containerFrame:GetID() ~= KEYRING_CONTAINER ) then
				bagsOpen = bagsOpen + 1;
			end
		end
	end
	if ( bagsOpen >= totalBags and not forceOpen ) then
		return;
	else
		ToggleBackpack();
		ToggleBag(1);
		ToggleBag(2);
		ToggleBag(3);
		ToggleBag(4);
		if ( BankFrame:IsVisible() ) then
			ToggleBag(5);
			ToggleBag(6);
			ToggleBag(7);
			ToggleBag(8);
			ToggleBag(9);
			ToggleBag(10);
		end
	end

end

function CloseAllBags()
	CloseBackpack();
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		CloseBag(i);
	end
end

--KeyRing functions
function KeyRingItemButton_OnClick(button)
	if ( button == "LeftButton" ) then
		if ( IsControlKeyDown() and not this.isBag ) then
			DressUpItemLink(GetContainerItemLink(KEYRING_CONTAINER, this:GetID()));
		elseif ( IsShiftKeyDown() and not this.isBag ) then
			if ( ChatFrameEditBox:IsVisible() ) then
				ChatFrameEditBox:Insert(GetContainerItemLink(KEYRING_CONTAINER, this:GetID()));
			else
				local texture, itemCount, locked = GetContainerItemInfo(KEYRING_CONTAINER, this:GetID());
				if ( not locked ) then
					OpenStackSplitFrame(this.count, this, "BOTTOMLEFT", "TOPLEFT");
				end
			end
		else
			PickupContainerItem(KEYRING_CONTAINER, this:GetID());
		end
	else
		if ( IsControlKeyDown() and not this.isBag ) then
			return;
		elseif ( IsShiftKeyDown() and not this.isBag ) then
			local texture, itemCount, locked = GetContainerItemInfo(KEYRING_CONTAINER, this:GetID());
			if ( not locked ) then
				OpenStackSplitFrame(this.count, this, "BOTTOMLEFT", "TOPLEFT");
			end
		else
			UseContainerItem(KEYRING_CONTAINER, this:GetID());
		end
	end
end

function PutKeyInKeyRing()
	local texture;
	local emptyKeyRingSlot;
	for i=1, GetKeyRingSize() do
		texture = GetContainerItemInfo(KEYRING_CONTAINER, i);
		if ( not texture ) then
			emptyKeyRingSlot = i;
			break;
		end
	end
	if ( emptyKeyRingSlot ) then
		PickupContainerItem(KEYRING_CONTAINER, emptyKeyRingSlot);
	else
		UIErrorsFrame:AddMessage(NO_EMPTY_KEYRING_SLOTS, 1.0, 0.1, 0.1, 1.0);
	end
end

function ToggleKeyRing()
	if ( IsOptionFrameOpen() ) then
		return;
	end
	
	local shownContainerID = IsBagOpen(KEYRING_CONTAINER);
	if ( shownContainerID ) then
		getglobal("ContainerFrame"..shownContainerID):Hide();
	else
		ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), GetKeyRingSize(), KEYRING_CONTAINER);

		-- Stop keyring button pulse
		SetButtonPulse(KeyRingButton, 0, 1);
	end
end

function GetKeyRingSize()
	local level = UnitLevel("player");
	local size;
	if ( level > 60 ) then
		size = 16;
	elseif ( level >= 50 ) then
		size = 12;
	elseif ( level >= 40 ) then
		size = 8;
	else
		size = 4;
	end
	return size;
end