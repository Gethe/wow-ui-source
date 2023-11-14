
local DEFAULT_ZOOM_INCREMENT = 1;
local DEFAULT_ROTATE_INCREMENT = 0.05;

--------------------------------------------------
-- MODEL SCENE CONTROL FRAME MIXIN
ModelSceneControlFrameMixin = {};
function ModelSceneControlFrameMixin:OnLoad()
	if self.enableZoom then
		local increment = self:GetZoomIncrement();
		self.zoomInButton:SetZoomAmount(increment);
		self.zoomInButton:Init();

		self.zoomOutButton:SetZoomAmount(-increment);
		self.zoomOutButton:Init();
	end
	self.zoomInButton:SetShown(self.enableZoom);
	self.zoomOutButton:SetShown(self.enableZoom);

	if self.enableRotate then
		local increment = self:GetRotateIncrement();
		self.rotateLeftButton:SetRotation("left");
		self.rotateLeftButton:SetRotationIncrement(increment);
		self.rotateLeftButton:Init();

		self.rotateRightButton:SetRotation("right");
		self.rotateRightButton:SetRotationIncrement(increment);
		self.rotateRightButton:Init();
	end
	self.rotateLeftButton:SetShown(self.enableRotate);
	self.rotateRightButton:SetShown(self.enableRotate);

	if self.enableReset then
		self.resetButton:Init();
	end
	self.resetButton:SetShown(self.enableReset);
end

function ModelSceneControlFrameMixin:OnShow()
	self:UpdateLayout();
end

function ModelSceneControlFrameMixin:OnEnter()
	self:SetAlpha(1);
end

function ModelSceneControlFrameMixin:OnLeave()
	self:SetAlpha(0.5);
end

function ModelSceneControlFrameMixin:SetZoomIncrement(increment)
	self.zoomIncrement = increment or DEFAULT_ZOOM_INCREMENT;
end

function ModelSceneControlFrameMixin:GetZoomIncrement()
	return self.zoomIncrement or DEFAULT_ZOOM_INCREMENT;
end

function ModelSceneControlFrameMixin:SetRotateIncrement(increment)
	self.rotationIncrement = increment or DEFAULT_ROTATE_INCREMENT;
end

function ModelSceneControlFrameMixin:GetRotateIncrement()
	return self.rotationIncrement or DEFAULT_ROTATE_INCREMENT;
end

function ModelSceneControlFrameMixin:SetModelScene(modelScene)
	self.modelScene = modelScene;
	self.zoomInButton:SetModelScene(modelScene);
	self.zoomOutButton:SetModelScene(modelScene);
	self.rotateLeftButton:SetModelScene(modelScene);
	self.rotateRightButton:SetModelScene(modelScene);
	self.resetButton:SetModelScene(modelScene);
end

function ModelSceneControlFrameMixin:UpdateLayout()
	local lastButton;
	local hPadding = self.buttonHorizontalPadding or 0;
	local vPadding = 0;
	local buttonSize = 32;
	local totalHeight = buttonSize;
	local totalWidth = 0 + hPadding;

	local function LayoutButton(button)
		button:ClearAllPoints();
		if lastButton then
			button:SetPoint("LEFT", lastButton, "RIGHT", hPadding, vPadding);
		else
			button:SetPoint("LEFT", 0, vPadding);
		end
		totalWidth = totalWidth + buttonSize + hPadding;
		lastButton = button;
	end

	if self.enableZoom then
		LayoutButton(self.zoomInButton);
		LayoutButton(self.zoomOutButton);
	end

	if self.enableRotate then
		LayoutButton(self.rotateLeftButton);
		LayoutButton(self.rotateRightButton);
	end

	if self.enableReset then
		LayoutButton(self.resetButton);
	end
	self:SetSize(totalWidth, totalHeight);
end

--------------------------------------------------
-- MODEL SCENE CONTROL BUTTON MIXIN
ModelSceneControlButtonMixin = {};
function ModelSceneControlButtonMixin:Init(clickTypes, atlas, tooltip, tooltipText)
	self:RegisterForClicks(clickTypes);
	if atlas then
		self.Icon:SetAtlas(atlas);
	end
	self.tooltip = tooltip;
	self.tooltipText = tooltipText;
end

function ModelSceneControlButtonMixin:SetModelScene(modelScene)
	self.modelScene = modelScene;
end

function ModelSceneControlButtonMixin:OnMouseDown()
	self.Icon:AdjustPointsOffset(1, -1);
	self:GetParent().buttonDown = self;
end

function ModelSceneControlButtonMixin:OnMouseUp()
	self.Icon:AdjustPointsOffset(-1, 1);
	self:GetParent().buttonDown = nil;
end

function ModelSceneControlButtonMixin:OnClick()
	--override for your mouse click 
end

function ModelSceneControlButtonMixin:OnEnter()
	self:GetParent():SetAlpha(1);
	if ( GetCVar("UberTooltips") == "1" ) then
		local tooltip = GetAppropriateTooltip();
		local uiParent = GetAppropriateTopLevelParent();
		GameTooltip_SetDefaultAnchor(tooltip, uiParent);
		GameTooltip_SetTitle(tooltip, self.tooltip);
		if ( self.tooltipText ) then
			GameTooltip_AddBodyLine(tooltip, self.tooltipText);
		end
		tooltip:Show();
	end
end

function ModelSceneControlButtonMixin:OnLeave()
	self:GetParent():SetAlpha(0.5);

	local tooltip = GetAppropriateTooltip();
	tooltip:Hide();
end

--------------------------------------------------
-- MODEL ZOOM BUTTON MIXIN
ModelSceneZoomButtonMixin = CreateFromMixins(ModelSceneControlButtonMixin);
function ModelSceneZoomButtonMixin:OnLoad()
	self.zoomAmount = 0;
end

function ModelSceneZoomButtonMixin:Init()
	if self.zoomAmount < 0 then
		ModelSceneControlButtonMixin.Init(self, "AnyUp", "common-icon-zoomout", ZOOM_OUT, KEY_MOUSEWHEELDOWN);
	else
		ModelSceneControlButtonMixin.Init(self, "AnyUp", "common-icon-zoomin", ZOOM_IN, KEY_MOUSEWHEELUP);
	end
end

function ModelSceneZoomButtonMixin:SetZoomAmount(amountToZoom)
	self.zoomAmount = amountToZoom;
end

function ModelSceneZoomButtonMixin:OnClick()
	if self.modelScene then
		self.modelScene:OnMouseWheel(self.zoomAmount);
	else
		assertsafe(fale, "Model Scene not specified");
	end
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end

--------------------------------------------------
-- MODEL SCENE ROTATE BUTTON MIXIN
ModelScenelRotateButtonMixin = CreateFromMixins(ModelSceneControlButtonMixin);
function ModelScenelRotateButtonMixin:OnLoad()
	ModelSceneControlButtonMixin.OnLoad(self);
	self.rotateDirection = "none";
end

function ModelScenelRotateButtonMixin:Init()
	if (self.rotateDirection == "left") then
		ModelSceneControlButtonMixin.Init(self, "AnyUp", "common-icon-rotateleft", ROTATE_LEFT, ROTATE_TOOLTIP);
	elseif (self.rotateDirection == "right") then
		ModelSceneControlButtonMixin.Init(self, "AnyUp", "common-icon-rotateright", ROTATE_RIGHT, ROTATE_TOOLTIP);
	else
		assertsafe(false, "Invalid rotation specified: "..tostring(self.rotateDirection));
	end
end

function ModelScenelRotateButtonMixin:SetRotation(rotation)
	self.rotateDirection = rotation;
end

function ModelScenelRotateButtonMixin:SetRotationIncrement(increment)
	self.rotationIncrement = increment or 0.05;
end

function ModelScenelRotateButtonMixin:OnMouseDown()
	ModelSceneControlButtonMixin.OnMouseDown(self);
	if self.modelScene then
		self.modelScene:AdjustCameraYaw(self.rotateDirection, self.rotationIncrement);
	else
		assertsafe(false, "Model Scene not specified");
	end
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end

function ModelScenelRotateButtonMixin:OnMouseUp()
	ModelSceneControlButtonMixin.OnMouseUp(self);
	if self.modelScene then
		self.modelScene:StopCameraYaw();
	end
end

--------------------------------------------------
-- MODEL SCENE RESET BUTTON MIXIN
ModelSceneResetButtonMixin = CreateFromMixins(ModelSceneControlButtonMixin);
function ModelSceneResetButtonMixin:OnLoad()
	ModelSceneControlButtonMixin.OnLoad(self);
end

function ModelSceneResetButtonMixin:Init()
	local tooltipText = nil;
	ModelSceneControlButtonMixin.Init(self, "AnyUp", "common-icon-undo", RESET_POSITION, tooltipText);
end

function ModelSceneResetButtonMixin:OnClick()
	if self.modelScene then
		self.modelScene:Reset();
	else
		assertsafe(false, "Model Scene not specified");
	end
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end
