NamePlateDriverMixin = {};

function NamePlateDriverMixin:OnLoad()
	self:RegisterEvent("NAME_PLATE_CREATED");
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterEvent("UNIT_FACTION");
	
	self:ApplySizes();
end

function NamePlateDriverMixin:OnEvent(event, ...)
	if event == "NAME_PLATE_CREATED" then
		local namePlateFrameBase = ...;
		self:OnNamePlateCreated(namePlateFrameBase);
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		local namePlateUnitToken = ...;
		self:OnNamePlateAdded(namePlateUnitToken);
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		local namePlateUnitToken = ...;
		self:OnNamePlateRemoved(namePlateUnitToken);
	elseif event == "PLAYER_TARGET_CHANGED" then
		self:OnTargetChanged();
	elseif event == "DISPLAY_SIZE_CHANGED" then
		self:ApplySizes();
	elseif event == "UNIT_AURA" then
		self:OnUnitAuraUpdate(...);
	elseif event == "VARIABLES_LOADED" then
		self:UpdateNamePlateOptions();
	elseif event == "CVAR_UPDATE" then
		local name = ...;
		if name == "SHOW_CLASS_COLOR_IN_V_KEY" or name == "SHOW_NAMEPLATE_LOSE_AGGRO_FLASH" then
			self:UpdateNamePlateOptions();
		end
	elseif event == "RAID_TARGET_UPDATE" then
		self:OnRaidTargetUpdate();
	elseif ( event == "UNIT_FACTION" ) then
		self:OnUnitFactionChanged(...);
	end
end

function NamePlateDriverMixin:ApplySizes()
	local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"));
	C_NamePlate.SetNamePlateSizes(110 * horizontalScale, 45);

	self:UpdateNamePlateOptions();
end

function NamePlateDriverMixin:OnNamePlateCreated(namePlateFrameBase)
	Mixin(namePlateFrameBase, NamePlateBaseMixin);

	CreateFrame("BUTTON", "$parentUnitFrame", namePlateFrameBase, "NamePlateUnitFrameTemplate");
	namePlateFrameBase.UnitFrame:EnableMouse(false);
	namePlateFrameBase.UnitFrame.nameChangedCallback = function(frame)
		self:UpdateRaidTargetIconPosition(frame);
	end
end

function NamePlateDriverMixin:OnNamePlateAdded(namePlateUnitToken)
	local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken);
	self:ApplyFrameOptions(namePlateFrameBase, namePlateUnitToken);
	
	namePlateFrameBase:OnAdded(namePlateUnitToken);
	self:SetupClassNameplateBars();
	
	self:OnUnitAuraUpdate(namePlateUnitToken);
	self:OnRaidTargetUpdate();
end

function NamePlateDriverMixin:ApplyFrameOptions(namePlateFrameBase, namePlateUnitToken)
	if UnitIsUnit("player", namePlateUnitToken) then
		CompactUnitFrame_SetUpFrame(namePlateFrameBase.UnitFrame, DefaultCompactNamePlatePlayerFrameSetup);
	elseif UnitIsFriend("player", namePlateUnitToken) then
		CompactUnitFrame_SetUpFrame(namePlateFrameBase.UnitFrame, DefaultCompactNamePlateTargetFriendlyFrameSetup);
	else
		CompactUnitFrame_SetUpFrame(namePlateFrameBase.UnitFrame, DefaultCompactNamePlateTargetEnemyFrameSetup);
	end
end

function NamePlateDriverMixin:OnNamePlateRemoved(namePlateUnitToken)
	local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken);

	namePlateFrameBase:OnRemoved();
end

function NamePlateDriverMixin:OnTargetChanged()
	self:SetupClassNameplateBars();
	self:OnUnitAuraUpdate("target");
end

function NamePlateDriverMixin:OnUnitAuraUpdate(unit)
	local filter = "HARMFUL";
	local reaction = UnitReaction("player", unit);
	if (UnitIsUnit("player", unit)) then
		filter = "HELPFUL";
	elseif (reaction and reaction <= 4) then
		-- Reaction 4 is neutral and less than 4 becomes increasingly more hostile
		filter = "HARMFUL";
	else
		filter = "NONE";
	end
	
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit);
	if (nameplate) then
		nameplate.UnitFrame.BuffFrame:UpdateBuffs(unit, filter);
	end
end

function NamePlateDriverMixin:UpdateRaidTargetIconPosition(frame)
	if (frame.RaidTargetFrame.RaidTargetIcon:IsShown()) then
		local namePos = frame.name:IsShown() and frame.name:GetRect() or nil;
		local barPos = frame.healthBar:IsShown() and frame.healthBar:GetRect() or nil;
		if (not barPos or (namePos and namePos < barPos)) then
			frame.RaidTargetFrame:SetPoint("RIGHT", frame.name, "LEFT", -5, 0);
		else
			frame.RaidTargetFrame:SetPoint("RIGHT", frame.healthBar, "LEFT", -5, 0);
		end
	end
end
		
function NamePlateDriverMixin:OnRaidTargetUpdate()
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		local icon = frame.UnitFrame.RaidTargetFrame.RaidTargetIcon;
		local index = GetRaidTargetIndex(frame.namePlateUnitToken);
		if ( index ) then
			SetRaidTargetIconTexture(icon, index);
			icon:Show();
			self:UpdateRaidTargetIconPosition(frame.UnitFrame);
		else
			icon:Hide();
		end
	end
	
end

function NamePlateDriverMixin:OnUnitFactionChanged(unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit);
	if (nameplate) then
		CompactUnitFrame_UpdateName(nameplate.UnitFrame);
		CompactUnitFrame_UpdateHealthColor(nameplate.UnitFrame);
	end
end

function NamePlateDriverMixin:SetupClassNameplateBar(onTarget, bar)
	if (not bar) then
		return;
	end
	
	bar:Hide();
	
	local showSelf = GetCVar("nameplateShowSelf");
	if (showSelf == "0") then
		return;
	end
	
	local healthResourceAlpha = GetCVar("nameplateBarAlpha");
	bar:SetAlpha(healthResourceAlpha);
	local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player");
	if (namePlatePlayer) then
		namePlatePlayer.UnitFrame.healthBar:SetAlpha(healthResourceAlpha);
	end
	
	if (onTarget and NamePlateTargetResourceFrame) then
		local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target");
		if (namePlateTarget) then
			bar:SetParent(NamePlateTargetResourceFrame);
			NamePlateTargetResourceFrame:SetParent(namePlateTarget.UnitFrame);
			NamePlateTargetResourceFrame:ClearAllPoints();
			NamePlateTargetResourceFrame:SetPoint("BOTTOM", namePlateTarget.UnitFrame.name, "TOP", 0, 4);
			bar:Show();
			NamePlateTargetResourceFrame:Layout();
		end
		NamePlateTargetResourceFrame:SetShown(namePlateTarget ~= nil);
	elseif (not onTarget and NamePlatePlayerResourceFrame) then
		local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player");
		if (namePlatePlayer) then
			bar:SetParent(NamePlatePlayerResourceFrame);
			NamePlatePlayerResourceFrame:SetParent(namePlatePlayer.UnitFrame);
			NamePlatePlayerResourceFrame:ClearAllPoints();
			NamePlatePlayerResourceFrame:SetPoint("TOP", namePlatePlayer.UnitFrame.healthBar, "BOTTOM", 0, -1);
			bar:Show();
			NamePlatePlayerResourceFrame:Layout();
		end
		NamePlatePlayerResourceFrame:SetShown(namePlatePlayer ~= nil);
	end
end

function NamePlateDriverMixin:SetupClassNameplateBars()
	local mode = GetCVar("nameplateResourceOnTarget");
	self:SetupClassNameplateBar(mode == "1", self.nameplateBar);
	self:SetupClassNameplateBar(false, self.nameplateManaBar);
end

function NamePlateDriverMixin:SetClassNameplateBar(frame)
	self.nameplateBar = frame;
	self:SetupClassNameplateBars();
end

function NamePlateDriverMixin:SetClassNameplateManaBar(frame)
	self.nameplateManaBar = frame;
	self:SetupClassNameplateBars();
end

function NamePlateDriverMixin:UpdateNamePlateOptions()
	DefaultCompactNamePlateTargetEnemyFrameOptions.useClassColors = GetCVarBool("ShowClassColorInNameplate");
	DefaultCompactNamePlateTargetEnemyFrameOptions.playLoseAggroHighlight = GetCVarBool("ShowNamePlateLoseAggroFlash");
	DefaultCompactNamePlateTargetFrameSetUpOptions.healthBarHeight = 4 * tonumber(GetCVar("NamePlateVerticalScale"));
	
	for i, frame in ipairs(C_NamePlate.GetNamePlates()) do
		self:ApplyFrameOptions(frame, frame.namePlateUnitToken);
		CompactUnitFrame_UpdateAll(frame.UnitFrame);
	end
end

NamePlateBaseMixin = {};

function NamePlateBaseMixin:OnAdded(namePlateUnitToken)
	self.namePlateUnitToken = namePlateUnitToken;
	
	CompactUnitFrame_SetUnit(self.UnitFrame, namePlateUnitToken);
end

function NamePlateBaseMixin:OnRemoved()
	self.namePlateUnitToken = nil;

	CompactUnitFrame_SetUnit(self.UnitFrame, nil);
end

--------------------------------------------------------------------------------
--
-- Buffs
--
--------------------------------------------------------------------------------

NameplateBuffMixin = {};

function NameplateBuffMixin:OnLoad()
	self.buffList = {};
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
end

function NameplateBuffMixin:OnEvent(event, ...)
	if (event == "PLAYER_TARGET_CHANGED") then
		self:UpdateAnchor();
	end
end

function NameplateBuffMixin:UpdateAnchor()
	local isTarget = self:GetParent().unit and UnitIsUnit(self:GetParent().unit, "target");
	local targetYOffset = isTarget and GetCVar("nameplateResourceOnTarget") == "1" and 18 or 0;
	if (self:GetParent().unit and ShouldShowName(self:GetParent())) then
		self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, targetYOffset);
	else
		self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 5 + targetYOffset);
	end
end

function NameplateBuffMixin:ShouldShowBuff(name, caster, nameplateShowPersonal, nameplateShowAll, duration)
	if (not name or
		GetCVar("nameplateShowBuffs") == "0") then
		return false;
	end
	return nameplateShowAll or 
		   (nameplateShowPersonal and (caster == "player" or caster == "pet" or caster == "vehicle"));
end

function NameplateBuffMixin:UpdateBuffs(unit, filter)
	self.unit = unit;
	self.filter = filter;
	self:UpdateAnchor();
	for i = 1, BUFF_MAX_DISPLAY do
		if (filter == "NONE" and self.buffList[i]) then
			self.buffList[i]:Hide();
			return;
		end
		local name, rank, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura(unit, i, filter);
		if (self:ShouldShowBuff(name, caster, nameplateShowPersonal, nameplateShowAll, duration)) then
			if (not self.buffList[i]) then
				self.buffList[i] = CreateFrame("Frame", self:GetParent():GetName() .. "Buff" .. i, self, "NameplateBuffButtonTemplate");
			end
			local buff = self.buffList[i];
			buff:SetID(i);
			buff.name = name;
			buff.layoutIndex = i;
			buff.Icon:SetTexture(texture);
			if (count > 1) then
				buff.CountFrame.Count:SetText(count);
				buff.CountFrame.Count:Show();
			else
				buff.CountFrame.Count:Hide();
			end
			
			if (duration > 0) then
				buff.Cooldown:Show();
				CooldownFrame_SetTimer(buff.Cooldown, expirationTime - duration, duration, 1);
			else
				buff.Cooldown:Hide();
			end
			
			buff:Show();
		else
			if (self.buffList[i]) then
				self.buffList[i]:Hide();
			end
		end
	end
	self:Layout();
end
