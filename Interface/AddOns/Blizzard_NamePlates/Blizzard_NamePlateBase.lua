-- Mixed in with the frame created in code.
-- Positioned and sized in code.
-- Contains a child using NamePlateUnitFrameMixin (self.UnitFrame) which displays the info about the unit to which the nameplate is attached.
NamePlateBaseMixin = {};

function NamePlateBaseMixin:Init(unitFrameTemplate, driverFrame)
	self:SetScript("OnSizeChanged", self.OnSizeChanged);

	self.unitFrameTemplate = unitFrameTemplate;
	self.driverFrame = driverFrame;
end

function NamePlateBaseMixin:GetUnitFrameTemplate()
	return self.unitFrameTemplate;
end

function NamePlateBaseMixin:AcquireUnitFrame()
	self.UnitFrame = self.driverFrame:AcquireUnitFrame(self);
	self.UnitFrame:SetParent(self);
	self.UnitFrame:SetAllPoints(self);
end

function NamePlateBaseMixin:ReleaseUnitFrame()
	self.driverFrame:ReleaseUnitFrame(self);
	self.UnitFrame = nil;
end

function NamePlateBaseMixin:SetUnit(namePlateUnitToken)
	self.unitToken = self.explicitUnitToken or namePlateUnitToken;

	self:ApplyFrameOptions();

	self.UnitFrame:OnUnitSet();
end

function NamePlateBaseMixin:GetUnit()
	return self.unitToken;
end

function NamePlateBaseMixin:ClearUnit()
	self.unitToken = nil;

	CompactUnitFrame_SetUnit(self.UnitFrame, nil);
	self.UnitFrame:OnUnitCleared();
end

function NamePlateBaseMixin:OnSizeChanged()
	if self.unitToken and self:IsVisible() then
		-- Necessary to align all components back to pixel boundaries as the nameplate moves around the screen and prevent jiterring.
		self.UnitFrame:UpdateAnchors();

		self.driverFrame:OnNamePlateResized(self);
	end
end

function NamePlateBaseMixin:GetFrameOptions()
	if UnitIsFriend("player", self.unitToken) and self.explicitEnemyFrameOptions ~= true then
		return NamePlateFriendlyFrameOptions;
	else
		return NamePlateEnemyFrameOptions;
	end
end

function NamePlateBaseMixin:ApplyFrameOptions()
	local applyFrameOptionsFunction = function()
		local frameOptions = self:GetFrameOptions();
		self.UnitFrame:ApplyFrameOptions(NamePlateSetupOptions, frameOptions);
	end

	CompactUnitFrame_SetUpFrame(self.UnitFrame, applyFrameOptionsFunction);
	CompactUnitFrame_SetUnit(self.UnitFrame, self.unitToken);
end
