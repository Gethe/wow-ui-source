LandingPageSoulbindButtonMixin = {}

local LandingSoulbindButtonEvents =
{
	"SOULBIND_ACTIVATED",
};

function LandingPageSoulbindButtonMixin:OnEvent(event, ...)
	if event == "SOULBIND_ACTIVATED" then
		local soulbindID = ...;
		if soulbindID > 0 then
			local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
			self:SetSoulbind(soulbindData);
		end
	end
end

function LandingPageSoulbindButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, LandingSoulbindButtonEvents);

	local soulbindID = C_Soulbinds.GetActiveSoulbindID();
	if soulbindID > 0 then
		self:SetSoulbind(C_Soulbinds.GetSoulbindData(soulbindID));

		if not GetCVarBool("soulbindsLandingPageTutorial") then
			self:ShowHelpTip();
		end
	end
end

function LandingPageSoulbindButtonMixin:ShowHelpTip()
	local helpTipInfo = {
		text = SOULBIND_LANDING_BUTTON_TUTORIAL,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		cvar = "soulbindsLandingPageTutorial",
		cvarValue = 1,
	};

	HelpTip:Show(self, helpTipInfo, self);
end

function LandingPageSoulbindButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, LandingSoulbindButtonEvents);
end

function LandingPageSoulbindButtonMixin:OnEnter()
	self.Highlight:Show();
end

function LandingPageSoulbindButtonMixin:OnLeave()
	self.Highlight:Hide();
end

function LandingPageSoulbindButtonMixin:OnMouseDown()
	self.Press:Show();
end

function LandingPageSoulbindButtonMixin:OnMouseUp()
	self.Press:Hide();
end

function LandingPageSoulbindButtonMixin:OnClick()
	if UIParentLoadAddOn("Blizzard_Soulbinds") then
		SetCVar("soulbindsLandingPageTutorial", true);
		SoulbindViewer:Open();
	end
end

function LandingPageSoulbindButtonMixin:SetSoulbind(soulbindData)
	local portraitAtlas = ("shadowlands-landingpage-soulbindsbutton-%s"):format(soulbindData.textureKit);
	self.Portrait:SetAtlas(portraitAtlas, true);
	self.Label:SetText(soulbindData.name);
end
