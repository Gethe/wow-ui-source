function ModelPreviewFrame_OnLoad(self)
	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideAttic(self);
	self.TitleText:SetText(PREVIEW);
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function ModelPreviewFrame_SetStyle(self, style)
	self.style = style;
	if style == "carousel" then
		self.Display.ModelScene.RotateLeftButton:Hide();
		self.Display.ModelScene.RotateRightButton:Hide();
		self.Display.ModelScene.CarouselLeftButton:Show();
		self.Display.ModelScene.CarouselRightButton:Show();
		self.Display.CarouselText:Show();
	else
		self.Display.ModelScene.RotateLeftButton:Show();
		self.Display.ModelScene.RotateRightButton:Show();
		self.Display.ModelScene.CarouselLeftButton:Hide();
		self.Display.ModelScene.CarouselRightButton:Hide();
		self.Display.CarouselText:Hide();
	end
end

function ModelPreviewFrame_RefreshCurrentDisplay()
	local display = ModelPreviewFrame.Display;
	ModelPreviewFrame_ShowModel(display.displayID, display.modelSceneID, display.allowZoom, true);
end

function ModelPreviewFrame_ShowModels(displayInfoEntries, allowZoom, forceUpdate)
	local self = ModelPreviewFrame;
	self.displayInfoEntries = displayInfoEntries;
	ModelPreviewFrame_SetStyle(self, "carousel");
	ModelPreviewFrame_SetCarouselIndex(self, 1, allowZoom, forceUpdate);
end

function ModelPreviewFrame_ShowModel(displayID, modelSceneID, allowZoom, forceUpdate)
	local self = ModelPreviewFrame;
	self.displayInfoEntries = nil;
	ModelPreviewFrame_SetStyle(self, nil);
	ModelPreviewFrame_ShowModelInternal(displayID, modelSceneID, allowZoom, forceUpdate);
end

function ModelPreviewFrame_ShowModelInternal(displayID, modelSceneID, allowZoom, forceUpdate)
	local display = ModelPreviewFrame.Display;
	display.displayID = displayID;
	display.modelSceneID = modelSceneID;
	display.allowZoom = allowZoom;
	display.ModelScene:SetFromModelSceneID(modelSceneID, forceUpdate);

	local item = display.ModelScene:GetActorByTag("item");
	if ( item ) then
		item:SetModelByCreatureDisplayID(displayID);
		item:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_NONE);
	end

	ModelPreviewFrame:Show();
end

function ModelPreviewFrame_OnEvent(self, event, ...)
	if ( event == "UI_MODEL_SCENE_INFO_UPDATED" ) then
		if ( ModelPreviewFrame:IsVisible() ) then
			ModelPreviewFrame_RefreshCurrentDisplay();
		end
	end
end

function ModelPreviewFrame_SetCarouselIndex(self, index, allowZoom, forceUpdate)
	self.carouselIndex = index;
	self.Display.CarouselText:SetText(MODEL_PREVIEW_FRAME_CAROUSEL_TEXT_FORMAT:format(self.carouselIndex, #self.displayInfoEntries));
	
	local displayInfoEntry = self.displayInfoEntries[self.carouselIndex];
	ModelPreviewFrame_ShowModelInternal(displayInfoEntry.creatureDisplayInfoID, displayInfoEntry.modelSceneID, allowZoom, forceUpdate);
	self.Display.Name:SetText(displayInfoEntry.title);
end

function ModelPreviewFrame_MoveCarousel(self, backward)
	local newCarouselIndex = self.carouselIndex;
	if backward then
		newCarouselIndex = newCarouselIndex - 1;
		if newCarouselIndex <= 0 then
			newCarouselIndex = #self.displayInfoEntries;
		end
	else
		newCarouselIndex = newCarouselIndex + 1;
		if newCarouselIndex > #self.displayInfoEntries then
			newCarouselIndex = 1;
		end
	end
	
	local display = self.Display;
	ModelPreviewFrame_SetCarouselIndex(self, newCarouselIndex, display.allowZoom, true);
end

function CarouselLeftButton_OnClick(self)
	local parentPreviewFrame = self:GetParent():GetParent():GetParent();
	ModelPreviewFrame_MoveCarousel(parentPreviewFrame, true);
end

function CarouselRightButton_OnClick(self)
	local parentPreviewFrame = self:GetParent():GetParent():GetParent();
	ModelPreviewFrame_MoveCarousel(parentPreviewFrame, false);
end