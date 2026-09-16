SocialUISystemMixin = {};

function SocialUISystemMixin:GetSocialUI()
	return SocialUIFrame;
end

function SocialUISystemMixin:TriggerSocialUIEvent(event, ...)
	local socialUI = self:GetSocialUI();
	if not socialUI then
		return;
	end

	socialUI:TriggerEvent(event, ...);
end

function SocialUISystemMixin:SocialUIRequestToggleSideWindow(sideWindowType)
	local socialUI = self:GetSocialUI();
	if not socialUI then
		return;
	end

	local isCurrentlyShown = socialUI:GetActiveSideWindowType() == sideWindowType;
	if isCurrentlyShown then
		socialUI:TriggerEvent(SocialUIFrameMixin.Event.SideWindowHideRequested, sideWindowType);
	else
		socialUI:TriggerEvent(SocialUIFrameMixin.Event.SideWindowShowRequested, sideWindowType);
	end
end

function SocialUISystemMixin:SocialUIRequestHideSideWindow(sideWindowType)
	self:TriggerSocialUIEvent(SocialUIFrameMixin.Event.SideWindowHideRequested, sideWindowType);
end
