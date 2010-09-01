local sizeScale = 0.8;
local longSide = 256 * sizeScale;
local shortSide = 128 * sizeScale;

function SpellActivationOverlay_OnLoad(self)
	self.overlaysInUse = {};
	self.unusedOverlays = {};
	
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_SHOW");
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_HIDE");
	
	self:SetSize(longSide, longSide)
end

function SpellActivationOverlay_OnEvent(self, event, ...)
	if ( event == "SPELL_ACTIVATION_OVERLAY_SHOW" ) then
		local spellID, texture, position, scale, r, g, b = ...;
		SpellActivationOverlay_ShowOverlay(self, spellID, texture, position, scale, r, g, b)
	elseif ( event == "SPELL_ACTIVATION_OVERLAY_HIDE" ) then
		local spellID = ...;
		SpellActivationOverlay_HideOverlays(self, spellID);
	end
end

function SpellActivationOverlay_ShowOverlay(self, spellID, texturePath, position, scale, r, g, b)
	if ( position == "Sides" ) then
		SpellActivationOverlay_ShowOverlay(self, spellID, texturePath, "Left", scale, r, g, b);
		SpellActivationOverlay_ShowOverlay(self, spellID, texturePath, "Right-Flipped", scale, r, g, b)
		return;
	end
	
	local overlay = SpellActivationOverlay_GetOverlay(self, spellID, position);
	overlay.spellID = spellID;
	overlay.position = position;
	
	overlay:ClearAllPoints();
	overlay.texture:SetTexCoord(0, 1, 0, 1);
	
	local width, height;
	if ( position == "Centered" ) then
		width, height = longSide, longSide;
		overlay:SetPoint("CENTER", self, "CENTER", 0, 0);
	elseif ( position == "Left" ) then
		width, height = shortSide, longSide;
		overlay:SetPoint("RIGHT", self, "LEFT", 0, 0);
	elseif ( position == "Top" ) then
		width, height = longSide, shortSide;
		overlay:SetPoint("BOTTOM", self, "TOP");
	elseif ( position == "Top-Right" ) then
		width, height = shortSide, shortSide;
		overlay:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);
	elseif ( position == "Top-Left" ) then
		width, height = shortSide, shortSide;
		overlay:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 0);
	elseif ( strsub(position, 1, 5) == "Right" ) then
		if ( strsub(position, 6) == "-Flipped" ) then
			overlay.texture:SetTexCoord(1, 0, 0, 1);
		end
		width, height = shortSide, longSide;
		overlay:SetPoint("LEFT", self, "RIGHT", 0, 0);
	else
		GMError("Unknown SpellActivationOverlay position: "..tostring(position));
		return;
	end
	
	overlay:SetSize(width * scale, height * scale);
	
	overlay.texture:SetTexture(texturePath);
	overlay.texture:SetVertexColor(r / 255, g / 255, b / 255);
	
	overlay.animOut:Stop();	--In case we're in the process of animating this out.
	overlay.pulse:Play();
	overlay:Show();
end

function SpellActivationOverlay_GetOverlay(self, spellID, position)
	local overlayList = self.overlaysInUse[spellID];
	local overlay;
	if ( overlayList ) then
		for i=1, #overlayList do
			if ( overlayList[i].position == position ) then
				overlay = overlayList[i];
			end
		end
	end
	
	if ( not overlay ) then
		overlay = SpellActivationOverlay_GetUnusedOverlay(self);
		if ( overlayList ) then
			tinsert(overlayList, overlay);
		else
			self.overlaysInUse[spellID] = { overlay };
		end
	end
	
	return overlay;
end

function SpellActivationOverlay_HideOverlays(self, spellID)
	local overlayList = self.overlaysInUse[spellID];
	if ( overlayList ) then
		for i=1, #overlayList do
			local overlay = overlayList[i];
			overlay.animOut:Play();
		end
	end
end

function SpellActivationOverlay_GetUnusedOverlay(self)
	local overlay = tremove(self.unusedOverlays, #self.unusedOverlays);
	if ( not overlay ) then
		overlay = SpellActivationOverlay_CreateOverlay(self);
	end
	return overlay;
end

function SpellActivationOverlay_CreateOverlay(self)
	return CreateFrame("Frame", nil, self, "SpellActivationOverlayTemplate");
end

function SpellActivationOverlayTexture_OnShow(self)
	self.animIn:Play();
end

function SpellActivationOverlayTexture_OnFadeInPlay(animGroup)
	animGroup:GetParent():SetAlpha(0);
end

function SpellActivationOverlayTexture_OnFadeInFinished(animGroup)
	animGroup:GetParent():SetAlpha(1);
end

function SpellActivationOverlayTexture_OnFadeOutFinished(anim)
	local overlay = anim:GetRegionParent();
	local overlayParent = overlay:GetParent();
	overlay.pulse:Stop();
	overlay:Hide();
	tDeleteItem(overlayParent.overlaysInUse[overlay.spellID], overlay)
	tinsert(overlayParent.unusedOverlays, overlay);
end