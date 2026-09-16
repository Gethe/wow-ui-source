local SOFT_CURSOR_DEFUALT_MAX_SPEED = 200;

SoftCursorMixin = {}

function SoftCursorMixin:OnLoad()
	self.speedX = 0;
	self.speedY = 0;
	self.maxSpeed = SOFT_CURSOR_DEFUALT_MAX_SPEED;

	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
end

function SoftCursorMixin:SetBounds(inBoundsFunc)
	self.boundsFunc = inBoundsFunc;
	self.bounds = inBoundsFunc();
	self.speedX = 0;
	self.speedY = 0;
	self:ResetPosition();
end

function SoftCursorMixin:OnShow()
	self:EnableGamePadStick(true);
	self:ResetPosition();

	local introAnim = self.IntroAnim;
	if introAnim:IsPlaying() then
		introAnim:Stop();
	end
	introAnim:Play();
end

function SoftCursorMixin:OnHide()
	self:EnableGamePadStick(false);
end

function SoftCursorMixin:OnUpdate(delta)
	if not self:IsShown() then
		return;
	end

	local currentX, currentY = self:GetCenter();

	local nextX = currentX + (self.speedX * delta);
	local nextY = currentY + (self.speedY * delta);

	nextX, nextY = self.bounds:ClampPointInBounds(nextX, nextY);

	if nextX ~= currentX or nextY ~= currentY then
		self:ClearAllPoints();
		self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", nextX, nextY);
	end
end

function SoftCursorMixin:ResetPosition()
	if self.bounds then
		local x, y = self.bounds:GetCenter();
		self:ClearAllPoints();
		self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
	end
end

function SoftCursorMixin:GetPosition()
	return self:GetCenter();
end

function SoftCursorMixin:GetScaledPosition()
	local left, bottom, width, height = self:GetScaledRect()
	local scaledX = left + (width / 2);
	local scaledY = bottom + (height / 2);

	return scaledX, scaledY;
end

function SoftCursorMixin:SetActive(inActive)
	local isActive = self:IsShown();

	if isActive ~= inActive then
		self:SetShown(inActive);
	end
end

function SoftCursorMixin:IsMoving()
	return self.speedX ~= 0 or self.speedY ~= 0;
end

function SoftCursorMixin:SetSpeed(speedX, speedY)
	self.speedX = speedX;
	self.speedY = speedY;
end

function SoftCursorMixin:SetMaxSpeed(maxSpeed)
	self.maxSpeed = maxSpeed;
end

function SoftCursorMixin:OnGamePadStick(inStick, inX, inY)
	if ( inStick ~= "Right" and inStick ~= "Camera" ) then
		return true;
	end

	self.speedX = inX * self.maxSpeed;
	self.speedY = inY * self.maxSpeed;

	return false;
end

function SoftCursorMixin:OnEvent(event, ...)
	if not self:IsShown() then
		return;
	end
	if event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		self:RefreshBounds();
	end
end

function SoftCursorMixin:RefreshBounds()
	self.bounds = self.boundsFunc();
	self:ResetPosition();
end

SoftCursorBoundsMixin = {}

--This is a base function expected to be overriden.
function SoftCursorBoundsMixin:ClampPointInBounds(inX, inY)
	return nil;
end

function SoftCursorBoundsMixin:GetCenter()
	return self.pointX, self.pointY;
end

SoftCursorCircleBoundsMixin = CreateFromMixins(SoftCursorBoundsMixin)

function SoftCursorCircleBoundsMixin:Init(inX, inY, inRadius)
	self.pointX = inX;
	self.pointY = inY;
	self.radius = inRadius;
	self.squareRadias = inRadius * inRadius;
end

function SoftCursorCircleBoundsMixin:ClampPointInBounds(inX, inY)
	local x = inX - self.pointX;
	local y = inY - self.pointY;
	local squareDistance = x * x + y * y;

	if squareDistance <= self.squareRadias then
		return inX, inY;
	else
		local distance = math.sqrt(squareDistance);
		local normalX = x / distance;
		local normalY = y / distance;

		return (normalX * self.radius) + self.pointX , (normalY * self.radius) + self.pointY;
	end
end

--The inX and inY refer to the center of the circle.
function SoftCursor_CreateCircleBounds(inX, inY, inRadius)
	return CreateAndInitFromMixin(SoftCursorCircleBoundsMixin, inX, inY, inRadius);
end

SoftCursorRectBoundsMixin = CreateFromMixins(SoftCursorBoundsMixin)

function SoftCursorRectBoundsMixin:Init(inX, inY, inWidth, inHeight)
	self.pointX = inX;
	self.pointY = inY;
	local halfWidth = inWidth * 0.5;
	local halfHeight = inHeight * 0.5;
	self.left = inX - halfWidth;
	self.right = inX + halfWidth;
	self.top = inY - halfHeight;
	self.bottom = inY + halfHeight;
end

function SoftCursorRectBoundsMixin:ClampPointInBounds(inX, inY)
	inX = Clamp(inX, self.left, self.right);
	inY = Clamp(inY, self.top, self.bottom);

	return inX, inY;
end

--The inX and inY refer to the center of the rectangle.
function SoftCursor_CreateRectBounds(inX, inY, inWidth, inHeight)
	return CreateAndInitFromMixin(SoftCursorRectBoundsMixin, inX, inY, inWidth, inHeight);
end
