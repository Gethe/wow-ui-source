
CREDITS_SCROLL_RATE_REWIND = -160;
CREDITS_SCROLL_RATE_PAUSE = 0;
CREDITS_SCROLL_RATE_PLAY = 40;
CREDITS_SCROLL_RATE_FASTFORWARD = 160;

CREDITS_SCROLL_RATE = 40;
CREDITS_FADE_RATE = 0.4;
--CREDITS_MAX_ALPHA = 0.7;
NUM_CREDITS_ART_TEXTURES_WIDE = 4;
NUM_CREDITS_ART_TEXTURES_HIGH = 2;
CACHE_WAIT_TIME = 0.5;

CreditsArtInfo = {};
CreditsArtInfo[1] = {};
CreditsArtInfo[1][1] = { file="NightsHollow", w=512, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[2] = {};
CreditsArtInfo[2][1] = { file="Illidan", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[3] = {};
CreditsArtInfo[3][1] = { file="CinSnow01TGA", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[4] = { path="CATACLYSM\\" };
CreditsArtInfo[4][1] = {  file="Greymane City Map01", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[5] = { path="Pandaria\\" };
CreditsArtInfo[5][1] = { file="Mogu_BossConcept_New", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6] = { path="Warlords\\" };
CreditsArtInfo[6][1] = { file="Alliance_Garrison_Armory", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][2] = { file="Arrak_Forest_Dark", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][3] = { file="Arrak_Landscape", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][4] = { file="Arrak_Landscape_Color", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][5] = { file="Ashrand_zone_concept", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][6] = { file="BoilingPlains_BW", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][7] = { file="CE_Nagrand_Landscape", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][8] = { file="Frostwind_ConceptPainting_jlo", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][9] = { file="Shadowmoon_Color_jlo", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][10] = { file="Zangar", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][11] = { file="Zangar_UndertheSea", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][12] = { file="Alliance_Garrison_WorkShopv", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][13] = { file="Alliance_Garrison_LumberMill", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };
CreditsArtInfo[6][14] = { file="Ashrand_zone_concept_B", w=1024, h=512, offsetx=0, offsety=0, maxAlpha=0.7 };

function CreditsFrame_OnShow(self)
	CreditsFrame_Update(self);
end

function CreditsFrame_Update(self)
	CreditsLogo:SetTexture(EXPANSION_LOGOS[CreditsFrame.creditsType-1]);

	CreditsFrame_SetSpeed(CREDITS_SCROLL_RATE_PLAY);
	CreditsScrollFrame:SetVerticalScroll(0);
	CreditsScrollFrame.scroll = 0;
	CreditsScrollFrame.scrollMax = CreditsScrollFrame:GetVerticalScrollRange() + 768;
	self.artCount = getn(CreditsArtInfo[CreditsFrame.creditsType]);
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
	CreditsText:SetText(GetCreditsText(CreditsFrame.creditsType));

	-- Set Switch Button Text
	local creditsType = CreditsFrame.creditsType;
	if ( creditsType < CreditsFrame.maxCreditsType ) then
		CreditsFrameSwitchButton1:Show();
		CreditsFrameSwitchButton1:SetText(CREDITS_TITLES[creditsType + 1]);
		CreditsFrameSwitchButton1:SetID(creditsType + 1);
	else
		CreditsFrameSwitchButton1:Hide();
	end
	if ( creditsType > 1 ) then
		CreditsFrameSwitchButton2:Show();
		CreditsFrameSwitchButton2:SetText(CREDITS_TITLES[creditsType - 1]);
		CreditsFrameSwitchButton2:SetID(creditsType - 1);
	else
		CreditsFrameSwitchButton2:Hide();
	end
end

function CreditsFrame_Switch(self, buttonID)
	PlaySound("igMainMenuOptionCheckBoxOff");
	CreditsFrame.creditsType = buttonID;
	CreditsFrame_Update(self);
	SetGlueScreen("credits");	
end

function CreditsFrame_Show(self, returnTo)
	self.returnTo = returnTo;
	SetGlueScreen("credits");
end

function CreditsFrame_SetArtTextures(self,textureName, index, alpha)
	local info = CreditsArtInfo[self.creditsType][index];
	if ( not info ) then
		return;
	end
	local path = CreditsArtInfo[self.creditsType].path;
	if ( not path ) then
		path = "";
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
				texture:SetTexture("Interface\\Glues\\Credits\\"..path..info.file..texIndex);
				texture:SetWidth(width);
				texture:SetHeight(height);
				texture:SetAlpha(alpha);
				texture:Show();
				texIndex = texIndex + 1;
			end
		end
	end
end

function CreditsFrame_CacheTextures(self, index)
	self.cacheArt = index;
	self.cacheIndex = 1;
	self.cacheElapsed = 0;

	local info = CreditsArtInfo[CreditsFrame.creditsType][index];
	if ( not info ) then
		return;
	end
	local path = CreditsArtInfo[CreditsFrame.creditsType].path;
	if ( not path ) then
		path = "";
	end

	CreditsArtCache1:SetTexture("Interface\\Glues\\Credits\\"..path..info.file.."1");
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

	local info = CreditsArtInfo[self.creditsType][self.cacheArt];
	if ( not info ) then
		return;
	end
	local path = CreditsArtInfo[self.creditsType].path;
	if ( not path ) then
		path = "";
	end

	_G["CreditsArtCache"..self.cacheIndex]:SetTexture("Interface\\Glues\\Credits\\"..path..info.file..self.cacheIndex);
end

function CreditsFrame_UpdateArt(self, index, elapsed)
	if (index > (self.currentArt + 1) ) then
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
			local maxAlpha = CreditsArtInfo[self.creditsType][self.currentArt].maxAlpha;
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
		self.alphaOut = CreditsArtInfo[self.creditsType][self.currentArt].maxAlpha;
		CreditsFrame_SetArtTextures(self, "CreditsArtAlt", self.currentArt, self.alphaOut);
	end

	self.fadingIn = 1;
	self.alphaIn = 0;
	self.currentArt = index;
	CreditsFrame_SetArtTextures(self, "CreditsArt", index, self.alphaIn);
end

function CreditsFrame_SetSpeed(speed)
	PlaySound("igMainMenuOptionCheckBoxOff");
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
		SetGlueScreen(self.returnTo);
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

function CreditsFrame_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		SetGlueScreen(CreditsFrame.returnTo);
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end
