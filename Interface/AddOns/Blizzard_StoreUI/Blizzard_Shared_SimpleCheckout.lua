---------------
--NOTE - Please do not change this section without talking to Dan
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

Import("IsOnGlueScreen");
Import("GetPhysicalScreenSize");
Import("GetScreenDPIScale");

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
			self:CalculateDesiredSize();
			self:RecalculateSize();
			self:Show();
			if (self:OpenCheckout(checkoutID)) then
				self:SetFocus();
			else
				self:Hide();
			end
		else
			self:CancelOpenCheckout();
		end
	elseif (event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED") then
		self:CalculateDesiredSize();
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
	-- newWidth and newHeight are in pixels
	self.desiredWidth = newWidth;
	self.desiredHeight = newHeight;

	self:RecalculateSize();
end

function SimpleCheckoutMixin:OnExternalLink()
	self:OpenExternalLink();
end

do
	local baseWidth = 860;
	local baseHeight = 645;

	local NormalizeScaleMultiplier = function(multiplier)
		if multiplier > 2.4 then
			return 3;
		elseif multiplier > 1.4 then
			return 2;
		else 
			return 1;
		end
	end

	function SimpleCheckoutMixin:CalculateDesiredSize()
		local physicalWidth, physicalHeight = GetPhysicalScreenSize();

		local scaleMultiplier = NormalizeScaleMultiplier(GetScreenDPIScale());

		local desiredWidth = baseWidth * scaleMultiplier;
		local desiredHeight = baseHeight * scaleMultiplier;
	
		while scaleMultiplier >= 2 and (desiredWidth > physicalWidth * 0.9 or desiredHeight > physicalHeight * 0.9) do
			scaleMultiplier = scaleMultiplier - 1;

			desiredWidth = baseWidth * scaleMultiplier;
			desiredHeight = baseHeight * scaleMultiplier;
		end

		self.desiredWidth = desiredWidth;
		self.desiredHeight = desiredHeight;
	end
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
	local physicalWidth, physicalHeight = GetPhysicalScreenSize();

	local pixelSize = ConvertPixelsToUI(1, self:GetEffectiveScale());

	-- Convert to ui coordinates, clamping to 90% of window size
	local desiredWidth = Clamp(self.desiredWidth * pixelSize, 1, physicalWidth * pixelSize * 0.9);
	local desiredHeight = Clamp(self.desiredHeight * pixelSize, 1, physicalHeight * pixelSize * 0.9);

	-- Convert back to pixel coordinates; this will include any clamping done above
	local uiWidth = desiredWidth / pixelSize;
	local uiHeight = desiredHeight / pixelSize;

	-- position frame on a pixel boundary.
	local left = math.floor((physicalWidth - uiWidth) / 2) * pixelSize;
	local bottom = math.floor((physicalHeight - uiHeight) / 2) * pixelSize;

	self:ClearAllPoints();
	self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom);
	self:SetSize(desiredWidth, desiredHeight);

	self.CloseButton:SetSize(20 * pixelSize, 20 * pixelSize);
	self.CloseButton:ClearAllPoints();
	self.CloseButton:SetPoint("TOPRIGHT", self, -10 * pixelSize, -20 * pixelSize);

	SetOffsets(self.TopInside, self.LeftInside, self.BottomInside, self.RightInside, pixelSize, -1, 1, 1, -1);
	SetOffsets(self.TopOutside, self.LeftOutside, self.BottomOutside, self.RightOutside, pixelSize, 0, 0, 0, 0);
end
