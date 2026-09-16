TargetFrameAuraButtonSharedMixin = {};

function TargetFrameAuraButtonSharedMixin:GetIcon()
	return self.Icon;
end

function TargetFrameAuraButtonSharedMixin:GetCount()
	return self.Count;
end

function TargetFrameAuraButtonSharedMixin:GetCooldown()
	return self.Cooldown;
end

function TargetFrameAuraButtonSharedMixin:ShouldShowAuraCount()
	return self.showAuraCount;
end

function TargetFrameAuraButtonSharedMixin:SetShowAuraCount(showAuraCount)
	showAuraCount = (showAuraCount == true);

	if self.showAuraCount ~= showAuraCount then
		self.showAuraCount = showAuraCount;
		self:ApplyAuraCount(self:GetAuraInstance());
	end
end

TargetFrameAuraButtonInboundMixin = CreateFromMixins(TargetFrameAuraButtonSharedMixin);
TargetFrameAuraButtonPrivateMixin = CreateFromMixins(AuraButtonPrivateMixin, TargetFrameAuraButtonSharedMixin);

function TargetFrameAuraButtonPrivateMixin:OnClick(mouseButtonName, isDownClick)
	EventRegistry:TriggerEvent("TargetAuraButton.OnClick", self, mouseButtonName, isDownClick);
end

--[[override]] function TargetFrameAuraButtonPrivateMixin:OnAuraInstanceAssigned(unitToken, auraData)
	self:ApplyAuraInstance(unitToken, auraData)
end

--[[override]] function TargetFrameAuraButtonPrivateMixin:OnAuraInstanceUpdated(unitToken, auraData)
	self:ApplyAuraInstance(unitToken, auraData);
end

--[[override]] function TargetFrameAuraButtonPrivateMixin:OnAuraInstanceCleared()
	local unitToken, auraData = nil, nil;
	self:ApplyAuraInstance(unitToken, auraData);
end

--[[override]] function TargetFrameAuraButtonPrivateMixin:UpdateAuraDisplay()
	local unitToken, auraData = self:GetAuraInstance();

	if auraData then
		self:ApplyAuraInstance(unitToken, auraData);
	end
end

function TargetFrameAuraButtonPrivateMixin:ApplyAuraBorder(_unitToken, _auraData)
	-- Implement in a derived mixin.
end

function TargetFrameAuraButtonPrivateMixin:ApplyAuraCooldown(_unitToken, auraData)
	if auraData then
		local enable = auraData.duration > 0;
		local forceDrawEdge = true;
		CooldownFrame_Set(self.Cooldown, auraData.expirationTime - auraData.duration, auraData.duration, enable, forceDrawEdge);
	else
		CooldownFrame_Clear(self.Cooldown);
	end
end

function TargetFrameAuraButtonPrivateMixin:ApplyAuraCount(_unitToken, auraData)
	if auraData and auraData.applications > 1 and self.showAuraCount then
		self.Count:SetText(auraData.applications);
		self.Count:Show();
	else
		self.Count:Hide();
	end
end

function TargetFrameAuraButtonPrivateMixin:ApplyAuraIcon(_unitToken, auraData)
	self.Icon:SetTexture(auraData and auraData.icon or QUESTION_MARK_ICON);
end

function TargetFrameAuraButtonPrivateMixin:ApplyAuraInstance(unitToken, auraData)
	self:ApplyAuraBorder(unitToken, auraData);
	self:ApplyAuraCooldown(unitToken, auraData);
	self:ApplyAuraCount(unitToken, auraData);
	self:ApplyAuraIcon(unitToken, auraData);
end

TargetFrameBuffButtonSharedMixin = {};

function TargetFrameBuffButtonSharedMixin:GetStealableBorder()
	return self.StealableBorder;
end

function TargetFrameBuffButtonSharedMixin:IsStealableBorderEnabled()
	return self.stealableBorderEnabled;
end

function TargetFrameBuffButtonSharedMixin:SetStealableBorderEnabled(enabled)
	enabled = (enabled == true);

	if self.stealableBorderEnabled ~= enabled then
		self.stealableBorderEnabled = enabled;
		self:ApplyAuraBorder(self:GetAuraInstance());
	end
end

TargetFrameBuffButtonInboundMixin = CreateFromMixins(TargetFrameBuffButtonSharedMixin);
TargetFrameBuffButtonPrivateMixin = CreateFromMixins(TargetFrameAuraButtonPrivateMixin, TargetFrameBuffButtonSharedMixin);

--[[override]] function TargetFrameBuffButtonPrivateMixin:OnLoad_Intrinsic()
	TargetFrameAuraButtonPrivateMixin.OnLoad_Intrinsic(self);
	self.stealableBorderEnabled = false;
end

--[[override]] function TargetFrameBuffButtonPrivateMixin:ApplyAuraBorder(_unitToken, auraData)
	if auraData then
		self.StealableBorder:SetShown(auraData.isStealable and self:IsStealableBorderEnabled());
	end
end

TargetFrameDebuffButtonSharedMixin = {};

function TargetFrameDebuffButtonSharedMixin:GetDispelBorder()
	return self.DispelBorder;
end

TargetFrameDebuffButtonInboundMixin = CreateFromMixins(TargetFrameDebuffButtonSharedMixin);
TargetFrameDebuffButtonPrivateMixin = CreateFromMixins(TargetFrameAuraButtonPrivateMixin, TargetFrameDebuffButtonSharedMixin);

--[[override]] function TargetFrameDebuffButtonPrivateMixin:ApplyAuraBorder(_unitToken, auraData)
	if auraData then
		AuraUtil.SetAuraBorderColor(self.DispelBorder, auraData.dispelName);
	end
end
