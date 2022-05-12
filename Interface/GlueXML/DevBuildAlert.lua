function DevBuildAlert_OnLoad(self)
	self:RegisterEvent("SHOW_DEV_BUILD_ALERT");
end

function DevBuildAlert_OnEvent(self, event, ...)
	if ( event == "SHOW_DEV_BUILD_ALERT" ) then
		local text = ...;
		self.ScrollFrame.Text:SetWidth(self.ScrollFrame:GetWidth());
		self.ScrollFrame.Text:SetText(text);
		if (text == nil or text == "") then
			self:Hide();
		else
			self:Show();
		end
	end
end

