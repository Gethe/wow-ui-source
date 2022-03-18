
--------------------------------------------------
-- MODEL SCENE CONTROL FRAME MIXIN
ModelSceneControlFrameMixin = {};

function ModelSceneControlFrameMixin:OnHide()
end


--------------------------------------------------
-- MODEL SCENE CONTROL BUTTON MIXIN
ModelSceneControlButtonMixin = {};

function ModelSceneControlButtonMixin:OnLoad()
	--cache off the model
	self.modelScene = self:GetParent():GetParent();
end

function ModelSceneControlButtonMixin:Init(clickTypes, texCoords, tooltip, tooltipText)
	self:RegisterForClicks(clickTypes);
	if (texCoords) then
		self.icon:SetTexCoord(unpack(texCoords));
	end
	self.tooltip = tooltip;
	self.tooltipText = tooltipText;
end

function ModelSceneControlButtonMixin:OnMouseDown()
	self.bg:SetTexCoord(0.01562500, 0.26562500, 0.14843750, 0.27343750);
	self.icon:SetPoint("CENTER", 1, -1);
	self:GetParent().buttonDown = self;
end

function ModelSceneControlButtonMixin:OnMouseUp()
	self.bg:SetTexCoord(0.29687500, 0.54687500, 0.14843750, 0.27343750);
	self.icon:SetPoint("CENTER", 0, 0);
	self:GetParent().buttonDown = nil;
end

function ModelSceneControlButtonMixin:OnClick()
	--override for your mouse click 
end

function ModelSceneControlButtonMixin:OnEnter()
	self:GetParent():SetAlpha(1);
	if ( GetCVar("UberTooltips") == "1" ) then
		local uiParent = GetAppropriateTopLevelParent();
		GameTooltip_SetDefaultAnchor(GameTooltip, uiParent);
		GameTooltip:SetText(self.tooltip, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		if ( self.tooltipText ) then
			GameTooltip:AddLine(self.tooltipText, _, _, _, 1, 1);
		end
		GameTooltip:Show();
	end
end

function ModelSceneControlButtonMixin:OnLeave()
	self:GetParent():SetAlpha(0.5);
	GameTooltip:Hide();
end


--------------------------------------------------
-- MODEL ZOOM BUTTON MIXIN
ModelSceneZoomButtonMixin = CreateFromMixins(ModelSceneControlButtonMixin);

function ModelSceneZoomButtonMixin:OnLoad()
	ModelSceneControlButtonMixin.OnLoad(self);
	if (self.zoomIn == true) then
		ModelSceneControlButtonMixin.Init(self, "AnyUp", {0.57812500, 0.82812500, 0.14843750, 0.27343750}, ZOOM_IN, KEY_MOUSEWHEELUP);
	else
		ModelSceneControlButtonMixin.Init(self, "AnyUp", {0.29687500, 0.54687500, 0.00781250, 0.13281250}, ZOOM_OUT, KEY_MOUSEWHEELDOWN);
	end
end

function ModelSceneZoomButtonMixin:OnClick()
	local zoomAmount = 1;
	if (not self.zoomIn) then
		zoomAmount = -1;
	end
	self.modelScene:OnMouseWheel(zoomAmount);

	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end


--------------------------------------------------
-- MODEL SCENE RESET BUTTON MIXIN
ModelSceneResetButtonMixin = CreateFromMixins(ModelSceneControlButtonMixin);

function ModelSceneResetButtonMixin:OnLoad()
	ModelSceneControlButtonMixin.OnLoad(self);
	local texCoords = nil;
	local tooltipText = nil;
	ModelSceneControlButtonMixin.Init(self, "AnyUp", texCoords, RESET_POSITION, tooltipText);
end

function ModelSceneResetButtonMixin:OnClick()
	self.modelScene:Reset();
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end


--------------------------------------------------
-- MODEL SCENE ROTATE BUTTON MIXIN
ModelScenelRotateButtonMixin = CreateFromMixins(ModelSceneControlButtonMixin);

function ModelScenelRotateButtonMixin:OnLoad()
	ModelSceneControlButtonMixin.OnLoad(self);

	if (self.rotateDirection == "left") then
		ModelSceneControlButtonMixin.Init(self, "AnyUp", {0.01562500, 0.26562500, 0.28906250, 0.41406250}, ROTATE_LEFT, ROTATE_TOOLTIP);
	elseif (self.rotateDirection == "right") then
		ModelSceneControlButtonMixin.Init(self, "AnyUp", {0.57812500, 0.82812500, 0.28906250, 0.41406250}, ROTATE_RIGHT, ROTATE_TOOLTIP);
	else
		assert("Invalid rotation specified: "..tostring(self.rotateDirection));
	end
end

function ModelScenelRotateButtonMixin:OnMouseDown()
	if ( not self.rotationIncrement ) then
		self.rotationIncrement = 0.03;
	end
	
	self.modelScene:AdjustCameraYaw(self.rotateDirection, self.rotationIncrement);
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end

function ModelScenelRotateButtonMixin:OnMouseUp()
	self.modelScene:StopCameraYaw();
end

