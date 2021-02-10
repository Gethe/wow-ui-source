TOOLTIP_BACKDROP_STYLE_DEFAULT = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true,
	tileEdge = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },

	backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
	backdropColor = TOOLTIP_DEFAULT_BACKGROUND_COLOR,
};

local function SetupTextFont(fontString, fontObject)
	if fontString and fontObject then
		fontString:SetFontObject(fontObject);
	end
end

function SharedTooltip_OnLoad(self)
	SharedTooltip_SetBackdropStyle(self, TOOLTIP_BACKDROP_STYLE_DEFAULT);
	self:SetClampRectInsets(0, 0, 15, 0);

	SetupTextFont(self.TextLeft1, self.textLeft1Font);
	SetupTextFont(self.TextRight1, self.textRight1Font);
	SetupTextFont(self.TextLeft2, self.textLeft2Font);
	SetupTextFont(self.TextRight2, self.textRight2Font);
end

function SharedTooltip_OnHide(self)
	self:SetPadding(0, 0, 0, 0);
end

local DEFAULT_TOOLTIP_OFFSET_X = -17;
local DEFAULT_TOOLTIP_OFFSET_Y = 70;

function SharedTooltip_SetDefaultAnchor(tooltip, parent)
	tooltip:SetOwner(parent or GetAppropriateTopLevelParent(), "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMRIGHT", GetAppropriateTopLevelParent(), "BOTTOMRIGHT", DEFAULT_TOOLTIP_OFFSET_X, DEFAULT_TOOLTIP_OFFSET_Y);
end

function SharedTooltip_ClearInsertedFrames(self)
	if self.insertedFrames then
		for i = 1, #self.insertedFrames do
			self.insertedFrames[i]:Hide();
		end
	end
	self.insertedFrames = nil;
end

function SharedTooltip_SetBackdropStyle(self, style)
	self:SetBackdrop(style);
	self:SetBackdropBorderColor((style.backdropBorderColor or TOOLTIP_DEFAULT_COLOR):GetRGB());
	self:SetBackdropColor((style.backdropColor or TOOLTIP_DEFAULT_BACKGROUND_COLOR):GetRGB());

	if self.TopOverlay then
		if style.overlayAtlasTop then
			self.TopOverlay:SetAtlas(style.overlayAtlasTop, true);
			self.TopOverlay:SetScale(style.overlayAtlasTopScale or 1.0);
			self.TopOverlay:SetPoint("CENTER", self, "TOP", style.overlayAtlasTopXOffset or 0, style.overlayAtlasTopYOffset or 0);
			self.TopOverlay:Show();
		else
			self.TopOverlay:Hide();
		end
	end

	if self.BottomOverlay then
		if style.overlayAtlasBottom then
			self.BottomOverlay:SetAtlas(style.overlayAtlasBottom, true);
			self.BottomOverlay:SetScale(style.overlayAtlasBottomScale or 1.0);
			self.BottomOverlay:SetPoint("CENTER", self, "BOTTOM", style.overlayAtlasBottomXOffset or 0, style.overlayAtlasBottomYOffset or 0);
			self.BottomOverlay:Show();
		else
			self.BottomOverlay:Hide();
		end
	end

	if style.padding then
		self:SetPadding(style.padding.right, style.padding.bottom, style.padding.left, style.padding.top);
	end
end

function GameTooltip_AddBlankLinesToTooltip(tooltip, numLines)
	if numLines ~= nil then
		for i = 1, numLines do
			tooltip:AddLine(" ");
		end
	end
end

function GameTooltip_AddBlankLineToTooltip(tooltip)
	GameTooltip_AddBlankLinesToTooltip(tooltip, 1);
end

function GameTooltip_SetTitle(tooltip, text, overrideColor, wrap)
	tooltip:ClearLines();
	GameTooltip_AddColoredLine(tooltip, text, overrideColor or HIGHLIGHT_FONT_COLOR, wrap)
end

function GameTooltip_AddNormalLine(tooltip, text, wrap, leftOffset)
	GameTooltip_AddColoredLine(tooltip, text, NORMAL_FONT_COLOR, wrap, leftOffset);
end

function GameTooltip_AddHighlightLine(tooltip, text, wrap, leftOffset)
	GameTooltip_AddColoredLine(tooltip, text, HIGHLIGHT_FONT_COLOR, wrap, leftOffset);
end

function GameTooltip_AddInstructionLine(tooltip, text, wrap, leftOffset)
	GameTooltip_AddColoredLine(tooltip, text, GREEN_FONT_COLOR, wrap, leftOffset);
end

function GameTooltip_AddErrorLine(tooltip, text, wrap, leftOffset)
	GameTooltip_AddColoredLine(tooltip, text, RED_FONT_COLOR, wrap, leftOffset);
end

function GameTooltip_AddDisabledLine(tooltip, text, wrap, leftOffset)
	GameTooltip_AddColoredLine(tooltip, text, DISABLED_FONT_COLOR, wrap, leftOffset);
end

function GameTooltip_AddColoredLine(tooltip, text, color, wrap, leftOffset)
	local r, g, b = color:GetRGB();
	if wrap == nil then
		wrap = true;
	end
	tooltip:AddLine(text, r, g, b, wrap, leftOffset);
end

function GameTooltip_AddColoredDoubleLine(tooltip, leftText, rightText, leftColor, rightColor, wrap)
	local leftR, leftG, leftB = leftColor:GetRGB();
	local rightR, rightG, rightB = rightColor:GetRGB();
	if wrap == nil then
		wrap = true;
	end
	tooltip:AddDoubleLine(leftText, rightText, leftR, leftG, leftB, rightR, rightG, rightB, wrap);
end

function GameTooltip_InsertFrame(tooltipFrame, frame, verticalPadding)
	verticalPadding = verticalPadding or 0;

	local textSpacing = 2;
	local textHeight = _G[tooltipFrame:GetName().."TextLeft2"]:GetLineHeight();
	local neededHeight = frame:GetHeight() + verticalPadding ;
	local numLinesNeeded = math.ceil(neededHeight / (textHeight + textSpacing));
	local currentLine = tooltipFrame:NumLines();
	GameTooltip_AddBlankLinesToTooltip(tooltipFrame, numLinesNeeded);
	frame:SetParent(tooltipFrame);
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", tooltipFrame:GetName().."TextLeft"..(currentLine + 1), "TOPLEFT", 0, -verticalPadding);
	if not tooltipFrame.insertedFrames then
		tooltipFrame.insertedFrames = { };
	end
	local frameWidth = frame:GetWidth();
	if ( tooltipFrame:GetMinimumWidth() < frameWidth ) then
		tooltipFrame:SetMinimumWidth(frameWidth);
	end
	frame:Show();
	tinsert(tooltipFrame.insertedFrames, frame);
	-- return space taken so inserted frame can resize if needed
	return (numLinesNeeded * textHeight) + (numLinesNeeded - 1) * textSpacing;
end
