GLUETOOLTIP_NUM_LINES = 5;
GLUETOOLTIP_HPADDING = 20;

function GlueTooltip_OnLoad(self)
	self.Clear = GlueTooltip_Clear;
	self.SetFont = GlueTooltip_SetFont;
	self.AddLine = GlueTooltip_AddLine;
	self.SetText = GlueTooltip_SetText;
	self.SetOwner = GlueTooltip_SetOwner;
	self.GetOwner = GlueTooltip_GetOwner;
	self.IsOwned = GlueTooltip_IsOwned;
	self.defaultColor = NORMAL_FONT_COLOR;
end

-- mimic what tooltip does ingame
local tooltipAnchorPointMapping = {
	["ANCHOR_LEFT"] =			{ myPoint = "BOTTOMRIGHT",	ownerPoint = "TOPLEFT" },
	["ANCHOR_RIGHT"] = 			{ myPoint = "BOTTOMLEFT", 	ownerPoint = "TOPRIGHT" },
	["ANCHOR_BOTTOMLEFT"] = 	{ myPoint = "TOPRIGHT", 	ownerPoint = "BOTTOMLEFT" },
	["ANCHOR_BOTTOM"] = 		{ myPoint = "TOP", 			ownerPoint = "BOTTOM" },
	["ANCHOR_BOTTOMRIGHT"] =	{ myPoint = "TOPLEFT", 		ownerPoint = "BOTTOMRIGHT" },
	["ANCHOR_TOPLEFT"] = 		{ myPoint = "BOTTOMLEFT", 	ownerPoint = "TOPLEFT" },
	["ANCHOR_TOP"] = 			{ myPoint = "BOTTOM", 		ownerPoint = "TOP" },
	["ANCHOR_TOPRIGHT"] = 		{ myPoint = "BOTTOMRIGHT", 	ownerPoint = "TOPRIGHT" },
};

function GlueTooltip_SetOwner(self, owner, anchor, xOffset, yOffset )
	if ( not self or not owner) then
		return;
	end
	self.owner = owner;
	anchor = anchor or "ANCHOR_LEFT";
	xOffset = xOffset or 0;
	yOffset = yOffset or 0;

	self:ClearAllPoints();
	local points = tooltipAnchorPointMapping[anchor];
	self:SetPoint(points.myPoint, owner, points.ownerPoint, xOffset, yOffset);
	self:Show();
end

function GlueTooltip_GetOwner(self)
	return self.owner;
end

function GlueTooltip_IsOwned(self, frame)
	return self:GetOwner() == frame;
end

function GlueTooltip_SetText(self, text, r, g, b, a, wrap)
	self:Clear();
	self:AddLine(text, r, g, b, a, wrap);
end

function GlueTooltip_SetFont(self, font)
	for i = 1, GLUETOOLTIP_NUM_LINES do
		local textString = _G[self:GetName().."TextLeft"..i];
		textString:SetFontObject(font);
		textString = _G[self:GetName().."TextRight"..i];
		textString:SetFontObject(font);
	end
end

function GlueTooltip_Clear(self)
	for i = 1, GLUETOOLTIP_NUM_LINES do
		local textString = _G[self:GetName().."TextLeft"..i];
		textString:SetText("");
		textString:Hide();
		textString:SetWidth(0);
		textString = _G[self:GetName().."TextRight"..i];
		textString:SetText("");
		textString:Hide();
		textString:SetWidth(0);
	end
	self:SetWidth(1);
	self:SetHeight(1);
end

function GlueTooltip_AddLine(self, text, r, g, b, a, wrap)
	r = r or self.defaultColor.r;
	g = g or self.defaultColor.g;
	b = b or self.defaultColor.b;
	a = a or 1;
	-- find a free line
	local freeLine;
	for i = 1, GLUETOOLTIP_NUM_LINES do
		local line = _G[self:GetName().."TextLeft"..i];
		if ( not line:IsShown() ) then
			freeLine = line;
			break;
		end
	end

	if (not freeLine) then return; end

	freeLine:SetTextColor(r, g, b, a);
	freeLine:SetText(text);
	freeLine:Show();
	freeLine:SetWidth(0);

	local wrapWidth = 230;
	if (wrap and freeLine:GetWidth() > wrapWidth) then

		-- Trim the right edge so that there isn't extra space after wrapping
		freeLine:SetWidth(wrapWidth);
		wrapWidth = freeLine:GetWrappedWidth();

		self:SetWidth(max(self:GetWidth(), wrapWidth+GLUETOOLTIP_HPADDING));
	else
		self:SetWidth(max(self:GetWidth(), freeLine:GetWidth()+GLUETOOLTIP_HPADDING));
	end

	-- Compute height and update width of text lines
	local height = 18;
	for i = 1, GLUETOOLTIP_NUM_LINES do
		-- Update width of all lines
		local line = _G[self:GetName().."TextLeft"..i];
		local rightLine = _G[self:GetName().."TextRight"..i];
		if (not rightLine:IsShown()) then
			line:SetWidth(self:GetWidth()-GLUETOOLTIP_HPADDING);
		end

		-- Update the height of the frame
		if ( line:IsShown() ) then
			height = height + line:GetHeight() + 2;
		end
	end
	self:SetHeight(height);
end

