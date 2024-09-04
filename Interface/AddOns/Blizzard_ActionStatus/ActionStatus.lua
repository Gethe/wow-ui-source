
ActionStatusMixin = {};

local ACTION_STATUS_FADETIME = 2.0;

function ActionStatusMixin:OnLoad()
	if (InGlue()) then
		self:RegisterEvent("GLUE_SCREENSHOT_STARTED");
		self:RegisterEvent("GLUE_SCREENSHOT_SUCCEEDED");
		self:RegisterEvent("GLUE_SCREENSHOT_FAILED");
	else
		self:RegisterEvent("SCREENSHOT_STARTED");
		self:RegisterEvent("SCREENSHOT_SUCCEEDED");
		self:RegisterEvent("SCREENSHOT_FAILED");
	end

	self.alternateParentFrame = nil;
	self:UpdateParent();

	EventRegistry:RegisterCallback("UI.AlternateTopLevelParentChanged", self.UpdateParent, self);
end

function ActionStatusMixin:OnEvent(event, ...)
	if ( event == "SCREENSHOT_STARTED" or event == "GLUE_SCREENSHOT_STARTED" ) then
		self:Hide();
	else
		self.startTime = GetTime();
		self:SetAlpha(1.0);
		if ( event == "SCREENSHOT_SUCCEEDED" or event == "GLUE_SCREENSHOT_SUCCEEDED" ) then
			self:DisplayMessage(SCREENSHOT_SUCCESS);
		end
		if ( event == "SCREENSHOT_FAILED" or event == "GLUE_SCREENSHOT_FAILED" ) then
			self:DisplayMessage(SCREENSHOT_FAILURE);
		end
		self:Show();
	end
end

function ActionStatusMixin:SetAlternateParentFrame(alternateParentFrame)
	self.alternateParentFrame = alternateParentFrame;
	self:UpdateParent();
end

function ActionStatusMixin:ClearAlternateParentFrame()
	self.alternateParentFrame = nil;
	self:UpdateParent();
end

function ActionStatusMixin:DisplayMessage(text)
	self.startTime = GetTime();
	self:SetAlpha(1.0);
	self.Text:SetText(text);
	self:Show();
end

function ActionStatusMixin:OnUpdate()
	local elapsed = GetTime() - self.startTime;
	if ( elapsed < ACTION_STATUS_FADETIME ) then
		local alpha = 1.0 - (elapsed / ACTION_STATUS_FADETIME);
		self:SetAlpha(alpha);
		return;
	end
	self:Hide();
end

function ActionStatusMixin:GetBestParent()
	if self.alternateParentFrame then
		return self.alternateParentFrame, 1;
	else
		local parent = GetAppropriateTopLevelParent();
		if parent then
			if parent:IsVisible() then
				return parent, 1;
			end

			if WorldFrame then
				return WorldFrame, parent:GetEffectiveScale();
			end
		end
	end

	return nil, 1;
end

function ActionStatusMixin:UpdateParent()
	self:ClearAllPoints();

	local parent, scale = self:GetBestParent();
	self:SetParent(parent);
	self:SetFrameStrata("TOOLTIP");
	self:SetScale(scale);

	if parent then
		self:SetAllPoints(parent);
	end
end
