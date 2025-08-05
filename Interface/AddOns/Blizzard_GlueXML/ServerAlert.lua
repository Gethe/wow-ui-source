
g_collapsedServerAlert = g_collapsedServerAlert or nil;

ServerAlertBoxMixin = {};

function ServerAlertBoxMixin:SetUp(text)
	self.alertText = text;

	-- We have to resize before calling SetText because SimpleHTML frames won't resize correctly.
	self.ScrollFrame.Text:SetWidth(self.ScrollFrame:GetWidth());
	self.ScrollFrame.Text:SetText(text);
end

function ServerAlertBoxMixin:GetAlertText()
	return self.alertText;
end

function ServerAlertBoxMixin:GetContentHeight()
	local MIN_CONTENT_HEIGHT = 40;
	local textHeight = self.ScrollFrame.Text:GetContentHeight();
	return self:IsShown() and math.max(textHeight, MIN_CONTENT_HEIGHT) or 0;
end

-- The default server alert is just a box. The collapsible version includes a box and an expand bar.
ServerAlertMixin = {};

function ServerAlertMixin:OnLoad()
	self:RegisterEvent("SHOW_SERVER_ALERT");
end

function ServerAlertMixin:OnEvent(event, ...)
	if event == "SHOW_SERVER_ALERT" then
		local text = ...;
		self:SetUp(text);

		self.isActive = true;
		if not self.isSuppressed then
			self:Show();
		end
	end
end

function ServerAlertMixin:SetUp(text)
	self.Box:SetUp(text);
end

function ServerAlertMixin:SetSuppressed(isSuppressed)
	self:SetShown(not isSuppressed and self.isActive);
	self.isSuppressed = isSuppressed;
end


CollapsibleServerAlertMixin = CreateFromMixins(ServerAlertMixin);

function CollapsibleServerAlertMixin:OnLoad()
	ServerAlertMixin.OnLoad(self);

	self.originalHeight = self:GetHeight();

	local expandButton = self.ExpandBar.ExpandButton;
	expandButton:SetPoint("RIGHT", -13, 3);

	self.ExpandBar:SetExpandTarget(self.Box);

	self.ExpandBar:SetOnToggleCallback(GenerateClosure(self.OnToggled, self));
end

function CollapsibleServerAlertMixin:OnShow()
	self:UpdateCollapsedState();
end

function CollapsibleServerAlertMixin:OnToggled(expanded, isUserInput)
	if isUserInput then
		if expanded then
			g_collapsedServerAlert = nil;
		else
			g_collapsedServerAlert = self.Box:GetAlertText();
		end
	end
	self:UpdateHeight();
end

function CollapsibleServerAlertMixin:ShouldBeCollapsed()
	return self.Box:GetAlertText() == g_collapsedServerAlert;
end

function CollapsibleServerAlertMixin:UpdateCollapsedState()
	self.ExpandBar:SetExpanded(not self:ShouldBeCollapsed());
end

function CollapsibleServerAlertMixin:GetMaxFrameHeight()
	return self.originalHeight;
end

function CollapsibleServerAlertMixin:UpdateHeight()
	local boxHeight = self.Box:GetContentHeight();
	local expandBarHeight = self.ExpandBar:GetHeight();
	local newsFrameHeight = math.min(boxHeight + expandBarHeight, self:GetMaxFrameHeight());
	self:SetHeight(newsFrameHeight);
end

function CollapsibleServerAlertMixin:SetUp(text)
	ServerAlertMixin.SetUp(self, text);

	self:UpdateHeight();

	local isCollapsedAlert = text == g_collapsedServerAlert;
	self.ExpandBar:SetExpanded(not isCollapsedAlert);
	if not isCollapsedAlert then
		g_collapsedServerAlert = nil;
	end
end

function CollapsibleServerAlertMixin:SetExpanded(expanded, isUserInput)
	return self.ExpandBar:SetExpanded(expanded, isUserInput);
end
