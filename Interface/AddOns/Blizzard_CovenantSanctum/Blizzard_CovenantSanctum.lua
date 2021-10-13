CovenantSanctumMixin = {};

local TAB_UPGRADES = 1;
local TAB_RENOWN = 2;

function CovenantSanctumMixin:OnLoad()
	PanelTemplates_SetNumTabs(self, 2);

	local attributes =
	{
		area = "center",
		pushable = 0,
		allowOtherPanels = 0,
	};
	RegisterUIPanel(CovenantSanctumFrame, attributes);
end

local CovenantSanctumEvents = {
	"COVENANT_SANCTUM_INTERACTION_ENDED",
};

function CovenantSanctumMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CovenantSanctumEvents);

	PlaySound(SOUNDKIT.UI_COVENANT_SANCTUM_OPEN_WINDOW);
end

function CovenantSanctumMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CovenantSanctumEvents);

	C_CovenantSanctumUI.EndInteraction();

	PlaySound(SOUNDKIT.UI_COVENANT_SANCTUM_CLOSE_WINDOW);
end

function CovenantSanctumMixin:OnEvent(event, ...)
	if event == "COVENANT_SANCTUM_INTERACTION_STARTED" then
		self:SetCovenantInfo();
		ShowUIPanel(self);
	elseif event == "COVENANT_SANCTUM_INTERACTION_ENDED" then
		HideUIPanel(self);
	end
end

function CovenantSanctumMixin:SetCovenantInfo()
	local covenantID = C_Covenants.GetActiveCovenantID();
	if covenantID ~= self.covenantID then
		self.covenantID = covenantID;
		self.covenantData = C_Covenants.GetCovenantData(covenantID);
		NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, self.covenantData.textureKit);
		NineSliceUtil.DisableSharpening(self.NineSlice);

		local atlas = "CovenantSanctum-Level-Border-%s";
		local useAtlasSize = true;
		self.LevelFrame.Background:SetAtlas(atlas:format(self.covenantData.textureKit), useAtlasSize);

		UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-%s-ExitButtonBorder", -1, 1, self.covenantData.textureKit);
	end
end

function CovenantSanctumMixin:GetCovenantID()
	return self.covenantID;
end

function CovenantSanctumMixin:GetCovenantData()
	return self.covenantData;
end