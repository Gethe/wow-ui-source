function CreditsFrame_OnLoad(self)
	self.creditsType = 1;
	self.maxCreditsType = 1;
end

function CreditsFrame_OnShow(self)
	StopGlueAmbience();
	CreditsFrame.creditsType = CREDITS_TYPE_CLASSIC;
	CreditsFrame.maxCreditsType = CreditsFrame.creditsType;
	CreditsFrame_Update(self);
end

function CreditsFrame_OnHide(self)
	ShowCursor();
end

function CreditsFrame_Update(self)
	PlayCreditsMusic(GLUE_CREDITS_SOUND_KITS[CreditsFrame.creditsType]);

	-- TODO: This would be better if it was driven by data in Constants.lua.
	if (CreditsFrame.creditsType == CREDITS_TYPE_CLASSIC) then
		SetClassicLogo(CreditsLogo);
	elseif (CreditsFrame.creditsType == CREDITS_TYPE_VANILLA) then
		local expansionInfo;
		expansionInfo = GetExpansionDisplayInfo(LE_EXPANSION_CLASSIC);
		if expansionInfo then
			CreditsLogo:SetTexCoord(0, 1, 0, 1);
			CreditsLogo:SetTexture(expansionInfo.logo);
		end
	end
	
	CreditsFrame_SetSpeed(CREDITS_SCROLL_RATE_PLAY);
	CreditsScrollFrame:SetVerticalScroll(0);
	CreditsScrollFrame.scroll = 0;
	CreditsScrollFrame.scrollMax = CreditsScrollFrame:GetVerticalScrollRange() + 768;
	self.artCount = #CREDITS_ART_INFO[CreditsFrame.creditsType];
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

	CreditsFrame_CacheTextures(self, 1);

	-- Set Credits Text
	-- TODO: This would be better if it was driven by data in Constants.lua.
	if (CreditsFrame.creditsType == CREDITS_TYPE_CLASSIC) then
		CreditsText:SetText(GetCreditsText(LE_EXPANSION_CLASSIC, LE_RELEASE_TYPE_MODERN));
	elseif (CreditsFrame.creditsType == CREDITS_TYPE_VANILLA) then
		CreditsText:SetText(GetCreditsText(LE_EXPANSION_CLASSIC, LE_RELEASE_TYPE_ORIGINAL));
	end

	-- Set Switch Button Text
	CreditsFrameSwitchButton1:Hide();
	CreditsFrameSwitchButton2:Hide();

	local creditsType = CreditsFrame.creditsType;
	if ( creditsType < CreditsFrame.maxCreditsType ) then
		if (CreditsFrame.maxCreditsType > 2) then
			CreditsFrameSwitchButton1:Show();
			CreditsFrameSwitchButton1:SetText(CREDITS_TITLES[creditsType + 1]);
			CreditsFrameSwitchButton1:SetID(creditsType + 1);
		else
			-- If we have only 2 credits, use Button2 (so that it doesn't look like the button is just jumping back and forth).
			CreditsFrameSwitchButton2:Show();
			CreditsFrameSwitchButton2:SetText(CREDITS_TITLES[creditsType + 1]);
			CreditsFrameSwitchButton2:SetID(creditsType + 1);
		end
	end

	if ( creditsType > 1 ) then
		CreditsFrameSwitchButton2:Show();
		CreditsFrameSwitchButton2:SetText(CREDITS_TITLES[creditsType - 1]);
		CreditsFrameSwitchButton2:SetID(creditsType - 1);
	end
end

function CreditsFrame_Switch(self, buttonID)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	CreditsFrame.creditsType = buttonID;
	CreditsFrame_Update(CreditsFrame);
end

local function IsValidTextureIndex(info, index)
	return info.maxTexIndex == nil or index <= info.maxTexIndex;
end

local function CreateCreditsTextureTilePath(self, info, textureIndex)
	local path = CREDITS_ART_INFO[self.creditsType].path;
	if path then
		return string.format("Interface\\Glues\\Credits\\%s\\%s%d", path, info.file, textureIndex);
	else
		return string.format("Interface\\Glues\\Credits\\%s%d", info.file, textureIndex);
	end
end

function CreditsFrame_SetArtTextures(self, textureName, index, alpha)
	local info = CREDITS_ART_INFO[self.creditsType][index];
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

function CreditsFrame_CacheTextures(self, index)
	self.cacheArt = index;
	self.cacheIndex = 1;
	self.cacheElapsed = 0;

	local info = CREDITS_ART_INFO[CreditsFrame.creditsType][index];
	if ( not info ) then
		return;
	end

	local tilePath = CreateCreditsTextureTilePath(self, info, 1);
	CreditsArtCache1:SetTexture(tilePath);
end

function CreditsFrame_UpdateCache(self)
	if ( self.cacheIndex >= (NUM_CREDITS_ART_TEXTURES_WIDE * NUM_CREDITS_ART_TEXTURES_HIGH) ) then
		return;
	end
	if ( self.cacheElapsed < CACHE_WAIT_TIME ) then
		return;
	end

	self.cacheElapsed = self.cacheElapsed - CACHE_WAIT_TIME;
	self.cacheIndex = self.cacheIndex + 1;

	local info = CREDITS_ART_INFO[self.creditsType][self.cacheArt];
	if ( not info ) then
		return;
	end

	if (IsValidTextureIndex(info, self.cacheIndex)) then
		local tilePath = CreateCreditsTextureTilePath(self, info, self.cacheIndex);
		_G["CreditsArtCache"..self.cacheIndex]:SetTexture(tilePath);
	end
end

function CreditsFrame_UpdateArt(self, index, elapsed)
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
				CreditsFrame_CacheTextures(self, self.currentArt + 1);
			end
		end

		if ( self.fadingIn ) then
			local maxAlpha = CREDITS_ART_INFO[self.creditsType][self.currentArt].maxAlpha;
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
		self.alphaOut = CREDITS_ART_INFO[self.creditsType][self.currentArt].maxAlpha;
		CreditsFrame_SetArtTextures(self, "CreditsArtAlt", self.currentArt, self.alphaOut);
	end

	self.fadingIn = 1;
	self.alphaIn = 0;
	self.currentArt = index;
	CreditsFrame_SetArtTextures(self, "CreditsArt", index, self.alphaIn);
end

function CreditsFrame_SetSpeed(speed)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	CREDITS_SCROLL_RATE = speed;
	CreditsFrame_UpdateSpeedButtons();
end

function CreditsFrame_SetSpeedButtonActive(button, active)
	if ( active ) then
		button:LockHighlight();
		button:GetHighlightTexture():SetAlpha(0.5);
	else
		button:UnlockHighlight();
		button:GetHighlightTexture():SetAlpha(1);
	end
end

function CreditsFrame_UpdateSpeedButtons()
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

	CreditsFrame_SetSpeedButtonActive(CreditsFrameRewindButton, activeButton == CreditsFrameRewindButton);
	CreditsFrame_SetSpeedButtonActive(CreditsFramePauseButton, activeButton ==  CreditsFramePauseButton);
	CreditsFrame_SetSpeedButtonActive(CreditsFramePlayButton, activeButton == CreditsFramePlayButton);
	CreditsFrame_SetSpeedButtonActive(CreditsFrameFastForwardButton, activeButton == CreditsFrameFastForwardButton);
end

function CreditsFrame_OnUpdate(self, elapsed)
	if ( not CreditsScrollFrame:IsShown() ) then
		return;
	end

	CreditsScrollFrame.scroll = CreditsScrollFrame.scroll + (CREDITS_SCROLL_RATE * elapsed);
	CreditsScrollFrame.scroll = max(CreditsScrollFrame.scroll, 1);

	if ( CreditsScrollFrame.scroll >= CreditsScrollFrame.scrollMax ) then
		GlueParent_CloseSecondaryScreen();
		return;
	end

	self.cacheElapsed = self.cacheElapsed + elapsed;
	CreditsFrame_UpdateCache(self);

	CreditsScrollFrame:SetVerticalScroll(CreditsScrollFrame.scroll);
	CreditsFrame_UpdateArt(self, ceil(self.artCount * (CreditsScrollFrame.scroll / CreditsScrollFrame.scrollMax)), elapsed);
end

function CreditsFrame_OnScrollRangeChanged()
	CreditsScrollFrame.scrollMax = CreditsScrollFrame:GetVerticalScrollRange() + 768;
end

function CreditsFrame_OnKeyDown(self, key)
	if ( key == "ESCAPE" ) then
		GlueParent_CloseSecondaryScreen();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end