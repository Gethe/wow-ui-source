
g_collapsedServerAlert = g_collapsedServerAlert or nil;

local s_serverAlertOffsets = {
	default = {
		titleX = 0,
		titleY = -20,
		scrollX1 = 22,
		scrollY1 = -51,
		scrollX2 = -35,
		scrollY2 = 17
		--no centerX or centerY needed
	},

	darkmoonlights = {
		titleX = 0,
		titleY = -30,
		scrollX1 = 25,
		scrollY1 = -56,
		scrollX2 = -47,
		scrollY2 = 27,
		centerX = 8,
		centerY = -10
	}
};


-- Allows generic support of texture kits for the expand bar and text box.
ServerAlertBackgroundMixin = {};

function ServerAlertBackgroundMixin:SetUITextureKit(uiTextureKitID)
	local offsets = s_serverAlertOffsets[uiTextureKitID or "default"];

	if uiTextureKitID then
		self.Border:Hide();
		self.NineSlice:Show();
		NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, uiTextureKitID);

		self.NineSlice.Center:ClearAllPoints();
		self.NineSlice.Center:SetPoint("TOPLEFT", self, "TOPLEFT", offsets.centerX, offsets.centerY);
		self.NineSlice.Center:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -offsets.centerX, -offsets.centerY);
		self.NineSlice.Center:SetDrawLayer("BACKGROUND");
	else
		self.Border:Show();
		self.NineSlice:Hide();
	end
end


ServerAlertBoxMixin = {};

function ServerAlertBoxMixin:SetUp(text, uiTextureKitID)
	self.alertText = text;

	self.Background:SetUITextureKit(uiTextureKitID);

	local offsets = s_serverAlertOffsets[uiTextureKitID or "default"];
	self.Title:SetPoint("TOP", offsets.titleX, offsets.titleY);

	-- We have to resize before calling SetText because SimpleHTML frames won't resize correctly.
	self.ScrollFrame.Text:SetWidth(self.ScrollFrame:GetWidth());
	self.ScrollFrame.Text:SetText(text);

	local titleAdjustY = self.Title:IsShown() and 0 or 30;
	self.ScrollFrame:SetPoint("TOPLEFT", offsets.scrollX1, offsets.scrollY1 + titleAdjustY);
	self.ScrollFrame:SetPoint("BOTTOMRIGHT", offsets.scrollX2, offsets.scrollY2);
end

function ServerAlertBoxMixin:GetAlertText()
	return self.alertText;
end

function ServerAlertBoxMixin:SetTitleShown(isShown)
	self.Title:SetShown(isShown);
end

function ServerAlertBoxMixin:GetContentHeight()
	return self.ScrollFrame.Text:GetContentHeight();
end


-- The default server alert is just a box. The collapsible version includes a box and an expand bar.
ServerAlertMixin = {};

function ServerAlertMixin:OnLoad()
	self:RegisterEvent("SHOW_SERVER_ALERT");
end

function ServerAlertMixin:OnEvent(event, ...)
	if event == "SHOW_SERVER_ALERT" then
		local text, uiTextureKitID = ...;
		self:SetUp(text, uiTextureKitID);

		self.isActive = true;
		if not self.isSuppressed then
			self:Show();
		end
	end
end

function ServerAlertMixin:SetUp(text, uiTextureKitID)
	self.Box:SetUp(text, uiTextureKitID);
end

function ServerAlertMixin:SetSuppressed(isSuppressed)
	self:SetShown(not isSuppressed and self.isActive);
	self.isSuppressed = isSuppressed;
end


CollapsibleServerAlertMixin = {};

function CollapsibleServerAlertMixin:OnLoad()
	self.originalHeight = self:GetHeight();

	ServerAlertMixin.OnLoad(self);

	self.Box:SetTitleShown(false);
	self.Box:ClearAllPoints();
	self.Box:SetPoint("TOP", self.ExpandBar, "BOTTOM", 0, 4);
	self.Box:SetPoint("BOTTOM");
	self.Box:SetPoint("LEFT");
	self.Box:SetPoint("RIGHT");

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
	local MinContentHeight = 40;
	local ExtraNewsFrameHeight = 85;

	local contentHeight = math.max(self.Box:GetContentHeight(), MinContentHeight);
	local baseFrameHeight = contentHeight + ExtraNewsFrameHeight;
	local newsFrameHeight = math.min(baseFrameHeight, self:GetMaxFrameHeight());
	self:SetHeight(newsFrameHeight);
end

function CollapsibleServerAlertMixin:SetUp(text, uiTextureKitID)
	ServerAlertMixin.SetUp(self, text, uiTextureKitID);

	self:UpdateHeight();

	local isCollapsedAlert = text == g_collapsedServerAlert;
	self.ExpandBar:SetExpanded(not isCollapsedAlert);
	if not isCollapsedAlert then
		g_collapsedServerAlert = nil;
	end

	self.ExpandBar:SetUITextureKit(uiTextureKitID);
end

function CollapsibleServerAlertMixin:SetExpanded(expanded, isUserInput)
	return self.ExpandBar:SetExpanded(expanded, isUserInput);
end

function CollapsibleServerAlertMixin:GetCollapsedHeight()
	return self.ExpandBar:GetHeight();
end

function CollapsibleServerAlertMixin:GetEffectiveHeight()
	if self.ExpandBar:IsExpanded() then
		return self:GetHeight();
	end

	return self:GetCollapsedHeight();
end
