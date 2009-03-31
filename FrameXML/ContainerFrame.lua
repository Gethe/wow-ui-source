NUM_CONTAINER_FRAMES = 13;
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
CONTAINER_SCALE = 0.75;
BACKPACK_HEIGHT = 240;

function ContainerFrame_OnLoad(self)
	self:RegisterEvent("BAG_OPEN");
	self:RegisterEvent("BAG_CLOSED");
	ContainerFrame1.bagsShown = 0;
	ContainerFrame1.bags = {};
end

function ContainerFrame_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "BAG_OPEN" ) then
		if ( self:GetID() == arg1 ) then
			self:Show();
		end
	elseif ( event == "BAG_CLOSED" ) then
		if ( self:GetID() == arg1 ) then
			self:Hide();
		end
	elseif ( event == "BAG_UPDATE" ) then
		if ( self:GetID() == arg1 ) then
 			ContainerFrame_Update(self);
		end
	elseif ( event == "ITEM_LOCK_CHANGED" ) then
		local bag, slot = arg1, arg2;
		if ( bag and slot and (bag == self:GetID()) ) then
			ContainerFrame_UpdateLockedItem(self, slot);
		end
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		ContainerFrame_UpdateCooldowns(self);
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		updateContainerFrameAnchors();
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
			-- Hide the token bar if closing the backpack
			if ( BackpackTokenFrame ) then
				BackpackTokenFrame:Hide();
			end
		end
	else
		ToggleBag(0);
		-- If there are tokens watched then show the bar
		if ( ManageBackpackTokenFrame ) then
			BackpackTokenFrame_Update();
			ManageBackpackTokenFrame();
		end
	end
end

function ContainerFrame_OnHide(self)
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");

	if ( self:GetID() == 0 ) then
		MainMenuBarBackpackButton:SetChecked(0);
	else
		local bagButton = getglobal("CharacterBag"..(self:GetID() - 1).."Slot");
		if ( bagButton ) then
			bagButton:SetChecked(0);
		else
			-- If its a bank bag then update its highlight
			
			UpdateBagButtonHighlight(self:GetID()); 
		end
	end
	ContainerFrame1.bagsShown = ContainerFrame1.bagsShown - 1;
	-- Remove the closed bag from the list and collapse the rest of the entries
	local index = 1;
	while ContainerFrame1.bags[index] do
		if ( ContainerFrame1.bags[index] == self:GetName() ) then
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

	if ( self:GetID() == KEYRING_CONTAINER ) then
		UpdateMicroButtons();
		PlaySound("KeyRingClose");
	else
		PlaySound("igBackPackClose");
	end
end

function ContainerFrame_OnShow(self)
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");

	if ( self:GetID() == 0 ) then
		MainMenuBarBackpackButton:SetChecked(1);
	elseif ( self:GetID() <= NUM_BAG_SLOTS ) then 
		local button = getglobal("CharacterBag"..(self:GetID() - 1).."Slot");
		if ( button ) then
			button:SetChecked(1);
		end
	else
		UpdateBagButtonHighlight(self:GetID());
	end
	ContainerFrame1.bagsShown = ContainerFrame1.bagsShown + 1;
	if ( self:GetID() == KEYRING_CONTAINER ) then
		UpdateMicroButtons();
		PlaySound("KeyRingOpen");
	else
		PlaySound("igBackPackOpen");
	end
 	ContainerFrame_Update(self);
	
	-- If there are tokens watched then decide if we should show the bar
	if ( ManageBackpackTokenFrame ) then
		ManageBackpackTokenFrame();
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
	
	return ContainerFrame1.backpackWasOpen;
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
	local itemButton;
	local texture, itemCount, locked, quality, readable;
	local tooltipOwner = GameTooltip:GetOwner();
	for i=1, frame.size, 1 do
		itemButton = getglobal(name.."Item"..i);
		
		texture, itemCount, locked, quality, readable = GetContainerItemInfo(id, itemButton:GetID());
		
		SetItemButtonTexture(itemButton, texture);
		SetItemButtonCount(itemButton, itemCount);
		SetItemButtonDesaturated(itemButton, locked, 0.5, 0.5, 0.5);

		if ( texture ) then
			ContainerFrame_UpdateCooldown(id, itemButton);
			itemButton.hasItem = 1;
		else
			getglobal(name.."Item"..i.."Cooldown"):Hide();
			itemButton.hasItem = nil;
		end
		itemButton.readable = readable;
		
		if ( itemButton == tooltipOwner ) then
			itemButton.UpdateTooltip(itemButton);
		end
	end
end

function ContainerFrame_UpdateLocked(frame)
	local id = frame:GetID();
	local name = frame:GetName();
	local itemButton;
	local texture, itemCount, locked, quality, readable;
	for i=1, frame.size, 1 do
		itemButton = getglobal(name.."Item"..i);
		
		texture, itemCount, locked, quality, readable = GetContainerItemInfo(id, itemButton:GetID());

		SetItemButtonDesaturated(itemButton, locked, 0.5, 0.5, 0.5);
	end
end

function ContainerFrame_UpdateLockedItem(frame, slot)
	local index = frame.size + 1 - slot;
	local itemButton = getglobal(frame:GetName().."Item"..index);
	local texture, itemCount, locked, quality, readable = GetContainerItemInfo(frame:GetID(), itemButton:GetID());

	SetItemButtonDesaturated(itemButton, locked, 0.5, 0.5, 0.5);
end

function ContainerFrame_UpdateCooldowns(frame)
	local id = frame:GetID();
	local name = frame:GetName();
	for i=1, frame.size, 1 do
		local itemButton = getglobal(name.."Item"..i);
		if ( GetContainerItemInfo(id, itemButton:GetID()) ) then
			ContainerFrame_UpdateCooldown(id, itemButton);
		else
			getglobal(name.."Item"..i.."Cooldown"):Hide();
		end
	end
end

function ContainerFrame_UpdateCooldown(container, button)
	local cooldown = getglobal(button:GetName().."Cooldown");
	local start, duration, enable = GetContainerItemCooldown(container, button:GetID());
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
	if ( duration > 0 and enable == 0 ) then
		SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4);
	else
		SetItemButtonTextureVertexColor(button, 1, 1, 1);
	end
end

function ContainerFrame_GenerateFrame(frame, size, id)
	frame.size = size;
	local name = frame:GetName();
	local bgTextureTop = getglobal(name.."BackgroundTop");
	local bgTextureMiddle = getglobal(name.."BackgroundMiddle1");
	local bgTextureMiddle2 = getglobal(name.."BackgroundMiddle2");
	local bgTextureBottom = getglobal(name.."BackgroundBottom");
	local bgTexture1Slot = getglobal(name.."Background1Slot");
	local columns = NUM_CONTAINER_COLUMNS;
	local rows = ceil(size / columns);
	-- if size = 0 then its the backpack
	if ( id == 0 ) then
		bgTexture1Slot:Hide();
		getglobal(name.."MoneyFrame"):Show();
		-- Set Backpack texture
		bgTextureTop:SetTexture("Interface\\ContainerFrame\\UI-BackpackBackground");
		bgTextureTop:SetHeight(256);
		bgTextureTop:SetTexCoord(0, 1, 0, 1);
		bgTextureTop:Show();

		-- Hide unused textures
		for i=1, MAX_BG_TEXTURES do
			getglobal(name.."BackgroundMiddle"..i):Hide();
		end
		bgTextureBottom:Hide();
		frame:SetHeight(BACKPACK_HEIGHT);
	else
		if (size == 1) then
			-- Halloween gag gift
			bgTexture1Slot:Show();
			bgTextureTop:Hide();
			bgTextureMiddle:Hide();
			bgTextureMiddle2:Hide();
			bgTextureBottom:Hide();
		else
			bgTexture1Slot:Hide();
			bgTextureTop:Show();
	
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
	end

	if (size == 1) then
		-- Halloween gag gift
		frame:SetHeight(70);	
		frame:SetWidth(99);
		getglobal(frame:GetName().."Name"):SetText("");
		SetBagPortraitTexture(getglobal(frame:GetName().."Portrait"), id);
		local itemButton = getglobal(name.."Item1");
		itemButton:SetID(1);
		itemButton:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", -10, 5);
		itemButton:Show();
	else
		frame:SetWidth(CONTAINER_WIDTH);

		--Special case code for keyrings
		if ( id == KEYRING_CONTAINER ) then
			getglobal(frame:GetName().."Name"):SetText(KEYRING);
			SetPortraitToTexture(frame:GetName().."Portrait", "Interface\\ContainerFrame\\KeyRing-Bag-Icon");
		else
			getglobal(frame:GetName().."Name"):SetText(GetBagName(id));
			SetBagPortraitTexture(getglobal(frame:GetName().."Portrait"), id);
		end

		local index, itemButton;
		for i=1, size, 1 do
			index = size - i + 1;
			itemButton = getglobal(name.."Item"..i);
			itemButton:SetID(index);
			-- Set first button
			if ( i == 1 ) then
				-- Anchor the first item differently if its the backpack frame
				if ( id == 0 ) then
					itemButton:SetPoint("BOTTOMRIGHT", bgTextureTop, "BOTTOMRIGHT", -12, 48);
				else
					itemButton:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", -12, 9);
				end
				
			else
				if ( mod((i-1), columns) == 0 ) then
					itemButton:SetPoint("BOTTOMRIGHT", name.."Item"..(i - columns), "TOPRIGHT", 0, 4);	
				else
					itemButton:SetPoint("BOTTOMRIGHT", name.."Item"..(i - 1), "BOTTOMLEFT", -5, 0);	
				end
			end
			itemButton:Show();
		end
	end
	for i=size + 1, MAX_CONTAINER_ITEMS, 1 do
		getglobal(name.."Item"..i):Hide();
	end
	
	frame:SetID(id);
	getglobal(frame:GetName().."PortraitButton"):SetID(id);

	-- Add the bag to the baglist
	ContainerFrame1.bags[ContainerFrame1.bagsShown + 1] = frame:GetName();
	updateContainerFrameAnchors();
	frame:Show();
end

function updateContainerFrameAnchors()
	local frame, xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column;
	local screenWidth = GetScreenWidth();
	local containerScale = 1;
	local leftLimit = 0;
	if ( BankFrame:IsShown() ) then
		leftLimit = BankFrame:GetRight() - 25;
	end
	
	while ( containerScale > CONTAINER_SCALE ) do
		screenHeight = GetScreenHeight() / containerScale;
		-- Adjust the start anchor for bags depending on the multibars
		xOffset = CONTAINER_OFFSET_X / containerScale; 
		yOffset = CONTAINER_OFFSET_Y / containerScale; 
		-- freeScreenHeight determines when to start a new column of bags
		freeScreenHeight = screenHeight - yOffset;
		leftMostPoint = screenWidth - xOffset;
		column = 1;
		local frameHeight;
		for index, frameName in ipairs(ContainerFrame1.bags) do
			frameHeight = getglobal(frameName):GetHeight();
			if ( freeScreenHeight < frameHeight ) then
				-- Start a new column
				column = column + 1;
				leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * containerScale ) - xOffset;
				freeScreenHeight = screenHeight - yOffset;
			end
			freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING;
		end
		if ( leftMostPoint < leftLimit ) then
			containerScale = containerScale - 0.01;
		else
			break;
		end
	end
	
	if ( containerScale < CONTAINER_SCALE ) then
		containerScale = CONTAINER_SCALE;
	end
	
	screenHeight = GetScreenHeight() / containerScale;
	-- Adjust the start anchor for bags depending on the multibars
	xOffset = CONTAINER_OFFSET_X / containerScale;
	yOffset = CONTAINER_OFFSET_Y / containerScale;
	-- freeScreenHeight determines when to start a new column of bags
	freeScreenHeight = screenHeight - yOffset;
	column = 0;
	for index, frameName in ipairs(ContainerFrame1.bags) do
		frame = getglobal(frameName);
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
	end
end

function ContainerFrameItemButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");

	self.SplitStack = function(button, split)
		SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
	end
	self.UpdateTooltip = ContainerFrameItemButton_OnEnter;
end

function ContainerFrameItemButton_OnDrag (self)
	ContainerFrameItemButton_OnClick(self, "LeftButton");
end

function ContainerFrame_GetExtendedPriceString(itemButton, quantity)
	quantity = (quantity or 1);
	local slot = itemButton:GetID();
	local bag = itemButton:GetParent():GetID();

	local money, honorPoints, arenaPoints, itemCount, refundSec, purchaseTime = GetContainerItemPurchaseInfo(bag, slot);
	if ( not refundSec or ((honorPoints == 0) and (arenaPoints == 0) and (itemCount == 0)) ) then
		return false;
	end
	
	local count = itemButton.count or 1;
	honorPoints, arenaPoints, itemCount = (honorPoints or 0) * quantity, (arenaPoints or 0) * quantity, (itemCount or 0) * quantity;
	local itemsString;

	if ( honorPoints and honorPoints ~= 0 ) then
		local factionGroup = UnitFactionGroup("player");
		if ( factionGroup ) then	
			local pointsTexture = "Interface\\PVPFrame\\PVP-Currency-"..factionGroup;
			itemsString = " |T" .. pointsTexture .. ":0:0:0:-1|t" ..  honorPoints .. " " .. HONOR_POINTS;
		end
	end
	if ( arenaPoints and arenaPoints ~= 0 ) then
		if ( itemsString ) then
			-- adding an extra space here because it looks nicer
			itemsString = itemsString .. "  |TInterface\\PVPFrame\\PVP-ArenaPoints-Icon:0:0:0:-1|t" .. arenaPoints .. " " .. ARENA_POINTS;
		else
			itemsString = " |TInterface\\PVPFrame\\PVP-ArenaPoints-Icon:0:0:0:-1|t" .. arenaPoints .. " " .. ARENA_POINTS;
		end
	end
	
	local maxQuality = 0;
	for i=1, itemCount, 1 do
		local itemTexture, itemQuantity, itemLink = GetContainerItemPurchaseItem(bag, slot, i);
		if ( itemLink ) then
			local _, _, itemQuality = GetItemInfo(itemLink);
			maxQuality = math.max(itemQuality, maxQuality);
			if ( itemsString ) then
				itemsString = itemsString .. ", " .. format(ITEM_QUANTITY_TEMPLATE, (itemQuantity or 0) * quantity, itemLink);
			else
				itemsString = format(ITEM_QUANTITY_TEMPLATE, (itemQuantity or 0) * quantity, itemLink);
			end
		end
	end
	
	MerchantFrame.refundBag = bag;
	MerchantFrame.refundSlot = slot;
	MerchantFrame.honorPoints = honorPoints;
	MerchantFrame.arenaPoints = arenaPoints;
	
	local refundItemTexture, _, _, _, _, _, refundItemLink = GetContainerItemInfo(bag, slot);
	local itemName, _, itemQuality = GetItemInfo(refundItemLink);
	local r, g, b = GetItemQualityColor(itemQuality);
	StaticPopup_Show("CONFIRM_REFUND_TOKEN_ITEM", itemsString, "", {["texture"] = refundItemTexture, ["name"] = itemName, ["color"] = {r, g, b, 1}, ["link"] = refundItemLink, ["index"] = index, ["count"] = count * quantity});
	return true;
end

function ContainerFrameItemButton_OnClick(self, button)
	MerchantFrame.refundItem = nil;

	if ( button == "LeftButton" ) then
		local type, money = GetCursorInfo();
		if ( SpellCanTargetItem() ) then
			-- Target the spell with the selected item
			UseContainerItem(self:GetParent():GetID(), self:GetID());
		elseif ( type == "guildbankmoney" ) then
			WithdrawGuildBankMoney(money);
			ClearCursor();
		elseif ( type == "money" ) then
			DropCursorMoney();
			ClearCursor();
		elseif ( type == "merchant" ) then
			if ( MerchantFrame.extendedCost ) then
				MerchantFrame_ConfirmExtendedItemCost(MerchantFrame.extendedCost);
			elseif ( MerchantFrame.price and MerchantFrame.price >= MERCHANT_HIGH_PRICE_COST ) then
				MerchantFrame_ConfirmHighCostItem(self);
			else
				PickupContainerItem(self:GetParent():GetID(), self:GetID());
			end
		else
			PickupContainerItem(self:GetParent():GetID(), self:GetID());
			if ( CursorHasItem() ) then
				MerchantFrame.refundItem = self;
			end
		end
		StackSplitFrame:Hide();
	else
		if ( MerchantFrame:IsShown() ) then
			if ( MerchantFrame.selectedTab == 2 ) then
				-- Don't sell the item if the buyback tab is selected
				return;
			end
			if ( ContainerFrame_GetExtendedPriceString(self)) then
				-- a confirmation dialog has been shown
				return;
			end
		end
		UseContainerItem(self:GetParent():GetID(), self:GetID());
		StackSplitFrame:Hide();
	end
end

function ContainerFrameItemButton_OnModifiedClick(self, button)
	if ( HandleModifiedItemClick(GetContainerItemLink(self:GetParent():GetID(), self:GetID())) ) then
		return;
	end
	if ( IsModifiedClick("SOCKETITEM") ) then
		SocketContainerItem(self:GetParent():GetID(), self:GetID());
	end
	if ( IsModifiedClick("SPLITSTACK") ) then
		local texture, itemCount, locked = GetContainerItemInfo(self:GetParent():GetID(), self:GetID());
		if ( not locked ) then
			self.SplitStack = function(button, split)
				SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
			end
			OpenStackSplitFrame(itemCount, self, "BOTTOMRIGHT", "TOPRIGHT");
		end
		return;
	end
end

function ContainerFrameItemButton_OnEnter(self)
	local x;
	x = self:GetRight();
	if ( x >= ( GetScreenWidth() / 2 ) ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end

	-- Keyring specific code
	if ( self:GetParent():GetID() == KEYRING_CONTAINER ) then
		GameTooltip:SetInventoryItem("player", KeyRingButtonIDToInvSlotID(self:GetID()));
		CursorUpdate(self);
		return;
	end

	local showSell = nil;
	local hasCooldown, repairCost = GameTooltip:SetBagItem(self:GetParent():GetID(), self:GetID());
	if ( InRepairMode() and (repairCost and repairCost > 0) ) then
		GameTooltip:AddLine(REPAIR_COST, "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	elseif ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 ) then
		showSell = 1;
	end

	if ( IsModifiedClick("DRESSUP") and self.hasItem ) then
		ShowInspectCursor();
	elseif ( showSell ) then
		ShowContainerSellCursor(self:GetParent():GetID(),self:GetID());
	elseif ( self.readable ) then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function OpenAllBags(forceOpen)
	if ( not UIParent:IsShown() ) then
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
		if ( BankFrame:IsShown() ) then
			ToggleBag(5);
			ToggleBag(6);
			ToggleBag(7);
			ToggleBag(8);
			ToggleBag(9);
			ToggleBag(10);
			ToggleBag(11);
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
	local numKeyringSlots = GetContainerNumSlots(KEYRING_CONTAINER);
	local maxSlotNumberFilled = 0;
	local numItems = 0;
	for i=1, numKeyringSlots do
		local texture = GetContainerItemInfo(KEYRING_CONTAINER, i);
		-- Update max slot
		if ( texture and i > maxSlotNumberFilled) then
			maxSlotNumberFilled = i;
		end
		-- Count how many items you have
		if ( texture ) then
			numItems = numItems + 1;
		end
	end

	-- Round to the nearest 4 rows that will hold the keys
	local modulo = maxSlotNumberFilled % 4;
	local size;
	if ( (modulo == 0) and (numItems < maxSlotNumberFilled) ) then
		size = maxSlotNumberFilled;
	else
		-- Only expand if the number of keys in the keyring exceed or equal the max slot filled
		size = maxSlotNumberFilled + (4 - modulo);
	end	
	size = min(size, numKeyringSlots);

	return size;
end

function GetBackpackFrame()
	local index = IsBagOpen(0);
	if ( index ) then
		return getglobal("ContainerFrame"..index);
	else
		return nil;
	end
end
