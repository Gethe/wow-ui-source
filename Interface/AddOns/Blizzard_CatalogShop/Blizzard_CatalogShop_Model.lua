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
	SelectableButtonMixin.OnClick(self);
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
	self:UpdateFormButtonVisibility();

	local forceSceneChange = true;
end


function CatalogShopModelSceneContainerFrameMixin:OnUpdate()
	local modelSceneData = CatalogShopFrame:GetCurrentModelSceneData();
	if self.currentData and self.currentData.isBundle then
		local displayData = self.currentData.sceneDisplayData;
		self.UpdateBundleVisuals(modelSceneData.modelScene, displayData);
	else
		local actor = CatalogShopFrame:GetCurrentActor();
		self.UpdateActorVisuals(modelSceneData.modelScene, actor);
	end
end

function CatalogShopModelSceneContainerFrameMixin:UpdateFormButtonVisibility(forceHideButtons)
	if forceHideButtons then
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
			fanfareActor:SetPosition(x, y, -1);
		end

		fanfareActor:SetModelByCreatureDisplayID(CatalogShopConstants.Celebrate.CreatureID);
		fanfareActor:SetSpellVisualKit(CatalogShopConstants.Celebrate.SpellVisualID, true);
		PlaySound(SOUNDKIT.CATALOG_SHOP_UI_PURCHASE_CELEBRATION);

		self.CelebrateTimer = C_Timer.NewTimer(5,
		function()
			fanfareActor:SetSpellVisualKit(nil);
			self.CelebrateTimer = nil;
		end);
	end
end

function CatalogShopModelSceneContainerFrameMixin:UpdatePlayerModel(data)
	self.currentData = data;
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(data.catalogShopProductID);
	local displayData = self.currentData.sceneDisplayData;
	local productCardType = displayInfo.productType;
	if productCardType == CatalogShopConstants.ProductCardType.Bundle then
		local forceSceneChange = false;
		local preserveCurrentView = true;
		self:OnProductSelected(data, forceSceneChange, preserveCurrentView);
	elseif productCardType == CatalogShopConstants.ProductCardType.Mount then
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
	elseif productCardType == CatalogShopConstants.ProductCardType.Transmog then
		local forceSceneChange = false;
		local preserveCurrentView = true;
		self:OnProductSelected(data, forceSceneChange, preserveCurrentView);
	end
end

local DefaultInsets = {left=80, right=0, top=0, bottom=0};
function CatalogShopModelSceneContainerFrameMixin:OnProductSelected(data, forceSceneChange, preserveCurrentView)
	local oldData = self.currentData;
	self.currentData = data;

	local dataHasChanged = true;
	local shouldSetupModelScene = forceSceneChange or dataHasChanged;
	local forceHideButtons = false;
	local currentActor;
	local modelScene = self.MainModelScene;

	modelScene:SetViewInsets(DefaultInsets.left, DefaultInsets.right, DefaultInsets.top, DefaultInsets.bottom);

	if shouldSetupModelScene then
		local modelLoadedCB = CatalogShopModelSceneContainerFrameMixin.UpdateActorVisuals;
		local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(data.catalogShopProductID);
		local defaultModelSceneID = displayInfo.defaultPreviewModelSceneID;
		local displayData = self.currentData.sceneDisplayData;
		local productCardType = displayInfo.productType;

		self.WatermarkLogoTexture:Hide();

		if productCardType == CatalogShopConstants.ProductCardType.Bundle then
			local forceHidePlayer = false;
			local bestActorTag = CatalogShopUtil.SetupModelSceneForBundle(modelScene, defaultModelSceneID, displayData, modelLoadedCB, forceHidePlayer);
			modelScene:Show();
			currentActor = modelScene:GetActorByTag(bestActorTag);
		else
			-- An Unknown License implies we have a product from Catalog that isn't known by our server (it was returned as a missing license)
			-- So in this case we are currently assuming this means the product is for another game (which could be another flavor of WoW)
			if displayInfo.hasUnknownLicense then
				modelScene:Hide();
				forceHideButtons = true;
				self.WatermarkLogoTexture:Show();
				CatalogShopUtil.SetAlternateProductIcon(self.WatermarkLogoTexture, displayInfo);
			elseif productCardType == CatalogShopConstants.ProductCardType.Mount then
				forceSceneChange = true;--forceSceneChange or self.previousMainModelSceneID ~= defaultModelSceneID;
				CatalogShopUtil.SetupModelSceneForMounts(modelScene, defaultModelSceneID, displayData, modelLoadedCB, forceSceneChange, forceHidePlayer);
				modelScene:Show();
				currentActor = modelScene:GetActorByTag(CatalogShopConstants.DefaultActorTag.Mount);
				self.previousMainModelSceneID = defaultModelSceneID;
			elseif productCardType == CatalogShopConstants.ProductCardType.Pet then
				forceSceneChange = true;--forceSceneChange or self.previousMainModelSceneID ~= defaultModelSceneID;
				CatalogShopUtil.SetupModelSceneForPets(modelScene, defaultModelSceneID, displayData, modelLoadedCB, forceSceneChange);
				modelScene:Show();
				self.previousMainModelSceneID = defaultModelSceneID;
				forceHideButtons = true;
				currentActor = modelScene:GetActorByTag(CatalogShopConstants.DefaultActorTag.Pet);
			elseif productCardType == CatalogShopConstants.ProductCardType.Transmog then --transmogs
				if forceSceneChange == nil then
					forceSceneChange = true;
				end
				CatalogShopUtil.SetupModelSceneForTransmogs(modelScene, defaultModelSceneID, displayData, modelLoadedCB, forceSceneChange, preserveCurrentView);
				modelScene:Show();
				currentActor = modelScene.CachedPlayerActor;
			else
				modelScene:Hide();
				forceHideButtons = true;
			end
			CatalogShopFrame:SetCurrentActor(currentActor);
			CatalogShopFrame:SetCurrentModelSceneData(modelScene, defaultModelSceneID, displayInfo.overridePreviewModelSceneID);
		end
	end
	self:UpdateFormButtonVisibility(forceHideButtons);
	EventRegistry:TriggerEvent("CatalogShopModel.OnProductSelectedAfterModel", self.currentData);
end

function CatalogShopModelSceneContainerFrameMixin:OnFormChanged(useNativeForm)
	CatalogShopFrame:SetUseNativeForm(useNativeForm);
	if self.currentData then
		self:UpdatePlayerModel(self.currentData);
	end
end

function CatalogShopModelSceneContainerFrameMixin.UpdateActorVisuals(modelScene, actor)
	CatalogShopModelSceneContainerFrameMixin.UpdateDropShadowForSingleActor(modelScene, actor);
end

function CatalogShopModelSceneContainerFrameMixin.UpdateDropShadowForSingleActor(modelScene, actor)
	local modelFrame = modelScene and modelScene.ModelFrame;
	local dropShadow = modelFrame and modelFrame.dropShadow;
	if actor and modelFrame and dropShadow then
		local bottomX, bottomY, bottomZ, topX, topY, topZ = actor:GetActiveBoundingBox();

		if not topX then
			dropShadow:Hide();
			return;
		end
		dropShadow:Show();

		local camera = modelScene:GetActiveCamera();
		local targetX, targetY, targetZ = camera:GetDerivedTarget();
		local camZoomPct = camera:GetZoomPercent();

		local actorScale = actor:GetScale();
		
		-- The center of the bounding box is important for making a reference to move points in bounding box space into model frame space
		local boundBoxCenterX = (topX + bottomX) * 0.5
		local boundBoxCenterY = (topY + bottomY) * 0.5
		local boundBoxCenterZ = (topZ + bottomZ) * 0.5

		-- We want the 4 points that make up the bottom of the bounding box (this is the rectangle around the feet of the model)
		-- These are then put in to screen space
		local point1x, point1y, _ = modelScene:Transform3DPointTo2D(topX*actorScale,		topY*actorScale,		bottomZ*actorScale);
		local point2x, point2y, _ = modelScene:Transform3DPointTo2D(topX*actorScale,		bottomY*actorScale,		bottomZ*actorScale);
		local point3x, point3y, _ = modelScene:Transform3DPointTo2D(bottomX*actorScale,		topY*actorScale,		bottomZ*actorScale);
		local point4x, point4y, _ = modelScene:Transform3DPointTo2D(bottomX*actorScale,		bottomY*actorScale,		bottomZ*actorScale);

		local modelSceneOffsetX = modelScene.frameOffsetX or 0;
		local modelSceneOffsetY = modelScene.frameOffsetY or 0;

		local actorPos = CreateVector3D(actor:GetPosition());
		-- Through experimentation it was found that ScaleBy doesn't work as expected.
		--actorPos:ScaleBy(actor:GetScale());
		local actorPosX, actorPosY, actorPosZ = actorPos:GetXYZ();
		actorPosX = actorPosX * actorScale;
		actorPosY = actorPosY * actorScale;
		actorPosZ = actorPosZ * actorScale;

		local actorDerivedPosX = actorPosX;
		local actorDerivedPosY = actorPosY;
		local actorDerivedPosZ = actorPosZ;
		local targetCamSpline = camera:GetTargetSpline();
		if targetCamSpline then
			actorDerivedPosX, actorDerivedPosY, actorDerivedPosZ = Vector3D_Add(actorPosX, actorPosY, actorPosZ, targetCamSpline:CalculatePointOnGlobalCurve(1.0 - camera:GetZoomPercent()));
		end

		local actorPosScreenSpaceX, actorPosScreenSpaceY, _ = modelScene:Transform3DPointTo2D(actorDerivedPosX, actorDerivedPosY, actorDerivedPosZ);
		
		local camTargetX, camTargetY, _ = modelScene:Transform3DPointTo2D(targetX, targetY, targetZ);
		local yShift = camTargetY - actorPosScreenSpaceY;

		-- Build an offset from the actor's position (in screen space) to the center of the frame to compensate for centering
		local iLeft, iRight, iTop, iBottom = modelScene:GetViewInsets();
		local frameWidth = modelFrame:GetWidth();
		local frameHeight = modelFrame:GetHeight();

		frameWidth = (frameWidth - iLeft) - iRight;
		frameHeight = (frameHeight - iBottom) - iTop;

		local frameOffsetX = (frameWidth * 0.5) - actorPosScreenSpaceX;
		local frameOffsetY = (frameHeight * 0.5) - actorPosScreenSpaceY;

		-- Circumscribe a rectangle around the parallelogram made when we projected the ground plane of the bounding box in to screen space
		local left		= math.min( math.min(point1x, point2x), math.min(point3x, point4x) );
		local right		= math.max( math.max(point1x, point2x), math.max(point3x, point4x) );
		local top		= math.max( math.max(point1y, point2y), math.max(point3y, point4y) );
		local bottom	= math.min( math.min(point1y, point2y), math.min(point3y, point4y) );
		
		-- An absolute vertical fudge value to make the shadow fit more correctly under the actor (versus just using the actor's origin)
		local yFudgeAmount = -50;

		-- Fudge values for adjusting the overall size of the shadow (value is applied in both directions, doubling its effect)
		local shadowSizeYFudge = 75;
		local shadowSizeXFudge = 225;

		yShift = (frameOffsetY - yShift) + yFudgeAmount;

		local screenSpaceOffsetsX = 100 + iLeft;	-- RNM : This is fixed, but may want to eventually be affected by camZoomPct
		local screenSpaceOffsetsY = yShift;

		left	= left		+	screenSpaceOffsetsX		-	shadowSizeXFudge;
		right	= right		+	screenSpaceOffsetsX		+	shadowSizeXFudge;
		top		= top		+	screenSpaceOffsetsY		+	shadowSizeYFudge;
		bottom	= bottom	+	screenSpaceOffsetsY		-	shadowSizeYFudge;

		dropShadow:ClearAllPoints();
		dropShadow:SetPoint("BOTTOMLEFT", modelFrame, "BOTTOMLEFT", left, bottom);
		dropShadow:SetPoint("TOPRIGHT", modelFrame, "BOTTOMLEFT", right, top);
	end
end

function CatalogShopModelSceneContainerFrameMixin.UpdateBundleVisuals(modelScene, displayData)
	CatalogShopModelSceneContainerFrameMixin.UpdateDropShadowForBundle(modelScene, displayData);
end


function CatalogShopModelSceneContainerFrameMixin.UpdateDropShadowForBundle(modelScene, displayData)
	local modelFrame = modelScene and modelScene.ModelFrame;
	local dropShadow = modelFrame and modelFrame.dropShadow;
	if displayData and modelFrame and dropShadow then
		if not displayData.actorDisplayBucket or #displayData.actorDisplayBucket <= 0 then
			dropShadow:Hide();
			return;
		end
		dropShadow:Show();

		local minX = 999;
		local minY = 999;
		local minZ = 999;
		local sumX = 0;
		local sumY = 0;
		local sumZ = 0;
		local maxX = -999;
		local maxY = -999;
		local maxZ = -999;

		for _, actorDisplay in ipairs(displayData.actorDisplayBucket) do
			minX = min(minX, actorDisplay.actorX);
			minY = min(minY, actorDisplay.actorY);
			minZ = min(minZ, actorDisplay.actorZ);

			sumX = sumX + actorDisplay.actorX;
			sumY = sumY + actorDisplay.actorY;
			sumZ = sumZ + actorDisplay.actorZ;

			maxX = max(maxX, actorDisplay.actorX);
			maxY = max(maxY, actorDisplay.actorY);
			maxZ = max(maxZ, actorDisplay.actorZ);
		end

		local avgX = sumX / #displayData.actorDisplayBucket;
		local avgY = sumY / #displayData.actorDisplayBucket;
		local avgZ = sumZ / #displayData.actorDisplayBucket;

		local camera = modelScene:GetActiveCamera();
		local targetX, targetY, targetZ = camera:GetDerivedTarget();
		local camZoomPct = camera:GetZoomPercent();

		-- We want the 4 points that make up the bottom of the bounding box (this is the rectangle around the feet of the model)
		-- These are then put in to screen space
		local point1x, point1y, _ = modelScene:Transform3DPointTo2D(maxX,		maxY,		minZ);
		local point2x, point2y, _ = modelScene:Transform3DPointTo2D(maxX,		minY,		minZ);
		local point3x, point3y, _ = modelScene:Transform3DPointTo2D(minX,		maxY,		minZ);
		local point4x, point4y, _ = modelScene:Transform3DPointTo2D(minX,		minY,		minZ);

		local modelSceneOffsetX = modelScene.frameOffsetX or 0;
		local modelSceneOffsetY = modelScene.frameOffsetY or 0;

		local actorDerivedPosX = avgX;
		local actorDerivedPosY = avgY;
		local actorDerivedPosZ = avgZ;
		local targetCamSpline = camera:GetTargetSpline();
		if targetCamSpline then
			actorDerivedPosX, actorDerivedPosY, actorDerivedPosZ = Vector3D_Add(avgX, avgY, avgZ, targetCamSpline:CalculatePointOnGlobalCurve(1.0 - camera:GetZoomPercent()));
		end

		local actorPosScreenSpaceX, actorPosScreenSpaceY, _ = modelScene:Transform3DPointTo2D(actorDerivedPosX, actorDerivedPosY, actorDerivedPosZ);
		local camTargetX, camTargetY, _ = modelScene:Transform3DPointTo2D(targetX, targetY, targetZ);
		local yShift = camTargetY - actorPosScreenSpaceY;

		-- Build an offset from the actor's position (in screen space) to the center of the frame to compensate for centering
		local iLeft, iRight, iTop, iBottom = modelScene:GetViewInsets();
		local frameWidth = modelFrame:GetWidth();
		local frameHeight = modelFrame:GetHeight();

		frameWidth = (frameWidth - iLeft) - iRight;
		frameHeight = (frameHeight - iBottom) - iTop;

		local frameOffsetY = (frameHeight * 0.5) - actorPosScreenSpaceY;

		-- Circumscribe a rectangle around the parallelogram made when we projected the ground plane of the bounding box in to screen space
		local left		= math.min( math.min(point1x, point2x), math.min(point3x, point4x) );
		local right		= math.max( math.max(point1x, point2x), math.max(point3x, point4x) );
		local top		= math.max( math.max(point1y, point2y), math.max(point3y, point4y) );
		local bottom	= math.min( math.min(point1y, point2y), math.min(point3y, point4y) );
		
		-- An absolute vertical fudge value to make the shadow fit more correctly under the actor (versus just using the actor's origin)
		local yFudgeAmount = 50;

		-- Fudge values for adjusting the overall size of the shadow (value is applied in both directions, doubling its effect)
		local shadowSizeYFudge = 75;
		local shadowSizeXFudge = 225;

		yShift = (frameOffsetY - yShift) + yFudgeAmount;

		local screenSpaceOffsetsX = 100 + iLeft;	-- RNM : This is fixed, but may want to eventually be affected by camZoomPct
		local screenSpaceOffsetsY = yShift;

		left	= left		+	screenSpaceOffsetsX		-	shadowSizeXFudge;
		right	= right		+	screenSpaceOffsetsX		+	shadowSizeXFudge;
		top		= top		+	screenSpaceOffsetsY		+	shadowSizeYFudge;
		bottom	= bottom	+	screenSpaceOffsetsY		-	shadowSizeYFudge;

		dropShadow:ClearAllPoints();
		dropShadow:SetPoint("BOTTOMLEFT", modelFrame, "BOTTOMLEFT", left, bottom);
		dropShadow:SetPoint("TOPRIGHT", modelFrame, "BOTTOMLEFT", right, top);
	end
end
