UIPanelWindows["VoidStorageFrame"] = { area = "doublewide", pushable = 0, width = 726 };

local BUTTON_TYPE_DEPOSIT = 1;
local BUTTON_TYPE_WITHDRAW = 2;
local BUTTON_TYPE_STORAGE = 3;
local VOID_DEPOSIT_MAX = 9;
local VOID_WITHDRAW_MAX = 9;
local VOID_STORAGE_MAX = 80;
local VOID_STORAGE_PAGES = 2;

local voidStorageTutorials = {
	[1] = { text1 = VOID_STORAGE_TUTORIAL1, text2 = VOID_STORAGE_TUTORIAL2, region = "VoidStorageDepositButton5", offsetY = -22 },
	[2] = { text1 = VOID_STORAGE_TUTORIAL3, region = "VoidStorageWithdrawButton5", offsetY = -22 },
	[3] = { text1 = VOID_STORAGE_TUTORIAL4, text2 = VOID_STORAGE_TUTORIAL5, region = "VoidStorageTransferButton", offsetY = 0 },
}

function VoidStorageFrame_OnLoad(self)
	-- The close button comes from the BasicFrameTemplate but VoidStorageBorderFrame is not the main
	-- frame, so click function must change to close the proper frame
	VoidStorageBorderFrame.CloseButton:SetScript("OnClick", function () C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.VoidStorageBanker); end);
	VoidStorageBorderFrame.TopTileStreaks:Hide();
	VoidStorageBorderFrame.Bg:SetTexture(nil);
	local button, lastButton, texture;
	-- create deposit buttons
	VoidStorageDepositFrame.Bg:SetColorTexture(0.1451, 0.0941, 0.1373, 0.8);
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
	VoidStorageWithdrawFrame.Bg:SetColorTexture(0.1451, 0.0941, 0.1373, 0.8);
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
	
	self.page = 1;

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
		local recentDepositPage;
		for i = VOID_STORAGE_PAGES, 1, -1 do
			for j = VOID_STORAGE_MAX, 1, -1 do
				if (select(4, GetVoidItemInfo(i, j))) then
					recentDepositPage = i;
					break;
				end
			end
			if (recentDepositPage) then
				break;
			end
		end

		if (recentDepositPage and self.page ~= recentDepositPage) then
			VoidStorage_SetPageNumber(recentDepositPage);
		else
			VoidStorage_ItemsUpdate(true, true);
		end
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
		local itemName, _, itemQuality, _, _, _, _, _, _, texture = C_Item.GetItemInfo(itemLink);
		local r, g, b = C_Item.GetItemQualityColor(itemQuality or 1);
		self.dropWarningItem = true;
		StaticPopup_Show("VOID_DEPOSIT_CONFIRM", nil, nil, {["texture"] = texture, ["name"] = itemName, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["slot"] = slot});
		VoidStorageTransferButton:Disable();
	end
end

function VoidStorageFrame_OnShow(self)
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_OPEN);
	SetUpSideDressUpFrame(self, 726, 906, "TOPLEFT", "TOPRIGHT", -2, -15);
	VoidStorageFrame_Update();
end

function VoidStorageFrame_UpdateTabs()
	local self = VoidStorageFrame;

	local canUse = CanUseVoidStorage();
	for i=1,2 do
		local page = self["Page"..i];
		page:SetEnabled(canUse);
		if (canUse) then
			page:SetChecked(page:GetID() == self.page);
		end
	end
end

function VoidStorageFrame_Update()
	HelpTip:HideAll(VoidStorageFrame);
	if ( CanUseVoidStorage() ) then
		local lastTutorial = tonumber(GetCVar("lastVoidStorageTutorial"));
		if ( lastTutorial ) then
			if ( lastTutorial >= #voidStorageTutorials ) then
				-- hide blocking frame if necessary
				if ( VoidStorageBorderFrameMouseBlockFrame:IsShown() ) then
					VoidStorageBorderFrameMouseBlockFrame:Hide();
					VoidStoragePurchaseFrame:Hide();
					VoidStorageBorderFrame.Bg:Hide();
				end
			else
				local tutorial = voidStorageTutorials[lastTutorial + 1];
				local text = tutorial.text1;
				if tutorial.text2 then
					text = text.."|n|n"..tutorial.text2;
				end

				local helpTipInfo = {
					text = text,
					buttonStyle = HelpTip.ButtonStyle.Okay,
					cvar = "lastVoidStorageTutorial",
					cvarValue = lastTutorial + 1,
					targetPoint = HelpTip.Point.TopEdgeCenter,
					onAcknowledgeCallback = VoidStorageFrame_Update,
					offsetY = tutorial.offsetY,
				};
				HelpTip:Show(VoidStorageFrame, helpTipInfo, _G[tutorial.region]);

				VoidStorageFrame_SetUpBlockingFrame();
				VoidStoragePurchaseFrame:Hide();
			end
		end
		IsVoidStorageReady();
		VoidStorage_ItemsUpdate(true, true);
	else
		local voidStorageUnlockCost = GetVoidUnlockCost();
		if ( voidStorageUnlockCost > GetMoney() ) then
			SetMoneyFrameColor("VoidStoragePurchaseMoneyFrame", "red");
			VoidStoragePurchaseButton:Disable();
		else
			SetMoneyFrameColor("VoidStoragePurchaseMoneyFrame");
			VoidStoragePurchaseButton:Enable();
		end
		MoneyFrame_Update("VoidStoragePurchaseMoneyFrame", voidStorageUnlockCost);
		VoidStoragePurchaseFrame:SetHeight(VoidStoragePurchaseFrameDescription:GetHeight() + 156);
		local width = max(VoidStoragePurchaseFrameLabel:GetWidth(), VoidStoragePurchaseFrameDescription:GetWidth());
		VoidStoragePurchaseFrame:SetWidth(min(550, width + 164));
		VoidStorageFrame_SetUpBlockingFrame();
		VoidStoragePurchaseFrame:Show();
	end
	VoidStorageFrame_UpdateTabs();
end

function VoidStorageFrame_OnHide(self)
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_CLOSE);
	StaticPopup_Hide("VOID_DEPOSIT_CONFIRM");
	CloseSideDressUpFrame(self);
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.VoidStorage);
end

function VoidStorageFrame_SetUpBlockingFrame(frame)
	if ( not VoidStorageBorderFrameMouseBlockFrame:IsShown() ) then
		VoidStorageBorderFrame.Bg:Show();
		VoidStorageBorderFrame.Bg:SetColorTexture(0, 0, 0, 0.5);
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

function VoidStorage_SetPageNumber(page)
	local self = VoidStorageFrame;

	self.page = page;
	VoidStorageFrame_Update();
end

function VoidStorage_ItemsUpdate(doDeposit, doContents)
	local self = VoidStorageFrame;
	local button;
	if ( doDeposit ) then
		for i = 1, VOID_DEPOSIT_MAX do
			local itemID, textureName, quality = GetVoidTransferDepositInfo(i);
			button = _G["VoidStorageDepositButton"..i];
			button.icon:SetTexture(textureName);

			local doNotSuppressOverlays = false;
			local isBound = true;
			SetItemButtonQuality(button, quality, itemID, doNotSuppressOverlays, isBound);

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
			local itemID, textureName, quality = GetVoidTransferWithdrawalInfo(i);
			button = _G["VoidStorageWithdrawButton"..i];
			button.icon:SetTexture(textureName);

			local doNotSuppressOverlays = false;
			local isBound = true;
			SetItemButtonQuality(button, quality, itemID, doNotSuppressOverlays, isBound);
			if ( itemID ) then
				button.hasItem = true;
			else
				button.hasItem = nil;
			end
		end
		
		-- storage
		for i = 1, VOID_STORAGE_MAX do
			local itemID, textureName, locked, recentDeposit, isFiltered, quality = GetVoidItemInfo(self.page, i);
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

			local doNotSuppressOverlays = false;
			local isBound = true;
			SetItemButtonQuality(button, quality, itemID, doNotSuppressOverlays, isBound);
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
		_, _, _, _, isFiltered = GetVoidItemInfo(VoidStorageFrame.page, i);
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
			itemID = GetVoidItemInfo(VoidStorageFrame.page, self.slot);
		elseif ( self.buttonType == BUTTON_TYPE_WITHDRAW ) then
			itemID = GetVoidTransferWithdrawalInfo(self.slot);
		end
		if ( itemID ) then
			local _, itemLink = C_Item.GetItemInfo(itemID);
			HandleModifiedItemClick(itemLink);
		end
	else
		local isRightClick = (button == "RightButton");
		if ( self.buttonType == BUTTON_TYPE_DEPOSIT ) then
			ClickVoidTransferDepositSlot(self.slot, isRightClick);
		elseif ( self.buttonType == BUTTON_TYPE_STORAGE ) then
			ClickVoidStorageSlot(VoidStorageFrame.page, self.slot, isRightClick);
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
			GameTooltip:SetVoidItem(VoidStorageFrame.page, self.slot);
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
