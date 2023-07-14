ProfessionsGuildCrafterButtonMixin = {};

function ProfessionsGuildCrafterButtonMixin:Init(elementData)
	self:SetText(elementData.displayName);

	if elementData.online then
		local color = GetClassColorObj(elementData.classFileName) or GRAY_FONT_COLOR;
		self.Text:SetTextColor(color:GetRGB());

		self:Enable();
	else
		self.Text:SetTextColor(GRAY_FONT_COLOR:GetRGB());

		self:Disable();
	end
end

ProfessionsGuildListingMixin = {};

function ProfessionsGuildListingMixin:OnLoad()
	self.Title:SetText(GUILD_CRAFTERS);

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("ProfessionsGuildCrafterButtonTemplate", function(button, elementData)
		button:Init(elementData);
		
		button:SetScript("OnClick", function(button, buttonName, down)
			if elementData.fullName then
				ChatFrame_SendTell(elementData.fullName);
			end
		end);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.Container.ScrollBox, self.Container.ScrollBar, view);

	self:RegisterEvent("GUILD_RECIPE_KNOWN_BY_MEMBERS");
end

function ProfessionsGuildListingMixin:OnEvent(event, ...)
	if event == "GUILD_RECIPE_KNOWN_BY_MEMBERS" then
		if self:IsVisible() and self.waitingOnData then
			local skillLineID, recipeID, numMembers = GetGuildRecipeInfoPostQuery();
			if self.skillLineID == skillLineID and self.recipeID == recipeID then
				self.waitingOnData = nil;
				self:Refresh();
			end
		end
	end
end

function ProfessionsGuildListingMixin:Clear()
	self.skillLineID = nil;
	self.recipeID = nil;
	self.waitingOnData = nil;
	self:Hide();
end

function ProfessionsGuildListingMixin:ShowGuildRecipe(skillLineID, recipeID, recipeLevel)
	local updatedRecipeID = C_GuildInfo.QueryGuildMembersForRecipe(skillLineID, recipeID, recipeLevel);
	if updatedRecipeID then
		self.skillLineID = skillLineID;
		self.recipeID = updatedRecipeID;
		self.waitingOnData = true;

		self:Refresh();
		self:Show();
	end
end

function ProfessionsGuildListingMixin:Refresh()
	if self.waitingOnData then
		self.Container.Spinner:Show();
		self.Container.ScrollBox:RemoveDataProvider();
	else
		self.Container.Spinner:Hide();

		local dataProvider = CreateDataProvider();
		for index = 1, select(3, GetGuildRecipeInfoPostQuery()) do
			local displayName, fullName, classFileName, online = GetGuildRecipeMember(index);
			dataProvider:Insert({displayName = displayName, fullName = fullName, classFileName = classFileName, online = online});
		end

		self.Container.ScrollBox:SetDataProvider(dataProvider);
	end
end