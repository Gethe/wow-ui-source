----------------------------------------------------------------------------------
-- CatalogShopAlteredFormButtonMixin
----------------------------------------------------------------------------------
CatalogShopAlteredFormButtonMixin = CreateFromMixins(SelectableButtonMixin);
function CatalogShopAlteredFormButtonMixin:OnLoad()
	RingedMaskedButtonMixin.OnLoad(self);
	SelectableButtonMixin.OnLoad(self);
end

function CatalogShopAlteredFormButtonMixin:OnSelected(newSelected)
	self:SetChecked(newSelected);
	self:UpdateHighlightTexture();
end

function CatalogShopAlteredFormButtonMixin:SetupAlteredFormButton(data, isNativeForm)
	self.isNativeForm = isNativeForm;
	self:SetIconAtlas(data.createScreenIconAtlas);

	self:ClearTooltipLines();
	self:AddTooltipLine(CHARACTER_FORM:format(data.name));
end

function CatalogShopAlteredFormButtonMixin:GetAppropriateTooltip()
	return CatalogShopTooltip;
end

function CatalogShopAlteredFormButtonMixin:OnClick()
	-- Clicking a button after it has already been clicked should have no effect.
	-- The only way to deselect a button is to click the other button in the group.
	self:SetChecked(true);
	SelectableButtonMixin.SetSelected(self, true);

	PlaySound(SOUNDKIT.CATALOG_SHOP_SELECT_GENERIC_UI_BUTTON);
end


----------------------------------------------------------------------------------
-- CatalogShopModelSceneContainerFrameMixin
----------------------------------------------------------------------------------
CatalogShopModelSceneContainerFrameMixin = {};
function CatalogShopModelSceneContainerFrameMixin:OnLoad()

end

function CatalogShopModelSceneContainerFrameMixin:OnShow()
	if C_Glue.IsOnGlueScreen() then
		self.hasAlternateForm = false;
	else
		self.hasAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
	end

	if self.hasAlternateForm and not self.formButtonsInitialized then
		local characterInfo = C_PlayerInfo.GetPlayerCharacterData();
		if characterInfo then
			self.NormalFormButton:SetupAlteredFormButton(characterInfo, true);
			self.AlternateFormButton:SetupAlteredFormButton(characterInfo.alternateFormRaceData, false);

			self.buttonGroup = CreateRadioButtonGroup();
			self.buttonGroup:AddButton(self.NormalFormButton);
			self.buttonGroup:AddButton(self.AlternateFormButton);
			local defaultIndex = 1;
			self.buttonGroup:SelectAtIndex(defaultIndex);
			self.buttonGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.OnFormSelected, self);

			self.formButtonsInitialized = true;
		end
	end
	local forceSceneChange = true;
end

function CatalogShopModelSceneContainerFrameMixin:UpdateFormButtonVisibility(forceHideFormButtons)
	if forceHideFormButtons then
		self.NormalFormButton:Hide();
		self.AlternateFormButton:Hide();
		return;
	end

	local showFormButtons = false;
	if self.hasAlternateForm then
		showFormButtons = true;
	end
	self.NormalFormButton:SetShown(showFormButtons);
	self.AlternateFormButton:SetShown(showFormButtons);
end

function CatalogShopModelSceneContainerFrameMixin:OnFormSelected(button, buttonIndex)
	EventRegistry:TriggerEvent("CatalogShop.OnFormChanged", button.isNativeForm);
end

function CatalogShopModelSceneContainerFrameMixin:Init()
	EventRegistry:RegisterCallback("CatalogShop.OnProductSelected", self.OnProductSelected, self);
	EventRegistry:RegisterCallback("CatalogShop.OnFormChanged", self.OnFormChanged, self);
	EventRegistry:RegisterCallback("CatalogShop.CelebratePurchase", self.OnCelebratePurchase, self);
	EventRegistry:RegisterCallback("CatalogShopModel.AfterTransmogActorLoadedCheckCarousel", self.AfterTransmogActorLoadedCheckCarousel, self);
	EventRegistry:RegisterCallback("CatalogShopModel.AfterTransmogActorLoaded", self.AfterTransmogActorLoaded, self);
end

function CatalogShopModelSceneContainerFrameMixin:OnCelebratePurchase(catalogShopProductID)
	if self.currentData.catalogShopProductID ~= catalogShopProductID then
		return;
	end

	if self.CelebrateTimer then
		self.CelebrateTimer:Cancel();
		self.CelebrateTimer = nil;
	end

	local fanfareActor = self.MainModelScene:GetActorByTag(CatalogShopConstants.DefaultActorTag.Celebrate);
	if fanfareActor then
		local camera = self.MainModelScene:GetActiveCamera();
		if camera then
			local x, y, z = camera:GetTarget();
			fanfareActor:SetPosition(x, y, 0);
		end

		fanfareActor:SetModelByCreatureDisplayID(CatalogShopConstants.Celebrate.CreatureID);
		fanfareActor:SetSpellVisualKit(CatalogShopConstants.Celebrate.SpellVisualID, true);
		PlaySound(SOUNDKIT.CATALOG_SHOP_UI_PURCHASE_CELEBRATION);

		self.CelebrateTimer = C_Timer.NewTimer(5,
		function()
			fanfareActor:SetSpellVisualKit(nil);
			self.CelebrateTimer = nil;
		end);
	else
		local startOffset = 0.0;
		PlaySound(SOUNDKIT.CATALOG_SHOP_UI_PURCHASE_BUNDLE_FANFARE_START);
		for tag, taggedActor in pairs(self.MainModelScene.tagToActor) do
			if taggedActor and taggedActor:IsLoaded() then
				taggedActor.CelebrateTimerStart = C_Timer.NewTimer(startOffset,
				function()
					taggedActor:SetSpellVisualKit(CatalogShopConstants.Celebrate.SpellVisualID, true);
					PlaySound(SOUNDKIT.CATALOG_SHOP_UI_PURCHASE_BUNDLE_FANFARE_OFFSET);
					taggedActor.CelebrateTimerStart = nil;
				end);
				startOffset = startOffset + 0.25;

				taggedActor.CelebrateTimerEnd = C_Timer.NewTimer(5 + startOffset,
				function()
					taggedActor:SetSpellVisualKit(nil);
					taggedActor.CelebrateTimerEnd = nil;
				end);
			end
		end
	end
end

function CatalogShopModelSceneContainerFrameMixin:UpdatePlayerModel(data)
	self.currentData = data;
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(data.catalogShopProductID);
	local displayData = self.currentData.sceneDisplayData;
	local productType = displayInfo.productType;
	if productType == CatalogShopConstants.ProductType.Bundle then
		local forceSceneChange = false;
		local preserveCurrentView = true;
		self:OnProductSelected(data, forceSceneChange, preserveCurrentView);
	elseif productType == CatalogShopConstants.ProductType.Mount then
		local modelScene = self.MainModelScene;
		local playerActor = modelScene:GetPlayerActor("player-rider");
		local mountActor = modelScene:GetActorByTag(CatalogShopConstants.DefaultActorTag.Mount);
		if (playerActor and mountActor) then
			mountActor:DetachFromMount(playerActor);
			playerActor:ClearModel();
			local isSelfMount = false;
			local disablePlayerMountPreview = false; -- some mounts are flagged to not show the player on the mount - this is static data we need to fetch
			local spellVisualInfo = C_CatalogShop.GetSpellVisualInfoForMount(displayData.spellVisualID);
			local spellVisualKitID = spellVisualInfo and spellVisualInfo.spellVisualKitID or nil;
			local animID = spellVisualInfo and spellVisualInfo.animID or nil;
			local useNativeForm = CatalogShopFrame:GetUseNativeForm();
			modelScene:AttachPlayerToMount(mountActor, animID, isSelfMount, disablePlayerMountPreview, spellVisualKitID, useNativeForm);
		end
	elseif productType == CatalogShopConstants.ProductType.Transmog then
		local forceSceneChange = false;
		local preserveCurrentView = true;
		self:OnProductSelected(data, forceSceneChange, preserveCurrentView);
	end
end

local DefaultInsets = {left=80, right=0, top=0, bottom=0};
function CatalogShopModelSceneContainerFrameMixin:OnProductSelected(data, forceSceneChange, preserveCurrentView)
	if not self:IsShown() then
		EventRegistry:TriggerEvent("CatalogShopModel.OnProductSelectEarlyOut", data);
		return;
	end

	local oldData = self.currentData;
	self.currentData = data;

	local dataHasChanged = true;
	local shouldSetupModelScene = forceSceneChange or dataHasChanged;
	local forceHideFormButtons = false;
	local currentActor;
	local modelScene = self.MainModelScene;

	modelScene:SetViewInsets(DefaultInsets.left, DefaultInsets.right, DefaultInsets.top, DefaultInsets.bottom);

	if shouldSetupModelScene then
		local modelLoadedCB = CatalogShopModelSceneContainerFrameMixin.AfterTransmogActorLoaded;
		local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(data.catalogShopProductID);
		local defaultModelSceneID = displayInfo.defaultPreviewModelSceneID;
		local displayData = self.currentData.sceneDisplayData;
		local productType = displayInfo.productType;

		CatalogShopUtil.ClearSpecialActors(modelScene)

		displayData.fallbackPMTImageURL = displayInfo.productPMTURL;
		displayData.modelSceneContext = CatalogShopConstants.ModelSceneContext.PreviewScene;
		if productType == CatalogShopConstants.ProductType.Bundle then
			forceHideFormButtons = true;
			if defaultModelSceneID > 0 then
				local forceHidePlayer = false;
				local bestActorTag = CatalogShopUtil.SetupModelSceneForBundle(modelScene, defaultModelSceneID, displayData, modelLoadedCB, forceHidePlayer);
				modelScene:Show();
				currentActor = modelScene:GetActorByTag(bestActorTag);
			else
				modelScene:Hide();
			end
		else
			if productType == CatalogShopConstants.ProductType.Mount then
				forceSceneChange = true;--forceSceneChange or self.previousMainModelSceneID ~= defaultModelSceneID;
				CatalogShopUtil.SetupModelSceneForMounts(modelScene, defaultModelSceneID, displayData, modelLoadedCB, forceSceneChange, forceHidePlayer);
				modelScene:Show();
				currentActor = modelScene:GetActorByTag(CatalogShopConstants.DefaultActorTag.Mount);
				self.previousMainModelSceneID = defaultModelSceneID;
			elseif productType == CatalogShopConstants.ProductType.Pet then
				forceSceneChange = true;--forceSceneChange or self.previousMainModelSceneID ~= defaultModelSceneID;
				CatalogShopUtil.SetupModelSceneForPets(modelScene, defaultModelSceneID, displayData, modelLoadedCB, forceSceneChange);
				modelScene:Show();
				self.previousMainModelSceneID = defaultModelSceneID;
				forceHideFormButtons = true;
				currentActor = modelScene:GetActorByTag(CatalogShopConstants.DefaultActorTag.Pet);
			elseif productType == CatalogShopConstants.ProductType.Transmog then --transmogs
				if forceSceneChange == nil then
					forceSceneChange = true;
				end
				modelLoadedCB = CatalogShopModelSceneContainerFrameMixin.AfterTransmogActorLoadedCheckCarousel;
				CatalogShopUtil.SetupModelSceneForTransmogs(modelScene, defaultModelSceneID, displayData, modelLoadedCB, forceSceneChange, preserveCurrentView);
				modelScene:Show();
				currentActor = modelScene.CachedPlayerActor;
			elseif productType == CatalogShopConstants.ProductType.Decor then
				forceSceneChange = true;--forceSceneChange or self.previousMainModelSceneID ~= defaultModelSceneID;
				CatalogShopUtil.SetupModelSceneForDecor(modelScene, defaultModelSceneID, displayData, modelLoadedCB, forceSceneChange);
				modelScene:Show();
				self.previousMainModelSceneID = defaultModelSceneID;
				forceHideFormButtons = true;
				currentActor = modelScene:GetActorByTag(CatalogShopConstants.DefaultActorTag.Decor);
			else
				modelScene:Hide();
				forceHideFormButtons = true;
			end
			CatalogShopFrame:SetCurrentActor(currentActor);
		end
		if CatalogShopUtil.HasSpecialActors(displayData) then
			CatalogShopUtil.SetupSpecialActors(displayData, modelScene);
		end
		local appliesOverrideActorPosition = productType ~= CatalogShopConstants.ProductType.Transmog;
		CatalogShopFrame:SetCurrentModelSceneData(modelScene, defaultModelSceneID, displayInfo.overridePreviewModelSceneID, appliesOverrideActorPosition, currentActor);
	end
	self:UpdateFormButtonVisibility(forceHideFormButtons);
	EventRegistry:TriggerEvent("CatalogShopModel.OnProductSelectedAfterModel", self.currentData);
end

function CatalogShopModelSceneContainerFrameMixin:OnFormChanged(useNativeForm)
	CatalogShopFrame:SetUseNativeForm(useNativeForm);
	if self.currentData then
		self:UpdatePlayerModel(self.currentData);
	end
end

function CatalogShopModelSceneContainerFrameMixin.AfterTransmogActorLoadedCheckCarousel(modelScene, actor, data)
	EventRegistry:TriggerEvent("CatalogShopModel.TransmogLoaded.CheckCarousel", modelScene, actor, data);
end

function CatalogShopModelSceneContainerFrameMixin.AfterTransmogActorLoaded(modelScene, actor, data)
	EventRegistry:TriggerEvent("CatalogShopModel.TransmogLoaded.HideCarousel");
end
