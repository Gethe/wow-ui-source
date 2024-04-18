--[[
	Paged Content Frame implementation for single-file list-based layouts
	Relies on ViewFrames inheriting the appropriate LayoutFrames to arrange elements
]]

BasePagedListContentFrameMixin = CreateFromMixins(PagedContentFrameBaseMixin);

function BasePagedListContentFrameMixin:InitializeElementSplit(splitData, viewFrame)
	if not viewFrame.IsLayoutFrame or not viewFrame:IsLayoutFrame() then
		error("View frames need to inherit from an appropriate LayoutFrame");
	end

	splitData.elementSpacing = viewFrame.spacing or 0;
end

function BasePagedListContentFrameMixin:WillElementUseTrackedViewSpace(splitData, elementData, elementTemplateInfo, needsGroupSpacer)
	-- Since lists are single, linear rows or columns, all elements take up view space on being added
	return true;
end

function BasePagedListContentFrameMixin:ProcessSpacerFrame(spacerFrame, elementIndex)
	spacerFrame.expand = true;
	spacerFrame.layoutIndex = elementIndex
end

function BasePagedListContentFrameMixin:ProcessElementFrame(elementFrame, elementData, elementIndex)
	elementFrame.layoutIndex = elementIndex

	if self.autoExpandHeaders and elementData.isHeader then
		elementFrame.expand = true;
	end
end

function BasePagedListContentFrameMixin:ApplyLayout(layoutFrames, viewFrame)
	-- Set view's width/height as fixed so that it doesn't attempt to adjust to the width/height of its children
	-- since we just populated it with elements based on its existing width/height
	viewFrame.fixedWidth = viewFrame:GetWidth();
	viewFrame.fixedHeight = viewFrame:GetHeight();
	viewFrame:Layout();
end


----------------- Vertical List -----------------
-- Vertical, single-column list of elements

PagedVerticalListContentFrameMixin = CreateFromMixins(BasePagedListContentFrameMixin);

function PagedVerticalListContentFrameMixin:ProcessTemplateInfo(templateInfo)
	templateInfo.verticalPadding = 0;

	for i, keyValue in ipairs(templateInfo.keyValues) do
		if keyValue.key and (keyValue.key == "topPadding" or  keyValue.key == "bottomPadding") then
			local padding = tonumber(keyValue.value) or 0;
			templateInfo.verticalPadding = templateInfo.verticalPadding + padding;
		end
	end
end

function PagedVerticalListContentFrameMixin:GetTotalViewSpace(viewFrame)
	local verticalViewPadding = (viewFrame.topPadding or 0) + (viewFrame.bottomPadding or 0);

	return viewFrame:GetHeight() - verticalViewPadding;
end

function PagedVerticalListContentFrameMixin:GetViewSpaceNeededForElement(splitData, elementData, elementTemplateInfo)
	return elementTemplateInfo.height + elementTemplateInfo.verticalPadding + splitData.elementSpacing;
end

function PagedVerticalListContentFrameMixin:GetViewSpaceNeededForSpacer(splitData, spacerTemplateInfo)
	return self.spacerSize + spacerTemplateInfo.verticalPadding + splitData.elementSpacing;
end

function PagedVerticalListContentFrameMixin:ProcessSpacerFrame(spacerFrame, elementIndex)
	BasePagedListContentFrameMixin.ProcessSpacerFrame(self, spacerFrame, elementIndex);
	spacerFrame:SetHeight(self.spacerSize);
end

----------------- Horizontal List -----------------
-- Horizontal, single-column list of elements

PagedHorizontalListContentFrameMixin = CreateFromMixins(BasePagedListContentFrameMixin);

function PagedHorizontalListContentFrameMixin:ProcessTemplateInfo(templateInfo)
	templateInfo.horizontalPadding = 0;

	for i, keyValue in ipairs(templateInfo.keyValues) do
		if keyValue.key and (keyValue.key == "leftPadding" or keyValue.key == "rightPadding") then
			local padding = tonumber(keyValue.value) or 0;
			templateInfo.horizontalPadding = templateInfo.horizontalPadding + padding;
		end
	end
end

function PagedHorizontalListContentFrameMixin:GetTotalViewSpace(viewFrame)
	local horizontalViewPadding = (viewFrame.leftPadding or 0) + (viewFrame.rightPadding or 0);

	return viewFrame:GetWidth() - horizontalViewPadding;
end

function PagedHorizontalListContentFrameMixin:GetViewSpaceNeededForElement(splitData, elementData, elementTemplateInfo)
	return elementTemplateInfo.width + elementTemplateInfo.horizontalPadding + splitData.elementSpacing;
end

function PagedHorizontalListContentFrameMixin:GetViewSpaceNeededForSpacer(splitData, spacerTemplateInfo)
	return self.spacerSize + spacerTemplateInfo.horizontalPadding + splitData.elementSpacing;
end

function PagedHorizontalListContentFrameMixin:ProcessSpacerFrame(spacerFrame, elementIndex)
	BasePagedListContentFrameMixin.ProcessSpacerFrame(self, spacerFrame, elementIndex);
	spacerFrame:SetWidth(self.spacerSize);
end