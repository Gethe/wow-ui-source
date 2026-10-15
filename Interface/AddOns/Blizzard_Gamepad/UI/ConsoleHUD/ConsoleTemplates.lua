--[[
	Mixins for console templates
]]

GamepadButtonIconWithTextMixin = {};

function GamepadButtonIconWithTextMixin:SetButtonScale(scale)
	if (self.text) then
		self.text:SetScale(scale);
	end

	for i = 1, #self.Icons do
		self.Icons[i]:SetScale(scale);
	end
end

function GamepadButtonIconWithTextMixin:OnClick(button, down)
	if (down) then
		self:SetButtonScale(0.9);
	else
		self:SetButtonScale(1);
	end
end

function GamepadButtonIconWithTextMixin:OnShow()
	self:SetButtonScale(1);
	self:SetScale(self.startingScale);
end

function GamepadButtonIconWithTextMixin:OnLoad()
	-- Set the icons based on the binding sets or icon declarations

	if (not self.startingScale) then self.startingScale = 1; end

	local keyNames = self.keyNames;
	local keyIcons = GamepadMode.GetBindingKeyIconsFromNames(keyNames);

	self.iconCount = 0;

	local i = 1;
	local lastIcon = nil;
	while (self.Icons[i] or (keyIcons and keyIcons[i])) do
		local icon = self.Icons[i];
		local isValid = false;

		if (keyIcons and keyIcons[i]) then
			-- Use the binding's key icon
			icon:SetAtlas(keyIcons[i]);
			isValid = true;
		else
			-- There isn't a bindingset so check if there's a direct icon declared
			local iconFileAtlasKey = self.iconNames and self.iconNames[i];
			local iconFile = iconFileAtlasKey and InputIconTextureSetUtility.GetNormalActiveInputIconButtonTexture(iconFileAtlasKey);
			if (iconFile) then
				icon:SetAtlas(iconFile);
				isValid = true;
			end
		end

		icon:SetShown(isValid);

		if i > 1 then
			self.PlusTextures[i - 1]:SetShown(isValid);
		end

		if isValid then
			self.iconCount = self.iconCount + 1;
			lastIcon = icon;
		end

		i = i + 1;
	end

	self.text:ClearAllPoints();
	if lastIcon then
		self.text:SetPoint("LEFT", lastIcon, "RIGHT", 5, 0);
	else
		self.text:SetPoint("LEFT", self, "LEFT", 10, 0);
	end

	self:SetScale(self.startingScale);
	if (self.text) then
		self.text:SetText(self.textValue);
		self.text:Show();
	end

	self:RefreshWidth();

	hooksecurefunc(self.text, "SetText", function() self:RefreshWidth() end);
end

function GamepadButtonIconWithTextMixin:RefreshWidth()
	local wrappedWidth = self.text:GetWrappedWidth();
	self:SetWidth((self.iconCount - 1) * 32 + (self.iconCount - 2) * 20 + wrappedWidth);
end

function GamepadButtonIconWithTextMixin:OnEnable()
	-- Restore saturation and vertex color
	for i = 1, #self.Icons do
		self.Icons[i]:SetDesaturation(0);
		self.Icons[i]:SetAlpha(1);
	end

	if (self.text) then
		self.text:SetVertexColor(1, 1, 1, 1);
	end
	self:SetScale(self.startingScale);
end

function GamepadButtonIconWithTextMixin:OnDisable()
	-- Desaturation and set vertex color to gray
	for i = 1, #self.Icons do
		self.Icons[i]:SetDesaturation(1);
		self.Icons[i]:SetAlpha(0.5);
	end

	if (self.text) then
		self.text:SetVertexColor(0.5, 0.5, 0.5, 1);
	end
	self:SetScale(self.startingScale);
end

GamepadPressAndHoldButtonMixin = {};

function GamepadPressAndHoldButtonMixin:OnLoad()
	-- Upcall
	GamepadButtonIconWithTextMixin.OnLoad(self);

	self.timer = 0;
	self.buttonHeld = false;
	self.originalText = self.textValue;
end

function GamepadPressAndHoldButtonMixin:OnUpdate(elapsed)
	if (self.buttonHeld) then
		self.timer = self.timer + elapsed;
		if (self.timer >= self.holdTime) then
			self:TimerFinished();
			return;
		end

		local displayTime = math.floor((self.holdTime - self.timer) * 3);
		self.text:SetText(self.originalText .. " " .. displayTime);
	else
		self.text:SetText(self.originalText);
		self.timer = 0;
	end
end

function GamepadPressAndHoldButtonMixin:OnClick(button, down)
	-- Upcall
	GamepadButtonIconWithTextMixin.OnClick(self, button, down);

	self.buttonHeld = down;
end

function GamepadPressAndHoldButtonMixin:TimerFinished()
	self.timer = 0;
	self.buttonHeld = false;
end
