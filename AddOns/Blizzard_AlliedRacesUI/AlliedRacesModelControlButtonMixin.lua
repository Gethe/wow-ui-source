
--------------------------------------------------
-- ALLIED RACES MODEL CONTROL BUTTON MIXIN
AlliedRacesModelControlButtonMixin = CreateFromMixins{ModelControlButtonMixin};

function AlliedRacesModelControlButtonMixin:OnLoad()
	--cache off the model
	self.model = self:GetParent();
end

function AlliedRacesModelControlButtonMixin:OnMouseDown()
	self.Icon:SetPoint("CENTER", 1, -1);
end

function AlliedRacesModelControlButtonMixin:OnMouseUp()
	self.Icon:SetPoint("CENTER",0, 0);
end


--------------------------------------------------
-- ALLIED RACES MODEL CONTROL ROTATE BUTTON MIXIN
AlliedRacesModelControlRotateButtonMixin = CreateFromMixins(ModelControlRotateButtonMixin, AlliedRacesModelControlButtonMixin);

function AlliedRacesModelControlRotateButtonMixin:OnLoad()
	AlliedRacesModelControlButtonMixin.OnLoad(self);
	self:RegisterForClicks("AnyUp");

	if (self.rotateDirection == "left") then
		self.Icon:SetAtlas("AlliedRace-UnlockingFrame-LeftRotation", true);
	elseif (self.rotateDirection == "right") then
		self.Icon:SetAtlas("AlliedRace-UnlockingFrame-RightRotation", true);
	else
		assert("Invalid rotation specified: "..self.rotateDirection);
	end
end


--------------------------------------------------
-- ALLIED RACES MODEL CONTROL ZOOM BUTTON MIXIN
AlliedRacesModelControlZoomButtonMixin = CreateFromMixins(ModelControlZoomButtonMixin, AlliedRacesModelControlButtonMixin);

function AlliedRacesModelControlZoomButtonMixin:OnLoad()
	AlliedRacesModelControlButtonMixin.OnLoad(self);
	self:RegisterForClicks("AnyUp");
	if (self.zoomIn) then
		self.Icon:SetAtlas("AlliedRace-UnlockingFrame-ZoomIn", true);
	else
		self.Icon:SetAtlas("AlliedRace-UnlockingFrame-ZoomOut", true);
	end
end
