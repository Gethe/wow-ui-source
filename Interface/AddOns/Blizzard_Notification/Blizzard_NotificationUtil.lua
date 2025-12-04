
local notificationPoolCollection = CreateFramePoolCollection();
notificationPoolCollection:CreatePool("FRAME", nil, "NotificationIconFrameTemplate");
notificationPoolCollection:CreatePool("FRAME", nil, "LargeNotificationIconFrameTemplate");

local function AcquireNotificationFrame(template, point, parent, relativePoint, offsetX, offsetY)
	local frame = notificationPoolCollection:Acquire(template);
	frame:SetParent(parent);
	frame:SetPoint(point, parent, relativePoint, offsetX, offsetY);
	frame:Show();
	return frame;
end

NotificationUtil = {};

function NotificationUtil.AcquireNotification(point, parent, relativePoint, offsetX, offsetY)
	return AcquireNotificationFrame("NotificationIconFrameTemplate", point, parent, relativePoint, offsetX, offsetY);
end

function NotificationUtil.AcquireLargeNotification(point, parent, relativePoint, offsetX, offsetY)
	return AcquireNotificationFrame("LargeNotificationIconFrameTemplate", point, parent, relativePoint, offsetX, offsetY);
end

function NotificationUtil.ReleaseNotification(frame)
	frame:SetParent(nil);
	notificationPoolCollection:Release(frame);
end
