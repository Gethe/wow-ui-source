-- Shared by ProfessionsCraftingOutputLogResourceTemplate and ResultContainer.
local function InitializeOutputFrame(frame, resultData)
	local item = Item:CreateFromItemLink(resultData.hyperlink);
	frame.Name:SetText(item:GetItemName());
	frame.Name:SetTextColor(item:GetItemQualityColorRGB());

	if resultData.craftingQuality then
		local atlasSize = 25;
		local atlasMarkup = CreateAtlasMarkup(Professions.GetIconForQuality(resultData.craftingQuality), atlasSize, atlasSize);
		frame.Quality:SetText(PROFESSIONS_CRAFTING_FORM_OUTPUT_QUALITY:format(atlasMarkup));
		frame.Quality:Show();
	else
		frame.Quality:Hide();
	end
	
	local icon = item:GetItemIcon();
	local itemID = item:GetItemID();
	local quantity = resultData.quantity;
	local quality = item:GetItemQuality();
	Professions.SetupOutputIconCommon(frame.OutputIcon, quantity, quantity, icon, itemID, quality);
end

ProfessionsCraftingOutputLogElementMixin = {};

function ProfessionsCraftingOutputLogElementMixin:Init(resultData)
	local continuableContainer = ContinuableContainer:Create();
	local item = Item:CreateFromItemID(resultData.itemID);
	continuableContainer:AddContinuable(item);
	
	local function OnItemLoaded()
		InitializeOutputFrame(self, resultData);

		self.OutputIcon:SetScript("OnLeave", GameTooltip_Hide);
		self.OutputIcon:SetScript("OnEnter", function(button)
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
			GameTooltip:SetHyperlink(resultData.hyperlink);
		end);
	end

	continuableContainer:ContinueOnLoad(OnItemLoaded);
end

ProfessionsCraftingOutputLogMixin = CreateFromMixins(CallbackRegistryMixin);

ProfessionsCraftingOutputLogMixin:GenerateCallbackEvents(
{
    "OrderRecraft",
});

function ProfessionsCraftingOutputLogMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	local view = CreateScrollBoxListLinearView();
	
	local function Initializer(frame, elementData)
		frame:Init(elementData);
	end
	view:SetElementInitializer("ProfessionsCraftingOutputLogElementTemplate", Initializer);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ResultsContainer.ScrollBox, self.ResultsContainer.ScrollBar, view);

	self.Header:SetText(PROFESSIONS_CRAFTING_COMPLETE);
	
	local function OnCancel()
		self:Hide();
	end

	self.CloseButton:SetScript("OnClick", OnCancel);

	self.ExitButton:SetTextToFit(PROFESSIONS_CRAFTING_FORM_OUTPUT_EXIT);
	self.ExitButton:SetScript("OnClick", OnCancel);

	self.RecraftButton:SetTextToFit(PROFESSIONS_CRAFTING_FORM_OUTPUT_RECRAFT);
	self.RecraftButton:Disable();

	self.ResultContainer.OutputIcon:SetScript("OnLeave", GameTooltip_Hide);
	self.ResultContainer.OutputIcon:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink(self.resultDatas[1].hyperlink);
	end);

	self.resourcesFramePool = CreateFramePool("FRAME", self.ResultContainer, "ProfessionsCraftingOutputLogResourceTemplate");
end

function ProfessionsCraftingOutputLogMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_ITEM_CRAFTED_RESULT" then
		if self.resultHandler then
			local resultData = ...;
			table.insert(self.resultDatas, resultData);

			self.resultHandler(self, resultData);
		end	
		self:Show();
	end
end

function ProfessionsCraftingOutputLogMixin:OnHide()
	self:UnregisterEvents();
	self:UnregisterEvent("TRADE_SKILL_ITEM_CRAFTED_RESULT");
end

function ProfessionsCraftingOutputLogMixin:Close()
	self:Hide();
end

function ProfessionsCraftingOutputLogMixin:StartListening(successive)
	if successive then
		self.resultHandler = self.ProcessSuccessiveCraftingResult;

		self.ResultContainer:Hide();
		self.ResultsContainer:Show();

		self.ResultsContainer.ScrollBox:SetDataProvider(CreateDataProvider());
		
		self:SetHeight(400);
	else
		self.resultHandler = self.ProcessSingleCraftingResult;

		self.ResultContainer:Show();
		self.ResultsContainer:Hide();
	end

	self.resultDatas = {};
	self:RegisterEvent("TRADE_SKILL_ITEM_CRAFTED_RESULT");
end

function ProfessionsCraftingOutputLogMixin:ProcessSingleCraftingResult(resultData)
	self.resourcesFramePool:ReleaseAll();

	local continuableContainer = ContinuableContainer:Create();
	local item = Item:CreateFromItemID(resultData.itemID);
	continuableContainer:AddContinuable(item);

	local frames = nil;
	if resultData.resourcesReturned then
		for index, resource in ipairs(resultData.resourcesReturned) do
			local item = Item:CreateFromItemID(resource.itemID);
			continuableContainer:AddContinuable(item);
		end
			
		local function FactoryFunction(index)
			local resource = resultData.resourcesReturned[index];
			if resource then
				local frame = self.resourcesFramePool:Acquire();
				return frame;
			end
			return nil;
		end

		local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self.ResultContainer.OutputIcon, "BOTTOMLEFT", 0, -20);
		local direction, stride, paddingX, paddingY = GridLayoutMixin.Direction.TopLeftToBottomRight, 1, 0, 0;
		local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);
		frames = AnchorUtil.GridLayoutFactoryByCount(FactoryFunction, 6, anchor, layout);
	end

	local function OnItemsLoaded()
		InitializeOutputFrame(self.ResultContainer, resultData);
		
		local height = 180;
		if frames then
			local scale = .75;
			for index, frame in ipairs(frames) do
				local resource = resultData.resourcesReturned[index];
				local itemID = resource.itemID;
				local quantity = resource.quantity;

				local item = Item:CreateFromItemID(itemID);
				local icon = item:GetItemIcon();
				local quality = item:GetItemQuality();
				Professions.SetupOutputIconCommon(frame.OutputIcon, quantity, quantity, icon, itemID, quality);
				
				frame.OutputIcon:SetScale(scale);
				frame.OutputIcon.Count:SetScale(1 / scale);
				frame.OutputIcon:SetScript("OnLeave", GameTooltip_Hide);
				frame.OutputIcon:SetScript("OnEnter", function(button)
					GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
					GameTooltip:SetItemByID(itemID);
				end);

				frame:Show();
			end

			local info = C_XMLUtil.GetTemplateInfo("ProfessionsCraftingOutputLogResourceTemplate");
			self:SetHeight(height + (info.height * #frames));
		else
			self:SetHeight(height);
		end
	end

	continuableContainer:ContinueOnLoad(OnItemsLoaded);
end

function ProfessionsCraftingOutputLogMixin:ProcessSuccessiveCraftingResult(data)
	self.ResultsContainer.ScrollBox:InsertElementData(data);
	self.ResultsContainer.ScrollBox:ScrollToEnd();
end