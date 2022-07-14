--------------------------------------------------
-- MODEL CONTROL FRAME MIXIN
ModelControlFrameMixin = {};

function ModelControlFrameMixin:OnHide()
	if ( self.buttonDown ) then
		self.buttonDown:OnMouseUp();
	end
end


--------------------------------------------------
-- MODEL CONTROL BUTTON MIXIN
ModelControlButtonMixin = {};

function ModelControlButtonMixin:OnLoad()
	--cache off the model
	self.model = self:GetParent():GetParent();
end

function ModelControlButtonMixin:Init(clickTypes, texCoords, tooltip, tooltipText)
	self:RegisterForClicks(clickTypes);
	if (texCoords) then
		self.icon:SetTexCoord(unpack(texCoords));
	end
	self.tooltip = tooltip;
	self.tooltipText = tooltipText;
end

function ModelControlButtonMixin:OnMouseDown()
	self.bg:SetTexCoord(0.01562500, 0.26562500, 0.14843750, 0.27343750);
	self.icon:SetPoint("CENTER", 1, -1);
	self:GetParent().buttonDown = self;
end

function ModelControlButtonMixin:OnMouseUp()
	self.bg:SetTexCoord(0.29687500, 0.54687500, 0.14843750, 0.27343750);
	self.icon:SetPoint("CENTER", 0, 0);
	self:GetParent().buttonDown = nil;
end

function ModelControlButtonMixin:OnClick()
	--override for your mouse click 
end

function ModelControlButtonMixin:OnEnter()
	self:GetParent():SetAlpha(1);
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetText(self.tooltip, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		if ( self.tooltipText ) then
			GameTooltip:AddLine(self.tooltipText, _, _, _, 1, 1);
		end
		GameTooltip:Show();
	end
end

function ModelControlButtonMixin:OnLeave()
	self:GetParent():SetAlpha(0.5);
	GameTooltip:Hide();
end


--------------------------------------------------
-- MODEL CONTROL ZOOM BUTTON MIXIN
ModelControlZoomButtonMixin = CreateFromMixins(ModelControlButtonMixin);

function ModelControlZoomButtonMixin:OnLoad()
	ModelControlButtonMixin.OnLoad(self);
	if (self.zoomIn == true) then
		ModelControlButtonMixin.Init(self, "AnyUp", {0.57812500, 0.82812500, 0.14843750, 0.27343750}, ZOOM_IN, KEY_MOUSEWHEELUP);
	else
		ModelControlButtonMixin.Init(self, "AnyUp", {0.29687500, 0.54687500, 0.00781250, 0.13281250}, ZOOM_OUT, KEY_MOUSEWHEELDOWN);
	end
end

function ModelControlZoomButtonMixin:OnClick()
	local zoomAmount = 1;
	if (not self.zoomIn) then
		zoomAmount = -1;
	end
	self.model:OnMouseWheel(zoomAmount);

	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end


--------------------------------------------------
-- MODEL CONTROL PAN BUTTON MIXIN
ModelControlPanButtonMixin = CreateFromMixins(ModelControlButtonMixin);

function ModelControlPanButtonMixin:OnLoad()
	ModelControlButtonMixin.OnLoad(self);
	ModelControlButtonMixin.Init(self, "AnyUp", {0.29687500, 0.54687500, 0.28906250, 0.41406250}, DRAG_MODEL, DRAG_MODEL_TOOLTIP);
end

function ModelControlPanButtonMixin:OnMouseDown()
	ModelControlButtonMixin.OnMouseDown(self);
	self.model:StartPanning(ModelPanningFrame);
end

function ModelControlPanButtonMixin:OnMouseUp()
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end


--------------------------------------------------
-- MODEL CONTROL RESET BUTTON MIXIN
ModelControlResetButtonMixin = CreateFromMixins(ModelControlButtonMixin);

function ModelControlResetButtonMixin:OnLoad()
	ModelControlButtonMixin.OnLoad(self);
	local texCoords = nil;
	local tooltipText = nil;
	ModelControlButtonMixin.Init(self, "AnyUp", texCoords, RESET_POSITION, tooltipText);
end

function ModelControlResetButtonMixin:OnClick()
	self.model:ResetModel();
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end


--------------------------------------------------
-- MODEL CONTROL ROTATE BUTTON MIXIN
ModelControlRotateButtonMixin = CreateFromMixins(ModelControlButtonMixin);

function ModelControlRotateButtonMixin:OnLoad()
	ModelControlButtonMixin.OnLoad(self);

	if (self.rotateDirection == "left") then
		ModelControlButtonMixin.Init(self, "AnyUp", {0.01562500, 0.26562500, 0.28906250, 0.41406250}, ROTATE_LEFT, ROTATE_TOOLTIP);
	elseif (self.rotateDirection == "right") then
		ModelControlButtonMixin.Init(self, "AnyUp", {0.57812500, 0.82812500, 0.28906250, 0.41406250}, ROTATE_RIGHT, ROTATE_TOOLTIP);
	else
		assert("Invalid rotation specified: "..self.rotateDirection);
	end
end

function ModelControlRotateButtonMixin:OnClick()
	if ( not rotationIncrement ) then
		rotationIncrement = 0.03;
	end

	if (self.rotateDirection == "left") then
		self.model.rotation = self.model.rotation + rotationIncrement;
	elseif (self.rotateDirection == "right") then
		self.model.rotation = self.model.rotation - rotationIncrement;
	else
		assert("Invalid rotation specified: "..self.rotateDirection);
	end
	
	self.model:SetRotation(self.model.rotation);
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end


--------------------------------------------------
-- MODEL PANNING FRAME MIXIN
ModelPanningFrameMixin = {};

function ModelPanningFrameMixin:OnLoad()
end

function ModelPanningFrameMixin:OnUpdate()
    local model = self.model;
	local controlFrame = self.model.controlFrame;
    if ( not IsMouseButtonDown(controlFrame.panButton) ) then
        model:StopPanning();
        if ( controlFrame.buttonDown ) then
			controlFrame.buttonDown:OnMouseUp();
        end
        if ( not controlFrame:IsMouseOver() ) then
			controlFrame:Hide();
        end
    end
end

