--[[
	infoTable = {
		text,									-- also acts as a key for various API, MUST BE SET
		textColor = HIGHLIGHT_FONT_COLOR,
		textJustifyH = "LEFT",
		buttonStyle = HelpTip.ButtonStyle.None	-- button to close the helptip, or no button at all
		targetPoint = HelpTip.Point.BottomEdgeCenter,	-- where at the parent the helptip should point
		alignment = HelpTip.Alignment.Center,	-- alignment of the helptip relative to the parent (basically where the arrow is located)
		hideArrow = false,						-- whether to hide the arrow
		offsetX = 0,
		offsetY	= 0,
		cvar, cvarValue,						-- cvar to set when closed by user or from HelpTip:Acknowledge()
		cvarBitfield, bitfieldFlag,				-- cvarbitfield to set when closed by user or from HelpTip:Acknowledge()
		onHideCallback, callbackArg,			-- callback whenever the helptip is closed:  onHideCallback(acknowledged, callbackArg)
	}
]]--

HelpTip = { };

-- external use enums

HelpTip.Point = {
	TopEdgeLeft = 1,
	TopEdgeCenter = 2,
	TopEdgeRight = 3,
	RightEdgeTop = 4,
	RightEdgeCenter = 5,
	RightEdgeBottom = 6,
	BottomEdgeRight = 7,
	BottomEdgeCenter = 8,
	BottomEdgeLeft = 9,
	LeftEdgeBottom = 10,
	LeftEdgeCenter = 11,
	LeftEdgeTop = 12,
};

HelpTip.Alignment = {
	Left = 1,
	Center = 2,
	Right = 3,
	-- Intentional re-use of indices, really just need 3 settings but 5 makes it easier to visualize
	Top = 1,
	Bottom = 3,
};

HelpTip.ButtonStyle = {
	None = 1,
	Close = 2,
	Okay = 3,
};

-- internal use enums

HelpTip.ArrowRotation = {
	Down = 1,
	Left = 2,
	Up = 3,
	Right = 4,
};

-- data

HelpTip.Anchors = {
	[HelpTip.Point.TopEdgeLeft]		= { arrowRotation = HelpTip.ArrowRotation.Down,	 relativeAnchor = "TOPLEFT" },
	[HelpTip.Point.TopEdgeCenter]	= { arrowRotation = HelpTip.ArrowRotation.Down,  relativeAnchor = "TOP" },
	[HelpTip.Point.TopEdgeRight]	= { arrowRotation = HelpTip.ArrowRotation.Down,  relativeAnchor = "TOPRIGHT" },

	[HelpTip.Point.RightEdgeTop]	= { arrowRotation = HelpTip.ArrowRotation.Left,  relativeAnchor = "TOPRIGHT" },
	[HelpTip.Point.RightEdgeCenter] = { arrowRotation = HelpTip.ArrowRotation.Left,  relativeAnchor = "RIGHT" },
	[HelpTip.Point.RightEdgeBottom] = { arrowRotation = HelpTip.ArrowRotation.Left,  relativeAnchor = "BOTTOMRIGHT" },

	[HelpTip.Point.BottomEdgeRight] = { arrowRotation = HelpTip.ArrowRotation.Up,	 relativeAnchor = "BOTTOMRIGHT" },
	[HelpTip.Point.BottomEdgeCenter]= { arrowRotation = HelpTip.ArrowRotation.Up,	 relativeAnchor = "BOTTOM" },
	[HelpTip.Point.BottomEdgeLeft]	= { arrowRotation = HelpTip.ArrowRotation.Up,	 relativeAnchor = "BOTTOMLEFT" },

	[HelpTip.Point.LeftEdgeBottom]	= { arrowRotation = HelpTip.ArrowRotation.Right, relativeAnchor = "BOTTOMLEFT" },
	[HelpTip.Point.LeftEdgeCenter]	= { arrowRotation = HelpTip.ArrowRotation.Right, relativeAnchor = "LEFT" },
	[HelpTip.Point.LeftEdgeTop]		= { arrowRotation = HelpTip.ArrowRotation.Right, relativeAnchor = "TOPLEFT" },
};

HelpTip.ArrowOffsets = {
	[HelpTip.Alignment.Center]	= { 0,	 5 };
	[HelpTip.Alignment.Left]	= { 35,  5 };
	[HelpTip.Alignment.Right]	= { -35, 5 };
};

HelpTip.ArrowGlowOffsets = { 0, 4 };

HelpTip.DistanceOffsets = {
	[HelpTip.Alignment.Center]	= { 0,	 -20 };
	[HelpTip.Alignment.Left]	= { -35, -20 };
	[HelpTip.Alignment.Right]	= { 35,  -20 };
};

HelpTip.Rotations = {
	[HelpTip.ArrowRotation.Down]	= { modOffsetX = 1,  modOffsetY = -1, swapOffsets = false,	degrees = 0,	anchors = { "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT" } },
	[HelpTip.ArrowRotation.Left]	= { modOffsetX = -1, modOffsetY = -1, swapOffsets = true,	degrees = 90,	anchors = { "TOPLEFT", "LEFT", "BOTTOMLEFT" } },
	[HelpTip.ArrowRotation.Up]		= { modOffsetX = 1,	 modOffsetY = 1,  swapOffsets = false,	degrees = 180,	anchors = { "TOPLEFT", "TOP", "TOPRIGHT"}  },
	[HelpTip.ArrowRotation.Right]	= { modOffsetX = 1,	 modOffsetY = -1, swapOffsets = true,	degrees = 270,	anchors = { "TOPRIGHT", "RIGHT", "BOTTOMRIGHT" } },
};

HelpTip.Buttons = {
	[HelpTip.ButtonStyle.None]	= { textWidthAdj = 0,	heightAdj = 0,	parentKey = nil },
	[HelpTip.ButtonStyle.Close]	= { textWidthAdj = -6,	heightAdj = 0,	parentKey = "CloseButton" },
	[HelpTip.ButtonStyle.Okay]	= { textWidthAdj = 0,	heightAdj = 30,	parentKey = "OkayButton" },
};

HelpTip.verticalPadding	 = 29;
HelpTip.minimumHeight	 = 69;
HelpTip.defaultTextWidth = 196;

do
	local function HelpTipReset(framePool, frame)
		frame:ClearAllPoints();
		frame:Reset();
	end

	HelpTip.framePool = CreateFramePool("FRAME", nil, "HelpTipTemplate", HelpTipReset);
end

function HelpTip:Show(parent, info, relativeRegion)
	assert(info and info.text, "Invalid helptip info");

	if self:IsShowing(parent, info.text) then
		return true;
	end

	local frame = self.framePool:Acquire();
	frame:Init(parent, info, relativeRegion or parent);
	frame:Show();

	return true;
end

function HelpTip:HideAll(parent)
	for frame in self.framePool:EnumerateActive() do
		if frame:Matches(parent) then
			frame:Hide();
		end
	end
end

function HelpTip:Hide(parent, text)
	for frame in self.framePool:EnumerateActive() do
		if frame:Matches(parent, text) then
			frame:Hide();
			break;
		end
	end
end

function HelpTip:IsShowing(parent, text)
	for frame in self.framePool:EnumerateActive() do
		if frame:Matches(parent, text) then
			return true;
		end
	end
	return false;
end

function HelpTip:IsShowingAny(parent)
	for frame in self.framePool:EnumerateActive() do
		if frame:Matches(parent) then
			return true;
		end
	end
	return false;
end

function HelpTip:Acknowledge(parent, text)
	for frame in self.framePool:EnumerateActive() do
		if frame:Matches(parent, text) then
			frame:Acknowledge();
			break;
		end
	end
end

function HelpTip:Release(helpTip)
	self.framePool:Release(helpTip);
end

HelpTipTemplateMixin = { };

local function TransformOffsetsForRotation(offsets, rotationInfo)
	local offsetX = offsets[1];
	local offsetY = offsets[2];
	if rotationInfo.swapOffsets then
		offsetX, offsetY = offsetY, offsetX;
	end
	offsetX = offsetX * rotationInfo.modOffsetX;
	offsetY = offsetY * rotationInfo.modOffsetY;
	return offsetX, offsetY;
end

function HelpTipTemplateMixin:OnLoad()
	self.Arrow.Arrow:ClearAllPoints();
	self.Arrow.Arrow:SetPoint("CENTER");
	self.Arrow.Glow:ClearAllPoints();
	self.acknowledged = false;
end

function HelpTipTemplateMixin:OnHide()
	local info = self.info;
	if info.onHideCallback then
		info.onHideCallback(self.acknowledged, info.callbackArg);
	end
	HelpTip:Release(self);
end

function HelpTipTemplateMixin:Init(parent, info, relativeRegion)
	self:SetParent(parent);
	self:SetFrameStrata("DIALOG");
	self.info = info;
	self:SetUp(relativeRegion);

	assert((info.bitfieldFlag ~= nil and info.cvarBitfield ~= nil) or (info.bitfieldFlag == nil and info.cvarBitfield == nil));
end

function HelpTipTemplateMixin:GetAnchorInfo()
	local targetPoint = self.info.targetPoint or HelpTip.Point.BottomEdgeCenter;
	return HelpTip.Anchors[targetPoint];
end

function HelpTipTemplateMixin:GetAlignment()
	return self.info.alignment or HelpTip.Alignment.Center;
end

function HelpTipTemplateMixin:GetButtonInfo()
	local buttonStyle = self.info.buttonStyle or HelpTip.ButtonStyle.None;
	return HelpTip.Buttons[buttonStyle];
end

function HelpTipTemplateMixin:SetUp(relativeRegion)
	local anchorInfo = self:GetAnchorInfo();
	local buttonInfo = self:GetButtonInfo();
	local alignment = self:GetAlignment();
	local rotationInfo = HelpTip.Rotations[anchorInfo.arrowRotation];

	-- starting defaults
	local textOffsetX = 15;
	local textOffsetY = 0;
	local textWidth = HelpTip.defaultTextWidth;
	local height = HelpTip.verticalPadding;
	-- anchor the helpTip
	local arrowAnchor = rotationInfo.anchors[alignment];
	local offsetX, offsetY = TransformOffsetsForRotation(HelpTip.DistanceOffsets[alignment], rotationInfo);
	offsetX = offsetX + (self.info.offsetX or 0);
	offsetY = offsetY + (self.info.offsetY or 0);
	self:ClearAllPoints();
	self:SetPoint(arrowAnchor, relativeRegion, anchorInfo.relativeAnchor, offsetX, offsetY);
	-- arrow
	if self.info.hideArrow then
		self.Arrow:Hide();
	else
		self.Arrow:Show();
		self:RotateArrow(anchorInfo.arrowRotation);
		self:AnchorArrow(rotationInfo, alignment);
	end
	-- button
	textWidth = textWidth + buttonInfo.textWidthAdj;
	textOffsetY = buttonInfo.heightAdj / 2;
	height = height + buttonInfo.heightAdj;
	if buttonInfo.parentKey then
		self[buttonInfo.parentKey]:Show();
	end
	-- set height based on the text
	self:ApplyText();
	self.Text:SetWidth(textWidth);
	self.Text:SetPoint("LEFT", textOffsetX, textOffsetY);
	height = height + self.Text:GetHeight();
	if anchorInfo.arrowRotation == HelpTip.ArrowRotation.Left or anchorInfo.arrowRotation == HelpTip.ArrowRotation.Right then
		height = max(height, HelpTip.minimumHeight);
	end
	self:SetHeight(height);
end

function HelpTipTemplateMixin:ApplyText()
	local info = self.info;

	self.Text:SetText(info.text);

	local color = info.textColor or HIGHLIGHT_FONT_COLOR;
	self.Text:SetTextColor(color:GetRGB());

	local justifyH = info.textJustifyH or "LEFT";
	self.Text:SetJustifyH(justifyH);
end

function HelpTipTemplateMixin:AnchorArrow(rotationInfo, alignment)
	local arrowAnchor = rotationInfo.anchors[alignment];
	local offsetX, offsetY = TransformOffsetsForRotation(HelpTip.ArrowOffsets[alignment], rotationInfo);
	self.Arrow:ClearAllPoints();
	self.Arrow:SetPoint("CENTER", self, arrowAnchor, offsetX, offsetY);
end

function HelpTipTemplateMixin:RotateArrow(rotation)
	if self.Arrow.rotation == rotation then
		return;
	end

	local rotationInfo = HelpTip.Rotations[rotation];
	SetClampedTextureRotation(self.Arrow.Arrow, rotationInfo.degrees);
	SetClampedTextureRotation(self.Arrow.Glow, rotationInfo.degrees);
	local offsetX, offsetY = TransformOffsetsForRotation(HelpTip.ArrowGlowOffsets, rotationInfo);
	self.Arrow.Glow:SetPoint("CENTER", self.Arrow.Arrow, "CENTER", offsetX, offsetY);

	self.Arrow.rotation = rotation;
end

function HelpTipTemplateMixin:Acknowledge()
	local info = self.info;
	if info.cvar then
		SetCVar(info.cvar, info.cvarValue);
	end
	if info.cvarBitfield then
		SetCVarBitfield(info.cvarBitfield, info.bitfieldFlag, true);
	end
	self.acknowledged = true;
	self:Hide();
end

function HelpTipTemplateMixin:Reset()
	self.info = nil;
	self.acknowledged = false;
	self.CloseButton:Hide();
	self.OkayButton:Hide();
end

function HelpTipTemplateMixin:Matches(parent, text)
	local textMatched = not text or self.info.text == text;
	return textMatched and self:GetParent() == parent;
end