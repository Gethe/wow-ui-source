
local function LeaveFullscreenMode()
	AccountStoreFrame:SetFullscreenMode(false);
	AccountStoreUtil.SetAccountStoreShown(false);

	if EndOfMatchFrame and not EndOfMatchFrame:IsShown() and EndOfMatchFrame:HasMatchDetails() then
		EndOfMatchFrame:Show();
	end
end

AccountStoreMixin = {};

function AccountStoreMixin:OnLoad()
	self:SetTitle(PLUNDERSTORM_PLUNDER_STORE_TITLE);

	self:SetPortraitToAsset("Interface\\Icons\\WoW_Store");
	self:SetPortraitTextureSizeAndOffset(60, -5, 7);

	if UIPanelWindows then
		UIPanelWindows["AccountStoreFrame"] = { area = "left", pushable = 1, whileDead = 1 };
	end
end

function AccountStoreMixin:OnShow()
	EventRegistry:TriggerEvent("AccountStore.ShownState", true);
end

function AccountStoreMixin:OnHide()
	EventRegistry:TriggerEvent("AccountStore.ShownState", false);

	if self.inFullscreenMode then
		LeaveFullscreenMode();
	end
end

function AccountStoreMixin:SetStoreFrontID(storeFrontID)
	self.storeFrontID = storeFrontID;
	EventRegistry:TriggerEvent("AccountStore.StoreFrontSet", storeFrontID);
end

function AccountStoreMixin:SetFullscreenMode(enabled)
	local currentMainParent = GetAppropriateTopLevelParent();
	self:SetParent(enabled and FullscreenAccountStoreContainer or currentMainParent);	
	FullscreenAccountStoreContainer:SetShown(enabled);

	self:ClearAllPoints();

	if enabled then
		self:SetPoint("CENTER", self:GetParent(), "CENTER", 0, 0);
	else
		self:SetPoint("LEFT", self:GetParent(), "LEFT", 50, 0);
	end

	self.inFullscreenMode = enabled;
end

FullscreenAccountStoreContainerMixin = {};

function FullscreenAccountStoreContainerMixin:OnShow()
	local currParent = self:GetParent();
	if currParent == GlueParent then
		return;
	end

	StaticPopup_SetFullScreenFrame(self);
	AlertFrame:SetFullScreenFrame(self, "HIGH");
	AlertFrame:SetBaseAnchorFrame(AccountStoreFrameBottom);
	ActionStatus:SetAlternateParentFrame(self);

	AlertFrame:BlockLeftClickingAlerts(self);
end

function FullscreenAccountStoreContainerMixin:OnHide()
	if currParent == GlueParent then
		return;
	end

	StaticPopup_ClearFullScreenFrame();
	AlertFrame:ClearFullScreenFrame();
	AlertFrame:ResetBaseAnchorFrame();
	ActionStatus:ClearAlternateParentFrame();
	
	AlertFrame:UnblockLeftClickingAlerts(self);
end

function FullscreenAccountStoreContainerMixin:OnKeyDown(key)
	-- Since the parent is capturing input, we need to manually implement an Escape key
	if key == "ESCAPE" then
		LeaveFullscreenMode();
	end
end

FullscreenLeaveAccountStoreButtonMixin = {};

function FullscreenLeaveAccountStoreButtonMixin:OnLoad()
	local widthPadding = 80;
	local width = self:GetTextWidth() + widthPadding;
	self:SetWidth(width);
end

function FullscreenLeaveAccountStoreButtonMixin:OnClick()
	LeaveFullscreenMode();
end