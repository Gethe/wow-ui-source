LandingPageSoulbindButtonMixin = {}

local LandingSoulbindButtonEvents =
{
	"SOULBIND_ACTIVATED",
};

function LandingPageSoulbindButtonMixin:OnEvent(event, ...)
	if event == "SOULBIND_ACTIVATED" then
		local soulbindID = ...;
		local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
		self:Init(soulbindData);
	end
end

function LandingPageSoulbindButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, LandingSoulbindButtonEvents);

	local soulbindData = C_Soulbinds.GetSoulbindData(C_Soulbinds.GetActiveSoulbindID());
	self:Init(soulbindData);
end

function LandingPageSoulbindButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, LandingSoulbindButtonEvents);
end

function LandingPageSoulbindButtonMixin:OnClick()
	if UIParentLoadAddOn("Blizzard_Soulbinds") then
		SoulbindViewer:Open();
	end
end

function LandingPageSoulbindButtonMixin:Init(soulbindData)
	self.Portrait:SetAtlas(string.format("LandingSoulbindButtonPortrait_%s", soulbindData.textureKit), true);
	self.Label:SetText(soulbindData.name);
end
