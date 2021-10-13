
ActionStatusMixin = {};

local ACTION_STATUS_FADETIME = 2.0;

function ActionStatusMixin:OnLoad()
	self:RegisterEvent("SCREENSHOT_STARTED");
	self:RegisterEvent("SCREENSHOT_SUCCEEDED");
	self:RegisterEvent("SCREENSHOT_FAILED");
end

function ActionStatusMixin:OnEvent(event, ...)
	if ( event == "SCREENSHOT_STARTED" ) then
		self:Hide();
	else
		self.startTime = GetTime();
		self:SetAlpha(1.0);
		if ( event == "SCREENSHOT_SUCCEEDED" ) then
			self:DisplayMessage(SCREENSHOT_SUCCESS);
			-- Append [Share] hyperlink
			if ( C_Social.IsSocialEnabled() ) then
				local screenshotText = SCREENSHOT_SUCCESS .. " " .. Social_GetShareScreenshotLink();
				ChatFrame_DisplaySystemMessageInPrimary(screenshotText);
			end
		end
		if ( event == "SCREENSHOT_FAILED" ) then
			self:DisplayMessage(SCREENSHOT_FAILURE);
		end
		self:Show();
	end
end

function ActionStatusMixin:DisplayMessage(text)
	self.startTime = GetTime();
	self:SetAlpha(1.0);
	self.Text:SetText(text);
	self:Show();
end

function ActionStatusMixin:OnUpdate(elapsed)
	elapsed = GetTime() - self.startTime;
	if ( elapsed < ACTION_STATUS_FADETIME ) then
		local alpha = 1.0 - (elapsed / ACTION_STATUS_FADETIME);
		self:SetAlpha(alpha);
		return;
	end
	self:Hide();
end

function ActionStatusMixin:UpdateParent()
	self:ClearAllPoints();

	if UIParent:IsVisible() then
		self:SetParent(UIParent);
		self:SetFrameStrata("TOOLTIP");
		self:SetScale(1);
	else
		self:SetParent(WorldFrame);
		self:SetScale(UIParent:GetEffectiveScale());
	end

	self:SetAllPoints(self:GetParent());
end
