function SpellActivationOverlay_OnLoad(self)
	self.overlaysInUse = {};
	self.unusedOverlays = {};
	
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_SHOW");
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_HIDE");
end

function SpellActivationOverlay_OnEvent(self, event, ...)
	if ( event == "SPELL_ACTIVATION_OVERLAY_SHOW" ) then
		local spellID, texture, position, scale, r, g, b = ...;
		SpellActivationOverlay_ShowOverlay(self, spellID, texture, position, scale, r, g, b)
	elseif ( event == "SPELL_ACTIVATION_OVERLAY_HIDE" ) then
		local spellID = ...;
		SpellActivationOverlay_HideOverlay(self, spellID);
	end
end

function SpellActivationOverlay_ShowOverlay(self, spellID, texturePath, position, scale, r, g, b)
	local overlay = self.overlaysInUse[spellID];
	if ( not overlay ) then
		overlay = SpellActivationOverlay_GetUnusedOverlay(self)
		self.overlaysInUse[spellID] = overlay;
	end
	overlay.spellID = spellID;
	
	if ( position == "Centered" ) then
		overlay:SetPoint("CENTER", self, "CENTER", 0, 0);
	else
		GMError("Unknown SpellActivationOverlay position: "..tostring(position));
		return;
	end
	
	local nativeWidth, nativeHeight = self:GetSize();
	overlay:SetSize(nativeWidth * scale, nativeHeight * scale);
	
	overlay.texture:SetTexture(texturePath);
	overlay.texture:SetVertexColor(r / 255, g / 255, b / 255);
	
	overlay.animOut:Stop();	--In case we're in the process of animating this out.
	overlay:Show();
end

function SpellActivationOverlay_HideOverlay(self, spellID)
	local overlay = self.overlaysInUse[spellID];
	if ( overlay ) then
		overlay.animOut:Play();
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
	overlay:Hide();
	overlayParent.overlaysInUse[overlay.spellID] = nil;
	tinsert(overlayParent.unusedOverlays, overlay);
end