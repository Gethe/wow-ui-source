--[[
	infoTable = {
		text,									-- also acts as a key for various API, MUST BE SET
		textColor = HIGHLIGHT_FONT_COLOR,
		textJustifyH = "LEFT",
		buttonStyle = HelpTip.ButtonStyle.None	-- button to close the helptip, or no button at all
		targetPoint = HelpTip.Point.BottomEdgeCenter,	-- where at the parent/relativeRegion the helptip should point
		alignment = HelpTip.Alignment.Center,	-- alignment of the helptip relative to the parent/relativeRegion (basically where the arrow is located)
		hideArrow = false,						-- whether to hide the arrow
		offsetX = 0,
		offsetY	= 0,
		cvar, cvarValue,						-- cvar to set when closed by user or from HelpTip:Acknowledge()
		cvarBitfield, bitfieldFlag,				-- cvarbitfield to set when closed by user or from HelpTip:Acknowledge()
		onHideCallback, callbackArg,			-- callback whenever the helptip is closed:  onHideCallback(acknowledged, callbackArg)
		onAcknowledgeCallback					-- callback whenever the helptip is closed by the user clicking its button: onAcknowledgeCallback(callbackArg)
		checkCVars = false,						-- on: helptip will only be shown if the cvar or cvarBitfield is not set
		autoEdgeFlipping = false,				-- on: will flip helptip to opposite edge based on relative region's center vs helptip's center during OnUpdate
		autoHorizontalSlide = false,			-- on: will change the alignment to fit helptip on screen during OnUpdate
		useParentStrata	= false,				-- whether to use parent framestrata
		system = ""								-- reference string
		systemPriority = 0,						-- if a system and a priority is specified, higher priority helptips will close another helptip in that system
		extraRightMarginPadding = 0,			--  extra padding on the right side of the helptip
		acknowledgeOnHide = false,				-- whether to treat a hide as an acknowledge
	}
]]--

HelpTip = { };

-- external use enums

HelpTip.Point = {
	TopEdgeLeft = 1,
	TopEdgeCenter = 2,
	TopEdgeRight = 3,
	BottomEdgeLeft = 4,	
	BottomEdgeCenter = 5,
	BottomEdgeRight = 6,
	RightEdgeTop = 7,
	RightEdgeCenter = 8,
	RightEdgeBottom = 9,
	LeftEdgeTop = 10,
	LeftEdgeCenter = 11,
	LeftEdgeBottom = 12,
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
	GotIt = 4,
	Next = 5,
};

-- internal use enums

HelpTip.ArrowRotation = {
	Down = 1,
	Left = 2,
	Up = 3,
	Right = 4,
};

-- data

HelpTip.PointInfo = {
	[HelpTip.Point.TopEdgeLeft]		= { arrowRotation = HelpTip.ArrowRotation.Down,	 relativeAnchor = "TOPLEFT",	oppositePoint = HelpTip.Point.BottomEdgeLeft },
	[HelpTip.Point.TopEdgeCenter]	= { arrowRotation = HelpTip.ArrowRotation.Down,  relativeAnchor = "TOP",		oppositePoint = HelpTip.Point.BottomEdgeCenter },
	[HelpTip.Point.TopEdgeRight]	= { arrowRotation = HelpTip.ArrowRotation.Down,  relativeAnchor = "TOPRIGHT",	oppositePoint = HelpTip.Point.BottomEdgeRight },

	[HelpTip.Point.RightEdgeTop]	= { arrowRotation = HelpTip.ArrowRotation.Left,  relativeAnchor = "TOPRIGHT",	oppositePoint = HelpTip.Point.LeftEdgeTop },
	[HelpTip.Point.RightEdgeCenter] = { arrowRotation = HelpTip.ArrowRotation.Left,  relativeAnchor = "RIGHT",		oppositePoint = HelpTip.Point.LeftEdgeCenter },
	[HelpTip.Point.RightEdgeBottom] = { arrowRotation = HelpTip.ArrowRotation.Left,  relativeAnchor = "BOTTOMRIGHT",oppositePoint = HelpTip.Point.LeftEdgeBottom },

	[HelpTip.Point.BottomEdgeRight] = { arrowRotation = HelpTip.ArrowRotation.Up,	 relativeAnchor = "BOTTOMRIGHT",oppositePoint = HelpTip.Point.TopEdgeRight },
	[HelpTip.Point.BottomEdgeCenter]= { arrowRotation = HelpTip.ArrowRotation.Up,	 relativeAnchor = "BOTTOM",		oppositePoint = HelpTip.Point.TopEdgeCenter },
	[HelpTip.Point.BottomEdgeLeft]	= { arrowRotation = HelpTip.ArrowRotation.Up,	 relativeAnchor = "BOTTOMLEFT",	oppositePoint = HelpTip.Point.TopEdgeLeft },

	[HelpTip.Point.LeftEdgeBottom]	= { arrowRotation = HelpTip.ArrowRotation.Right, relativeAnchor = "BOTTOMLEFT",	oppositePoint = HelpTip.Point.RightEdgeBottom },
	[HelpTip.Point.LeftEdgeCenter]	= { arrowRotation = HelpTip.ArrowRotation.Right, relativeAnchor = "LEFT",		oppositePoint = HelpTip.Point.RightEdgeCenter },
	[HelpTip.Point.LeftEdgeTop]		= { arrowRotation = HelpTip.ArrowRotation.Right, relativeAnchor = "TOPLEFT",	oppositePoint = HelpTip.Point.RightEdgeTop },
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
	[HelpTip.ButtonStyle.Okay]	= { textWidthAdj = 0,	heightAdj = 30,	parentKey = "OkayButton", text = OKAY },
	[HelpTip.ButtonStyle.GotIt]	= { textWidthAdj = 0,	heightAdj = 30,	parentKey = "OkayButton", text = HELP_TIP_BUTTON_GOT_IT },
	[HelpTip.ButtonStyle.Next]	= { textWidthAdj = 0,	heightAdj = 30,	parentKey = "OkayButton", text = NEXT },
};

HelpTip.verticalPadding	 = 31;
HelpTip.minimumHeight	 = 72;
HelpTip.defaultTextWidth = 196;
HelpTip.width = 226;
HelpTip.halfWidth = HelpTip.width / 2;

HelpTip.supressHelpTips = {};

do
	local function HelpTipReset(framePool, frame)
		frame:ClearAllPoints();
		frame:Hide();
		frame:Reset();
	end

	HelpTip.framePool = CreateFramePool("FRAME", nil, "HelpTipTemplate", HelpTipReset);
end

function HelpTip:SetHelpTipsEnabled(flag, enabled)
	HelpTip.supressHelpTips[flag] = enabled or false;
end

function HelpTip:AreHelpTipsEnabled()
	if GetCVarBool("hideHelptips") then
		return false;
	end

	for flagType, flagValue in pairs(self.supressHelpTips) do
		if not flagValue then
			return false;
		end
	end
	return true;
end

function HelpTip:Show(parent, info, relativeRegion)
	assert(info and info.text, "Invalid helptip info");
	assert((info.bitfieldFlag ~= nil and info.cvarBitfield ~= nil) or (info.bitfieldFlag == nil and info.cvarBitfield == nil));

	if not self:CanShow(info) then
		return false;
	end

	if self:IsShowing(parent, info.text) then
		return true;
	end

	local frame = self.framePool:Acquire();
	frame.width = HelpTip.width + (info.extraRightMarginPadding or 0);
	frame:SetWidth(frame.width);
	frame:Init(parent, info, relativeRegion or parent);
	frame:Show();

	return true;
end

function HelpTip:CanShow(info)
	if Kiosk.IsEnabled() then
		return false;
	end

	if not self:AreHelpTipsEnabled() then
		return false;
	end

	if info.checkCVars then
		if info.cvar then
			if GetCVar(info.cvar) ~= info.cvarValue then
				return false;
			end
		end
		if info.cvarBitfield then
			if GetCVarBitfield(info.cvarBitfield, info.bitfieldFlag) then
				return false;
			end
		end
	end

	-- priority
	if info.system and info.systemPriority then
		for frame in self.framePool:EnumerateActive() do
			if frame.info.system == info.system and frame.info.systemPriority then
				if info.systemPriority > frame.info.systemPriority then
					frame:Close();
					-- by design there can only be one such frame, no need to keep going
					break;
				else
					-- higher or equal priority is already shown
					return false;
				end
			end
		end
	end

	return true;
end

function HelpTip:ForceHideAll()
	self:SetHelpTipsEnabled("ForceHideAll", false);
	self.framePool:ReleaseAll();
	self:SetHelpTipsEnabled("ForceHideAll", true);
end

function HelpTip:HideAllSystem(system, text)
	local framesToClose = { };

	for frame in self.framePool:EnumerateActive() do
		if frame:MatchesSystem(system, text) then
			tinsert(framesToClose, frame);
		end
	end

	for i, frame in ipairs(framesToClose) do
		frame:Close();
	end	
end

function HelpTip:HideAll(parent)
	local framesToClose = { };

	for frame in self.framePool:EnumerateActive() do
		if frame:Matches(parent) then
			tinsert(framesToClose, frame);
		end
	end

	for i, frame in ipairs(framesToClose) do
		frame:Close();
	end
end

function HelpTip:Hide(parent, text)
	for frame in self.framePool:EnumerateActive() do
		if frame:Matches(parent, text) then
			frame:Close();
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

function HelpTip:IsShowingAnyInSystem(system)
	for frame in self.framePool:EnumerateActive() do
		if frame.info.system == system then
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

function HelpTip:AcknowledgeSystem(system, text)
	for frame in self.framePool:EnumerateActive() do
		if frame:MatchesSystem(system, text) then
			frame:Acknowledge();
		end
	end
end

function HelpTip:Release(helpTip)
	self.framePool:Release(helpTip);
end

function HelpTip:IsPointVertical(point)
	return point <= HelpTip.Point.BottomEdgeRight;
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

function HelpTipTemplateMixin:OnShow()
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function HelpTipTemplateMixin:OnHide()
	self:UnregisterEvent("UI_SCALE_CHANGED");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");

	local info = self.info;
	if info.onHideCallback then
		info.onHideCallback(self.acknowledged, info.callbackArg);
	end
	if not self.acknowledged and info.acknowledgeOnHide then
		self:HandleAcknowledge();
	end
	if self.acknowledged and info.onAcknowledgeCallback then
		info.onAcknowledgeCallback(info.callbackArg);
	end
	HelpTip:Release(self);
end

function HelpTipTemplateMixin:OnEvent()
	self:Layout();
end

-- this exists because OnHide can be deferred
function HelpTipTemplateMixin:Close()
	self.closed = true;
	self:Hide();
end

function HelpTipTemplateMixin:OnUpdate()
	local rx, ry = self.relativeRegion:GetCenter();
	local targetPoint = self.info.targetPoint;
	local targetAlignment = self.info.alignment;

	if self.info.autoHorizontalSlide then
		-- check right edge first
		local rightEdge = UIParent:GetRight();
		local canFitOnRight = rx + self.width + HelpTip.ArrowOffsets[HelpTip.Alignment.Right][1] < rightEdge;
		if not canFitOnRight then
			if rx + HelpTip.halfWidth < rightEdge then
				targetAlignment = HelpTip.Alignment.Center;
			else
				targetAlignment = HelpTip.Alignment.Right;
			end
		else
			-- left edge
			local leftEdge = UIParent:GetLeft();
			local canFitOnLeft = rx - self.width + HelpTip.ArrowOffsets[HelpTip.Alignment.Left][1] > leftEdge;
			if not canFitOnLeft then
				if rx - HelpTip.halfWidth > leftEdge then
					targetAlignment = HelpTip.Alignment.Center;
				else
					targetAlignment = HelpTip.Alignment.Left;
				end
			end
		end
	end

	if self.info.autoEdgeFlipping then
		local ux, uy = UIParent:GetCenter();
		local useMin;
		if HelpTip:IsPointVertical(targetPoint) then
			useMin = ry <= uy;
		else
			useMin = rx <= ux;
		end
		if useMin then
			targetPoint = min(self.flippedTargetPoint, targetPoint);
		else
			targetPoint = max(self.flippedTargetPoint, targetPoint);
		end
	end

	self:AnchorAndRotate(targetPoint, targetAlignment);
end

function HelpTipTemplateMixin:Init(parent, info, relativeRegion)
	self:SetParent(parent);
	if info.useParentStrata then
		self:SetFrameLevel(9000);
	else
		self:SetFrameStrata("DIALOG");
	end
	self.info = info;
	self.relativeRegion = relativeRegion;

	if info.autoEdgeFlipping then
		local targetPoint = self:GetTargetPoint();
		local pointInfo = HelpTip.PointInfo[targetPoint];
		self.flippedTargetPoint = pointInfo.oppositePoint;
		self:SetScript("OnUpdate", function() self:OnUpdate(); end);
	end
	if info.autoHorizontalSlide then
		self:SetScript("OnUpdate", function() self:OnUpdate(); end);
	end

	self:AnchorAndRotate();
	self:Layout();
end

function HelpTipTemplateMixin:GetTargetPoint()
	return self.info.targetPoint or HelpTip.Point.BottomEdgeCenter;
end

function HelpTipTemplateMixin:GetAlignment()
	return self.info.alignment or HelpTip.Alignment.Center;
end

function HelpTipTemplateMixin:GetButtonInfo()
	local buttonStyle = self.info.buttonStyle or HelpTip.ButtonStyle.None;
	return HelpTip.Buttons[buttonStyle];
end

function HelpTipTemplateMixin:AnchorAndRotate(overrideTargetPoint, overrideAlignment)
	local baseTargetPoint = self:GetTargetPoint();
	local targetPoint = overrideTargetPoint or baseTargetPoint;
	local alignment = overrideAlignment or self:GetAlignment();
	if targetPoint == self.appliedTargetPoint and alignment == self.appliedAlignment then
		return;
	end

	local pointInfo = HelpTip.PointInfo[targetPoint];
	local rotationInfo = HelpTip.Rotations[pointInfo.arrowRotation];
	-- anchor
	local arrowAnchor = rotationInfo.anchors[alignment];
	local offsetX, offsetY = TransformOffsetsForRotation(HelpTip.DistanceOffsets[alignment], rotationInfo);
	local baseOffsetX = self.info.offsetX or 0;
	local baseOffsetY = self.info.offsetY or 0;
	if overrideTargetPoint and overrideTargetPoint ~= baseTargetPoint then
		if HelpTip:IsPointVertical(targetPoint) then
			baseOffsetY = -baseOffsetY;
		else
			baseOffsetX = -baseOffsetX;
		end
	end
	offsetX = offsetX + baseOffsetX;
	offsetY = offsetY + baseOffsetY;
	self:ClearAllPoints();
	self:SetPoint(arrowAnchor, self.relativeRegion, pointInfo.relativeAnchor, offsetX, offsetY);
	-- arrow
	if self.info.hideArrow then
		self.Arrow:Hide();
	else
		self.Arrow:Show();
		self:RotateArrow(pointInfo.arrowRotation);
		self:AnchorArrow(rotationInfo, alignment);
	end
	self.appliedAlignment = alignment;
	self.appliedTargetPoint = targetPoint;
end

function HelpTipTemplateMixin:Layout()
	local targetPoint = self:GetTargetPoint();
	local pointInfo = HelpTip.PointInfo[targetPoint];
	local buttonInfo = self:GetButtonInfo();

	-- starting defaults
	local textOffsetX = 15;
	local textOffsetY = 1;
	local textWidth = HelpTip.defaultTextWidth;
	local height = HelpTip.verticalPadding;
	-- button
	textWidth = textWidth + buttonInfo.textWidthAdj;
	textOffsetY = textOffsetY + buttonInfo.heightAdj / 2;
	height = height + buttonInfo.heightAdj;
	if buttonInfo.parentKey then
		self[buttonInfo.parentKey]:Show();

		if buttonInfo.text then
			self[buttonInfo.parentKey]:SetText(buttonInfo.text);
		end
	end
	-- set height based on the text
	self:ApplyText();
	self.Text:SetWidth(textWidth);
	self.Text:SetPoint("LEFT", textOffsetX, textOffsetY);
	height = height + self.Text:GetHeight();
	if pointInfo.arrowRotation == HelpTip.ArrowRotation.Left or pointInfo.arrowRotation == HelpTip.ArrowRotation.Right then
		height = max(height, HelpTip.minimumHeight);
	end
	self:SetHeight(height);
end

function HelpTipTemplateMixin:ApplyText()
	local info = self.info;

	self.Text:SetText(info.text);

	local color = info.textColor or HIGHLIGHT_FONT_COLOR;
	self.Text:SetTextColor(color:GetRGB());

	local justifyH = info.textJustifyH;
	if not justifyH then
		if self.Text:GetNumLines() == 1 then
			justifyH = "CENTER";
		else
			justifyH = "LEFT";
		end
	end
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
	self:HandleAcknowledge();
	self:Close();
end

function HelpTipTemplateMixin:HandleAcknowledge()
	local info = self.info;
	if info.cvar then
		SetCVar(info.cvar, info.cvarValue);
	end
	if info.cvarBitfield then
		SetCVarBitfield(info.cvarBitfield, info.bitfieldFlag, true);
	end
	self.acknowledged = true;
end

function HelpTipTemplateMixin:Reset()
	self.info = nil;
	self.relativeRegion = nil;
	self.closed = false;
	self.acknowledged = false;
	self.CloseButton:Hide();
	self.OkayButton:Hide();
	-- flippity flip settings
	self.appliedTargetPoint = nil;
	self.flippedTargetPoint = nil;
	self.appliedAlignment = nil;
	self:SetScript("OnUpdate", nil);
end

function HelpTipTemplateMixin:Matches(parent, text)
	if self.closed then
		return false;
	end
	local textMatched = not text or self.info.text == text;
	return textMatched and self:GetParent() == parent;
end

function HelpTipTemplateMixin:MatchesSystem(system, text)
	if self.closed then
		return false;
	end
	local textMatched = not text or self.info.text == text;
	return textMatched and self.info.system == system;
end