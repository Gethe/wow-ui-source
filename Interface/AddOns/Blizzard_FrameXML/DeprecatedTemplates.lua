function OptionsListButton_OnLoad (self, toggleFunc)
	self.text = self.Text;
	self.highlight = self:GetHighlightTexture();
	self.highlight:SetVertexColor(.196, .388, .8);
	self.text:SetPoint("RIGHT", self.Toggle, "LEFT", -2, 0);
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	self.toggleFunc = toggleFunc;
end

function OptionsListButton_OnClick (self, mouseButton)
	if ( mouseButton == "RightButton" ) then
		if ( self.element.hasChildren ) then
			OptionsListButtonToggle_OnClick(self.toggle);
		end
		return;
	end
end

function OptionsListButton_OnEnter (self)
	if (self.text:IsTruncated()) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self:GetText(), NORMAL_FONT_COLOR[1], NORMAL_FONT_COLOR[2], NORMAL_FONT_COLOR[3], 1, true);
	end
end

function OptionsListButton_OnLeave (self)
	GetAppropriateTooltip():Hide();
end

function OptionsListButtonToggle_OnClick (self)
	local button = self:GetParent();
	button:toggleFunc();
end