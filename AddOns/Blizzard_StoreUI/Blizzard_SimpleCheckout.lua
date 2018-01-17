---------------
--NOTE - Please do not change this section without talking to Dan
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

Import("IsOnGlueScreen");
Import("GetScreenWidth");
Import("GetScreenHeight");
Import("GetPhysicalScreenSize");
Import("ConvertPixelsToUI");

if ( tbl.IsOnGlueScreen() ) then
	tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
end

setfenv(1, tbl);
----------------


SimpleCheckoutMixin = {};

function SimpleCheckoutMixin:OnLoad()
	self:RegisterEvent("STORE_OPEN_SIMPLE_CHECKOUT");
end

function SimpleCheckoutMixin:OnEvent(event, ...)
	if (event == "STORE_OPEN_SIMPLE_CHECKOUT") then
		local checkoutID = ...;
		if (StoreFrame:IsShown()) then
			self.requestedWidth = 800;
			self.requestedHeight = 600;
			self:RecalculateSize();
			if (self:OpenCheckout(checkoutID)) then
				self:Show();
				self:SetFocus();
			end
		else
			self:CancelOpenCheckout();
		end
	elseif (event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED") then
		self:RecalculateSize();
	elseif (event == "SUBSCRIPTION_CHANGED_KICK_IMMINENT") then
		if (IsOnGlueScreen()) then
			self.closeShopOnHide = true;
		end
	end
end

function SimpleCheckoutMixin:OnShow()
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("SUBSCRIPTION_CHANGED_KICK_IMMINENT");
	self.closeShopOnHide = false;
end

function SimpleCheckoutMixin:OnHide()
	self:UnregisterEvent("UI_SCALE_CHANGED");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("SUBSCRIPTION_CHANGED_KICK_IMMINENT");
	
	if (IsOnGlueScreen() and self.closeShopOnHide) then
		_G.SetStoreUIShown(false);
		_G.GlueDialog_Show("SUBSCRIPTION_CHANGED_KICK_WARNING");
		self.closeShopOnHide = false;
	end
	
	self:CloseCheckout();
end

function SimpleCheckoutMixin:OnRequestNewSize(newWidth, newHeight)
	-- newWidth and newHeight are in pixels; we need to convert to UI coordinates
	self.requestedWidth = newWidth;
	self.requestedHeight = newHeight;

	self:RecalculateSize();
end

local function SetOffsets(top, left, bottom, right, size, topOffset, leftOffset, bottomOffset, rightOffset)
	top:SetThickness(size);
	top:SetStartPoint("TOPLEFT", leftOffset * size, topOffset * size);
	top:SetEndPoint("TOPRIGHT", rightOffset * size, topOffset * size);

	left:SetThickness(size);
	left:SetStartPoint("TOPLEFT", leftOffset * size, (topOffset - 1) * size);
	left:SetEndPoint("BOTTOMLEFT", leftOffset * size, (bottomOffset + 1) * size);

	bottom:SetThickness(size);
	bottom:SetStartPoint("BOTTOMLEFT", leftOffset * size, bottomOffset * size);
	bottom:SetEndPoint("BOTTOMRIGHT", rightOffset * size, bottomOffset * size);

	right:SetThickness(size);
	right:SetStartPoint("TOPRIGHT", rightOffset * size, (topOffset - 1) * size);
	right:SetEndPoint("BOTTOMRIGHT", rightOffset * size, (bottomOffset + 1) * size);
end

function SimpleCheckoutMixin:RecalculateSize()
	local screenWidth = GetScreenWidth();
	local screenHeight = GetScreenHeight();

	local physicalWidth, physicalHeight = GetPhysicalScreenSize();

	local pixelSize = ConvertPixelsToUI(1, self:GetEffectiveScale());

	-- Convert to ui coordinates, clamping to 90% of window size
	local requestedWidth = Clamp(self.requestedWidth * pixelSize, 1, physicalWidth * pixelSize * 0.9);
	local requestedHeight = Clamp(self.requestedHeight * pixelSize, 1, physicalHeight * pixelSize * 0.9);

	-- Convert back to pixel coordinates; this will include any clamping done above
	local uiWidth = requestedWidth / pixelSize;
	local uiHeight = requestedHeight / pixelSize;

	-- position frame on a pixel boundary.
	local left = math.floor((physicalWidth - uiWidth) / 2) * pixelSize;
	local bottom = math.floor((physicalHeight - uiHeight) / 2) * pixelSize;

	self:ClearAllPoints();
	self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom);
	self:SetSize(requestedWidth, requestedHeight);

	self.CloseButton:SetSize(20 * pixelSize, 20 * pixelSize);
	self.CloseButton:ClearAllPoints();
	self.CloseButton:SetPoint("TOPRIGHT", self, -10 * pixelSize, -20 * pixelSize);

	SetOffsets(self.TopInside, self.LeftInside, self.BottomInside, self.RightInside, pixelSize, -1, 1, 1, -1);
	SetOffsets(self.TopOutside, self.LeftOutside, self.BottomOutside, self.RightOutside, pixelSize, 0, 0, 0, 0);
end

