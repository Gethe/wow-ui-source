CovenantSanctumMixin = {};

function CovenantSanctumMixin:OnLoad()
	local attributes =
	{
		area = "center",
		pushable = 0,
		allowOtherPanels = 0,
	};
	RegisterUIPanel(CovenantSanctumFrame, attributes);
end

function CovenantSanctumMixin:OnShow()
	PlaySound(SOUNDKIT.UI_COVENANT_SANCTUM_OPEN_WINDOW);
end

function CovenantSanctumMixin:OnHide()
	C_CovenantSanctumUI.EndInteraction();

	PlaySound(SOUNDKIT.UI_COVENANT_SANCTUM_CLOSE_WINDOW);
end

function CovenantSanctumMixin:InteractionStarted() 
	self:SetCovenantInfo();
	ShowUIPanel(self);
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