LandingPageSoulbindButtonMixin = {}

local LandingSoulbindButtonEvents =
{
	"SOULBIND_ACTIVATED",
};

function LandingPageSoulbindButtonMixin:OnEvent(event, ...)
	if event == "SOULBIND_ACTIVATED" then
		local soulbindID = ...;
		local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
		self:SetSoulbind(soulbindData);
	end
end

function LandingPageSoulbindButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, LandingSoulbindButtonEvents);

	local soulbindData = C_Soulbinds.GetSoulbindData(C_Soulbinds.GetActiveSoulbindID());
	self:SetSoulbind(soulbindData);
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
		SoulbindViewer:Open();
	end
end

function LandingPageSoulbindButtonMixin:SetSoulbind(soulbindData)
	local portraitAtlas = ("shadowlands-landingpage-soulbindsbutton-%s"):format(soulbindData.textureKit);
	self.Portrait:SetAtlas(portraitAtlas, true);
	self.Label:SetText(soulbindData.name);
end
