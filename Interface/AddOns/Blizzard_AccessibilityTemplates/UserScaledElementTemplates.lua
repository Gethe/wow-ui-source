UserScaledElementMixin = {};

function UserScaledElementMixin:OnLoad_UserScaledElement()
	TextSizeManager:RegisterObject(self);
end

function UserScaledElementMixin:UpdateWidth()
	TextSizeManager:UpdateObject(self);
end

function UserScaledElementMixin:GetWeightedScale(scaleContext, scale, registrationInfo)
	registrationInfo = registrationInfo or self;
	scale = scale or TextSizeManager:GetScale();

	local useWeightedScale = (scaleContext == "width") or (scaleContext == "height" and registrationInfo.useScaleWeightForHeight);
	if useWeightedScale then
		return TextSizeManager:GetWeightedScale(scale, registrationInfo);
	else
		return scale;
	end
end

function UserScaledElementMixin:GetScaledDesiredDimension(scaleContext, dimensionValue, scale, registrationInfo)
	if dimensionValue then
		return dimensionValue * self:GetWeightedScale(scaleContext, scale, registrationInfo);
	end
end

function UserScaledElementMixin:SetDesiredWidth(desiredWidth)
	self.desiredWidth = desiredWidth;
	TextSizeManager:UpdateObject(self);
end

function UserScaledElementMixin:GetDesiredWidth(registrationInfo)
	return self.desiredWidth or (registrationInfo and registrationInfo.baseWidth);
end

function UserScaledElementMixin:GetScaledDesiredWidth(scale, registrationInfo)
	registrationInfo = registrationInfo or self;
	local scaledWidth = self:GetScaledDesiredDimension("width", self:GetDesiredWidth(registrationInfo), scale, registrationInfo);
	return registrationInfo.maxWidth and math.min(scaledWidth, registrationInfo.maxWidth) or scaledWidth;
end

function UserScaledElementMixin:GetDesiredHeight(registrationInfo)
	return registrationInfo and registrationInfo.baseHeight;
end

function UserScaledElementMixin:GetScaledDesiredHeight(scale, registrationInfo)
	registrationInfo = registrationInfo or self;
	return self:GetScaledDesiredDimension("height", self:GetDesiredHeight(registrationInfo), scale, registrationInfo);
end

function UserScaledElementMixin:OnTextScaleUpdated(scale, registrationInfo)
	local scaledWidth = self:GetScaledDesiredWidth(scale, registrationInfo);
	if scaledWidth then
		self:SetWidth(scaledWidth);
	end

	local scaledHeight = self:GetScaledDesiredHeight(scale, registrationInfo);
	if scaledHeight then
		self:SetHeight(scaledHeight);
	end
end

UserScaledButtonFitToTextMixin = CreateFromMixins(UserScaledElementMixin);

function UserScaledButtonFitToTextMixin:OnLoad()
	self:OnLoad_UserScaledElement();
	self:ReanchorTextForScale();
end

function UserScaledButtonFitToTextMixin:ReanchorTextForScale(scale, registrationInfo)
	self.Text:ClearAllPoints();
	local scaledButtonTextInset = (self.baseButtonTextInset or 0) * self:GetWeightedScale("width", scale, registrationInfo);
	self.Text:SetPoint("LEFT", scaledButtonTextInset, 0);
	self.Text:SetPoint("RIGHT", -scaledButtonTextInset, 0);
end

function UserScaledButtonFitToTextMixin:SetText(text)
	self.Text:SetText(text);
	self:UpdateWidth();
end

function UserScaledButtonFitToTextMixin:OnTextScaleUpdated(scale, registrationInfo)
	self:TryRecalculateDesiredWidth(scale);
	UserScaledElementMixin.OnTextScaleUpdated(self, scale, registrationInfo);
	self:ReanchorTextForScale(scale, registrationInfo);
end

function UserScaledButtonFitToTextMixin:TryRecalculateDesiredWidth(scale)
	-- Inset applies to both sides of the button so multiply by 2.
	local buttonTextInsetWidth = (self.baseButtonTextInset or 0) * 2;
	local unboundedStringWidth = self.Text:GetUnboundedStringWidth() / scale;
	local fitToTextWidth = unboundedStringWidth + buttonTextInsetWidth;
	self.desiredWidth = math.max(self.baseWidth, fitToTextWidth);
end

UserScaledFrameByHeightMixin = {}

function UserScaledFrameByHeightMixin:OnLoad_UserScaledByHeight()
	TextSizeManager:RegisterObject(self);
end

--Actually do have to forward declare for mutual recursion of local functions
local GetContributingHeight;

local function GetHeightFromRegions(...)
	local contributedHeight = 0;
	for i = 1, select("#", ...) do
		local region = select(i, ...);
		if region:IsObjectType("FontString") then
			if region.heightContributing then
				contributedHeight = contributedHeight + region:GetFontHeight();
			end
		end
	end
	return contributedHeight;
end

local function GetHeightFromChildren(...)
	local contributedHeight = 0;
	for i = 1, select("#", ...) do
		local child = select(i, ...);
		contributedHeight = contributedHeight + GetContributingHeight(child);
	end
	return contributedHeight;
end

GetContributingHeight = function(elem)
	local contributedHeight = elem.additionalHeight or 0;

	contributedHeight = contributedHeight + GetHeightFromRegions(elem:GetRegions());
	contributedHeight = contributedHeight + GetHeightFromChildren(elem:GetChildren());

	return contributedHeight;
end

function UserScaledFrameByHeightMixin:OnTextScaleUpdated(scale, registrationInfo)
	self:SetHeight(GetContributingHeight(self));
end
