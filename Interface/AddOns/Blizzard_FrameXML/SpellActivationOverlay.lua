local sizeScale = 0.8;
local longSide = 256 * sizeScale;
local shortSide = 128 * sizeScale;

SpellActivationOverlayMixin = {};

function SpellActivationOverlayMixin:OnLoad()
	self.overlaysInUse = {};
	self.overlayPool = CreateFramePool("FRAME", self, "SpellActivationOverlayTemplate");

	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_SHOW");
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_HIDE");
	self:RegisterEvent("SETTINGS_LOADED");
	
	self:SetSize(longSide, longSide)

	local function OnValueChanged(o, setting, value)
		self:SetAlpha(value);
	end
	Settings.SetOnValueChangedCallback("spellActivationOverlayOpacity", OnValueChanged);
end

function SpellActivationOverlayMixin:OnEvent(event, ...)
	if event == "SPELL_ACTIVATION_OVERLAY_SHOW" then
		local spellID, texture, locationType, scale, r, g, b = ...;
		if GetCVarBool("displaySpellActivationOverlays") then
			self:ShowAllOverlays(spellID, texture, locationType, scale, r, g, b);
		end
	elseif event == "SPELL_ACTIVATION_OVERLAY_HIDE" then
		local spellID = ...;
		if spellID then
			self:HideOverlays(spellID);
		else
			self:HideAllOverlays();
		end
	elseif event == "SETTINGS_LOADED" then
		self:SetAlpha(Settings.GetValue("spellActivationOverlayOpacity"));
	end
end

local complexLocationTypes = {
	[Enum.ScreenLocationType.LeftRight] = {
		Enum.ScreenLocationType.Left,
		Enum.ScreenLocationType.Right,
	},
	[Enum.ScreenLocationType.TopBottom] = {
		Enum.ScreenLocationType.Top,
		Enum.ScreenLocationType.Bottom,
	},
	[Enum.ScreenLocationType.LeftRightOutside] = {
		Enum.ScreenLocationType.LeftOutside,
		Enum.ScreenLocationType.RightOutside,
	},
}

function SpellActivationOverlayMixin:ShowAllOverlays(spellID, texturePath, locationType, scale, r, g, b)
	local locations = complexLocationTypes[locationType];
	if locations then
		for _, location in ipairs(locations) do
			self:ShowOverlay(spellID, texturePath, location, scale, r, g, b);
		end
	else
		self:ShowOverlay(spellID, texturePath, locationType, scale, r, g, b);
	end
end

local hFlippedPositions = {
	[Enum.ScreenLocationType.Right] = true,
	[Enum.ScreenLocationType.RightOutside] = true,
};

local vFlippedPositions = {
	[Enum.ScreenLocationType.Bottom] = true,
};

function SpellActivationOverlayMixin:ShowOverlay(spellID, texturePath, position, scale, r, g, b)
	local overlay = self:GetOverlay(spellID, position);
	overlay.spellID = spellID;
	overlay.position = position;
	
	overlay:ClearAllPoints();
	
	local texLeft, texRight, texTop, texBottom = 0, 1, 0, 1;
	if vFlippedPositions[position] then
		texTop, texBottom = 1, 0;
	end
	if hFlippedPositions[position] then
		texLeft, texRight = 1, 0;
	end
	overlay.texture:SetTexCoord(texLeft, texRight, texTop, texBottom);
	
	local width, height;
	if position == Enum.ScreenLocationType.Center then
		width, height = longSide, longSide;
		overlay:SetPoint("CENTER", self, "CENTER", 0, 0);
	elseif position == Enum.ScreenLocationType.Left then
		width, height = shortSide, longSide;
		overlay:SetPoint("RIGHT", self, "LEFT", 0, 0);
	elseif position == Enum.ScreenLocationType.LeftOutside then
		width, height = shortSide, longSide;
		overlay:SetPoint("RIGHT", self, "LEFT", -shortSide, 0);
	elseif position == Enum.ScreenLocationType.Right then
		width, height = shortSide, longSide;
		overlay:SetPoint("LEFT", self, "RIGHT", 0, 0);
	elseif position == Enum.ScreenLocationType.RightOutside then
		width, height = shortSide, longSide;
		overlay:SetPoint("LEFT", self, "RIGHT", shortSide, 0);
	elseif position == Enum.ScreenLocationType.Top then
		width, height = longSide, shortSide;
		overlay:SetPoint("BOTTOM", self, "TOP");
	elseif position == Enum.ScreenLocationType.Bottom then
		width, height = longSide, shortSide;
		overlay:SetPoint("TOP", self, "BOTTOM");
	elseif position == Enum.ScreenLocationType.TopRight then
		width, height = shortSide, shortSide;
		overlay:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);
	elseif position == Enum.ScreenLocationType.TopLeft then
		width, height = shortSide, shortSide;
		overlay:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 0);
	else
		--GMError("Unknown SpellActivationOverlay position: "..tostring(position));
		return;
	end
	
	overlay:SetSize(width * scale, height * scale);
	
	overlay.texture:SetTexture(texturePath);
	overlay.texture:SetVertexColor(r / 255, g / 255, b / 255);
	
	overlay.animOut:Stop();	--In case we're in the process of animating this out.
	PlaySound(SOUNDKIT.UI_POWER_AURA_GENERIC);
	overlay:Show();
end

function SpellActivationOverlayMixin:GetOverlay(spellID, position)
	if not self.overlaysInUse[spellID] then
		self.overlaysInUse[spellID] = {};
	end

	local overlayList = self.overlaysInUse[spellID];
	local overlay = overlayList[position];
	
	if not overlay then
		overlay = self.overlayPool:Acquire();
		overlayList[position] = overlay;
	end
	
	return overlay;
end

function SpellActivationOverlayMixin:HideOverlays(spellID)
	local overlayList = self.overlaysInUse[spellID];
	if overlayList then
		for _, overlay in pairs(overlayList) do
			overlay.pulse:Pause();
			overlay.animOut:Play();
		end
	end
end

function SpellActivationOverlayMixin:HideAllOverlays()
	for spellID, _ in pairs(self.overlaysInUse) do
		self:HideOverlays(spellID);
	end
end

function SpellActivationOverlayMixin:ReleaseOverlay(overlay)
	self.overlaysInUse[overlay.spellID][overlay.position] = nil;
	self.overlayPool:Release(overlay);
end

SpellActivationOverlayTextureMixin = {}

function SpellActivationOverlayTextureMixin:OnShow()
	self.animIn:Play();
end

SpellActivationOverlayFadeInAnimMixin = {};

function SpellActivationOverlayFadeInAnimMixin:OnPlay()
	self:GetParent():SetAlpha(0);
end

function SpellActivationOverlayFadeInAnimMixin:OnFinished()
	local overlay = self:GetParent();
	overlay:SetAlpha(1);
	overlay.pulse:Play();
end

SpellActivationOverlayFadeOutAnimMixin = {};

function SpellActivationOverlayFadeOutAnimMixin:OnFinished()
	local overlay = self:GetParent();
	overlay.pulse:Stop();
	overlay:GetParent():ReleaseOverlay(overlay);
end
