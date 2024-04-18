ClassNameplateBar = {};

function ClassNameplateBar:OnLoad()
	-- Initialize these variables in the class-specific OnLoad mixin function. Also make sure to implement
	-- an UpdatePower() mixin function that handles UI changes for whenever the power display changes

	self:SetScale(self.scale or 1);
	self:Setup();
end

function ClassNameplateBar:OnEvent(event, ...)
	if ( event == "UNIT_POWER_FREQUENT" ) then
		local unitTag, powerToken = ...;
		if (unitTag == "player" and self.powerToken == powerToken ) then
			self:UpdatePower();
			return true;
		end
	elseif ( event == "UNIT_MAXPOWER" ) then
		local unitTag = ...;
		if (unitTag == "player") then
			self:UpdateMaxPower();
			return true;
		end
	elseif ( event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD" ) then
		self:Setup();
		self:UpdatePower();
		return true;
	elseif (event == "PLAYER_TALENT_UPDATE" ) then
		self:Setup();
		self:UpdatePower();
		return true;
	end
	return false;
end

function ClassNameplateBar:OnShow()
	self:OnSizeChanged();
end

function ClassNameplateBar:OnSizeChanged()
	-- override if needed
end

function ClassNameplateBar:MatchesClass()
	local _, myclass = UnitClass("player");
	return myclass == self.class;
end

function ClassNameplateBar:MatchesSpec()
	if ( not self.spec ) then
		return true;
	end
	local myspec = GetSpecialization();
	return myspec == self.spec;
end

function ClassNameplateBar:Setup()
	local showBar = false;

	if ( self:MatchesClass() ) then
		if ( self:MatchesSpec() ) then
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
			self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
			self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player");
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			showBar = true;
		else
			self:UnregisterEvent("UNIT_POWER_FREQUENT");
			self:UnregisterEvent("UNIT_MAXPOWER");
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");
			self:UnregisterEvent("UNIT_DISPLAYPOWER");
		end

		self:RegisterEvent("PLAYER_TALENT_UPDATE");
	end

	if (showBar) then
		self:ShowNameplateBar();
		self:UpdateMaxPower();
	else
		self:HideNameplateBar();
	end

	return showBar;
end

function ClassNameplateBar:ShowNameplateBar()
	self:Show();
	NamePlateDriverFrame:SetClassNameplateBar(self);
end

function ClassNameplateBar:HideNameplateBar()
	self:Hide();
	if (NamePlateDriverFrame:GetClassNameplateBar() == self) then
		NamePlateDriverFrame:SetClassNameplateBar(nil);
	end
end

function ClassNameplateBar:TurnOn(frame, texture, toAlpha)
	ClassPowerBar:TurnOn(frame, texture, toAlpha);
end

function ClassNameplateBar:TurnOff(frame, texture, toAlpha)
	ClassPowerBar:TurnOff(frame, texture, toAlpha);
end

function ClassNameplateBar:UpdateMaxPower()
end

function ClassNameplateBar:UpdatePower()
end

function ClassNameplateBar:OnOptionsUpdated()
end

function ClassNameplateBar:GetUnit()
	return "player";
end

--------------------------------------------------------------------------------
--
-- ClassNameplateManaBar
--
--------------------------------------------------------------------------------

ClassNameplateManaBar = {};

local NameplatePowerBarColor = {
	["MANA"] = { r = 0.1, g = 0.25, b = 1.00, predictionColor = POWERBAR_PREDICTION_COLOR_MANA }
};

function ClassNameplateManaBar:OnLoad()
	ClassNameplateBar.OnLoad(self);

	self.Border:SetVertexColor(0, 0, 0, 1);
end

function ClassNameplateManaBar:OnEvent(event, ...)
	if (event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MAXPOWER") then
		self:SetupBar();
		if (event == "UNIT_MAXPOWER") then
			ClassNameplateBar.OnEvent(self, event, ...);
		end
	elseif ( event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" ) then
		self:UpdatePredictedPowerCost(event == "UNIT_SPELLCAST_START");
		self:SetupBar();
	elseif ( event == "PLAYER_GAINS_VEHICLE_DATA" or event == "PLAYER_LOSES_VEHICLE_DATA" ) then
		self:SetupBar();
	else
		ClassNameplateBar.OnEvent(self, event, ...);
	end
end

function ClassNameplateBar:UpdatePredictedPowerCost(queryCurrentCastingInfo)
	local cost = 0;

	if queryCurrentCastingInfo then
		local spellID = select(9, UnitCastingInfo("player"));

		if spellID then
			local costTable = GetSpellPowerCost(spellID);
			for _, costInfo in pairs(costTable) do
				if costInfo.type == self.powerType then
					cost = costInfo.cost;
					break;
				end
			end
		end
	end

	self.predictedPowerCost = cost;
end

function ClassNameplateManaBar:Setup()
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player");
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player");
	self:RegisterUnitEvent("PLAYER_GAINS_VEHICLE_DATA", "player");
	self:RegisterUnitEvent("PLAYER_LOSES_VEHICLE_DATA", "player");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	local statusBarTexture = self:GetStatusBarTexture();

	self.ManaCostPredictionBar:ClearAllPoints();
	self.ManaCostPredictionBar:SetPoint("TOPLEFT", statusBarTexture, "TOPRIGHT", 0, 0);
	self.ManaCostPredictionBar:SetPoint("BOTTOMLEFT", statusBarTexture, "BOTTOMRIGHT", 0, 0);

	self:Show();
	NamePlateDriverFrame:SetClassNameplateManaBar(self);
end

function ClassNameplateManaBar:SetupBar()
	local powerType, powerToken, altR, altG, altB = UnitPowerType("player");
	local info;
	if (powerToken) then
		info = NameplatePowerBarColor[powerToken] or PowerBarColor[powerToken];
		if not info then
			if altR then
				info = CreateColor(altR, altG, altB);
			else
				info = PowerBarColor[powerType];
			end
		end
		self:SetStatusBarColor(info.r, info.g, info.b);

		-- Nameplate mana bar uses only solid color (no atlases), ensure its feedback frame does the same
		local colorOnlyInfo = { r = info.r, g = info.g, b = info.b };
		self.FeedbackFrame:Initialize(colorOnlyInfo, "player", powerType);

		self:SetScript("OnUpdate", ClassNameplateManaBar_OnUpdate);

		self.FullPowerFrame:SetSize(86, 6);
		self.FullPowerFrame.SpikeFrame:SetSize(86, 6);
		self.FullPowerFrame.PulseFrame:SetSize(86, 6);
		self.FullPowerFrame.SpikeFrame.AlertSpikeStay:SetSize(30, 12);
		self.FullPowerFrame.PulseFrame.YellowGlow:SetSize(20, 20);
		self.FullPowerFrame.PulseFrame.SoftGlow:SetSize(20, 20);
		self.FullPowerFrame:Initialize(info.fullPowerAnim);
	end

	if ( self.powerToken ~= powerToken or self.powerType ~= powerType ) then
		self.powerToken = powerToken;
		self.powerType = powerType;
		self.FullPowerFrame:RemoveAnims();
		self:UpdatePredictedPowerCost(true);

		if (self.ManaCostPredictionBar) then
			local predictionColor;
			if (info and info.predictionColor) then
				predictionColor = info.predictionColor;
			else
				-- No prediction color set, default to mana prediction color
				predictionColor = POWERBAR_PREDICTION_COLOR_MANA;
			end
	
			self.ManaCostPredictionBar:SetVertexColor(predictionColor:GetRGBA());
		end
	end

	self.currValue = UnitPower("player", powerType) - self.predictedPowerCost;
	self.forceUpdate = true;

	self:UpdateMaxPower();
	self:UpdatePower();
	self:OnOptionsUpdated();
end

function ClassNameplateManaBar:UpdateMaxPower()
	local maxValue = UnitPowerMax("player", self.powerType);
	self:SetMinMaxValues(0, maxValue);
	self.FullPowerFrame:SetMaxValue(maxValue);
end

function ClassNameplateManaBar:UpdatePower()
	local currValue = UnitPower("player", self.powerType) - self.predictedPowerCost;
	self:SetValue(currValue);
	if (self.predictedPowerCost == 0) then
		self.ManaCostPredictionBar:Hide();
	else
		local bar = self.ManaCostPredictionBar;

		local totalWidth = self:GetWidth();
		local _, totalMax = self:GetMinMaxValues();

		local barSize = (self.predictedPowerCost / totalMax) * totalWidth;
		bar:SetWidth(barSize);
		bar:Show();
	end
end

function ClassNameplateManaBar:OnOptionsUpdated()
	self:OnSizeChanged();
end

function ClassNameplateManaBar:OnSizeChanged() -- override
	PixelUtil.SetHeight(self, DefaultCompactNamePlatePlayerFrameSetUpOptions.healthBarHeight);
	self.Border:UpdateSizes();
end

function ClassNameplateManaBar:GetUnit()
	return "player";
end

function ClassNameplateManaBar_OnUpdate(self)
	local currValue = UnitPower("player", self.powerType) - self.predictedPowerCost;
	local oldValue = self.currValue or 0;

	if ( currValue ~= self.currValue or self.forceUpdate ) then
		self.forceUpdate = nil;
		-- Only show anim if change is more than 10%
		if ( self.FeedbackFrame.maxValue ~= 0 and ( math.abs(currValue - oldValue) / self.FeedbackFrame.maxValue ) > 0.1 ) then
			self.FeedbackFrame:StartFeedbackAnim(oldValue, currValue);
		end
		if ( self.FullPowerFrame.active ) then
			self.FullPowerFrame:StartAnimIfFull(currValue);
		end
		self.currValue = currValue;
	end
end
