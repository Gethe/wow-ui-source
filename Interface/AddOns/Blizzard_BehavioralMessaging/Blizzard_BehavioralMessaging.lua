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

local function ShareNotificationData(notificationTypeExisting, notificationTypeNew)
	NotificationData[notificationTypeNew] = notificationTypeExisting;
end

InsertNotificationData("RECEIVED_COMPLAINT_LANGUAGE", BEHAVIORAL_NOTIFICATION_WARNING, "gmchat-icon-alert", BEHAVIORAL_DETAILS_LANGUAGE_TITLE, BEHAVIORAL_DETAILS_LANGUAGE_MESSAGE);
InsertNotificationData("COMPLAINT_SUCCESSFUL", BEHAVIORAL_NOTIFICATION_RESOLUTION, "gmchat-icon-wow", BEHAVIORAL_DETAILS_RESOLUTION_TITLE, BEHAVIORAL_DETAILS_RESOLUTION_MESSAGE);
ShareNotificationData("RECEIVED_COMPLAINT_LANGUAGE", "RECEIVED_COMPLAINT_SPAM");

BehavioralMessagingNotificationMixin = {}

function BehavioralMessagingNotificationMixin:Init(data, notificationType)
	self.notificationType = notificationType;
	self.TitleText:SetText(data.label);
	self.Icon:SetAtlas(data.icon, TextureKitConstants.UseAtlasSize);
	
	local titleWidth, titleHeight = self.TitleText:GetSize();
	local subtitleWidth, subtitleHeight = self.SubtitleText:GetSize();
	self:SetWidth(math.max(titleWidth, subtitleWidth) + 50);
	self:SetHeight(titleHeight + subtitleHeight + 20);
end

BehavioralMessagingTrayMixin = {};

function BehavioralMessagingTrayMixin:OnLoad()
	self:RegisterEvent("BEHAVIORAL_NOTIFICATION");

	self.pool = CreateFramePool("Button", self, "BehaviorMessagingNotificationTemplate");
	self.notifications = {};
end

function BehavioralMessagingTrayMixin:OnEvent(event, ...)
	if event == "BEHAVIORAL_NOTIFICATION" then
		local notificationType = ...;
		local data = NotificationData[notificationType];
		if not data then
			-- Notification type needs to be shared or added altogether. See InsertNotificationData and ShareNotificationData above.
			return;
		end

		if not self.notifications[notificationType] then
			self.notifications[notificationType] = self.pool:Acquire();
		end

		local notification = self.notifications[notificationType];
		notification:Init(data.notification, notificationType);
		notification:Show();

		local function OnClick(button, buttonName, down)
			BehavioralMessagingDetails:DisplayNotification(data.details, button);
		end
		notification:SetScript("OnClick", OnClick);
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
	local notificationType = notification.notificationType;
	self.notifications[notificationType] = nil;
	self.pool:Release(notification);
	
	C_BehavioralMessaging.SendNotificationReceipt(notificationType);

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