
function StanceBarMixin:ShouldShowBackgroundArt()
	return MainMenuBar:IsShown()
		and self:IsInDefaultPosition()
		and self:IsSystemSettingDefault(Enum.EditModeActionBarSetting.Orientation)
		and self:IsSystemSettingDefault(Enum.EditModeActionBarSetting.NumRows)
		and self:IsSystemSettingDefault(Enum.EditModeActionBarSetting.IconSize)
		and self:IsSystemSettingDefault(Enum.EditModeActionBarSetting.IconPadding);
end

function StanceBarMixin:SetBackgroundArtShown(shown)
	self.BackgroundArtLeft:SetShown(shown);
	-- Middle art should only be shown if we have >= 3 icons.
	self.BackgroundArtMiddle:SetShown(shown and self.numForms >= 3);
	self.BackgroundArtRight:SetShown(shown);
end

function StanceBarMixin:UpdateBackgroundArt()
	self:SetBackgroundArtShown(self:ShouldShowBackgroundArt());

	--Setup the Stance bar to display the appropriate number of slots
	if ( self.numForms == 1 ) then
		self.BackgroundArtMiddle:ClearAllPoints();
		self.BackgroundArtRight:SetPoint("LEFT", self.BackgroundArtLeft, "LEFT", 12, 0);
	elseif ( self.numForms == 2 ) then
		self.BackgroundArtMiddle:ClearAllPoints();
		self.BackgroundArtRight:SetPoint("LEFT", self.BackgroundArtLeft, "RIGHT", 1, 0);
	else
		self.BackgroundArtMiddle:SetPoint("LEFT", self.BackgroundArtLeft, "RIGHT", 0, 0);
		self.BackgroundArtMiddle:SetWidth(37 * (self.numForms-2));
		self.BackgroundArtMiddle:SetTexCoord(0, self.numForms-2, 0, 1);
		self.BackgroundArtRight:SetPoint("LEFT", self.BackgroundArtMiddle, "RIGHT", 0, 0);
	end
end
