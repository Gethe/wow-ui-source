CommentatorSpellBaseMixin = {};

function CommentatorSpellBaseMixin:Initialize(spellCache)
	self.spellCache = spellCache;

	local spellID = spellCache:GetSpellID();
	self.Icon:SetTexture(select(3, GetSpellInfo(spellID)))

	self:SetActive(spellCache:IsActive());
end

function CommentatorSpellBaseMixin:Reset()
	self.spellCache = nil;
end

function CommentatorSpellBaseMixin:GetSpellID()
	return self.spellCache:GetSpellID();
end

function CommentatorSpellBaseMixin:IsActive()
	return self.spellCache:IsActive();
end

function CommentatorSpellBaseMixin:OnUpdate(elapsed)
	-- derive
end

function CommentatorSpellBaseMixin:SetActive(isActive)
	-- derive
end

CommentatorSpellMixin = CreateFromMixins(CommentatorSpellBaseMixin);

function CommentatorSpellMixin:OnLoad()
	self.Charges:SetScript("OnCooldownDone", GenerateClosure(self.UpdateCooldownsAndCharges, self));
	self.Charges:SetDrawSwipe(false);
end

function CommentatorSpellMixin:OnUpdate(elapsed)
	CommentatorSpellBaseMixin.OnUpdate(self, elapsed);
	
	self:UpdateActiveAnimation(elapsed);
	self:UpdateCharges();
end

function CommentatorSpellMixin:UpdateActiveAnimation(elapsed)
	AnimateTexCoords(self.Ants, 256, 256, 48, 48, 22, elapsed, 0.01);
end

function CommentatorSpellMixin:SetActive(isActive)
	CommentatorSpellBaseMixin.SetActive(self, isActive);

	self:UpdateCooldownsAndCharges();

	self.ActiveGlow:SetShown(isActive);
	self.Ants:SetShown(isActive);
end

function CommentatorSpellMixin:UpdateCharges()
	local charges, maxCharges, chargeStart, chargeDuration = self.spellCache:GetSpellCharges();
	local requiresCharges = charges and maxCharges and maxCharges > 1;
	if requiresCharges and charges < maxCharges then
		self.Charges:SetCooldown(chargeStart, chargeDuration);
	end
	self.ChargesText:SetText(requiresCharges and charges or "");
end

function CommentatorSpellMixin:UpdateCooldown()
	local charges, maxCharges, chargeStart, chargeDuration = self.spellCache:GetSpellCharges();
	local start, duration, enable = self.spellCache:GetCooldownInfo();
	-- The swipe is only displayed if no charges are available. This mimics the behavior 
	-- of charge spells in the action bar.
	if maxCharges == 0 or charges == 0 then
		CooldownFrame_Set(self.Cooldown, start, duration, enable);
	end
end

function CommentatorSpellMixin:UpdateCooldownsAndCharges()
	if self:IsActive() then
		CooldownFrame_Clear(self.Cooldown);
		CooldownFrame_Clear(self.Charges);
	else
		self:UpdateCooldown();
		self:UpdateCharges();
	end
end

function CommentatorSpellMixin:Initialize(spellCache)
	CommentatorSpellBaseMixin.Initialize(self, spellCache);

	self:UpdateCooldownsAndCharges();
end

CommentatorDebuffMixin = CreateFromMixins(CommentatorSpellBaseMixin);

function CommentatorDebuffMixin:UpdateCooldowns()
	local start, duration, enable = self.spellCache:GetPlayerAuraInfo();
	CooldownFrame_Set(self.Cooldown, start, duration, enable);
end

function CommentatorDebuffMixin:SetActive(isActive)
	self:UpdateCooldowns();
end

function CommentatorDebuffMixin:Initialize(spellCache)
	CommentatorSpellBaseMixin.Initialize(self, spellCache);

	self:UpdateCooldowns();
end

CommentatorCooldownMixin = {}

function CommentatorCooldownMixin:OnLoad()
	self:SetCountdownFont("SystemFont_Shadow_Med3");
	local seconds = 60;
	self:SetCountdownAbbrevThreshold(seconds);
end