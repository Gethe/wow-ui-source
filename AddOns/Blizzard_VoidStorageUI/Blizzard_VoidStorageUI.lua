UIPanelWindows["VoidStorageFrame"] = { area = "doublewide", pushable = 0, width = 726 };

local VOID_STORAGE_UNLOCK_COST = 100 * 100 * 100;	-- 100 gold
local BUTTON_TYPE_DEPOSIT = 1;
local BUTTON_TYPE_WITHDRAW = 2;
local BUTTON_TYPE_STORAGE = 3;
local VOID_DEPOSIT_MAX = 9;
local VOID_WITHDRAW_MAX = 9;
local VOID_STORAGE_MAX = 80;
local voidStorageTutorials = {
	[1] = { text1 = VOID_STORAGE_TUTORIAL1, text2 = VOID_STORAGE_TUTORIAL2, yOffset = 340 },
	[2] = { text1 = VOID_STORAGE_TUTORIAL3, yOffset = 180 },
	[3] = { text1 = VOID_STORAGE_TUTORIAL4, text2 = VOID_STORAGE_TUTORIAL5, yOffset = 86 },
}

function VoidStorageFrame_Show()
	ShowUIPanel(VoidStorageFrame);
	if ( not VoidStorageFrame:IsShown() ) then
		CloseVoidStorageFrame();
	end
end

function VoidStorageFrame_Hide()
	HideUIPanel(VoidStorageFrame);
end

function VoidStorageFrame_OnLoad(self)
	-- The close button comes from the BasicFrameTemplate but VoidStorageBorderFrame is not the main
	-- frame, so click function must change to close the proper frame
	VoidStorageBorderFrameCloseButton:SetScript("OnClick", function () VoidStorageFrame_Hide(); end);
	VoidStorageBorderFrameTopTileStreaks:Hide();
	VoidStorageBorderFrameBg:SetTexture(nil);
	local button, lastButton, texture;
	-- create deposit buttons
	VoidStorageDepositFrame.Bg:SetTexture(0.1451, 0.0941, 0.1373, 0.8);
	lastButton = VoidStorageDepositButton1;
	lastButton.buttonType = BUTTON_TYPE_DEPOSIT;
	lastButton.slot = 1;
	for i = 2, VOID_DEPOSIT_MAX do
		button = CreateFrame("BUTTON", "VoidStorageDepositButton"..i, VoidStorageDepositFrame, "VoidStorageItemButtonTemplate");
		if ( mod(i, 3) == 1 ) then
			button:SetPoint("TOP", _G["VoidStorageDepositButton"..(i - 3)], "BOTTOM", 0, -5);
		else
			button:SetPoint("LEFT", lastButton, "RIGHT", 7, 0);
		end
		lastButton = button;
		lastButton.buttonType = BUTTON_TYPE_DEPOSIT;
		lastButton.slot = i;
	end
	-- create withdraw buttons
	VoidStorageWithdrawFrame.Bg:SetTexture(0.1451, 0.0941, 0.1373, 0.8);
	lastButton = VoidStorageWithdrawButton1;
	lastButton.buttonType = BUTTON_TYPE_WITHDRAW;
	lastButton.slot = 1;
	for i = 2, VOID_WITHDRAW_MAX do
		button = CreateFrame("BUTTON", "VoidStorageWithdrawButton"..i, VoidStorageDepositFrame, "VoidStorageItemButtonTemplate");
		if ( mod(i, 3) == 1 ) then
			button:SetPoint("TOP", _G["VoidStorageWithdrawButton"..(i - 3)], "BOTTOM", 0, -5);
		else
			button:SetPoint("LEFT", lastButton, "RIGHT", 7, 0);
		end
		lastButton = button;
		lastButton.buttonType = BUTTON_TYPE_WITHDRAW;
		lastButton.slot = i;
	end
	-- create storage buttons
	VoidStorageStorageFrame.Bg:SetTexture(nil);
	lastButton = VoidStorageStorageButton1;
	lastButton.buttonType = BUTTON_TYPE_STORAGE;
	lastButton.slot = 1;
	for i = 2, VOID_STORAGE_MAX do
		button = CreateFrame("BUTTON", "VoidStorageStorageButton"..i, VoidStorageDepositFrame, "VoidStorageItemButtonTemplate");
		if ( mod(i, 8) == 1 ) then
			if ( mod(i, 16) == 1 ) then
				button:SetPoint("LEFT", _G["VoidStorageStorageButton"..(i - 8)], "RIGHT", 14, 0);
			else
				button:SetPoint("LEFT", _G["VoidStorageStorageButton"..(i - 8)], "RIGHT", 7, 0);
			end
		else
			button:SetPoint("TOP", lastButton, "BOTTOM", 0, -5);
		end
		lastButton = button;
		lastButton.buttonType = BUTTON_TYPE_STORAGE;
		lastButton.slot = i;
	end
	
	MoneyFrame_Update("VoidStorageMoneyFrame", 0);

	self:RegisterEvent("VOID_STORAGE_UPDATE");
	self:RegisterEvent("VOID_STORAGE_CONTENTS_UPDATE");
	self:RegisterEvent("VOID_STORAGE_DEPOSIT_UPDATE");
	self:RegisterEvent("VOID_TRANSFER_DONE");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
	self:RegisterEvent("VOID_DEPOSIT_WARNING");
end

function VoidStorageFrame_OnEvent(self, event, ...)
	if ( event == "VOID_TRANSFER_DONE" ) then
		VoidStorage_ItemsUpdate(true, true);
	elseif ( event == "VOID_STORAGE_DEPOSIT_UPDATE" ) then
		local slot = ...;
		local dialog = StaticPopup_FindVisible("VOID_DEPOSIT_CONFIRM");
		if ( dialog and dialog.data.slot == slot ) then
			self.dropWarningItem = false;
			StaticPopup_Hide("VOID_DEPOSIT_CONFIRM");
		end
		VoidStorage_ItemsUpdate(true, false);
	elseif ( event == "VOID_STORAGE_CONTENTS_UPDATE" ) then
		VoidStorage_ItemsUpdate(false, true);
	elseif ( event == "VOID_STORAGE_UPDATE" ) then
		VoidStorageFrame_Update();
	elseif ( event == "INVENTORY_SEARCH_UPDATE" ) then
		VoidStorage_ItemsFilteredUpdate();
	elseif ( event == "VOID_DEPOSIT_WARNING" ) then
		local slot, itemLink = ...;
		local itemName, _, itemQuality, _, _, _, _, _, _, texture = GetItemInfo(itemLink);
		local r, g, b = GetItemQualityColor(itemQuality or 1);
		self.dropWarningItem = true;
		StaticPopup_Show("VOID_DEPOSIT_CONFIRM", nil, nil, {["texture"] = texture, ["name"] = itemName, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["slot"] = slot});
		VoidStorageTransferButton:Disable();
	end
end

function VoidStorageFrame_OnShow(self)
	PlaySound("UI_EtherealWindow_Open");
	SetUpSideDressUpFrame(self, 726, 906, "TOPLEFT", "TOPRIGHT", -2, -15);
	VoidStorageFrame_Update();
end

function VoidStorageFrame_Update()
	if ( CanUseVoidStorage() ) then
		local lastTutorial = tonumber(GetCVar("lastVoidStorageTutorial"));
		if ( lastTutorial >= #voidStorageTutorials ) then
			-- hide blocking frame if necessary
			if ( VoidStorageBorderFrameMouseBlockFrame:IsShown() ) then
				VoidStorageBorderFrameMouseBlockFrame:Hide();
				VoidStoragePurchaseFrame:Hide();
				VoidStorageBorderFrameBg:Hide();
				VoidStorageHelpBox:Hide();
			end
			IsVoidStorageReady();
			VoidStorage_ItemsUpdate(true, true);
		else
			local tutorial = voidStorageTutorials[lastTutorial + 1];
			local height = 58;	-- button height + top and bottom padding + spacing between text and button
			VoidStorageHelpBoxBigText:SetText(tutorial.text1);
			height = height + VoidStorageHelpBoxBigText:GetHeight();
			if ( tutorial.text2 ) then
				VoidStorageHelpBoxSmallText:SetText(tutorial.text2);
				height = height + 12 + VoidStorageHelpBoxSmallText:GetHeight();
				VoidStorageHelpBoxSmallText:Show();
			else
				VoidStorageHelpBoxSmallText:Hide();
			end
			VoidStorageHelpBox:SetHeight(height);
			VoidStorageHelpBox:SetPoint("BOTTOMLEFT", 12, tutorial.yOffset);
			VoidStorageHelpBoxButton.currentTutorial = lastTutorial + 1;
			VoidStorageFrame_SetUpBlockingFrame();
			VoidStoragePurchaseFrame:Hide();
			VoidStorageHelpBox:Show();
		end
	else
		if ( VOID_STORAGE_UNLOCK_COST > GetMoney() ) then
			SetMoneyFrameColor("VoidStoragePurchaseMoneyFrame", "red");
			VoidStoragePurchaseButton:Disable();
		else
			SetMoneyFrameColor("VoidStoragePurchaseMoneyFrame");
			VoidStoragePurchaseButton:Enable();
		end
		MoneyFrame_Update("VoidStoragePurchaseMoneyFrame", VOID_STORAGE_UNLOCK_COST);
		VoidStoragePurchaseFrame:SetHeight(VoidStoragePurchaseFrameDescription:GetHeight() + 156);
		local width = max(VoidStoragePurchaseFrameLabel:GetWidth(), VoidStoragePurchaseFrameDescription:GetWidth());
		VoidStoragePurchaseFrame:SetWidth(min(550, width + 164));
		VoidStorageFrame_SetUpBlockingFrame();
		VoidStoragePurchaseFrame:Show();
	end
end

function VoidStorageFrame_OnHide(self)
	PlaySound("UI_EtherealWindow_Close");
	StaticPopup_Hide("VOID_DEPOSIT_CONFIRM");
	CloseVoidStorageFrame();
	CloseSideDressUpFrame(self);
end

function VoidStorageFrame_SetUpBlockingFrame(frame)
	if ( not VoidStorageBorderFrameMouseBlockFrame:IsShown() ) then
		VoidStorageBorderFrameBg:Show();
		VoidStorageBorderFrameBg:SetTexture(0, 0, 0, 0.5);
		VoidStorageBorderFrame:SetFrameLevel(100);
		VoidStorageBorderFrameMouseBlockFrame:Show();
	end
end

function VoidStorage_CloseConfirmationDialog(slot)
	if ( VoidStorageFrame.dropWarningItem ) then
		ClearVoidTransferDepositSlot(slot);
	end
	VoidStorage_UpdateTransferButton();
end

function VoidStorage_ItemsUpdate(doDeposit, doContents)	
	local button;
	if ( doDeposit ) then
		for i = 1, VOID_DEPOSIT_MAX do
			itemID, textureName = GetVoidTransferDepositInfo(i);
			button = _G["VoidStorageDepositButton"..i];
			button.icon:SetTexture(textureName);
			if ( itemID ) then
				button.hasItem = true;
			else
				button.hasItem = nil;
			end
		end
	end
	if ( doContents ) then
		-- withdrawal
		for i = 1, VOID_WITHDRAW_MAX do
			itemID, textureName = GetVoidTransferWithdrawalInfo(i);
			button = _G["VoidStorageWithdrawButton"..i];
			button.icon:SetTexture(textureName);
			if ( itemID ) then
				button.hasItem = true;
			else
				button.hasItem = nil;
			end
		end
		
		-- storage
		for i = 1, VOID_STORAGE_MAX do
			itemID, textureName, locked, recentDeposit, isFiltered = GetVoidItemInfo(i);
			button = _G["VoidStorageStorageButton"..i];
			button.icon:SetTexture(textureName);
			if ( itemID ) then
				button.icon:SetDesaturated(locked);
				button.hasItem = true;
			else
				button.hasItem = nil;
			end
			
			if ( recentDeposit ) then
				local antsFrame = button.antsFrame;
				if ( not antsFrame ) then
					antsFrame = VoidStorageFrame_GetAntsFrame();
					antsFrame:SetParent(button);
					antsFrame:SetPoint("CENTER");
					button.antsFrame = antsFrame;
				end
				antsFrame:Show();
			elseif ( button.antsFrame ) then
				button.antsFrame:Hide();
				button.antsFrame = nil;
			end
			
			if ( isFiltered ) then
				button.searchOverlay:Show();
			else
				button.searchOverlay:Hide();
			end
		end
	end
	if ( VoidStorageFrame.mousedOverButton ) then
		VoidStorageItemButton_OnEnter(VoidStorageFrame.mousedOverButton);
	end
	local hasWarningDialog = StaticPopup_FindVisible("VOID_DEPOSIT_CONFIRM");
	VoidStorage_UpdateTransferButton(hasWarningDialog);
end

function VoidStorage_UpdateTransferButton(hasWarningDialog)
	local cost = GetVoidTransferCost();
	local canApply = false;
	if ( cost > GetMoney() ) then
		SetMoneyFrameColor("VoidStorageMoneyFrame", "red");
	else
		SetMoneyFrameColor("VoidStorageMoneyFrame");
		local numDeposits = GetNumVoidTransferDeposit();
		local numWithdrawals = GetNumVoidTransferWithdrawal();
		if ( ( numDeposits > 0 or numWithdrawals > 0 ) and IsVoidStorageReady() ) then
			canApply = true;
		end
	end
	if ( hasWarningDialog ) then
		canApply = false;
	end
	MoneyFrame_Update("VoidStorageMoneyFrame", cost);
	if ( canApply ) then
		VoidStorageTransferButton:Enable();
	else
		VoidStorageTransferButton:Disable();
	end
end

function VoidStorage_ItemsFilteredUpdate()
	local button, isFiltered, _;
	-- storage
	for i = 1, VOID_STORAGE_MAX do
		_, _, _, _, isFiltered = GetVoidItemInfo(i);
		button = _G["VoidStorageStorageButton"..i];
		
		if ( isFiltered ) then
			button.searchOverlay:Show();
		else
			button.searchOverlay:Hide();
		end
	end
end

function VoidStorageFrame_GetAntsFrame()
	local name, frame;
	local i = 1;
	while true do
		name = "VoidStorageAntsFrame"..i;
		frame = _G[name];
		if ( frame ) then
			if ( not frame:IsShown() ) then
				return frame;
			end
		else
			frame = CreateFrame("Frame", name, VoidStorageFrame, "VoidStorageAntsFrameTemplate");
			return frame;
		end
		i = i + 1;
		-- You could deposit 9 items, move them to the back, then deposit 9 more. Until the items in the back get updated, their ants frame won't be released.
		assert(i <= VOID_DEPOSIT_MAX * 2);
	end
end

function VoidStorageItemButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
	self.UpdateTooltip = VoidStorageItemButton_OnEnter;
end

function VoidStorageItemButton_OnClick(self, button)
	if ( IsModifiedClick() ) then
		local itemID;
		if ( self.buttonType == BUTTON_TYPE_DEPOSIT ) then
			itemID = GetVoidTransferDepositInfo(self.slot);
		elseif ( self.buttonType == BUTTON_TYPE_STORAGE ) then
			itemID = GetVoidItemInfo(self.slot);
		elseif ( self.buttonType == BUTTON_TYPE_WITHDRAW ) then
			itemID = GetVoidTransferWithdrawalInfo(self.slot);
		end
		if ( itemID ) then
			local _, itemLink = GetItemInfo(itemID);
			HandleModifiedItemClick(itemLink);
		end
	else
		local isRightClick = (button == "RightButton");
		if ( self.buttonType == BUTTON_TYPE_DEPOSIT ) then
			ClickVoidTransferDepositSlot(self.slot, isRightClick);
		elseif ( self.buttonType == BUTTON_TYPE_STORAGE ) then
			ClickVoidStorageSlot(self.slot, isRightClick);
		elseif ( self.buttonType == BUTTON_TYPE_WITHDRAW ) then
			ClickVoidTransferWithdrawalSlot(self.slot, isRightClick);
		end
	end
	VoidStorageItemButton_OnEnter(self);
end

function VoidStorageItemButton_OnDrag(self)
	VoidStorageItemButton_OnClick(self, "LeftButton");
end

function VoidStorageItemButton_OnEnter(self)
	VoidStorageFrame.mousedOverButton = self;
	if ( self.hasItem ) then
		local x = self:GetRight();
		if ( x >= ( GetScreenWidth() / 2 ) ) then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		end	
		if ( self.buttonType == BUTTON_TYPE_DEPOSIT ) then
			GameTooltip:SetVoidDepositItem(self.slot);
		elseif ( self.buttonType == BUTTON_TYPE_STORAGE ) then
			GameTooltip:SetVoidItem(self.slot);
		elseif ( self.buttonType == BUTTON_TYPE_WITHDRAW ) then
			GameTooltip:SetVoidWithdrawalItem(self.slot);
		end
		if ( IsModifiedClick("DRESSUP") ) then
			ShowInspectCursor();
		else
			ResetCursor();
		end
	else
		GameTooltip:Hide();
		ResetCursor();
	end
end

function VoidStorageItemButton_OnLeave(self)
	GameTooltip:Hide();
	VoidStorageFrame.mousedOverButton = nil;
end