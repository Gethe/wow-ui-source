local DisplayData = {};

local function InsertDisplayData(notificationType, label, icon, soundKit, title, message)
	DisplayData[notificationType] = {
		notification = {
			label = label,
			icon =  icon,
			soundKit = soundKit,
		},
		details = {
			title = title,
			message = message,
		}
	};
end

InsertDisplayData("ComplaintWarning_Social", BEHAVIORAL_NOTIFICATION_WARNING, "gmchat-icon-alert", 
	SOUNDKIT.BEHAVIORAL_NOTIFICATION_WARNING, BEHAVIORAL_DETAILS_SOCIAL_TITLE, BEHAVIORAL_DETAILS_SOCIAL_MESSAGE);

InsertDisplayData("ComplaintThankYou_Social", BEHAVIORAL_NOTIFICATION_TY, "gmchat-icon-wow", 
	SOUNDKIT.BEHAVIORAL_NOTIFICATION_TY, BEHAVIORAL_DETAILS_TY_TITLE, BEHAVIORAL_DETAILS_TY_MESSAGE);

BehavioralMessagingNotificationMixin = {}

function BehavioralMessagingNotificationMixin:OnLoad()
	self.backgroundsPool = CreateFramePool("Frame", self, "BehaviorMessagingBackgroundTemplate");
end

function BehavioralMessagingNotificationMixin:Init(notificationData, notificationType)
	self.instances = {};
	self.notificationData = notificationData;
	self.notificationType = notificationType;

	self.Icon:SetAtlas(notificationData.icon, TextureKitConstants.UseAtlasSize);
	self:Update();
end

function BehavioralMessagingNotificationMixin:UpdateText()
	local count = self:GetCount();
	if count > 1 then
		self.TitleText:SetText(string.format(AUCTION_MAIL_ITEM_STACK, self.notificationData.label, count));
	else
		self.TitleText:SetText(self.notificationData.label);
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
	for index = 1, math.max(minAllowed, math.min(self:GetCount(), maxAllowed)) do
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
	return #self.instances;
end

function BehavioralMessagingNotificationMixin:PushInstance(id)
	local function HasId(tbl)
		return tbl.id == id;
	end

	if not ContainsIf(self.instances, HasId) then
		local tbl = {id = id, createTimeSeconds = GetTime()};
		table.insert(self.instances, tbl);
		self:Update();
		return true;
	end
	return false;
end

function BehavioralMessagingNotificationMixin:PopInstance()
	local tbl = table.remove(self.instances);
	self:Update();
	return tbl;
end

function BehavioralMessagingNotificationMixin:PeekInstance()
	return self.instances[#self.instances];
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
		local notificationType, id = ...;
		local displayData = DisplayData[notificationType];
		if displayData then
			local function OnClick(button, buttonName, down)
				PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
				BehavioralMessagingDetails:DisplayNotification(displayData.details, button);
			end

			local notification = self:FindNotification(notificationType);
			if not notification then
				notification = self.pool:Acquire();
				notification:SetFrameLevel(10);
				notification:Init(displayData.notification, notificationType);
				notification:Show();
				notification:SetScript("OnClick", OnClick);
			end

			local success = notification:PushInstance(id);
			if success then
				PlaySound(displayData.notification.soundKit);
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
	local instance = notification:PopInstance();
	local openSeconds = instance.openTimeSeconds - instance.createTimeSeconds;
	local readSeconds = (GetTime() - instance.createTimeSeconds) - openSeconds;
	C_BehavioralMessaging.SendNotificationReceipt(instance.id, openSeconds, readSeconds);
	
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

function BehavioralMessagingDetailsMixin:OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function BehavioralMessagingDetailsMixin:DisplayInternal(titleText, bodyText)
	self.Body.TitleText:SetText(titleText);
	self.Body.BodyText:SetText(bodyText);

	ShowUIPanel(self);
end

function BehavioralMessagingDetailsMixin:DisplayNotification(details, notification)
	local instance = notification:PeekInstance();
	if not instance.openTimeSeconds then
		instance.openTimeSeconds = GetTime();
	end

	self:DisplayInternal(details.title, details.message);
	
	local function OnClick(button, buttonName, down)
		HideUIPanel(self);

		BehavioralMessagingTray:OnNotificationAchknowledged(notification);
	end
	self.CloseButton:SetScript("OnClick", OnClick);
end