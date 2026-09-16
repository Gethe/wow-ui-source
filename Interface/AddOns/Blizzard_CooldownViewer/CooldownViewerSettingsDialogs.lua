CooldownViewerBaseDialogMixin = {}; -- implements API from CreateFromMixins(EditModeBaseDialogMixin);

function CooldownViewerBaseDialogMixin:GetManagerExitCallbackEventName()
	return "CooldownViewerSettings.OnHide";
end

function CooldownViewerBaseDialogMixin:GetOnCancelEvent()
	return nil;
end

function CooldownViewerBaseDialogMixin:GetDesiredLayoutType()
	return self:IsCharacterSpecificLayoutChecked() and Enum.CooldownLayoutType.Character or Enum.CooldownLayoutType.Account;
end

CooldownViewerImportLayoutDialogMixin = {};

function CooldownViewerImportLayoutDialogMixin:SetLayoutIDs(layoutIDs)
	self.layoutIDs = layoutIDs;
end

function CooldownViewerImportLayoutDialogMixin:GetLayoutIDs()
	return self.layoutIDs;
end

function CooldownViewerImportLayoutDialogMixin:ProcessImportText(text)
	self:SetLayoutIDs(self:GetLayoutManager():CreateLayoutsFromSerializedData(text));
	self:SetLayoutInfo(self:GetImportedLayout()); -- Cache the newly created layout(s)
	self:DeleteImportedLayouts(); -- Delete them from the manager the user will end up re-adding if they want to keep it and after they name it.
	self:UpdateLayoutNameFromCreatedLayout();
end

function CooldownViewerImportLayoutDialogMixin:UpdateLayoutNameFromCreatedLayout()
	local layout = self:GetLayoutInfo(); -- Use cached results from ProcessImportText
	if layout then
		CooldownManagerLayout_SetName(layout, ""); -- Force the user to rename this, don't trust incoming text.
	end
end

function CooldownViewerImportLayoutDialogMixin:GetImportedLayout()
	local layoutIDs = self:GetLayoutIDs();
	if layoutIDs and layoutIDs[1] then
		return self:GetLayoutManager():GetLayout(layoutIDs[1]); -- NOTE: Only support single layout for now
	end

	return nil;
end

function CooldownViewerImportLayoutDialogMixin:DeleteImportedLayouts()
	local layoutIDs = self:GetLayoutIDs();
	if layoutIDs then
		local layoutManager = self:GetLayoutManager();
		for index, layoutID in pairs(layoutIDs) do
			layoutManager:RemoveLayout(layoutID);
		end

		self:SetLayoutIDs(nil);
	end
end
