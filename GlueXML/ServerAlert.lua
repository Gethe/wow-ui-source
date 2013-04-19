function ServerAlert_OnLoad(self)
	self:RegisterEvent("SHOW_SERVER_ALERT");
end

function ServerAlert_OnEvent(self, event, ...)
	if ( event == "SHOW_SERVER_ALERT" ) then
		local text = ...;
		--We have to resize before calling SetText because SimpleHTML frames won't resize correctly.
		self.ScrollFrame.Text:SetWidth(self.ScrollFrame:GetWidth());
		self.ScrollFrame.Text:SetText(text);
		self.isActive = true;
		if ( not self.disabled ) then
			self:Show();
		end
	end
end

function ServerAlert_Disable(self)
	self:Hide()
	self.disabled = true;
end

function ServerAlert_Enable(self)
	self.disabled = false;
	if ( self.isActive ) then
		self:Show();
	end
end
