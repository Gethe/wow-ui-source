--------------------------------------------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
local _, tbl = ...;
if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
		Import("C_StoreGlue");
	end

	setfenv(1, tbl);
	
	Import("error");
	Import("getmetatable");
	Import("ipairs");
	Import("Round");
	Import("LE_MODEL_BLEND_OPERATION_NONE");
end
--------------------------------------------------

-- Mix this into a FontString to have it resize until it stops truncating, or gets too small
ShrinkUntilTruncateFontStringMixin = {};

-- From largest to smallest
function ShrinkUntilTruncateFontStringMixin:SetFontObjectsToTry(...)
	self.fontObjectsToTry = { ... };
	if self:GetText() then
		self:ApplyFontObjects();
	end
end

function ShrinkUntilTruncateFontStringMixin:ApplyFontObjects()
	if not self.fontObjectsToTry then
		error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
	end

	for i, fontObject in ipairs(self.fontObjectsToTry) do
		self:SetFontObject(fontObject);
		if not self:IsTruncated() then
			break;
		end
	end
end

function ShrinkUntilTruncateFontStringMixin:SetText(text)
	if not self:GetFont() then
		if not self.fontObjectsToTry then
			error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
		end
		self:SetFontObject(self.fontObjectsToTry[1]);
	end

	getmetatable(self).__index.SetText(self, text);
	self:ApplyFontObjects();
end

function ShrinkUntilTruncateFontStringMixin:SetFormattedText(format, ...)
	if not self:GetFont() then
		if not self.fontObjectsToTry then
			error("No fonts applied to ShrinkUntilTruncateFontStringMixin, call SetFontObjectsToTry first");
		end
		self:SetFontObject(self.fontObjectsToTry[1]);
	end

	getmetatable(self).__index.SetFormattedText(self, format, ...);
	self:ApplyFontObjects();
end

--------------------------------------------------
AutoScalingFontStringMixin = { }

local DEFAULT_AUTO_SCALING_MIN_LINE_HEIGHT = 10;

function AutoScalingFontStringMixin:SetText(text)
	getmetatable(self).__index.SetText(self, text);
	self:ScaleTextToFit();
end

function AutoScalingFontStringMixin:SetFormattedText(format, ...)
	getmetatable(self).__index.SetFormattedText(self, format, ...);
	self:ScaleTextToFit();
end

function AutoScalingFontStringMixin:SetMinLineHeight(minLineHeight)
	self.minLineHeight = minLineHeight;
	self:ScaleTextToFit();
end

function AutoScalingFontStringMixin:ScaleTextToFit()
	if not self.baseLineHeight then
		-- store the initial line height for calculating scaling
		self.baseLineHeight = Round(self:GetLineHeight());
	end
	local baseLineHeight = self.baseLineHeight;
	local tryHeight = baseLineHeight;
	local minLineHeight = self.minLineHeight or DEFAULT_AUTO_SCALING_MIN_LINE_HEIGHT;
	local stringWidth = self:GetUnboundedStringWidth() / self:GetTextScale();
	if stringWidth > 0 then
		local maxLines = self:GetMaxLines();
		if maxLines == 0 then
			maxLines = Round(self:GetHeight() / (baseLineHeight + self:GetSpacing()));
		end
		local targetScale = self:GetWidth() * maxLines / stringWidth;
		if targetScale >= 1 then
			tryHeight = baseLineHeight;
		else
			tryHeight = Round(targetScale * baseLineHeight);
			if tryHeight < minLineHeight then
				tryHeight = minLineHeight;
			end
		end
	end

	while tryHeight >= minLineHeight do
		local scale = tryHeight / baseLineHeight;
		self:SetTextScale(scale);
		if self:IsTruncated() then
			tryHeight = tryHeight - 1;
		else
			break;
		end
	end
end

--------------------------------------------------
function SetupPlayerForModelScene(modelScene, itemModifiedAppearanceIDs, sheatheWeapons, autoDress, hideWeapons)
	if not modelScene then
		return;
	end

	local actor = modelScene:GetPlayerActor();
	if actor then
		sheatheWeapons = (sheatheWeapons == nil) or sheatheWeapons;
		hideWeapons = (hideWeapons == nil) or hideWeapons;
		if IsOnGlueScreen() then
			actor:SetPlayerModelFromGlues(sheatheWeapons, autoDress, hideWeapons);
		else
			actor:SetModelByUnit("player", sheatheWeapons, autoDress, hideWeapons);
		end

		if itemModifiedAppearanceIDs then
			for i, itemModifiedAppearanceID in ipairs(itemModifiedAppearanceIDs) do
				actor:TryOn(itemModifiedAppearanceID);
			end
		end
		actor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_NONE);
	end
end

function SetupItemPreviewActor(actor, displayID)
	if actor then
		actor:SetModelByCreatureDisplayID(displayID);
		actor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_NONE);
	end
end
