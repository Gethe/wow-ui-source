local NotificationData = {};

local function InsertNotificationData(notificationType, label, icon, title, message)
	NotificationData[notificationType] = {
		notification = {
			label = label,
			icon =  icon,
		},
		details = {
			title = title,
			message = message,
		}
	};
end

InsertNotificationData("ComplaintWarning_Social", BEHAVIORAL_NOTIFICATION_WARNING, "gmchat-icon-alert", BEHAVIORAL_DETAILS_LANGUAGE_TITLE, BEHAVIORAL_DETAILS_LANGUAGE_MESSAGE);
InsertNotificationData("ComplaintThankYou_Social", BEHAVIORAL_NOTIFICATION_RESOLUTION, "gmchat-icon-wow", BEHAVIORAL_DETAILS_RESOLUTION_TITLE, BEHAVIORAL_DETAILS_RESOLUTION_MESSAGE);

BehavioralMessagingNotificationMixin = {}

function BehavioralMessagingNotificationMixin:Init(data, notificationType, count)
	self.notificationType = notificationType;
	self.count = count;
	self.backgroundsPool = CreateFramePool("Frame", self, "BehaviorMessagingBackgroundTemplate");
	
	self.Icon:SetAtlas(data.icon, TextureKitConstants.UseAtlasSize);
	self:Update();
end

function BehavioralMessagingNotificationMixin:UpdateText()
	local data = NotificationData[self.notificationType].notification;
	
	if self.count > 1 then
		self.TitleText:SetText(string.format(AUCTION_MAIL_ITEM_STACK, data.label, self.count));
	else
		self.TitleText:SetText(data.label);
	end
	
	local titleWidth, titleHeight = self.TitleText:GetSize();
	local subtitleWidth, subtitleHeight = self.SubtitleText:GetSize();
	self:SetWidth(math.max(titleWidth, subtitleWidth) + 50);
	self:SetHeight(titleHeight + subtitleHeight + 20);
end

function BehavioralMessagingNotificationMixin:UpdateBackgrounds()
	self.backgroundsPool:ReleaseAll();

	local frameLevel = self:GetFrameLevel() - 1;
	local indent = 0;
	local minAllowed = 1;
	local maxAllowed = 2;
	for index = 1, math.max(minAllowed, math.min(self.count, maxAllowed)) do
		local background = self.backgroundsPool:Acquire();
		background:SetPoint("TOPLEFT", self, "TOPLEFT", indent, indent); 
		background:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", indent, indent);
		background:SetFrameLevel(frameLevel);
		background:Show();
		frameLevel = frameLevel - 1;
		indent = indent - 3;
	end
end

function BehavioralMessagingNotificationMixin:Update()
	self:UpdateText();
	self:UpdateBackgrounds();
end

function BehavioralMessagingNotificationMixin:GetCount()
	return self.count;
end

function BehavioralMessagingNotificationMixin:Increment()
	self.count = self.count + 1;
	self:Update();
end

function BehavioralMessagingNotificationMixin:Decrement()
	self.count = self.count - 1;
	self:Update();
end

BehavioralMessagingTrayMixin = {};

function BehavioralMessagingTrayMixin:OnLoad()
	self:RegisterEvent("BEHAVIORAL_NOTIFICATION");

	self.pool = CreateFramePool("Button", self, "BehaviorMessagingNotificationTemplate");
end

function BehavioralMessagingTrayMixin:FindNotification(notificationType)
	for notification in self.pool:EnumerateActive() do
		if notification.notificationType == notificationType then
			return notification;
		end
	end
end
			
function BehavioralMessagingTrayMixin:OnEvent(event, ...)
	if event == "BEHAVIORAL_NOTIFICATION" then
		local notificationType, count = ...;
		local data = NotificationData[notificationType];
		if data then
			local function OnClick(button, buttonName, down)
				BehavioralMessagingDetails:DisplayNotification(data.details, button);
			end

			local notification = self:FindNotification(notificationType);
			if notification then
				notification:Increment();
			else
				notification = self.pool:Acquire();
				notification:SetFrameLevel(10);
				notification:Init(data.notification, notificationType, count);
				notification:Show();
				notification:SetScript("OnClick", OnClick);
			end
		end
	end

	self:EvaluateLayout();
end

function BehavioralMessagingTrayMixin:EvaluateLayout()
	local index = 0;
	for notification in self.pool:EnumerateActive() do
		notification.layoutIndex = index;
		index = index + 1;
	end

	self:Layout();
	self:SetShown(index > 0);

	-- Anchoring occurs in UIParent_UpdateTopFramePositions.
	UIParent_UpdateTopFramePositions();
end

function BehavioralMessagingTrayMixin:OnNotificationAchknowledged(notification)
	C_BehavioralMessaging.SendNotificationReceipt(notification.notificationType);
	
	notification:Decrement();
	if notification:GetCount() == 0 then
		self.pool:Release(notification);
	else
		notification:Update();
	end

	self:EvaluateLayout();
end

BehavioralMessagingDetailsMixin = {};

function BehavioralMessagingDetailsMixin:OnLoad()
	NineSliceUtil.ApplyLayoutByName(self.Border, "Dialog");

	local fontString = self.CloseButton:GetFontString();
	self.CloseButton:SetWidth(fontString:GetStringWidth() + 50);
end

function BehavioralMessagingDetailsMixin:DisplayInternal(titleText, bodyText)
	self.Body.TitleText:SetText(titleText);
	self.Body.BodyText:SetText(bodyText);

	ShowUIPanel(self);
end

function BehavioralMessagingDetailsMixin:DisplayNotification(details, notification)
	self:DisplayInternal(details.title, details.message);
	
	local function OnClick(button, buttonName, down)
		HideUIPanel(self);

		BehavioralMessagingTray:OnNotificationAchknowledged(notification);
	end
	self.CloseButton:SetScript("OnClick", OnClick);
end