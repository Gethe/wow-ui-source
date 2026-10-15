CenterReticleUtil = {};

function CenterReticleUtil.GetColor()
	return CreateColorFromHexString(GetCVar("SoftTargetReticleColor") or "ffffffff") or CreateColor(1, 1, 1, 1);
end

SimpleCenterReticleMixin = {};

function SimpleCenterReticleMixin:OnLoad()
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:Refresh();
end

function SimpleCenterReticleMixin:OnEvent(event, ...)
	if (event == "CVAR_UPDATE") then
		local cvarName = ...;
		if (cvarName == "SoftTargetReticle") then
			self:Refresh();
		elseif (cvarName == "SoftTargetReticleColor") then
			self:RefreshColor();
		elseif (cvarName == "SoftTargetReticleOffset") then
			self:Recenter();
		end
	elseif (event == "DISPLAY_SIZE_CHANGED") then
		self:Recenter();
	end
end

function SimpleCenterReticleMixin:Refresh()
	self:SetShown(GetCVarBool("SoftTargetReticle"));
	self:Recenter();
	self:RefreshColor();
end

function SimpleCenterReticleMixin:Recenter()
	local offset = Clamp(tonumber(GetCVar("SoftTargetReticleOffset")) or 100, 50, 140);
	self:ClearAllPoints();
	self:SetPoint("CENTER", UIParent, "CENTER", 0, offset);
end

function SimpleCenterReticleMixin:RefreshColor()
	self.Reticle:SetVertexColor(CenterReticleUtil.GetColor():GetRGB());
end
