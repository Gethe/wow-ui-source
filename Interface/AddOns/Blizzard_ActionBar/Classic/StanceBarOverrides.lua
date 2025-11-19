
function StanceBarMixin:SetBackgroundArtShown(shown)
	self.BackgroundArtLeft:SetShown(shown);
	if (self.numForms >= 3) then
		-- Middle art should only be shown if we have >= 3 icons.
		self.BackgroundArtMiddle:SetShown(shown);
	end
	self.BackgroundArtRight:SetShown(shown);
end

function StanceBarMixin:UpdateBackgroundArt()
	--Setup the Stance bar to display the appropriate number of slots
	if ( self.numForms == 1 ) then
		self.BackgroundArtMiddle:Hide();
		self.BackgroundArtMiddle:ClearAllPoints();
		self.BackgroundArtRight:SetPoint("LEFT", self.BackgroundArtLeft, "LEFT", 12, 0);
	elseif ( self.numForms == 2 ) then
		self.BackgroundArtMiddle:Hide();
		self.BackgroundArtMiddle:ClearAllPoints();
		self.BackgroundArtRight:SetPoint("LEFT", self.BackgroundArtLeft, "RIGHT", 1, 0);
	else
		self.BackgroundArtMiddle:Show();
		self.BackgroundArtMiddle:SetPoint("LEFT", self.BackgroundArtLeft, "RIGHT", 0, 0);
		self.BackgroundArtMiddle:SetWidth(37 * (self.numForms-2));
		self.BackgroundArtMiddle:SetTexCoord(0, self.numForms-2, 0, 1);
		self.BackgroundArtRight:SetPoint("LEFT", self.BackgroundArtMiddle, "RIGHT", 0, 0);
	end
end
