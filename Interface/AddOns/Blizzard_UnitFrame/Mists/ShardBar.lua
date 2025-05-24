local WARLOCK_POWER_FILLBAR = {
	Demonology 			= { left = 0.03906250, right = 0.55468750, top = 0.10546875, bottom = 0.19921875, width = 132, fileWidth = 256 };
	DemonologyActivated	= { left = 0.03906250, right = 0.55468750, top = 0.00390625, bottom = 0.09765625, width = 132, fileWidth = 256 };
	Destruction			= { left = 0.30078125, right = 0.37890625, top = 0.32812500, bottom = 0.67187500, height = 22, fileHeight = 64 };
};

WarlockPowerFrameMixin = {}
ShardBarMixin = {}
DemonicFuryBarMixin = {}
BurningEmbersBarMixin = {}

-- GENERAL WARLOCK
function WarlockPowerFrameMixin:OnLoad()
	local _, class = UnitClass("player");
	if ( class == "WARLOCK" ) then
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
		self:RegisterEvent("UNIT_DISPLAYPOWER");
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player", "vehicle");	
		self:RegisterEvent("PLAYER_TALENT_UPDATE");

		BurningEmbersBarFrame.displayedPower = 0;
		DemonicFuryBarFrame.displayedPower = 0;
		self:SetUpCurrentPower();
	end
end

function WarlockPowerFrameMixin:OnEvent(event, arg1, arg2)
	-- update events
	if ( self.activeBar ) then
		if ( (event == "UNIT_POWER_FREQUENT") and (arg1 == WarlockPowerFrame:GetParent().unit) ) then
			self.activeBar:OnEvent(arg2);
			return;
		elseif ( event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD" ) then
			self.activeBar:OnEvent();
			return;
		end
	end
	-- power specific events
	if ( event == "UNIT_AURA" and (arg1 == WarlockPowerFrame:GetParent().unit) ) then
		DemonicFuryBarFrame:CheckAndSetState();
	elseif ( event == "SPELLS_CHANGED" ) then
		if ( self.reqSpellID ) then
			if ( IsPlayerSpell(self.reqSpellID) ) then
				self:UnregisterEvent("SPELLS_CHANGED");
				self.reqSpellID = nil;
				-- clear spec to force reevaluation
				self.spec = nil;
				self:SetUpCurrentPower(true);
			end
		elseif ( self.spec == SPEC_WARLOCK_DESTRUCTION ) then
			BurningEmbersBarFrame:SetColorTextures();
		end
	elseif ( self.activeBar and event == "CVAR_UPDATE" and ( arg1 == "STATUS_TEXT_PLAYER" or arg1 == "STATUS_TEXT_DISPLAY" ) ) then
		DemonicFuryBarFrame:CheckStatusCVars();
		self.activeBar:OnEvent(nil, true);
	-- power may have changed
	elseif ( event == "PLAYER_TALENT_UPDATE" ) then
		self:SetUpCurrentPower(true);
	end
end

-- this function might be called to reshow the power bar, like after leaving a vehicle
function WarlockPowerFrameMixin:SetUpCurrentPower(shouldAnim)
	local doShow = false;
	local doAnim = false;
	local spec = GetSpecialization();

	if ( spec == SPEC_WARLOCK_AFFLICTION ) then
		-- set up Affliction
		if ( self.spec ~= spec ) then
			-- tear down Demonic and Destruction
			DemonicFuryBarFrame:Hide();
			self:UnregisterEvent("UNIT_AURA");
			self:UnregisterEvent("CVAR_UPDATE");
			BurningEmbersBarFrame:Hide();
			self:UnregisterEvent("SPELLS_CHANGED");
			self:SetScript("OnUpdate", nil);
			-- set up Affliction
			-- only show shard bar if soulburn is known
			if ( IsPlayerSpell(WARLOCK_SOULBURN) ) then
				self.activeBar = ShardBarFrame;
				self.activeBar.OnEvent = ShardBarFrame.Update;
				ShardBarFrame:Show();
				if ( shouldAnim ) then
					doAnim = true;
				end
			else
				self.activeBar = nil;
				self:RegisterEvent("SPELLS_CHANGED");
				self.reqSpellID = WARLOCK_SOULBURN;
			end
		end
		doShow = true;
	elseif ( spec == SPEC_WARLOCK_DESTRUCTION ) then
		-- set up Destruction
		if ( self.spec ~= spec ) then
			-- tear down Affliction and Demonic
			DemonicFuryBarFrame:Hide();
			self:UnregisterEvent("UNIT_AURA");
			self:UnregisterEvent("CVAR_UPDATE");
			ShardBarFrame:Hide();
			-- set up Destruction
			-- only show if burning embers is known
			if ( IsPlayerSpell(WARLOCK_BURNING_EMBERS) ) then
				self.activeBar = BurningEmbersBarFrame;
				self.activeBar.OnEvent = BurningEmbersBarFrame.Update;
				self.activeBar.SetPower = BurningEmbersBarFrame.SetPower;
				self:SetScript("OnUpdate", self.OnUpdate);
				BurningEmbersBarFrame:Show();
				if ( shouldAnim ) then
					doAnim = true;
				end
				BurningEmbersBarFrame:SetColorTextures();
				self.reqSpellID = nil;
			else
				self.activeBar = nil;
				self:SetScript("OnUpdate", nil);
				self.reqSpellID = WARLOCK_BURNING_EMBERS;
			end
			-- always register for this, need to check for green fire
			self:RegisterEvent("SPELLS_CHANGED");
		end
		doShow = true;
	elseif ( spec == SPEC_WARLOCK_DEMONOLOGY ) then
		if ( self.spec ~= spec ) then
			-- tear down Affliction and Destruction
			ShardBarFrame:Hide();
			BurningEmbersBarFrame:Hide();
			self:UnregisterEvent("SPELLS_CHANGED");
			-- set up Demonic
			self.activeBar = DemonicFuryBarFrame;
			self.activeBar.OnEvent = DemonicFuryBarFrame.Update;
			self.activeBar.SetPower = DemonicFuryBarFrame.SetPower;
			self:RegisterUnitEvent("UNIT_AURA", "player", "vehicle");
			self:RegisterEvent("CVAR_UPDATE");
			self:SetScript("OnUpdate", self.OnUpdate);
			DemonicFuryBarFrame:CheckStatusCVars();
			DemonicFuryBarFrame:Show();
			if ( shouldAnim ) then
				doAnim = true;
			end
		end
		DemonicFuryBarFrame:CheckAndSetState();
		doShow = true;
	else
		-- no spec
		self.activeBar = nil;
		self:UnregisterEvent("SPELLS_CHANGED");
		self:UnregisterEvent("UNIT_AURA");
		self:UnregisterEvent("CVAR_UPDATE");
		self:Hide();
	end
	
	self.spec = spec;
	if ( doShow ) then
		self:Show();
		if ( doAnim ) then
			self:SetAlpha(0);
			self.showAnim:Play();
		end
		if ( self.activeBar ) then
			self.activeBar:OnEvent(nil, true);	-- forces instant update instead of smooth progress
		end
	end
end

function WarlockPowerFrameMixin:UpdateFill(texture, texData, value, maxValue)
	if ( value <= 0 ) then
		texture:Hide();
	elseif ( value >= maxValue ) then
		texture:SetTexCoord(texData["left"], texData["right"], texData["top"], texData["bottom"]);
		if ( texData.width ) then
			texture:SetWidth(texData["width"]);
		else
			texture:SetHeight(texData["height"]);
		end
		texture:Show();
	else
		if ( texData.width ) then
			local texWidth = (value / maxValue) * texData["width"];
			local right = texData["left"] + texWidth / texData["fileWidth"];
			texture:SetTexCoord(texData["left"], right, texData["top"], texData["bottom"]);
			texture:SetWidth(texWidth);
		else
			local texHeight = (value / maxValue) * texData["height"];
			local top = texData["bottom"] - texHeight / texData["fileHeight"];
			texture:SetTexCoord(texData["left"], texData["right"], top, texData["bottom"]);
			texture:SetHeight(texHeight);
		end
		texture:Show();
	end
end

function WarlockPowerFrameMixin:OnUpdate(elapsed)
	local activeBar = self.activeBar;
	if ( activeBar.power and activeBar.power ~= activeBar.displayedPower ) then
		activeBar:SetPower(GetSmoothProgressChange(activeBar.power, activeBar.displayedPower, activeBar.maxPower, elapsed));
	end
end

-- AFFLICTION
function ShardBarMixin:SetShard(active)
	if ( active ) then
		if (self.animOut:IsPlaying()) then
			self.animOut:Stop();
		end
		
		if (not self.active and not self.animIn:IsPlaying()) then
			self.animIn:Play();
			self.active = true;
		end
	else
		if (self.animIn:IsPlaying()) then
			self.animIn:Stop();
		end
		
		if (self.active and not self.animOut:IsPlaying()) then
			self.animOut:Play();
			self.active = false;
		end
	end
end

function ShardBarMixin:Update(powerType)
	if ( powerType and powerType ~= "SOUL_SHARDS" ) then
		return;
	end

	local numShards = UnitPower( WarlockPowerFrame:GetParent().unit, Enum.PowerType.SoulShards );
	local maxShards = UnitPowerMax( WarlockPowerFrame:GetParent().unit, Enum.PowerType.SoulShards );
	-- update individual shard display
	for i = 1, maxShards do
		local shard = _G["ShardBarFrameShard"..i];
		local shouldShow = i <= numShards;
		self:SetShard(shard, shouldShow);
	end
end

-- DEMONOLOGY

function DemonicFuryBarMixin:Update(powerType, forceUpdate)
	if ( powerType and powerType ~= "DEMONIC_FURY" ) then
		return;
	end
	self.power = UnitPower("player", Enum.PowerType.DemonicFury);
	self.maxPower = UnitPowerMax("player", Enum.PowerType.DemonicFury);
	if ( forceUpdate ) then
		self:SetPower(self.power);
	end
end

function DemonicFuryBarMixin:SetPower(power)
	self.displayedPower = power;
	local texData;
	if ( self.activated ) then
		texData = WARLOCK_POWER_FILLBAR["DemonologyActivated"];
	else
		texData = WARLOCK_POWER_FILLBAR["Demonology"];
	end
	WarlockPowerFrame:UpdateFill(self.fill, texData, power, self.maxPower);
	TextStatusBar_UpdateTextStringWithValues(self, self.powerText, math.floor(power), 1, self.maxPower);
end

function DemonicFuryBarMixin:CheckAndSetState()
	local activated = false;
	local index = 1;
	local name, _, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", index);
	while spellId do
		if ( spellId == WARLOCK_METAMORPHOSIS ) then
			activated = true;
			break;
		end
		name, _, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", index);
		index = index + 1
	end
	if ( activated and not self.activated ) then
		self.activated = true;
		self.bar:SetTexCoord(0.03906250, 0.69921875, 0.30859375, 0.51171875);
		self.notch:SetTexCoord(0.00390625, 0.03125000, 0.00390625, 0.08984375);
	elseif ( not activated and self.activated ) then
		self.activated = nil;
		self.bar:SetTexCoord(0.03906250, 0.69921875, 0.51953125, 0.72265625);
		self.notch:SetTexCoord(0.00390625, 0.03125000, 0.09765625, 0.18359375);
	end
	self:Update();
end

function DemonicFuryBarMixin:CheckStatusCVars()
	self.textDisplay = GetCVar("statusTextDisplay");
	if ( GetCVarBool("playerStatusText") ) then
		self.showText = true;
		self.lockShow = 1;
	else
		self.showText = false;
		self.lockShow = 0;
	end
end

-- DESTRUCTION

function BurningEmbersBarMixin:Update(powerType, forceUpdate)
	if ( powerType and powerType ~= "BURNING_EMBERS" ) then
		return;
	end

	local maxPower = UnitPowerMax("player", Enum.PowerType.BurningEmbers, true);
	local power = UnitPower("player", Enum.PowerType.BurningEmbers, true);
	local numEmbers = floor(maxPower / MAX_POWER_PER_EMBER);
	self.emberCount = numEmbers;
	self.power = power;
	self.maxPower = maxPower;
	if ( forceUpdate ) then
		self:SetPower(power);
	end
end

function BurningEmbersBarMixin:SetPower(power)
	self.displayedPower = power;
	for i = 1, self.emberCount do
		local ember = self["ember"..i];
		if ember then

			WarlockPowerFrame:UpdateFill(ember.fill, WARLOCK_POWER_FILLBAR["Destruction"], power, MAX_POWER_PER_EMBER);

			-- animate?
			if ( power >= MAX_POWER_PER_EMBER ) then
				if (ember.animOut:IsPlaying()) then
					ember.animOut:Stop();
				end
			
				if (not ember.active and not ember.animIn:IsPlaying()) then
					ember.animIn:Play();
					ember.active = true;
					ember.fire:Show();
				end
			else
				if (ember.animIn:IsPlaying()) then
					ember.animIn:Stop();
				end
			
				if (ember.active and not ember.animOut:IsPlaying()) then
					ember.animOut:Play();
					ember.active = false;
					ember.fire:Hide();
				end
			end
		
			-- leftover for the other embers
			power = power - MAX_POWER_PER_EMBER;
		end
	end
end

function BurningEmbersBarMixin:SetColorTextures()
	local frame = BurningEmbersBarFrame;
	local textureFile;
	if ( IsSpellKnown(WARLOCK_GREEN_FIRE) ) then
		if ( not frame.hasGreenFire ) then
			frame.hasGreenFire = true;
			textureFile = "Interface\\PlayerFrame\\Warlock-DestructionUI-Green";
		end
	else
		if ( frame.hasGreenFire ) then
			frame.hasGreenFire = nil;
			textureFile = "Interface\\PlayerFrame\\Warlock-DestructionUI";
		end
	end
	if ( textureFile ) then
		frame.background:SetTexture(textureFile);
		for i = 1, 4 do
			local ember = frame["ember"..i];
			ember.border:SetTexture(textureFile); 
			ember.fill:SetTexture(textureFile);
			ember.fire:SetTexture(textureFile);
			ember.glow:SetTexture(textureFile);
			ember.glow2:SetTexture(textureFile);
		end
	end
end

function BurningEmbersBarMixin:OnEnter()
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip:SetText(BURNING_EMBERS, 1, 1, 1);
	GameTooltip:AddLine(BURNING_EMBERS_TOOLTIP, nil, nil, nil, true);
	GameTooltip:Show();
end

function BurningEmbersBarMixin:OnLeave()
	GameTooltip:Hide();
end