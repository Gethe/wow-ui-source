local DialogPopupEvent_Hidden = "DialogPopupEvent.Hidden";

---------------------------------------------------------------------------------------------------
-- DialogButtonMixin is the button used to toggle on and off a DialogPopupMixin.

DialogButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function DialogButtonMixin:OnLoad()
	ButtonStateBehaviorMixin.OnLoad(self);
end

function DialogButtonMixin:OnHide()
	self:ClosePopup();
end

function DialogButtonMixin:OnClick()
	self:ToggleDialog();
end

function DialogButtonMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);
end

function DialogButtonMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);
end

function DialogButtonMixin:OnMouseDown()
	ButtonStateBehaviorMixin.OnMouseDown(self);
end

function DialogButtonMixin:OnMouseUp()
	ButtonStateBehaviorMixin.OnMouseUp(self);
end

function DialogButtonMixin:SetDialog(dialog)
	assertsafe(dialog.AttachToButton, "Dialog should inherit from DialogPopupTemplate.");

	if dialog == self.dialog then
		return;
	end

	self.dialog = dialog;
end

function DialogButtonMixin:ClearPopup()
	if not self.dialog then
		return;
	end

	self:ClosePopup();

	self.dialog = nil;
end

function DialogButtonMixin:GetPopup()
	return self.dialog;
end

function DialogButtonMixin:HasPopup()
	return self.dialog ~= nil;
end

function DialogButtonMixin:GetDialogDirection()
	return self.dialogDirection or "DOWN";
end

function DialogButtonMixin:IsDialogOpen()
	local dialog = self.dialog;
	return dialog and dialog:IsAttachedToButton(self);
end

function DialogButtonMixin:ToggleDialog()
	local isDialogOpen = self:IsDialogOpen();
	if isDialogOpen then
		EventRegistry:UnregisterCallback(DialogPopupEvent_Hidden, self);
		self.dialog:DetatchFromButton();
	else
		EventRegistry:RegisterCallback(DialogPopupEvent_Hidden, function() self:OnDialogHidden(); end, self);
		self.dialog:AttachToButton(self);
	end

	self:OnDialogToggled();
end

function DialogButtonMixin:ClosePopup()
	if self:IsDialogOpen() then
		self:ToggleDialog();
	end
end

function DialogButtonMixin:OnDialogToggled()
end

-- Used to detect when the popup is hidden by code calling Hide on it directly, to keep the button state in sync.
function DialogButtonMixin:OnDialogHidden()
	self:ClosePopup();
end

function DialogButtonMixin:OnButtonStateChanged()
end

---------------------------------------------------------------------------------------------------
-- DialogPopupMixin is the container that is shown or hidden as the result of clicking a DialogButtonMixin
-- It is responsible for positioning itself relative to the DialogButtonMixin and updating its background.

DialogPopupMixin = {};

function DialogPopupMixin:IsAttachedToButton(dialogButton)
	return self.dialogButton == dialogButton;
end

function DialogPopupMixin:AttachToButton(dialogButton)
	assertsafe(not self.dialogButton, "DialogPopup already has a button set.");

	self.dialogButton = dialogButton;

	self:SetParent(dialogButton);
	self:UpdatePosition();
	self:UpdateBackground();
	self:Show();

	for _, child in ipairs({self:GetChildren()}) do
		if child.SetDialog then
			child:SetDialog(self);
		end
	end
end

function DialogPopupMixin:DetatchFromButton()
	assertsafe(self.dialogButton, "DialogPopup is not attached to a DialogButton.");

	self:Hide();

	self.dialogButton = nil;
end

function DialogPopupMixin:Close()
	if self.dialogButton then
		self.dialogButton:ClosePopup();
	end
end

function DialogPopupMixin:GetDirection()
	return self.dialogButton:GetDialogDirection();
end

function DialogPopupMixin:IsHorizontal()
	local direction = self:GetDirection();
	return direction == "LEFT" or direction == "RIGHT";
end

function DialogPopupMixin:GetCrossAxisSize()
	return self.dialogButton.popupCrossAxisSize;
end

function DialogPopupMixin:UpdatePosition()
	self:ClearAllPoints();

	local direction = self:GetDirection();
	local offset = self.flyoutButton.popupOffset;

	if (direction == "UP") then
		self:SetPoint("BOTTOM", self.dialogButton, "TOP", 0, offset);
	elseif (direction == "DOWN") then
		self:SetPoint("TOP", self.dialogButton, "BOTTOM", 0, -offset);
	elseif (direction == "LEFT") then
		self:SetPoint("RIGHT", self.dialogButton, "LEFT", -offset, 0);
	elseif (direction == "RIGHT") then
		self:SetPoint("LEFT", self.dialogButton, "RIGHT", offset, 0);
	end
end

function DialogPopupMixin:UpdateBackground()
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

function DialogPopupMixin:SetBorderColor(r, g, b)
	self.Background.Start:SetVertexColor(r, g, b);
	self.Background.HorizontalMiddle:SetVertexColor(r, g, b);
	self.Background.VerticalMiddle:SetVertexColor(r, g, b);
	self.Background.End:SetVertexColor(r, g, b);
end

function DialogPopupMixin:OnHide()
	if not self.dialogButton then
		return;
	end

	-- Used if the popup is hidden by something that's not the dialogButton to communicate the change to the dialogButton.
	EventRegistry:TriggerEvent(DialogPopupEvent_Hidden);
end

