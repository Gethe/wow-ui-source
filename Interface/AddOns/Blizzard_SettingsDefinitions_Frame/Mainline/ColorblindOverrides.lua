ColorblindOverrides = {}

function ColorblindOverrides.CreateSettings(category, layout)
	-- Color Overrides
	local data = { categoryID = category:GetID(), panelSetting = "panelItemQualityColorOverrides" };
	local initializer = Settings.CreatePanelInitializer("ItemQualityColorOverrides", data);

	-- Include both 'Item Quality' and 'Rarity', since the terms are a bit interchangeable players could search for either.
	initializer:AddSearchTags(COLORS_ITEM_QUALITY, RARITY);
	layout:AddInitializer(initializer);
end


ItemQualityColorOverrideMixin = {
	OverrideData =
	{
		{
			qualityBase = Enum.ItemQuality.Poor,
			qualityOverride = Enum.ColorOverride.ItemQualityPoor
		},
		{
			qualityBase = Enum.ItemQuality.Common,
			qualityOverride = Enum.ColorOverride.ItemQualityCommon
		},
		{
			qualityBase = Enum.ItemQuality.Uncommon,
			qualityOverride = Enum.ColorOverride.ItemQualityUncommon
		},
		{
			qualityBase = Enum.ItemQuality.Rare,
			qualityOverride = Enum.ColorOverride.ItemQualityRare
		},
		{
			qualityBase = Enum.ItemQuality.Epic,
			qualityOverride = Enum.ColorOverride.ItemQualityEpic
		},
		{
			qualityBase = Enum.ItemQuality.Legendary,
			qualityOverride = Enum.ColorOverride.ItemQualityLegendary
		},
		{
			qualityBase = Enum.ItemQuality.Artifact,
			qualityOverride = Enum.ColorOverride.ItemQualityArtifact
		},
		{
			qualityBase = Enum.ItemQuality.Heirloom,
			qualityOverride = Enum.ColorOverride.ItemQualityAccount
		}
	};
};

function ItemQualityColorOverrideMixin:Init(initializer)
	self.categoryID = initializer.data.categoryID;

	for index, data in ipairs(ItemQualityColorOverrideMixin.OverrideData) do
		initializer:AddSearchTags(_G["ITEM_QUALITY"..data.qualityBase.."_DESC"]);
	end

	self.NewFeature:SetShown(initializer:IsNewTagShown());
end

function ItemQualityColorOverrideMixin:OnLoad()
	self.ColorOverrideFramePool = CreateFramePool("FRAME", self.ItemQualities, "ColorOverrideTemplate", nil);
	self.colorOverrideFrames = {};

	local function ResetColorSwatches()
		C_ColorOverrides.ClearColorOverrides();
		ColorManager.UpdateColorData();

		for _, frame in ipairs(self.colorOverrideFrames) do
			local colorData = ColorManager.GetColorDataForItemQuality(frame.data.qualityBase);
			if colorData then
				frame.Text:SetTextColor(colorData.color:GetRGB());
				frame.ColorSwatch.Color:SetVertexColor(colorData.color:GetRGB());
			end
		end
	end
	EventRegistry:RegisterCallback("Settings.Defaulted", ResetColorSwatches);

	local function CategoryDefaulted(o, category)
		if self.categoryID == category:GetID() then
			ResetColorSwatches();
		end
	end
	EventRegistry:RegisterCallback("Settings.CategoryDefaulted", CategoryDefaulted);

	for index, data in ipairs(ItemQualityColorOverrideMixin.OverrideData) do
		local frame = self.ColorOverrideFramePool:Acquire();
		frame.layoutIndex = index;
		self:SetupColorSwatch(frame, data);
		frame:Show();

		table.insert(self.colorOverrideFrames, frame);
	end
end

function ItemQualityColorOverrideMixin:SetupColorSwatch(frame, data)
	frame.data = data;

	frame.Text:SetText(_G["ITEM_QUALITY"..frame.data.qualityBase.."_DESC"]);

	local colorData = ColorManager.GetColorDataForItemQuality(frame.data.qualityBase);
	if colorData then
		frame.Text:SetTextColor(colorData.color:GetRGB());
		frame.ColorSwatch.Color:SetVertexColor(colorData.color:GetRGB());
	end

	frame.ColorSwatch:SetScript("OnClick", function(button, buttonName, down)
		self:OpenColorPicker(frame);
	end);
end

function ItemQualityColorOverrideMixin:OpenColorPicker(frame)
	local info = UIDropDownMenu_CreateInfo();

	local overrideInfo = C_ColorOverrides.GetColorOverrideInfo(frame.data.qualityOverride);

	local colorData = ColorManager.GetColorDataForItemQuality(frame.data.qualityBase);
	if colorData then
		info.r, info.g, info.b = colorData.color:GetRGB();
	end

	info.extraInfo = nil;
	info.swatchFunc = function ()
		local r,g,b = ColorPickerFrame:GetColorRGB();
		local a = ColorPickerFrame:GetColorAlpha();
		frame.Text:SetTextColor(r,g,b);
		frame.ColorSwatch.Color:SetVertexColor(r,g,b);

		C_ColorOverrides.SetColorOverride(frame.data.qualityOverride, CreateColor(r, g, b, a));
		ColorManager.UpdateColorData();
	end;

	info.cancelFunc = function ()
		local r,g,b = ColorPickerFrame:GetPreviousValues();
		frame.Text:SetTextColor(r,g,b);
		frame.ColorSwatch.Color:SetVertexColor(r,g,b);

		if overrideInfo then
			C_ColorOverrides.SetColorOverride(frame.data.qualityOverride, CreateColor(overrideInfo.overrideColor:GetRGBA()));
		else
			C_ColorOverrides.RemoveColorOverride(frame.data.qualityOverride);
		end
		ColorManager.UpdateColorData();
	end;

	ColorPickerFrame:SetupColorPickerAndShow(info);
end