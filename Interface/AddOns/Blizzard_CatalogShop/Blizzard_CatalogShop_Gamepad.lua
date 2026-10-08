-- DO NOT PUT ANY SENSITIVE CODE IN THIS FILE
-- This file does not have access to the secure (forbidden) code.  It is only called via Outbound and no function in this file should ever return values.

-- Use weak keys to avoid retaining frame references.
local catalogShopGamepadData = setmetatable({}, { __mode = "k" });

local function GetGamepadData(frame)
	local data = catalogShopGamepadData[frame];
	if not data then
		data = {};
		catalogShopGamepadData[frame] = data;
	end

	return data;
end

function CatalogShopFocusGamepad(frame)
	local data = GetGamepadData(frame);
	local footer = frame.showDetails and data.detailsFooter or data.footer;

	footer:ShowAndActivateBindings();
	GamepadMode.ActivateBindingGroup(data.modelSceneRotationBindings);
end

function CatalogShopUnfocusGamepad(frame)
	local data = GetGamepadData(frame);

	data.footer:HideAndDeactivateBindings();
	data.detailsFooter:HideAndDeactivateBindings();
	GamepadMode.DeactivateBindingGroup(data.modelSceneRotationBindings);
end

function CatalogShopShowProductDetails(frame)
	if GamepadMode.FrameControlsManager:GetActiveFrame() ~= frame then
		return;
	end

	local data = GetGamepadData(frame);
	data.footer:HideAndDeactivateBindings();
	data.detailsFooter:ShowAndActivateBindings();
end

function CatalogShopHideProductDetails(frame)
	if GamepadMode.FrameControlsManager:GetActiveFrame() ~= frame then
		return;
	end

	local data = GetGamepadData(frame);
	data.detailsFooter:HideAndDeactivateBindings();
	data.footer:ShowAndActivateBindings();
end

function CatalogShopRefreshGamepadPurchaseButton(frame)
	local data = GetGamepadData(frame);
	if not data.footer then
		return;
	end

	local purchaseButton = frame.CatalogShopDetailsFrame.ButtonContainer.PurchaseButton;
	local gamepadPurchaseButton = frame.CatalogShopDetailsFrame.ButtonContainer.GamepadPurchaseButton;

	gamepadPurchaseButton:SetText(CONTEXT_ACTION_LABEL_BUY .. " " .. purchaseButton:GetText());
	gamepadPurchaseButton:SetEnabled(purchaseButton:IsEnabled());
	GamepadMode.UpdateGamepadIconAnchor(data.gamepadPurchaseIcon);
	gamepadPurchaseButton:Show();
	data.footer:Refresh();
end

function CatalogShopRefreshSmartNav(frame)
	local data = GetGamepadData(frame);

	SmartNavigation:RefreshButtonGroups(frame);
	SmartNavigation:SelectFirstButton(true);
	SmartNavigation:SetScrollFrameForFrame(frame, frame.ProductContainerFrame.ProductsScrollBoxContainer.ScrollBox);
	GamepadScrollBarHint:SetOwner(frame.ProductContainerFrame.ProductsScrollBoxContainer.ScrollBar.Track.Thumb, "CENTER");
	GamepadScrollBarHint:Show();
	CatalogShopRefreshGamepadPurchaseButton(frame);
end

function CatalogShopSetupGamepad(frame)
	local data = GetGamepadData(frame);
	if data.footer then
		return;
	end

	-- Footer for main shop frame
	local navBar = frame.HeaderFrame.CatalogShopNavBar;
	local function PreviousCategory()
		navBar:SelectPreviousNavButton();
		CatalogShopRefreshSmartNav(frame);
	end
	local function NextCategory()
		navBar:SelectNextNavButton();
		CatalogShopRefreshSmartNav(frame);
	end

	local purchaseButton = frame.CatalogShopDetailsFrame.ButtonContainer.PurchaseButton;
	local gamepadPurchaseButton = frame.CatalogShopDetailsFrame.ButtonContainer.GamepadPurchaseButton;

	local function PurchaseProduct()
		purchaseButton:Click();
	end

	local function CanPurchaseProduct()
		return gamepadPurchaseButton:IsVisible() and purchaseButton:IsEnabled();
	end

	local detailsButton = frame.CatalogShopDetailsFrame.ButtonContainer.DetailsButton;
	local function CanViewProductDetails()
		return frame.CatalogShopDetailsFrame:IsVisible() and detailsButton:IsEnabled();
	end

	local function ViewProductDetails()
		detailsButton:Click();
		SmartNavigation:HideCursor();
	end

	local modelScene = frame.ModelSceneContainerFrame.MainModelScene;
	local function CanRotateProduct()
		return frame:CanRotateCurrentProduct();
	end

	local function RotateProduct(x, y)
		if x == 0 or not CanRotateProduct() then
			modelScene:StopCameraYaw();
			return;
		end

		local direction = x < 0 and "left" or "right";
		modelScene:AdjustCameraYaw(direction, .05);
	end

	local function FocusSearch()
		frame.HeaderFrame.SearchBox:SetFocus();
	end

	local detailsBackButton = frame.ProductDetailsContainerFrame.BackButton;
	local function Back()
		if frame.HeaderFrame.SearchBox:HasFocus() then
			CatalogShopFrameClearButton:Click();
			return;
		end

		if frame.showDetails then
			detailsBackButton:Click();
			SmartNavigation:ShowCursor();
			return;
		end

		CatalogShopFrameCloseButton:Click();
	end

	data.modelSceneRotationBindings = GamepadMode.CreateBindingGroup("CatalogShopModelSceneRotation");
	data.modelSceneRotationBindings:AddAxisBinding(GAMEPAD_STICK_LEFT, RotateProduct);

	local rotateProduct = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_LEFT, nil, ACTION_LABEL_ROTATE);
	rotateProduct:AddCondition(CanRotateProduct);
	rotateProduct:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local purchaseProduct = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, PurchaseProduct, CONTEXT_ACTION_LABEL_BUY);
	purchaseProduct:AddCondition(CanPurchaseProduct);
	data.gamepadPurchaseIcon = GamepadMode.AddGamepadIconToButton(frame.CatalogShopDetailsFrame.ButtonContainer.GamepadPurchaseButton, GAMEPAD_FACE_BOTTOM, { buttonHeightScale = (0.65), });

	local viewDetails = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, ViewProductDetails, CONTEXT_ACTION_LABEL_DETAILS);
	viewDetails:AddCondition(CanViewProductDetails);

	local previousCategory = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_SHOULDER_LEFT, PreviousCategory);
	previousCategory:SetCustomPromptFrame(navBar.GamepadPreviousCategoryIcon);

	local nextCategory = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_SHOULDER_RIGHT, NextCategory);
	nextCategory:SetCustomPromptFrame(navBar.GamepadNextCategoryIcon);

	local search = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, FocusSearch, nil);
	search:SetCustomPromptFrame(frame.HeaderFrame.SearchBoxIcon);

	local back = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, Back, FRAME_ACTION_CLOSE);

	local function AddSharedBindings(footer)
		footer:AddPromptedBinding(rotateProduct);
		footer:AddPromptedBinding(previousCategory);
		footer:AddPromptedBinding(nextCategory);
		footer:AddPromptedBinding(search);
		footer:AddPromptedBinding(back);
	end

	data.footer = GamepadSharedUtility.CreatePromptedBindingFooter(frame);
	data.footer:AddPromptedBinding(purchaseProduct);
	data.footer:AddPromptedBinding(viewDetails);
	AddSharedBindings(data.footer);
	data.footer:Finalize();

	-- Footer for product details frame
	local function OpenBnetLink()
		local legalDisclaimerText = frame.ProductDetailsContainerFrame.DetailsProductContainerFrame.ProductsHeader.LegalDisclaimerText;

		local hyperlinkOwner = legalDisclaimerText:GetParent();
		local onHyperlinkClick = hyperlinkOwner:GetScript("OnHyperlinkClick");

		if onHyperlinkClick then
			onHyperlinkClick(hyperlinkOwner, "codelink", CATALOG_SHOP_DISCLAIMER_ALL_PRODUCTS, "LeftButton", legalDisclaimerText);
		end
	end

	local openBnet = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, OpenBnetLink, FRAME_ACTION_BATTLE_NET);

	data.detailsFooter = GamepadSharedUtility.CreatePromptedBindingFooter(frame);
	data.detailsFooter:AddPromptedBinding(openBnet);
	AddSharedBindings(data.detailsFooter);
	data.detailsFooter:Finalize();
end
