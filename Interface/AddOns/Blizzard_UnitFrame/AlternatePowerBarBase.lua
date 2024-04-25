----------------- Alternate Power Bar Base -----------------

-- Base mixin for an alternate unit power bar, typically shown as a 3rd bar under the primary power bar
AlternatePowerBarBaseMixin = {};

function AlternatePowerBarBaseMixin:OnLoad()
	self.isEnabled = nil;
	self:Initialize();
end

function AlternatePowerBarBaseMixin:Initialize()
	self:UpdateArt();

	local statusBarTexture = self:GetStatusBarTexture();
	statusBarTexture:SetTexelSnappingBias(0);
	statusBarTexture:SetSnapToPixelGrid(false);

	if self.PowerBarMask then
		statusBarTexture:AddMaskTexture(self.PowerBarMask);
	end

	if self.frequentUpdates then
		self:SetScript("OnUpdate", self.OnUpdate);
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("UNIT_DISPLAYPOWER");

	self:EvaluateUnit();
end

function AlternatePowerBarBaseMixin:OnUpdate()
	if not self.isEnabled then
		return;
	end

	self:UpdatePower();
end

function AlternatePowerBarBaseMixin:OnEvent(event, ...)
	local unit = self:GetUnit();

	if event=="PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" then
		self:EvaluateUnit();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		local unitToken = ...;
		if unitToken == unit or unitToken == nil then
			self:EvaluateUnit();
		end
	elseif self.isEnabled then
		if event == "PLAYER_ALIVE"  or event == "PLAYER_DEAD" or event == "PLAYER_UNGHOST" then
			self:UpdateIsAliveState();
		end
	end
end

function AlternatePowerBarBaseMixin:SetBarEnabled(enabled)
	if self.isEnabled == enabled then
		return;
	end

	local wasEnabled = self.isEnabled;
	self.isEnabled = enabled;

	if self.isEnabled then
		self:OnBarEnabled();

		self:AttachBarToUnitUI();

		if (self:GetUnit() == "player") then
			self:RegisterEvent("PLAYER_DEAD");
			self:RegisterEvent("PLAYER_ALIVE");
			self:RegisterEvent("PLAYER_UNGHOST");
		end
	else
		self:OnBarDisabled();

		-- If isEnabled is nil, that means we're starting disabled & have never been enabled before
		-- So avoid unncessarily undoing things we've never actually done
		if wasEnabled then
			if (self:GetUnit() == "player") then
				self:UnregisterEvent("PLAYER_DEAD");
				self:UnregisterEvent("PLAYER_ALIVE");
				self:UnregisterEvent("PLAYER_UNGHOST");
			end

			self:RemoveBarFromUnitUI();
		end
		self:Hide();
	end
end

function AlternatePowerBarBaseMixin:UpdatePower()
	local currentPower = self:GetCurrentPower();
	self:SetValue(currentPower);
	self.currentPower = currentPower;
end

function AlternatePowerBarBaseMixin:UpdateMinMaxPower()
	local minPower, maxPower = self:GetCurrentMinMaxPower();
	self:SetMinMaxValues(minPower, maxPower);
	self.minPower = minPower;
	self.maxPower = maxPower;
end

function AlternatePowerBarBaseMixin:GetUnit()
	local unit = self.unit;
	if not unit then
		local parent = self:GetParent();
		local grandParent = parent and parent:GetParent() or nil;
		unit = grandParent and grandParent.unit or nil;
	end

	return unit or "player";
end

-- UI-Context-Specific base mixin functions

function AlternatePowerBarBaseMixin:UpdateArt()
	-- Implement in a base mixin specific to what kind of unit UI is displaying the bar
	-- (ex a PlayerFrame-specific base mixin)
end

function AlternatePowerBarBaseMixin:UpdateIsAliveState()
	-- Implement in a base mixin specific to what kind of unit UI is displaying the bar
	-- (ex a PlayerFrame-specific base mixin)
end

function AlternatePowerBarBaseMixin:AttachBarToUnitUI()
	-- Implement in a base mixin specific to what kind of unit UI is displaying the bar
	-- (ex a PlayerFrame-specific base mixin)
end

function AlternatePowerBarBaseMixin:RemoveBarFromUnitUI()
	-- Implement in a base mixin specific to what kind of unit UI is displaying the bar
	-- (ex a PlayerFrame-specific base mixin)
end

-- Class/Spec/Power-specific mixin functions

function AlternatePowerBarBaseMixin:EvaluateUnit()
	-- Implement in derived mixins
	-- Should evalute unit's current class, spec, power type, etc, and SetBarEnabled accordingly
end

function AlternatePowerBarBaseMixin:OnBarEnabled()
	-- Implement in derived mixins
end

function AlternatePowerBarBaseMixin:OnBarDisabled()
	-- Implement in derived mixins
end

function AlternatePowerBarBaseMixin:GetCurrentPower()
	-- Implement in derived mixins
end

function AlternatePowerBarBaseMixin:GetCurrentMinMaxPower()
	-- Implement in derived mixins
end


----------------- Player Frame Alternate Power Base -----------------

-- Base mixin for alternate power bars attached to the Player Unit Frame
PlayerFrameAlternatePowerBarBaseMixin = CreateFromMixins(AlternatePowerBarBaseMixin);

function PlayerFrameAlternatePowerBarBaseMixin:Initialize()
	self.textLockable = 1;
	self.cvar = "statusText";
	self.cvarLabel = "STATUS_TEXT_PLAYER";
	self.capNumericDisplay = true;

	self:SetBarText(_G[self:GetName().."Text"]);
	self:InitializeTextStatusBar();

	AlternatePowerBarBaseMixin.Initialize(self);

	if self.Spark and self.PowerBarMask then
		self.Spark:AddMaskTexture(self.PowerBarMask);
	end
end

function PlayerFrameAlternatePowerBarBaseMixin:OnShow()
	self.pauseUpdates = false;
	self:UpdatePower();
	self:UpdateTextString();
end

function PlayerFrameAlternatePowerBarBaseMixin:OnHide()
	self.pauseUpdates = true;
end

function PlayerFrameAlternatePowerBarBaseMixin:OnEvent(event, ...)
	AlternatePowerBarBaseMixin.OnEvent(self, event, ...);
	self:TextStatusBarOnEvent(event, ...);
end

function PlayerFrameAlternatePowerBarBaseMixin:AttachBarToUnitUI()
	PlayerFrame_OnAlternatePowerBarEnabled(self);
end

function PlayerFrameAlternatePowerBarBaseMixin:RemoveBarFromUnitUI()
	PlayerFrame_OnAlternatePowerBarDisabled(self);
end

function PlayerFrameAlternatePowerBarBaseMixin:UpdateArt()
	local info = self.overrideArtInfo or PowerBarColor[self.powerName];
	if info then
		if info.atlasElementName then
			-- Currently alt power bars are only shown for player, non-vehicle, portrait-on unit frames
			self:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOn-Bar-"..info.atlasElementName);
		elseif info.atlas then
			self:SetStatusBarTexture(info.atlas);
		else
			-- No texture specified, default to Mana-Status (colorable).
			self:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Status");
		end

		if not info.atlasElementName and not info.atlas and info.r then
			self:SetStatusBarColor(info.r, info.g, info.b);
		else
			self:SetStatusBarColor(1, 1, 1);
		end
	else
		-- If we cannot find the info for what the bar should be, default to Mana bar
		self:SetStatusBarColor(1, 1, 1);
		self:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana");
	end

	if self.Spark then
		self.Spark:SetVisuals(info.spark);
	end

	self:UpdateIsAliveState();
end

function PlayerFrameAlternatePowerBarBaseMixin:UpdateIsAliveState()
	local playerDeadOrGhost = self:GetUnit() == "player" and (UnitIsDead("player") or UnitIsGhost("player"));
	local statusBarTexture = self:GetStatusBarTexture();
	statusBarTexture:SetDesaturated(playerDeadOrGhost);
	statusBarTexture:SetAlpha(playerDeadOrGhost and 0.5 or 1);
end