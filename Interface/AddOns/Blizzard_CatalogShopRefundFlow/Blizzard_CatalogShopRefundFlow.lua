local ScreenPadding =
{
	Horizontal = 100,
	Vertical = 100,
};

local SortFields =
{
	DecorGUID = "decorGUID",
	Name = "name",
	Price = "price",
	TimeRemainingSeconds = "timeRemainingSeconds",
};

-- Async timeouts
local BULK_REFUND_RESULT_RECEIVED_TIMEOUT_SECONDS = 15;
local CATALOG_SHOP_REFUNDABLE_DECORS_UPDATED_TIMEOUT_SECONDS = 5;

----------------------------------------------------------------------------------
-- CatalogShopRefundFrameMixin
----------------------------------------------------------------------------------
CatalogShopRefundFrameMixin = {};
function CatalogShopRefundFrameMixin:OnLoad()
	if ( C_Glue.IsOnGlueScreen() ) then
		self:SetFrameStrata("FULLSCREEN_DIALOG");
		-- block keys
		self:EnableKeyboard(true);
		self:SetScript("OnKeyDown",
			function(self, key)
				if ( key == "ESCAPE" ) then
					CatalogShopRefundFrame:SetAttribute("action", "EscapePressed");
				end
			end
		);
	end

	self:SetTitle(CATALOG_SHOP_REFUND_FLOW_TITLE);

	self.onCloseCallback = function()
		self:Hide(); 
		return false;
	end;

	do
		local scrollContainer = self.DecorsScrollBoxContainer;

		local DefaultPad = 5;
		local DefaultSpacing = 1;

		local function InitializeButton(frame, decorInfo)
			frame:SetDecorInfo(decorInfo);
			frame:SetScript("OnClick", function(button, buttonName)
				button:ToggleSelected();
			end);
		end

		local view = CreateScrollBoxListLinearView(DefaultPad, DefaultPad, DefaultPad, DefaultPad, DefaultSpacing);
		view:SetElementFactory(function(factory, elementData)
			factory("RefundFlowDecorButtonTemplate", InitializeButton);
		end);
		ScrollUtil.InitScrollBoxListWithScrollBar(scrollContainer.ScrollBox, scrollContainer.ScrollBar, view);
	end

	self.isProcessingRefund = false;
	self.refundableDecors = {};
	self.sortField = SortFields.TimeRemainingSeconds;
	self.sortAscending = self:GetDefaultSortAscending(self.sortField);

	-- Set up the async requests for refund processing
	self.refreshRequest = AsyncRequests:CreateAsyncRequest({
		requestFunction = function()
			C_CatalogShop.RefreshRefundableDecors();
		end,
		responseEventName = "CATALOG_SHOP_REFUNDABLE_DECORS_UPDATED",
		responseEventCallback = function()
			self:StopProcessing();
		end,
		timeoutSeconds = CATALOG_SHOP_REFUNDABLE_DECORS_UPDATED_TIMEOUT_SECONDS,
		timeoutCallback = function()
			self:StopProcessing();
			self:ShowBulkRefundError(BLIZZARD_STORE_ERROR_TITLE_OTHER);
		end,
	});
	self.refundRequest = AsyncRequests:CreateAsyncRequest({
		requestFunction = function(selectedGUIDs)
			self:StartProcessing();
			C_CatalogShop.BulkRefundDecors(selectedGUIDs);
		end,
		responseEventName = "BULK_REFUND_RESULT_RECEIVED",
		responseEventCallback = function(result)
			if (result == Enum.BulkRefundResult.ResultOk) then
				-- TODO (WOW12-25993): This timer is a workaround for the server-side entitlements refresh delay.
				--                     When WOW12-25993 is being worked on, remove this timer and just call the inner function directly.
				C_Timer.NewTimer(10, function()
					self.refreshRequest:StartRequest();
				end);
			else
				self:StopProcessing();
				self:ShowBulkRefundError(BLIZZARD_STORE_ERROR_TITLE_OTHER);
			end
		end,
		timeoutSeconds = BULK_REFUND_RESULT_RECEIVED_TIMEOUT_SECONDS,
		timeoutCallback = function()
			self:StopProcessing();
			self:ShowBulkRefundError(BLIZZARD_STORE_ERROR_TITLE_OTHER);
		end,
	});

	self:RegisterEvent("CATALOG_SHOP_REFUNDABLE_DECORS_UPDATED");
end

function CatalogShopRefundFrameMixin:OnEvent(event, ...)
	if (event == "CATALOG_SHOP_REFUNDABLE_DECORS_UPDATED") then
		self:UpdateDecors();
	end
end

local INTERVAL_UPDATE_SECONDS_TIME = 60.0;
function CatalogShopRefundFrameMixin:OnUpdate(deltaTime)
	self.currentInterval = self.currentInterval + deltaTime;
	if self.currentInterval >= INTERVAL_UPDATE_SECONDS_TIME then
		self:UpdateDecors();
		self.currentInterval = 0.0;
	end
end

function CatalogShopRefundFrameMixin:OnShow()
	EventRegistry:RegisterCallback("CatalogShopRefund.SortFieldSet", self.SortFieldSet, self);
	EventRegistry:RegisterCallback("CatalogShopRefund.SelectionsUpdated", self.SelectionsUpdated, self);

	self:SetAttribute("isshown", true);
	if ( not C_Glue.IsOnGlueScreen() ) then
		
	else
		
	end
	self:ShowCoverFrame();
	FrameUtil.UpdateScaleForFitSpecific(self, self:GetWidth() + ScreenPadding.Horizontal, self:GetHeight() + ScreenPadding.Vertical);

	self.currentInterval = 0.0;
	self:UpdateDecors();
	self:UpdateProcessing();
end

function CatalogShopRefundFrameMixin:OnHide()
	EventRegistry:UnregisterCallback("CatalogShopRefund.SortFieldSet", self);
	EventRegistry:UnregisterCallback("CatalogShopRefund.SelectionsUpdated", self);

	self:SetAttribute("isshown", false);

	if ( not C_Glue.IsOnGlueScreen() ) then

	else

	end
	self:HideCoverFrame();
	PlaySound(SOUNDKIT.CATALOG_SHOP_CLOSE_SHOP);
end

function CatalogShopRefundFrameMixin:ShowCoverFrame()
	local coverFrameParent = GetAppropriateTopLevelParent();
	self.CoverFrame:ClearAllPoints();
	self.CoverFrame:SetPoint("TOPLEFT", coverFrameParent, "TOPLEFT");
	self.CoverFrame:SetPoint("BOTTOMRIGHT", coverFrameParent, "BOTTOMRIGHT");
	self.CoverFrame:SetShown(true);
end

function CatalogShopRefundFrameMixin:HideCoverFrame()
	self.CoverFrame:SetShown(false);
end

function CatalogShopRefundFrameMixin:StartProcessing()
	self.isProcessingRefund = true;
	self.ProcessingContainer:Show();
end

function CatalogShopRefundFrameMixin:StopProcessing()
	self.isProcessingRefund = false;
	self.ProcessingContainer:Hide();
end

function CatalogShopRefundFrameMixin:UpdateProcessing()
	self.ProcessingContainer:SetShown(self.isProcessingRefund);
end

function CatalogShopRefundFrameMixin:OnAttributeChanged(name, value)
	--Note - Setting attributes is how the external UI should communicate with this frame. That way their taint won't be spread to this code.
	if ( name == "action" ) then
		if ( value == "Show" ) then
			local parent = CatalogShopRefundFlowOutbound.GetAppropriateTopLevelParent();
			FrameUtil.SetParentMaintainRenderLayering(self, parent);
			self:Show();
		elseif ( value == "Hide" ) then
			self:Hide();
		elseif ( value == "EscapePressed" ) then
			local handled = false;
			if ( self:IsShown() ) then
				self:Hide();
				handled = true;
			end
			self:SetAttribute("escaperesult", handled);
		end
	end
end

function CatalogShopRefundFrameMixin:Leave()
	--... handle leaving
	self:Hide();
end

function CatalogShopRefundFrameMixin:SetSortAscending(ascending)
	self.sortAscending = ascending;
end

function CatalogShopRefundFrameMixin:GetSortAscending()
	return self.sortAscending;
end

-- TODO (WOW12-45327): Table would be a little cleaner here mapping a SortFields to a default (see https://wowhub.corp.blizzard.net/warcraft/wow/pull/40310)
function CatalogShopRefundFrameMixin:GetDefaultSortAscending(sortField)
	if (sortField == SortFields.DecorGUID) then
		return true;
	elseif (sortField == SortFields.Name) then
		return true;
	elseif (sortField == SortFields.Price) then
		return false;
	elseif (sortField == SortFields.TimeRemainingSeconds) then
		return true;
	end
	return true;
end

function CatalogShopRefundFrameMixin:SetSortField(sortField)
	if (self.sortField == sortField) then
		self:SetSortAscending(not self:GetSortAscending());
	else
		-- If we are setting the sort field to something new, then default SortAscending to whatever that field prefers
		local sortAscending = self:GetDefaultSortAscending(sortField);
		self:SetSortAscending(sortAscending);
	end
	self.sortField = sortField;
	EventRegistry:TriggerEvent("CatalogShopRefund.SortFieldSet");
end

function CatalogShopRefundFrameMixin:GetSortField()
	return self.sortField or SortFields.TimeRemainingSeconds;
end

local function DecorSortComparator(lhs, rhs)
	local sortField = CatalogShopRefundFrame:GetSortField();
	local sortAscending = CatalogShopRefundFrame:GetSortAscending();
	local lhsValue = lhs[sortField];
	local rhsValue = rhs[sortField];

	-- Fall back to name then decorGUID if the original values are equal
	if (lhsValue == rhsValue) then
		if (lhs.name ~= rhs.name) then
			sortAscending = CatalogShopRefundFrame:GetDefaultSortAscending(SortFields.Name);
			lhsValue = lhs.name;
			rhsValue = rhs.name;
		else
			sortAscending = CatalogShopRefundFrame:GetDefaultSortAscending(SortFields.DecorGUID);
			lhsValue = lhs.decorGUID;
			rhsValue = rhs.decorGUID;
		end
	end

	if sortAscending then
		return lhsValue < rhsValue;
	else
		return  lhsValue > rhsValue;
	end
end

function CatalogShopRefundFrameMixin:GetDecor(decorGUID)
	return self.refundableDecors[decorGUID];
end

function CatalogShopRefundFrameMixin:UpdateDecors()
	local dataProvider = CreateDataProvider();

	local productID = CatalogShopRefundFrame:GetAttribute("productid");
	local refundableDecorInfos = C_CatalogShop.GetRefundableDecors(productID);

	local refundableDecorsNew = {};
	for _, refundableDecorInfo in ipairs(refundableDecorInfos) do
		local refundableDecorOld = self.refundableDecors[refundableDecorInfo.decorGUID];

		refundableDecorsNew[refundableDecorInfo.decorGUID] = refundableDecorInfo;
		local refundableDecorNew = refundableDecorsNew[refundableDecorInfo.decorGUID];
		refundableDecorNew.isSelected = refundableDecorOld and refundableDecorOld.isSelected or false;

		dataProvider:Insert(refundableDecorNew);
	end
	self.refundableDecors = refundableDecorsNew;

	if (TableIsEmpty(self.refundableDecors)) then
		self:Hide();
		return;
	end

	local retainScrollPosition = true;
	dataProvider:SetSortComparator(DecorSortComparator);
	self.DecorsScrollBoxContainer.ScrollBox:SetDataProvider(dataProvider, retainScrollPosition);

	self:SelectionsUpdated();
end

function CatalogShopRefundFrameMixin:SortFieldSet()
	local dataProvider = self.DecorsScrollBoxContainer.ScrollBox:GetDataProvider();
	if (not dataProvider) then
		return;
	end

	dataProvider:Sort();
end

function CatalogShopRefundFrameMixin:SelectionsUpdated()
	local numSelected = 0;
	local numUnselected = 0;
	local totalRefund = 0;

	for _, decorInfo in pairs(self.refundableDecors) do
		if (decorInfo.isSelected) then
			totalRefund = totalRefund + decorInfo.price;
			numSelected = numSelected + 1;
		else
			numUnselected = numUnselected + 1;
		end
	end

	self.RefundButton:SetEnabled(numSelected > 0);
	self.TotalRefundContainer.TotalRefundAmountText:SetText(totalRefund);

	-- Flip the select all/select none button if necessary
	local selectAllButton = self.DecorsScrollBoxContainer.SelectAllButton;
	if (numUnselected > 0 or (numSelected == 0 and numUnselected == 0)) then
		selectAllButton:SetText(CATALOG_SHOP_REFUND_FLOW_SELECT_ALL);
		selectAllButton.isSelectAll = true;
	else
		selectAllButton:SetText(CATALOG_SHOP_REFUND_FLOW_SELECT_NONE);
		selectAllButton.isSelectAll = false;
	end
	selectAllButton:SetEnabled(numSelected > 0 or numUnselected > 0);
end

function CatalogShopRefundFrameMixin:SelectAllDecors()
	local isSelectAll = self.DecorsScrollBoxContainer.SelectAllButton.isSelectAll;

	for _, decorInfo in pairs(self.refundableDecors) do
		decorInfo.isSelected = isSelectAll;
	end

	self.DecorsScrollBoxContainer.ScrollBox:ForEachFrame(function(frame, _)
		frame:SetSelectedNoClick(isSelectAll);
	end);

	self:SelectionsUpdated();
end

function CatalogShopRefundFrameMixin:RefundSelectedDecors()
	if (self.isProcessingRefund) then
		self:ShowBulkRefundError(BLIZZARD_STORE_ERROR_TITLE_OTHER);
		return;
	end

	local selectedGUIDs = {};
	for decorGUID, decorInfo in pairs(self.refundableDecors) do
		if (decorInfo.isSelected) then
			table.insert(selectedGUIDs, decorGUID);
		end
	end

	if (#selectedGUIDs <= 0) then
		self:ShowBulkRefundError(BLIZZARD_STORE_ERROR_TITLE_OTHER);
		return;
	end

	self.refundRequest:StartRequest(selectedGUIDs);
end

function CatalogShopRefundFrameMixin:ShowBulkRefundError(errorMessage)
	CatalogShopRefundFlowOutbound.ShowBulkRefundError(errorMessage);
end
