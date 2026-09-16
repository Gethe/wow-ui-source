DefaultAnimOutMixin = {};

function DefaultAnimOutMixin:OnFinished()
	self:GetParent():Hide();
end

SocialToastCloseButtonMixin = {};

function SocialToastCloseButtonMixin:OnEnter()
	self:GetParent():OnEnter();
end

function SocialToastCloseButtonMixin:OnLeave()
	self:GetParent():OnLeave();
end

function SocialToastCloseButtonMixin:OnClick()
	-- Currently all work is done in OnHide...possibly better to have a dedicated close method?
	self:GetParent():Hide();
end

SocialToastMixin = {};

function SocialToastMixin:OnEnter()
	AlertFrame_PauseOutAnimation(self);
end

function SocialToastMixin:OnLeave()
	AlertFrame_ResumeOutAnimation(self);
end

--This is used to track the time remaining until a player gets forcibly sharded
ShardTransferImminentMixin = {};

function ShardTransferImminentMixin:OnLoad()
	self:RegisterEvent("SHARD_TRANSFER_IMMINENT");
	self:RegisterEvent("SHARD_TRANSFER");

	self:ClearAllPoints();
	self:SetPoint("BOTTOMLEFT", ChatAlertFrame, "TOPLEFT", 30, 55);

	-- We can minimize this alert with the ShardTransferImminentMinimizeButton; so we don't want to have a close button.
	if self.CloseButton then
		self.CloseButton:Hide();
		self.CloseButton:SetParent(nil);
	end
end

function ShardTransferImminentMixin:OnEvent(event, ...)
	if (event == "SHARD_TRANSFER_IMMINENT") then
		self:Start(...);
	elseif (event == "SHARD_TRANSFER") then
		self:Hide();
	end
end

function ShardTransferImminentMixin:Start(time)
	self:SetExternallyManagedOutroAnimation(true);
	AlertFrame_ShowNewAlert(self);
	self.timer = GetEvictionTimeRemaining();
end

function ShardTransferImminentMixin:OnUpdate(elapsed)
	if self.timer then
		self.timer = self.timer - elapsed;
	end

	-- As long as this frame is shown, continue to update
	if not self.timer or self.timer < 0 then
		self.Text:SetFormattedText(SHARD_TRANSFER_ANYTIME);
	elseif self.timer < 60 then
		self.Text:SetFormattedText(SHARD_TRANSFER_REFRESH_MESSAGE, ceil(self.timer), SECONDS);
	else
		self.Text:SetFormattedText(SHARD_TRANSFER_REFRESH_MESSAGE, ceil(self.timer / 60), MINUTES);
	end
	self:SetHeight(self.Text:GetStringHeight() + 20);
end

function ShardTransferImminentMixin:OnClick()
	if self.timer and self.timer > 0 then
		StaticPopup_Show("SHARD_TRANSFER_IMMINENT_EVENT");
	else
		StaticPopup_Show("SHARD_TRANSFER_IMMEDIATE");
	end
end

--This is used to minimize the ShardTransferImminentMixin element
ShardTransferImminentMinimizeMixin = {};

function ShardTransferImminentMinimizeMixin:OnLoad()
	self:RegisterEvent("SHARD_TRANSFER_IMMINENT");
	self:RegisterEvent("SHARD_TRANSFER");

	self:ClearAllPoints();
	self:SetPoint("TOPRIGHT", ShardTransferImminentFrame, "TOPLEFT", -5, 0);

	-- We don't want this element to have a close button
	if self.CloseButton then
		self.CloseButton:Hide();
		self.CloseButton:SetParent(nil);
	end
end

function ShardTransferImminentMinimizeMixin:OnEvent(event, ...)
	if (event == "SHARD_TRANSFER_IMMINENT") then
		self:Start(...);
	elseif (event == "SHARD_TRANSFER") then
		self:Hide();
	end
end

function ShardTransferImminentMinimizeMixin:Start(time)
	self:SetExternallyManagedOutroAnimation(true);
	AlertFrame_ShowNewAlert(self);
	self.timer = GetEvictionTimeRemaining();
end

function ShardTransferImminentMinimizeMixin:OnUpdate(elapsed)
	if self.timer then
		self.timer = self.timer - elapsed;
		if self.timer < 0 then
			self:SetExternallyManagedOutroAnimation(false);
			AlertFrame_PlayOutroAnimation(self);
		end
	end
end

function ShardTransferImminentMinimizeMixin:OnClick()
	if ShardTransferImminentFrame:IsShown() then
		ShardTransferImminentFrame:Hide();
	else
		ShardTransferImminentFrame:Show();
	end
end
