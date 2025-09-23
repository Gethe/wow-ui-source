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
	return self:GetScaledDesiredDimension("width", self:GetDesiredWidth(registrationInfo), scale, registrationInfo);
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
