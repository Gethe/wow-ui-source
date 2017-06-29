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
		if (checkoutID and StoreFrame:IsShown()) then
			self.requestedWidth = 800;
			self.requestedHeight = 600;
			self:RecalculateSize();
			if (self:OpenCheckout(checkoutID)) then
				self:Show();
				self:SetFocus();
			end
		end
	elseif (event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED") then
		self:RecalculateSize();
	end
end

function SimpleCheckoutMixin:OnShow()
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function SimpleCheckoutMixin:OnHide()
	self:UnregisterEvent("UI_SCALE_CHANGED");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");

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

	local requestedWidth = Clamp(self.requestedWidth * pixelSize, 1, physicalWidth * 0.9);
	local requestedHeight = Clamp(self.requestedHeight * pixelSize, 1, physicalHeight * 0.9);

	self:SetSize(requestedWidth, requestedHeight);

	self.CloseButton:SetSize(20 * pixelSize, 20 * pixelSize);
	self.CloseButton:ClearAllPoints();
	self.CloseButton:SetPoint("TOPRIGHT", self, -10 * pixelSize, -20 * pixelSize);

	SetOffsets(self.TopInside, self.LeftInside, self.BottomInside, self.RightInside, pixelSize, -1, 1, 1, -1);
	SetOffsets(self.TopOutside, self.LeftOutside, self.BottomOutside, self.RightOutside, pixelSize, 0, 0, 0, 0);
end

