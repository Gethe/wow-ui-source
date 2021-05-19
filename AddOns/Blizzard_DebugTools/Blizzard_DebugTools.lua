function FrameStackTooltip_OnDisplaySizeChanged(self)
	local height = GetScreenHeight();
	if (height > 768) then
		self:SetScale(768/height);
	else
		self:SetScale(1);
	end
end

function FrameStackTooltip_OnLoad(self)
	self:SetFrameLevel(self:GetFrameLevel() + 2);
	SharedTooltip_OnLoad(self);

	self.nextUpdate = 0;

	FrameStackTooltip_OnDisplaySizeChanged(self);
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");

	self.commandKeys =
	{
		KeyCommand_Create(function() FrameStackTooltip_ChangeHighlight(self, 1); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("LALT")),
		KeyCommand_Create(function() FrameStackTooltip_ChangeHighlight(self, -1); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("RALT")),
		KeyCommand_Create(function() FrameStackTooltip_InspectTable(self); end, KeyCommand.RUN_ON_UP, KeyCommand_CreateKey("CTRL")),
		KeyCommand_Create(function() FrameStackTooltip_ToggleTextureInformation(self); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("SHIFT")),
		KeyCommand_Create(function() FrameStackTooltip_HandleFrameCommand(self); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("CTRL", "C")),
	};
end

function FrameStackTooltip_ChangeHighlight(self, direction)
	self.highlightIndexChanged = direction;
	self.shouldSetFSObj = true;
end

function FrameStackTooltip_InspectTable(self)
	if self.highlightFrame then
		TableAttributeDisplay:InspectTable(self.highlightFrame);
		TableAttributeDisplay:Show();
	end
end

function FrameStackTooltip_ToggleTextureInformation(self)
	self.showTextureInfo = not self.showTextureInfo;
end

function FrameStackTooltip_HandleFrameCommand(self)
	if self.currentAssets then
		for index, asset in ipairs(self.currentAssets) do
			local assetName, assetType = asset[1], asset[2];

			if assetType == "Atlas" then
				HandleAtlasMemberCommand(assetName);
				PlaySound(SOUNDKIT.MAP_PING);
				break;
			elseif assetType == "File" then
				CopyToClipboard(assetName);
				PlaySound(SOUNDKIT.UI_BONUS_LOOT_ROLL_END); -- find sound
			end
		end
	end
end

function FrameStackTooltip_OnEvent(self, event, ...)
	if ( event == "DISPLAY_SIZE_CHANGED" ) then
		FrameStackTooltip_OnDisplaySizeChanged(self);
	end
end

local function AreTextureCoordinatesValid(...)
	local coordCount = select("#", ...);
	for i = 1, coordCount do
		if type(select(i, ...)) ~= "number" then
			return false;
		end
	end

	return coordCount == 8;
end

local function AreTextureCoordinatesEntireImage(...)
	local ulX, ulY, blX, blY, urX, urY, brX, brY = ...;
	return	ulX == 0 and ulY == 0 and
			blX == 0 and blY == 1 and
			urX == 1 and urY == 0 and
			brX == 1 and brY == 1;
end

local function FormatTextureCoordinates(...)
	if AreTextureCoordinatesValid(...) then
		if not AreTextureCoordinatesEntireImage(...) then
			return WrapTextInColorCode(("UL:(%.2f, %.2f), BL:(%.2f, %.2f), UR:(%.2f, %.2f), BR:(%.2f, %.2f)"):format(...), "ff00ffff");
		end

		return "";
	end

	return "invalid coordinates";
end

local function ColorAssetType(assetType)
	if assetType == "Atlas" then
		return WrapTextInColorCode(assetType, "ff00ff00");
	end

	return WrapTextInColorCode(assetType, "ffff0000");
end

local function FormatTextureAssetName(assetName, assetType)
	return ("%s: %s"):format(ColorAssetType(assetType), tostring(assetName));
end

local function FormatTextureInfo(region, ...)
	if ... ~= nil then
		local assetInfo = { select(1, ...), select(2, ...) };
		return ("%s : %s %s"):format(region:GetDebugName(), FormatTextureAssetName(...), FormatTextureCoordinates(select(3, ...))), assetInfo;
	end
end

local function CheckGetRegionsTextureInfo(...)
	local info = {};
	local assets = {};
	for i = 1, select("#", ...) do
		local region = select(i, ...);
		if CanAccessObject(region) and region:IsMouseOver() then
			local textureInfo, assetInfo = FormatTextureInfo(region, GetTextureInfo(region))
			if textureInfo then
				table.insert(info, textureInfo);
				table.insert(assets, assetInfo);
			end
		end
	end

	if #info > 0 then
		return table.concat(info, "\n"), assets;
	end
end

local function CheckFormatTextureInfo(self, obj)
	if self.showTextureInfo and CanAccessObject(obj) then
		if obj.GetRegions then
			return CheckGetRegionsTextureInfo(obj:GetRegions());
		else
			return CheckGetRegionsTextureInfo(obj);
		end
	end
end

function FrameStackTooltip_OnTooltipSetFrameStack(self, highlightFrame)
	self.highlightFrame = highlightFrame;

	if self.highlightFrame then
		local textureInfo, assets = CheckFormatTextureInfo(self, self.highlightFrame);
		if textureInfo then
			self:AddLine(textureInfo);
			self.currentAssets = assets;
		end
	end

	if self.shouldSetFSObj then
		fsobj = self.highlightFrame;
		self.shouldSetFSObj = nil;
	end

	if fsobj then
		self:AddLine(("\nfsobj = %s"):format(fsobj:GetDebugName()));
	end
end

function FrameStackTooltip_Toggle(showHidden, showRegions, showAnchors)
	local tooltip = FrameStackTooltip;
	if ( tooltip:IsVisible() ) then
		tooltip:Hide();
		FrameStackHighlight:Hide();
	else
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -(CONTAINER_OFFSET_X or 0) - 13, (CONTAINER_OFFSET_Y or 0));
		tooltip.default = 1;
		tooltip.showRegions = showRegions;
		tooltip.showHidden = showHidden;
		tooltip.showAnchors = showAnchors;
		tooltip:SetFrameStack(showHidden, showRegions);
	end
end

local function AnchorHighlight(frame, highlight, relativePoint)
	highlight:SetAllPoints(frame);
	highlight:Show();

	if highlight.AnchorPoint then
		if relativePoint then
			highlight.AnchorPoint:ClearAllPoints();
			highlight.AnchorPoint:SetPoint("CENTER", highlight, relativePoint);
			highlight.AnchorPoint:Show();
		else
			highlight.AnchorPoint:Hide();
		end
	end
end

AnchorHighlightMixin = {};

function AnchorHighlightMixin:RetrieveAnchorHighlight(pointIndex)
	if not self.AnchorHighlights then
		CreateFrame("FRAME", "FrameStackAnchorHighlightTemplate1", self, "FrameStackAnchorHighlightTemplate");
	end

	while pointIndex > #self.AnchorHighlights do
		CreateFrame("FRAME", "FrameStackAnchorHighlightTemplate"..(#self.AnchorHighlights + 1), self, "FrameStackAnchorHighlightTemplate");
	end

	return self.AnchorHighlights[pointIndex];
end

function AnchorHighlightMixin:HighlightFrame(baseFrame, showAnchors)
	AnchorHighlight(baseFrame, self);

	local pointIndex = 1;
	if (showAnchors) then
		while pointIndex <= baseFrame:GetNumPoints() do
			local _, anchorFrame, anchorRelativePoint = baseFrame:GetPoint(pointIndex);
			AnchorHighlight(anchorFrame, self:RetrieveAnchorHighlight(pointIndex), anchorRelativePoint);
			pointIndex = pointIndex + 1;
		end
	end

	while self.AnchorHighlights and self.AnchorHighlights[pointIndex] do
		self.AnchorHighlights[pointIndex]:Hide();
		pointIndex = pointIndex + 1;
	end
end

FRAMESTACK_UPDATE_TIME = .1

function FrameStackTooltip_OnUpdate(self)
	KeyCommand_Update(self.commandKeys);

	local now = GetTime();
	if now >= self.nextUpdate or self.highlightIndexChanged ~= 0 then
		self.nextUpdate = now + FRAMESTACK_UPDATE_TIME;
		self.highlightFrame = self:SetFrameStack(self.showHidden, self.showRegions, self.highlightIndexChanged);
		self.highlightIndexChanged = 0;
		if self.highlightFrame then
			FrameStackHighlight:HighlightFrame(self.highlightFrame, self.showAnchors);
		end
	end
end

function FrameStackTooltip_OnShow(self)
	local parent = self:GetParent() or UIParent;
	local ps = parent:GetEffectiveScale();
	local px, py = parent:GetCenter();
	px, py = px * ps, py * ps;
	local x, y = GetCursorPosition();
	self:ClearAllPoints();
	if (x > px) then
		if (y > py) then
			self:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 20, 20);
		else
			self:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -20);
		end
	else
		if (y > py) then
			self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 20);
		else
			self:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, -20);
		end
	end
end

function FrameStackTooltip_OnHide(self)
end

function FrameStackTooltip_OnTooltipCleared(self)
end

FrameStackTooltip_OnEnter = FrameStackTooltip_OnShow;
