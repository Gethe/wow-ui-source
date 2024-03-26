function ServerAlert_OnLoad(self)
	self:RegisterEvent("SHOW_SERVER_ALERT");
end

local ServerAlertOffsets = {
	default = {
		titleX = 0,
		titleY = -20,
		scrollX1 = 15,
		scrollY1 = -46,
		scrollX2 = -35,
		scrollY2 = 13
		--no centerX or centerY needed
	},
};

function ServerAlert_OnEvent(self, event, ...)
	if ( event == "SHOW_SERVER_ALERT" ) then
		local text, uiTextureKitID = ...;
		--We have to resize before calling SetText because SimpleHTML frames won't resize correctly.
		self.ScrollFrame.Text:SetWidth(self.ScrollFrame:GetWidth());
		self.ScrollFrame.Text:SetText(text);
		self.isActive = true;

		local offsets = ServerAlertOffsets[uiTextureKitID or "default"];

		self.Title:SetPoint("TOP", offsets.titleX, offsets.titleY);

		self.ScrollFrame:SetPoint("TOPLEFT", offsets.scrollX1, offsets.scrollY1);
		self.ScrollFrame:SetPoint("BOTTOMRIGHT", offsets.scrollX2, offsets.scrollY2);

		if ( uiTextureKitID ) then
			self.Border:Hide();
			self.NineSlice:Show();
			NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, uiTextureKitID);

			self.NineSlice.Center:ClearAllPoints();
			self.NineSlice.Center:SetPoint("TOPLEFT", self, "TOPLEFT", offsets.centerX, offsets.centerY);
			self.NineSlice.Center:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -offsets.centerX, -offsets.centerY);
			self.NineSlice.Center:SetDrawLayer("BACKGROUND");
		else
			self.Border:Show();
			self.NineSlice:Hide();
		end

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
