MessageFrameScrollButtonMixin = {};

function MessageFrameScrollButtonMixin:OnLoad()
	self.clickDelay = MessageFrameScrollButtonConstants.InitialScrollDelay;
	self:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp", "RightButtonDown");
end

function MessageFrameScrollButtonMixin:OnUpdate(elapsed)
	if (self:GetButtonState() == "PUSHED") then
		self.clickDelay = self.clickDelay - elapsed;
		if ( self.clickDelay < 0 ) then
			local name = self:GetName();
			if ( name == self:GetParent():GetName().."DownButton" ) then
				self:GetParent():GetParent():ScrollDown();
			elseif ( name == self:GetParent():GetName().."UpButton" ) then
				self:GetParent():GetParent():ScrollUp();
			end
			self.clickDelay = MessageFrameScrollButtonConstants.HeldScrollDelay;
		end
	end
end

function MessageFrameScrollButtonMixin:ScrollDown()
	if ( self:GetButtonState() == "PUSHED" ) then
		self.clickDelay = MessageFrameScrollButtonConstants.InitialScrollDelay;
	else
		self:GetParent():GetParent():ScrollDown();
	end
	PlaySound(SOUNDKIT.IG_CHAT_SCROLL_DOWN);
end

function MessageFrameScrollButtonMixin:ScrollUp()
	if ( self:GetButtonState() == "PUSHED" ) then
		self.clickDelay = MessageFrameScrollButtonConstants.InitialScrollDelay;
	else
		self:GetParent():GetParent():ScrollUp();
	end
	PlaySound(SOUNDKIT.IG_CHAT_SCROLL_UP);
end
