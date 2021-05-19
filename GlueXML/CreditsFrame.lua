CreditsFrameMixin = {};

function CreditsFrameMixin:OnShow()
	StopGlueAmbience();
	self.expansion = GetClientDisplayExpansionLevel();
	self.maxExpansion = LE_EXPANSION_LEVEL_CURRENT;
	self.releaseType = LE_RELEASE_TYPE_MODERN;
	self.maxReleaseType = LE_RELEASE_TYPE_MODERN;
	self:Update();
end

function CreditsFrameMixin:OnHide()
	self.ExpansionList:Hide();
	ShowCursor();
	self:ResetPools();
end

function CreditsFrameMixin:ResetPools()
	if not self.normalPool then
		self.normalPool = CreateFontStringPool(self.ClipFrame, "ARTWORK", 0, "CreditsNormal");
	end
	if not self.header1Pool then
		self.header1Pool = CreateFontStringPool(self.ClipFrame, "ARTWORK", 0, "CreditsHeader1");
	end
	if not self.header2Pool then
		self.header2Pool = CreateFontStringPool(self.ClipFrame, "ARTWORK", 0, "CreditsHeader2");
	end

	self.normalPool:ReleaseAll();
	self.header1Pool:ReleaseAll();
	self.header2Pool:ReleaseAll();

	self.strings = {};
end

function CreditsFrameMixin:GetFontStringPool(type)
	if type == "H1" then
		return self.header1Pool;
	elseif type == "H2" then
		return self.header2Pool;
	else
		return self.normalPool;
	end
end

function CreditsFrameMixin:GetCreditsFontString(data)
	local fontString = self:GetFontStringPool(data.type):Acquire();
	fontString:SetText(data.text);
	fontString:SetWidth(self.creditsTextWidth);
	fontString:SetJustifyH(data.align);
	fontString:Show();
	return fontString;
end

function CreditsFrameMixin:ReleaseCreditsFontString(data, fontString)
	self:GetFontStringPool(data.type):Release(fontString);
end

function CreditsFrameMixin:JumpToCreditsIndex(position)
	self:ResetPools();

	local screenHeight = self:GetHeight();
	local left = self.ScrollFrame:GetLeft() - self:GetLeft();

	self.startIdx = Clamp(position, 1, #self.data);
	self.startPos = 0;
	self.pixelAlignedRemainder = 0;
	local startPos = self.startPos;
	for i = self.startIdx, #self.data do
		assert(not self.strings[i]);
		local fontString = self:GetCreditsFontString(self.data[i]);
		self.strings[i] = fontString;
		fontString:SetPoint("TOPLEFT", CreditsFrame, "TOPLEFT", left, startPos + fontString:GetSpacing());
		startPos = startPos - fontString:GetHeight() - fontString:GetSpacing();
		if startPos < -screenHeight then
			break;
		end
	end

	self.Slider:SetValue(self.startIdx);
end


function CreditsFrameMixin:Update()
	PlayCreditsMusic(self.expansion);
	SetGameLogo(self.Logo, self.expansion, self.releaseType);

	self:SetSpeed(CREDITS_SCROLL_RATE_PLAY);
	self.artCount = #CREDITS_ART_INFO[self.expansion][self.releaseType];
	self.currentArt = 0;
	self.fadingIn = nil;
	self.fadingOut = nil;
	self.cacheArt = 0;
	self.cacheIndex = 1;
	self.cacheElapsed = 0;
	self.alphaIn = 0;
	self.alphaOut = 0;

	for i=1, NUM_CREDITS_ART_TEXTURES_HIGH, 1 do
		for j=1, NUM_CREDITS_ART_TEXTURES_WIDE, 1 do
			_G["CreditsArtAlt"..(((i - 1) * NUM_CREDITS_ART_TEXTURES_WIDE) + j)]:Hide();
			_G["CreditsArtCache"..(((i - 1) * NUM_CREDITS_ART_TEXTURES_WIDE) + j)]:SetAlpha(0.005);
		end
	end

	self:CacheTextures(1);

	self.creditsTextWidth = self.ScrollFrame:GetWidth();

	-- Set Credits Text
	self.ScrollFrame.Text:SetText(GetCreditsText(self.expansion, self.releaseType));
	self.data = self.ScrollFrame.Text:GetTextData();
	self.Slider:SetMinMaxValues(1, #self.data);
	self.ScrollFrame.Text:SetText("");

	self:JumpToCreditsIndex(1);
end

function CreditsFrameMixin:Switch(expansion, releaseType)
	self.expansion = expansion;
	self.releaseType = releaseType;
	self:Update();
end

local function IsValidTextureIndex(info, index)
	return info.maxTexIndex == nil or index <= info.maxTexIndex;
end

local function CreateCreditsTextureTilePath(self, info, textureIndex)
	local path = CREDITS_ART_INFO[self.expansion].path;
	if path then
		return string.format("Interface\\Glues\\Credits\\%s\\%s%d", path, info.file, textureIndex);
	else
		return string.format("Interface\\Glues\\Credits\\%s%d", info.file, textureIndex);
	end
end

function CreditsFrameMixin:SetArtTextures(textureName, index, alpha)
	local info = CREDITS_ART_INFO[self.expansion][self.releaseType][index];
	if ( not info ) then
		return;
	end

	local texture;
	local texIndex = 1;
	local width, height;
	_G[textureName..1]:SetPoint("TOPLEFT", "CreditsFrame", "TOPLEFT", info.offsetx, info.offsety - 128);
	for i=1, NUM_CREDITS_ART_TEXTURES_HIGH, 1 do
		height = info.h - ((i - 1) * 256);
		if ( height > 256 ) then
			height = 256;
		end
		for j=1, NUM_CREDITS_ART_TEXTURES_WIDE, 1 do
			texture = _G[textureName..(((i - 1) * NUM_CREDITS_ART_TEXTURES_WIDE) + j)];
			width = info.w - ((j - 1) * 256);
			if ( width > 256 ) then
				width = 256;
			end
			if ( (width <= 0) or (height <= 0) ) then
				texture:Hide();
			else
				if (IsValidTextureIndex(info, texIndex)) then
					local tilePath = CreateCreditsTextureTilePath(self, info, texIndex);
					texture:SetTexture(tilePath);
					texture:SetWidth(width);
					texture:SetHeight(height);
					texture:SetAlpha(alpha);
					texture:Show();
				end

				texIndex = texIndex + 1;
			end
		end
	end
end

function CreditsFrameMixin:CacheTextures(index)
	self.cacheArt = index;
	self.cacheIndex = 1;
	self.cacheElapsed = 0;

	local info = CREDITS_ART_INFO[self.expansion][self.releaseType][index];
	if ( not info ) then
		return;
	end

	local tilePath = CreateCreditsTextureTilePath(self, info, 1);
	CreditsArtCache1:SetTexture(tilePath);
end

function  CreditsFrameMixin:UpdateCache()
	if ( self.cacheIndex >= (NUM_CREDITS_ART_TEXTURES_WIDE * NUM_CREDITS_ART_TEXTURES_HIGH) ) then
		return;
	end
	if ( self.cacheElapsed < CACHE_WAIT_TIME ) then
		return;
	end

	self.cacheElapsed = self.cacheElapsed - CACHE_WAIT_TIME;
	self.cacheIndex = self.cacheIndex + 1;

	local info = CREDITS_ART_INFO[self.expansion][self.releaseType][self.cacheArt];
	if ( not info ) then
		return;
	end

	if (IsValidTextureIndex(info, self.cacheIndex)) then
		local tilePath = CreateCreditsTextureTilePath(self, info, self.cacheIndex);
		_G["CreditsArtCache"..self.cacheIndex]:SetTexture(tilePath);
	end
end

function CreditsFrameMixin:UpdateArt(index, elapsed)
	if ( index > self.artCount ) then
		return;
	end

	if ( index == self.currentArt ) then
		if ( self.fadingOut ) then
			self.alphaOut = max(self.alphaOut - (CREDITS_FADE_RATE * elapsed), 0);

			for i=1, NUM_CREDITS_ART_TEXTURES_HIGH, 1 do
				for j=1, NUM_CREDITS_ART_TEXTURES_WIDE, 1 do
					_G["CreditsArtAlt"..(((i - 1) * NUM_CREDITS_ART_TEXTURES_WIDE) + j)]:SetAlpha(self.alphaOut);
				end
			end

			if ( self.alphaOut <= 0 ) then
				self.fadingOut = nil;
				self:CacheTextures(self, self.currentArt + 1);
			end
		end

		if ( self.fadingIn ) then
			local maxAlpha = CREDITS_ART_INFO[self.expansion][self.releaseType][self.currentArt].maxAlpha;
			self.alphaIn = min(self.alphaIn + (CREDITS_FADE_RATE * elapsed), maxAlpha);
			for i=1, NUM_CREDITS_ART_TEXTURES_HIGH, 1 do
				for j=1, NUM_CREDITS_ART_TEXTURES_WIDE, 1 do
					_G["CreditsArt"..(((i - 1) * NUM_CREDITS_ART_TEXTURES_WIDE) + j)]:SetAlpha(self.alphaIn);
				end
			end

			if ( self.alphaIn >= maxAlpha ) then
				self.fadingIn = nil;
			end
		end
		return;
	end

	if ( self.currentArt > 0 ) then
		self.fadingOut = 1;
		self.alphaOut = CREDITS_ART_INFO[self.expansion][self.releaseType][self.currentArt].maxAlpha;
		self:SetArtTextures("CreditsArtAlt", self.currentArt, self.alphaOut);
	end

	self.fadingIn = 1;
	self.alphaIn = 0;
	self.currentArt = index;
	self:SetArtTextures("CreditsArt", index, self.alphaIn);
end

function CreditsFrameMixin:SetSpeed(speed)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	CREDITS_SCROLL_RATE = speed;
	self:UpdateSpeedButtons();
end

function CreditsFrameMixin:SetSpeedButtonActive(button, active)
	if ( active ) then
		button:LockHighlight();
		button:GetHighlightTexture():SetAlpha(0.5);
	else
		button:UnlockHighlight();
		button:GetHighlightTexture():SetAlpha(1);
	end
end

function CreditsFrameMixin:UpdateSpeedButtons()
	local activeButton;
	if ( CREDITS_SCROLL_RATE == CREDITS_SCROLL_RATE_REWIND ) then
		activeButton = CreditsFrameRewindButton;
	elseif ( CREDITS_SCROLL_RATE == CREDITS_SCROLL_RATE_PAUSE ) then
		activeButton = CreditsFramePauseButton;
	elseif ( CREDITS_SCROLL_RATE == CREDITS_SCROLL_RATE_PLAY ) then
		activeButton = CreditsFramePlayButton;
	elseif ( CREDITS_SCROLL_RATE == CREDITS_SCROLL_RATE_FASTFORWARD ) then
		activeButton = CreditsFrameFastForwardButton;
	end

	self:SetSpeedButtonActive(CreditsFrameRewindButton, activeButton == CreditsFrameRewindButton);
	self:SetSpeedButtonActive(CreditsFramePauseButton, activeButton ==  CreditsFramePauseButton);
	self:SetSpeedButtonActive(CreditsFramePlayButton, activeButton == CreditsFramePlayButton);
	self:SetSpeedButtonActive(CreditsFrameFastForwardButton, activeButton == CreditsFrameFastForwardButton);
end

function CreditsFrameMixin:OnUpdate(elapsed)
	local scrollIdx = self.scrollIdx;
	if scrollIdx then
		self.scrollIdx = nil;
		local startIdx = math.floor(scrollIdx);
		self:JumpToCreditsIndex(startIdx);
		return;
	end

	local screenHeight = self:GetHeight();
	local left = self.ScrollFrame:GetLeft() - self:GetLeft();

	if CREDITS_SCROLL_RATE ~= 0 then
		local offset = self.pixelAlignedRemainder + CREDITS_SCROLL_RATE * elapsed;
		local pixelAlignedOffset = PixelUtil.GetNearestPixelSize(offset, 1);
		self.pixelAlignedRemainder = offset - pixelAlignedOffset;
		self.startPos = self.startPos + pixelAlignedOffset;
	end

	if CREDITS_SCROLL_RATE < 0 then
		local startPos = self.startPos;
		local prevString = self.strings[self.startIdx];
		while (prevString:GetTop() - self:GetTop() < screenHeight and self.startIdx > 1) do
			self.startIdx = self.startIdx - 1;
			self.Slider:SetValue(self.startIdx);
			assert(not self.strings[self.startIdx]);
			local fontString = self:GetCreditsFontString(self.data[self.startIdx]);
			self.strings[self.startIdx] = fontString;
			self.startPos = self.startPos + fontString:GetHeight() + fontString:GetSpacing();
			fontString:SetPoint("TOPLEFT", CreditsFrame, "TOPLEFT", left, self.startPos - fontString:GetSpacing());
			prevString = fontString;
		end

		if (self.startIdx == 1 and self.startPos <= 0) then
			self.startPos = 0;
			CREDITS_SCROLL_RATE = 0;
			self:UpdateSpeedButtons();
			return;
		end
	end

	local startPos = self.startPos;
	local lastIdx;
	for i = self.startIdx, #self.data do
		local fontString = self.strings[i];
		if not fontString then
			fontString = self:GetCreditsFontString(self.data[i]);
			self.strings[i] = fontString;
		end
		if not fontString then
			break;
		end
		fontString:SetPoint("TOPLEFT", CreditsFrame, "TOPLEFT", left, startPos - fontString:GetSpacing());
		startPos = startPos - fontString:GetHeight() - fontString:GetSpacing();
		if fontString:GetBottom() - self:GetBottom() > screenHeight then
			self.startIdx = i + 1;
			self.Slider:SetValue(self.startIdx);
			self.startPos = self.startPos - fontString:GetHeight() - fontString:GetSpacing();
			self:ReleaseCreditsFontString(self.data[i], fontString);
			self.strings[i] = nil;
			if self.startIdx >= #self.data then
				GlueParent_CloseSecondaryScreen();
				return;
			end
		end
		if startPos < -screenHeight then
			lastIdx = i;
			break;
		end
	end
	if lastIdx then
		for i = lastIdx + 1, #self.data do
			if self.strings[i] then
				self:ReleaseCreditsFontString(self.data[i], self.strings[i]);
				self.strings[i] = nil;
			else
				break;
			end
		end
	end

	self.cacheElapsed = self.cacheElapsed + elapsed;
	self:UpdateCache();
	self:UpdateArt(ceil(self.artCount * (self.startIdx / #self.data)), elapsed);
end

function CreditsFrameMixin:OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		if self.ExpansionList:IsShown() then
			self.ExpansionList:Hide();
		else
			GlueParent_CloseSecondaryScreen();
		end
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function CreditsFrameMixin:ToggleExpansionList()
	if not self.ExpansionList:IsShown() then
		self.ExpansionList:OpenExpansionList(self.expansion, self.maxExpansion, self.releaseType, self.maxReleaseType);
	else
		self.ExpansionList:Hide();
	end
end

CreditsExpansionListMixin = {}

function CreditsExpansionListMixin:OnOKClicked()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	CreditsFrame:Switch(self.expansion, self.releaseType);
	self:Hide();
end

function CreditsExpansionListMixin:OnCancelClicked()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	self:Hide();
end

function CreditsExpansionListMixin:SetSelectedExpansion(expansion, releaseType)
	for button in self.buttonPool:EnumerateActive() do
		button.Selection:SetShown(expansion == button.expansion and releaseType == button.releaseType);
	end
	self.expansion = expansion;
	self.releaseType = releaseType;
end

function CreditsExpansionListMixin:OpenExpansionList(selectedExpansion, maxExpansion, releaseType, maxReleaseType)
	self.expansion = selectedExpansion;
	self.releaseType = releaseType;
	if not self.buttonPool then
		self.buttonPool = CreateFramePool("BUTTON", self, "CreditsFrameExpansionsButtonTemplate");
	end

	self.buttonPool:ReleaseAll();
	local numButtons = (maxExpansion + 1) * (maxReleaseType + 1);

	local prevButton = nil;
	local minWidth = 200;
	local maxWidth = minWidth;
	local buttonSpacing = 5;
	for type=0,maxReleaseType do
		for exp=0,maxExpansion do
			local button = self.buttonPool:Acquire();
			button.expansion = exp;
			button.releaseType = type;
			if (prevButton == nil) then
				button:SetPoint("TOP", self, "TOP", 0, -35);
			else
				button:SetPoint("TOP", prevButton, "BOTTOM", 0, -buttonSpacing);
			end
			button:SetText(_G["CREDITS_EXPANSION_NAME_" .. exp .. "_" .. type]);

			local width = button:GetTextWidth();
			maxWidth = math.max(width, maxWidth);
			button:SetWidth(width);
			button:Show();
			prevButton = button;
		end
	end
	for button in self.buttonPool:EnumerateActive() do
		button:SetWidth(maxWidth);
	end

	local minOKCancelButtonWidth = 80;
	local buttonBorderWidth = 10;
	local buttonTextWidth = math.max(minOKCancelButtonWidth, math.max(self.OKButton:GetTextWidth(), self.CancelButton:GetTextWidth())) + buttonBorderWidth * 2;
	self.OKButton:SetWidth(buttonTextWidth);
	self.CancelButton:SetWidth(buttonTextWidth);

	local frameWidth = math.max(maxWidth, 2 * buttonTextWidth) + 60;

	self:SetWidth(frameWidth);
	self:SetHeight(numButtons * (prevButton:GetHeight() + buttonSpacing) + 100);

	self:SetSelectedExpansion(self.expansion, self.releaseType);
	self:Show();
end