DevourerFuryPowerBar = {
	FURY_OVERRIDE_INFO = {
		r = 0.788,
		g = 0.259,
		b = 0.992,
		atlas = "UF-DDH-Fury",
		predictionColor = POWERBAR_PREDICTION_COLOR_FURY,
		fullPowerAnim = true,
		spark = {
			atlas = "UF-DDH-Fury-Endcap-Add",
			xOffset = 1,
			barHeight = 10,
			showAtMax = true
		}
	};
	VOID_METAMORPHOSIS_FURY_OVERRIDE_INFO = {
		r = 0.788,
		g = 0.259,
		b = 0.992,
		atlas = "UF-DDH-MetaFury",
		predictionColor = POWERBAR_PREDICTION_COLOR_FURY,
		fullPowerAnim = true,
		spark = {
			atlas = "UF-DDH-Fury-Endcap-Minus",
			xOffset = 8,
			barHeight = 10,
			showAtMax = true
		}
	};
};

function DevourerFuryPowerBar:OnLoad()
	self.class = "DEMONHUNTER";
	self.spec = SPEC_DEMONHUNTER_DEVOURER;
	self:SetPowerTokens("FURY");

	ClassPowerBar.OnLoad(self);
end

function DevourerFuryPowerBar:OnEvent(event, arg1, arg2)
	if event == "UNIT_AURA" then
		self:UpdateAuraState();
	else
		ClassPowerBar.OnEvent(self, event, arg1, arg2);
	end
end

function DevourerFuryPowerBar:Setup()
	local showBar = ClassPowerBar.Setup(self);
	if showBar then
		self:RegisterUnitEvent("UNIT_AURA", "player");
		self:UpdateAuraState();
	else
		self:UnregisterEvent("UNIT_AURA");
		local playerFrameManaBar = PlayerFrame_GetManaBar();
		local overrideInfo = nil;
		UnitFrameManaBar_SetOverrideInfo(playerFrameManaBar, overrideInfo);
	end
end

function DevourerFuryPowerBar:UpdateAuraState()
	local inVoidMetamorphosis = C_UnitAuras.GetPlayerAuraBySpellID(Constants.UnitPowerSpellIDs.VOID_METAMORPHOSIS_SPELL_ID) ~= nil;

	if inVoidMetamorphosis ~= self.inVoidMetamorphosis then
		self.inVoidMetamorphosis = inVoidMetamorphosis;

		local playerFrameManaBar = PlayerFrame_GetManaBar();
		local overrideInfo = self.FURY_OVERRIDE_INFO;
		if self.inVoidMetamorphosis then
			self.StartAnim:Restart();
			overrideInfo = self.VOID_METAMORPHOSIS_FURY_OVERRIDE_INFO;
		end
		UnitFrameManaBar_SetOverrideInfo(playerFrameManaBar, overrideInfo);
	end
end

function DevourerFuryPowerBar:UpdatePower()
	-- Nothing to do here
end
