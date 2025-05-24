local FlyoutPopupEvent_Hidden = "FlyoutPopupEvent.Hidden";

---------------------------------------------------------------------------------------------------
-- FlyoutButtonMixin is the button used to toggle on and off a FlyoutPopupMixin.
-- It controls the state of an arrow that indicates whether the Popup is open or not.

FlyoutButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function FlyoutButtonMixin:OnLoad()
	ButtonStateBehaviorMixin.OnLoad(self);

	self.Arrow:SetSize(self.arrowMainAxisSize, self.arrowCrossAxisSize);

	self:UpdateArrowShown();
	self:UpdateArrowPosition();
	self:UpdateArrowRotation();
end

function FlyoutButtonMixin:OnHide()
	self:ClosePopup();
end

function FlyoutButtonMixin:Flyout_OnClick()
	self:TogglePopup();
end

function FlyoutButtonMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);
end

function FlyoutButtonMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);
end

function FlyoutButtonMixin:OnMouseDown()
	ButtonStateBehaviorMixin.OnMouseDown(self);
end

function FlyoutButtonMixin:OnMouseUp()
	ButtonStateBehaviorMixin.OnMouseUp(self);
end

function FlyoutButtonMixin:OnDragStart()
	-- Starting to drag the button needs to clear the down state so the arrow is updated.
	ButtonStateBehaviorMixin.OnMouseUp(self);
end

function FlyoutButtonMixin:SetPopup(popup)
	assertsafe(popup.AttachToButton, "Popup should inherit from FlyoutPopupTemplate.");

	if popup == self.popup then
		return;
	end

	self.popup = popup;

	self:UpdateArrowShown();
end

function FlyoutButtonMixin:ClearPopup()
	if not self.popup then
		return;
	end

	self:ClosePopup();

	self.popup = nil;

	self:UpdateArrowShown();
end

function FlyoutButtonMixin:GetPopup()
	return self.popup;
end

function FlyoutButtonMixin:HasPopup()
	return self.popup ~= nil;
end

function FlyoutButtonMixin:GetPopupDirection()
	return self.popupDirection or "DOWN";
end

function FlyoutButtonMixin:SetPopupDirection(popupDirection)
	if self.popupDirection == popupDirection then
		return;
	end

	self.popupDirection = popupDirection;
	self:UpdateArrowPosition();
	self:UpdateArrowRotation();
end

function FlyoutButtonMixin:IsPopupOpen()
	local popup = self.popup;
	return popup and popup:IsAttachedToButton(self);
end

function FlyoutButtonMixin:TogglePopup()
	local isPopupOpen = self:IsPopupOpen();
	if isPopupOpen then
		EventRegistry:UnregisterCallback(FlyoutPopupEvent_Hidden, self);
		self.popup:DetatchFromButton();
	elseif self:HasPopup() then
		EventRegistry:RegisterCallback(FlyoutPopupEvent_Hidden, function() self:OnPopupHidden(); end, self);
		self.popup:AttachToButton(self);
	end

	self:OnPopupToggled();
end

function FlyoutButtonMixin:ClosePopup()
	if self:IsPopupOpen() then
		self:TogglePopup();
	end
end

function FlyoutButtonMixin:OnPopupToggled()
	self:UpdateArrowRotation();
	self:UpdateArrowPosition();
	self:UpdateBorderShadow();
end

-- Used to detect when the popup is hidden by code calling Hide on it directly, to keep the button state in sync.
function FlyoutButtonMixin:OnPopupHidden()
	self:ClosePopup();
end

function FlyoutButtonMixin:OnButtonStateChanged()
	self:UpdateArrowTexture();
	self:UpdateBorderShadow();
end

function FlyoutButtonMixin:UpdateArrowShown()
	local arrowShown = self:HasPopup();
	self.Arrow:SetShown(arrowShown);
end

function FlyoutButtonMixin:UpdateArrowPosition()
	self.Arrow:ClearAllPoints();

	local direction = self:GetPopupDirection();
	local offset = self:IsPopupOpen() and self.openArrowOffset or self.closedArrowOffset;

	if (direction == "UP") then
		self.Arrow:SetPoint("TOP", self, "TOP", 0, offset);
	elseif (direction == "DOWN") then
		self.Arrow:SetPoint("BOTTOM", self, "BOTTOM", 0, -offset);
	elseif (direction == "LEFT") then
		self.Arrow:SetPoint("LEFT", self, "LEFT", -offset, 0);
	elseif (direction == "RIGHT") then
		self.Arrow:SetPoint("RIGHT", self, "RIGHT", offset, 0);
	end
end

function FlyoutButtonMixin:GetArrowRotation()
	local direction = self:GetPopupDirection();
	local rotation = 0;

	if (direction == "UP") then
		rotation = 0;
	elseif (direction == "DOWN") then
		rotation = 180;
	elseif (direction == "LEFT") then
		rotation = 270;
	elseif (direction == "RIGHT") then
		rotation = 90;
	end

	-- The arrow is flipped when the popup is open.
	if self:IsPopupOpen() then
		rotation = (rotation + 180) % 360;
	end

	return rotation;
end

function FlyoutButtonMixin:UpdateArrowRotation()
	local rotation = self:GetArrowRotation();
	SetClampedTextureRotation(self.Arrow, rotation);
end

function FlyoutButtonMixin:UpdateArrowTexture()
	local useAtlasSize = false;
	if self:IsDown() then
		self.Arrow:SetAtlas(self.arrowDownTexture, useAtlasSize);
	elseif self:IsOver() then
		self.Arrow:SetAtlas(self.arrowOverTexture, useAtlasSize);
	else
		self.Arrow:SetAtlas(self.arrowNormalTexture, useAtlasSize);
	end
end

function FlyoutButtonMixin:UpdateBorderShadow()
	if self:HasPopup() and (self:IsPopupOpen() or self:IsOver()) then
		self.BorderShadow:Show();
	else
		self.BorderShadow:Hide();
	end
end

---------------------------------------------------------------------------------------------------
-- FlyoutPopupMixin is the container that is shown or hidden as the result of clicking a FlyoutButtonMixin
-- It contains a set of FlyoutPopupButtonMixin as children.
-- It is responsible for positioning itself relative to the FlyoutButtonMixin and updating its background.

FlyoutPopupMixin = {};

function FlyoutPopupMixin:IsAttachedToButton(flyoutButton)
	return self.flyoutButton == flyoutButton;
end

function FlyoutPopupMixin:AttachToButton(flyoutButton)
	assertsafe(not self.flyoutButton, "FlyoutPopup already has a button set.");

	self.flyoutButton = flyoutButton;

	self:SetParent(flyoutButton);
	self:UpdatePosition();
	self:UpdateBackground();
	self:Show();

	for _, child in ipairs({self:GetChildren()}) do
		if child.SetPopup then
			child:SetPopup(self);
		end
	end
end

function FlyoutPopupMixin:DetatchFromButton()
	assertsafe(self.flyoutButton, "FlyoutPopup is not attached to a FlyoutButton.");

	self:Hide();

	self.flyoutButton = nil;
end

function FlyoutPopupMixin:Close()
	if self.flyoutButton then
		self.flyoutButton:ClosePopup();
	end
end

function FlyoutPopupMixin:GetDirection()
	return self.flyoutButton:GetPopupDirection();
end

function FlyoutPopupMixin:IsHorizontal()
	local direction = self:GetDirection();
	return direction == "LEFT" or direction == "RIGHT";
end

function FlyoutPopupMixin:GetCrossAxisSize()
	return self.flyoutButton.popupCrossAxisSize;
end

function FlyoutPopupMixin:UpdatePosition()
	self:ClearAllPoints();

	local direction = self:GetDirection();
	local offset = self.flyoutButton.popupOffset;

	if (direction == "UP") then
		self:SetPoint("BOTTOM", self.flyoutButton, "TOP", 0, offset);
	elseif (direction == "DOWN") then
		self:SetPoint("TOP", self.flyoutButton, "BOTTOM", 0, -offset);
	elseif (direction == "LEFT") then
		self:SetPoint("RIGHT", self.flyoutButton, "LEFT", -offset, 0);
	elseif (direction == "RIGHT") then
		self:SetPoint("LEFT", self.flyoutButton, "RIGHT", offset, 0);
	end
end

function FlyoutPopupMixin:UpdateBackground()
	self.Background.End:ClearAllPoints();
	self.Background.Start:ClearAllPoints();
	self.Background.VerticalMiddle:ClearAllPoints();
	self.Background.HorizontalMiddle:ClearAllPoints();

	local direction = self:GetDirection();
	local isHorizontal = self:IsHorizontal();
	local crossAxisSize = self:GetCrossAxisSize();

	self.Background.HorizontalMiddle:SetShown(isHorizontal);
	self.Background.VerticalMiddle:SetShown(not isHorizontal);

	if (direction == "UP") then
		self.Background.Start:SetPoint("BOTTOM");
		self.Background.VerticalMiddle:SetPoint("BOTTOM", self.Background.Start, "TOP");
		self.Background.VerticalMiddle:SetPoint("TOP", self.Background.End, "BOTTOM");
		self.Background.End:SetPoint("TOP");
		SetClampedTextureRotation(self.Background.Start, 0);
		SetClampedTextureRotation(self.Background.VerticalMiddle, 0);
		SetClampedTextureRotation(self.Background.End, 0);
	elseif (direction == "DOWN") then
		self.Background.Start:SetPoint("TOP");
		self.Background.VerticalMiddle:SetPoint("BOTTOM", self.Background.End, "TOP");
		self.Background.VerticalMiddle:SetPoint("TOP", self.Background.Start, "BOTTOM");
		self.Background.End:SetPoint("BOTTOM");
		SetClampedTextureRotation(self.Background.Start, 180);
		SetClampedTextureRotation(self.Background.VerticalMiddle, 180);
		SetClampedTextureRotation(self.Background.End, 180);
	elseif (direction == "LEFT") then
		self.Background.Start:SetPoint("RIGHT");
		self.Background.HorizontalMiddle:SetPoint("RIGHT", self.Background.Start, "LEFT");
		self.Background.HorizontalMiddle:SetPoint("LEFT", self.Background.End, "RIGHT");
		self.Background.End:SetPoint("LEFT");
		SetClampedTextureRotation(self.Background.Start, 270);
		SetClampedTextureRotation(self.Background.HorizontalMiddle, 180);
		SetClampedTextureRotation(self.Background.End, 270);
	elseif (direction == "RIGHT") then
		self.Background.Start:SetPoint("LEFT");
		self.Background.HorizontalMiddle:SetPoint("RIGHT", self.Background.End, "LEFT");
		self.Background.HorizontalMiddle:SetPoint("LEFT", self.Background.Start, "RIGHT");
		self.Background.End:SetPoint("RIGHT");
		SetClampedTextureRotation(self.Background.Start, 90);
		SetClampedTextureRotation(self.Background.HorizontalMiddle, 0);
		SetClampedTextureRotation(self.Background.End, 90);
	end

	if not isHorizontal then
		self.Background.Start:SetWidth(crossAxisSize);
		self.Background.VerticalMiddle:SetWidth(crossAxisSize);
		self.Background.End:SetWidth(crossAxisSize);
	else
		self.Background.Start:SetHeight(crossAxisSize);
		self.Background.HorizontalMiddle:SetHeight(crossAxisSize);
		self.Background.End:SetHeight(crossAxisSize);
	end
end

function FlyoutPopupMixin:SetBorderColor(r, g, b)
	self.Background.Start:SetVertexColor(r, g, b);
	self.Background.HorizontalMiddle:SetVertexColor(r, g, b);
	self.Background.VerticalMiddle:SetVertexColor(r, g, b);
	self.Background.End:SetVertexColor(r, g, b);
end

function FlyoutPopupMixin:OnHide()
	if not self.flyoutButton then
		return;
	end

	-- Used if the popup is hidden by something that's not the flyoutButton to communicate the change to the flyoutButton.
	EventRegistry:TriggerEvent(FlyoutPopupEvent_Hidden);
end

---------------------------------------------------------------------------------------------------
-- FlyoutPopupButtonMixin is for buttons that are children of a FlyoutPopupMixin.
-- Derived Mixins should call FlyoutPopupButton_OnClick so the popup is closed when the button is clicked.

FlyoutPopupButtonMixin = {};

function FlyoutPopupButtonMixin:SetPopup(popup)
	assertsafe(not self.poup or self.popup == popup, "Setting a different popup on a FlyoutPopupButton. Possible setup error.");
	self.popup = popup;
end

function FlyoutPopupButtonMixin:GetPopup()
	return self.popup;
end

function FlyoutPopupButtonMixin:ClosePopup()
	if self.popup then
		self.popup:Close();
	end
end

function FlyoutPopupButtonMixin:OnClick()
	self:ClosePopup();
end
