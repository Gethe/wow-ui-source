---------------------------------------------------------------------------------
--- OrderHallCommandBarMixin                                                             ---
---------------------------------------------------------------------------------

OrderHallCommandBarMixin = { }

function OrderHallCommandBarMixin:OnLoad()

	self.categoryPool = CreateFramePool("FRAME", self, "OrderHallClassSpecCategoryTemplate");

	local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(Enum.GarrisonType.Type_7_0);
	self.currency = primaryCurrency;


		-- setup portrait texture
	local _, class = UnitClass("player");
	self.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
	local x1, x2, y1, y2 = unpack(CLASS_ICON_TCOORDS[strupper(class)]);
	local height = y2 - y1;
	y1 = y1 + 0.25 * height;
	y2 = y2 - 0.25 * height;
	self.ClassIcon:SetTexCoord(x1, x2, y1, y2);

	-- don't wnat to get mouse events on anything under the command bar
	self:EnableMouse(true);

	self.AreaName:SetText(_G["ORDER_HALL_"..class]);
end

function OrderHallCommandBarMixin:OnShow()
	UIParent_UpdateTopFramePositions();

	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterUnitEvent("UNIT_PHASE", "player");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("GARRISON_TALENT_COMPLETE");
	self:RegisterEvent("GARRISON_TALENT_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED");
	self:RegisterEvent("GARRISON_FOLLOWER_ADDED");
	self:RegisterEvent("GARRISON_FOLLOWER_REMOVED");
	self:RegisterEvent("UPDATE_BINDINGS");

	self:RequestCategoryInfo();
	self:RefreshAll();

	self.WorldMapButton.tooltipText = MicroButtonTooltipText(WORLDMAP_BUTTON, "TOGGLEWORLDMAP");
	self.WorldMapButton.newbieText = NEWBIE_TOOLTIP_WORLDMAP;
end

function OrderHallCommandBarMixin:OnHide()
	self:UnregisterEvent("UNIT_AURA");
	self:UnregisterEvent("UNIT_PHASE");
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("UI_SCALE_CHANGED");
	self:UnregisterEvent("GARRISON_TALENT_COMPLETE");
	self:UnregisterEvent("GARRISON_TALENT_UPDATE");
	self:UnregisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED");
	self:UnregisterEvent("GARRISON_FOLLOWER_ADDED");
	self:UnregisterEvent("GARRISON_FOLLOWER_REMOVED");
	self:UnregisterEvent("UPDATE_BINDINGS");

	self.categoryPool:ReleaseAll();
	UIParent_UpdateTopFramePositions();
end

function OrderHallCommandBarMixin:OnEvent(event)
	if (event == "CURRENCY_DISPLAY_UPDATE") then
		self:RefreshCurrency();
	elseif (event == "DISPLAY_SIZE_CHANGED" 
		or event == "UI_SCALE_CHANGED" 
		or event == "GARRISON_FOLLOWER_CATEGORIES_UPDATED" 
		or event == "GARRISON_FOLLOWER_ADDED" 
		or event == "GARRISON_FOLLOWER_REMOVED") then

		self:RefreshCategories();
	elseif (event == "UNIT_AURA") then
		local inOrderHall = C_Garrison.IsPlayerInGarrison(Enum.GarrisonType.Type_7_0);
		self:SetShown(inOrderHall);
	elseif (event == "GARRISON_TALENT_COMPLETE" 
		or event == "GARRISON_TALENT_UPDATE"
		or event == "UNIT_PHASE") then

		self:RequestCategoryInfo();
	elseif (event == "UPDATE_BINDINGS") then
		self.WorldMapButton.tooltipText = MicroButtonTooltipText(WORLDMAP_BUTTON, "TOGGLEWORLDMAP");
		self.WorldMapButton.newbieText = NEWBIE_TOOLTIP_WORLDMAP;
	end
end

function OrderHallCommandBarMixin:RequestCategoryInfo()
	C_Garrison.RequestClassSpecCategoryInfo(Enum.GarrisonFollowerType.FollowerType_7_0);
end

function OrderHallCommandBarMixin:RefreshAll()
	self:RefreshCurrency();
	self:RefreshCategories();
end

function OrderHallCommandBarMixin:RefreshCategories()
	self.categoryPool:ReleaseAll();
	local categoryInfo = C_Garrison.GetClassSpecCategoryInfo(Enum.GarrisonFollowerType.FollowerType_7_0);

	local numCategories = #categoryInfo;
	local prevCategory, firstCategory;
	local xSpacing = 20;	-- space between categories
	for index, category in ipairs(categoryInfo) do
		local categoryInfoFrame = self.categoryPool:Acquire();
		categoryInfoFrame.Icon:SetTexture(category.icon);
		categoryInfoFrame.Icon:SetTexCoord(0, 1, 0.25, 0.75);
		categoryInfoFrame.name = category.name;
		categoryInfoFrame.description = category.description;

		categoryInfoFrame.Count:SetFormattedText(ORDER_HALL_COMMANDBAR_CATEGORY_COUNT, category.count, category.limit);
		categoryInfoFrame:ClearAllPoints();
		if (not firstCategory) then
			-- calculate positioning so that the set of categories ends up being centered
			categoryInfoFrame:SetPoint("LEFT", self, "RIGHT", (0 - (numCategories * (categoryInfoFrame:GetWidth() + xSpacing))) - 30, 0);
			firstCategory = categoryInfoFrame;
		else
			categoryInfoFrame:SetPoint("LEFT", prevCategory, "RIGHT", xSpacing, 0);
		end
		categoryInfoFrame:Show();
		prevCategory = categoryInfoFrame;
	end

end

function OrderHallCommandBarMixin:RefreshCurrency()
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.currency);
	local amount = currencyInfo and currencyInfo.quantity or 0;
	amount = BreakUpLargeNumbers(amount);
	self.Currency:SetText(amount);
	-- self.CurrencyIcon:SetTexture(currencyTexture);
end


---------------------------------------------------------------------------------
--- OrderHallClassSpecCategory                                                     ---
---------------------------------------------------------------------------------

OrderHallClassSpecCategory = { }

function OrderHallClassSpecCategory:OnEnter()
	if (self.name) then
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("TOPLEFT", self.Count, "BOTTOMRIGHT", -20, -20);
		GameTooltip:AddLine(self.name);
		if (self.description) then
			GameTooltip:AddLine(self.description, 1, 1, 1, true);
		end
		GameTooltip:Show();
	end
end

function OrderHallClassSpecCategory:OnLeave()
	GameTooltip:Hide();
end

