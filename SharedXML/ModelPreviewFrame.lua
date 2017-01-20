function ModelPreviewFrame_OnLoad(self)
	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideAttic(self);
	self.TitleText:SetText(PREVIEW);
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function ModelPreviewFrame_RefreshCurrentDisplay()
	local display = ModelPreviewFrame.Display;
	ModelPreviewFrame_ShowModel(display.displayID, display.modelSceneID, display.allowZoom, true);
end

function ModelPreviewFrame_ShowModel(displayID, modelSceneID, allowZoom, forceUpdate)
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