InsanityPowerBar = {};

function InsanityPowerBar:OnLoad()
	self.class = "PRIEST";
	self.spec = SPEC_PRIEST_SHADOW;
	self:SetPowerTokens("INSANITY");
	self.insane = false;

	self:SetInsanityVisualsActive(false);

	ClassPowerBar.OnLoad(self);
end

function InsanityPowerBar:OnEvent(event, arg1, arg2)
	if event == "UNIT_AURA" then
		local insane = IsInsane();
		if insane ~= self.insane then
			self.insane = insane;
			self:SetInsanityVisualsActive(insane);
		end
	else
		ClassPowerBar.OnEvent(self, event, arg1, arg2);
	end
end

function InsanityPowerBar:Setup()
	local showBar = ClassPowerBar.Setup(self);
	if showBar then
		self:RegisterUnitEvent("UNIT_AURA", "player");

		local playerFrameManaBar = PlayerFrame_GetManaBar();
		local manaBarMask = playerFrameManaBar.ManaBarMask;
		local manaBarTexture = playerFrameManaBar:GetStatusBarTexture();
		self.FillOverlay.FlipbookMask:ClearAllPoints();
		self.FillOverlay.FlipbookMask:SetPoint("TOPLEFT", manaBarMask, 0, -3);
		self.FillOverlay.FlipbookMask:SetPoint("BOTTOMLEFT", manaBarMask, 0, 3);
		self.FillOverlay.FlipbookMask:SetPoint("RIGHT", manaBarTexture);
	else
		self:UnregisterEvent("UNIT_AURA");
		self.FillOverlay.FlipbookMask:ClearAllPoints();
	end
end

function InsanityPowerBar:SetInsanityVisualsActive(active)
	if active then
		self.PortraitGlow:Show();
		self.FillOverlay:Show();
		self.InsanityAnims:Restart();
	else
		self.InsanityAnims:Stop();
		self.PortraitGlow:Hide();
		self.FillOverlay:Hide();
	end
end

function InsanityPowerBar:UpdatePower()
	-- Nothing to do here
end