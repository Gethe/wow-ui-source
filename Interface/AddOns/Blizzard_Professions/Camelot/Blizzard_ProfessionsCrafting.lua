function ProfessionsCraftingPageMixin:GetDesiredPageWidth()
	return 782;
end

function ProfessionsCraftingPageMixin:GetSchematicWidth(useCondensedPanel)
	return useCondensedPanel and 500 or 360;
end

function ProfessionsCraftingPageMixin:SetRankBarAnchors()
	self.RankBar:SetPoint("TOPLEFT", 110, -40);
end

function ProfessionsCraftingPageMixin:OverrideArt()
	self.SchematicForm.OutputIcon.Icon:SetSize(53, 53);

	-- Cannot simply Hide() because this is conditionally
	-- shown in Blizzard_ProfessionsRecipeSchematicForm.lua
	self.SchematicForm.NineSlice:ClearAllPoints();

	self.SchematicForm.TrackRecipeCheckbox:ClearAllPoints();
	self.SchematicForm.TrackRecipeCheckbox:SetPoint("BOTTOMLEFT", 17, 11);

	self.RecipeList:SetWidth(304);
end

function ProfessionsCraftingPageMixin:GetButtonTemplate()
	return "SharedButtonSmallTemplate";
end

function ProfessionsCraftingPageMixin:SetControlAnchors()
	self.CreateAllButton:ClearAllPoints();
	self.CreateAllButton:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -362, 7);

	self.CreateMultipleInputBox:ClearAllPoints();
	self.CreateMultipleInputBox:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -185, 11);
end
