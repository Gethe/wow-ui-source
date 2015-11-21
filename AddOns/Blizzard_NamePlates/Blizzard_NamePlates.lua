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
		local arg1 = ...;
		if arg1 == "SHOW_CLASS_COLOR_IN_V_KEY" then
			self:UpdateNamePlateOptions();
		end
	end
end

function NamePlateDriverMixin:ApplySizes()
	C_NamePlate.SetNamePlateSizes(110, 45);
end

function NamePlateDriverMixin:OnNamePlateCreated(namePlateFrameBase)
	Mixin(namePlateFrameBase, NamePlateBaseMixin);

	CreateFrame("BUTTON", "$parentUnitFrame", namePlateFrameBase, "NamePlateUnitFrameTemplate");
	namePlateFrameBase.UnitFrame:EnableMouse(false);
end

function NamePlateDriverMixin:OnNamePlateAdded(namePlateUnitToken)
	local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken);

	if (UnitIsUnit("player", namePlateUnitToken)) then
		CompactUnitFrame_SetUpFrame(namePlateFrameBase.UnitFrame, DefaultCompactNamePlatePlayerFrameSetup);
	elseif (UnitIsFriend("player", namePlateUnitToken)) then
		CompactUnitFrame_SetUpFrame(namePlateFrameBase.UnitFrame, DefaultCompactNamePlateTargetFriendlyFrameSetup);
	else
		CompactUnitFrame_SetUpFrame(namePlateFrameBase.UnitFrame, DefaultCompactNamePlateTargetEnemyFrameSetup);
	end
	
	namePlateFrameBase:OnAdded(namePlateUnitToken);
	self:SetupClassNameplateBars();
	
	self:OnUnitAuraUpdate(namePlateUnitToken);
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

function NamePlateDriverMixin:SetupClassNameplateBar(mode, bar)
	if (not bar) then
		return;
	end
	
	bar:Hide();
	if (mode == "0") then
		return;
	end
	
	local healthResourceAlpha = GetCVar("nameplateBarAlpha");
	bar:SetAlpha(healthResourceAlpha);
	local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player");
	if (namePlatePlayer) then
		namePlatePlayer.UnitFrame.healthBar:SetAlpha(healthResourceAlpha);
	end
	
	if (mode == "1" and NamePlateTargetResourceFrame) then
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
	elseif (mode == "2" and NamePlatePlayerResourceFrame) then
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
	local mode = GetCVar("nameplateBarMode");
	self:SetupClassNameplateBar(mode, self.nameplateBar);
	
	local mode = GetCVar("nameplateManaBarMode");
	self:SetupClassNameplateBar(mode, self.nameplateManaBar);
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
	if (GetCVarBool("ShowClassColorInNameplate")) then
		DefaultCompactNamePlateTargetEnemyFrameOptions.colorHealthBySelection = false;
		DefaultCompactNamePlateTargetEnemyFrameOptions.useClassColors = true;
	else
		DefaultCompactNamePlateTargetEnemyFrameOptions.colorHealthBySelection = true;
		DefaultCompactNamePlateTargetEnemyFrameOptions.useClassColors = false;
	end
	
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
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
	if (self:GetParent().unit and ShouldShowName(self:GetParent())) then
		self:SetPoint("BOTTOM", self:GetParent(), "TOP");
	else
		self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 5);
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
