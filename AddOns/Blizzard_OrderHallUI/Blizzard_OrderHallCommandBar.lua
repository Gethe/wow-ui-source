---------------------------------------------------------------------------------
--- OrderHallCommandBarMixin                                                             ---
---------------------------------------------------------------------------------

OrderHallCommandBarMixin = { }

function OrderHallCommandBarMixin:OnLoad()

	self.categoryPool = CreateFramePool("FRAME", self, "OrderHallClassSpecCategoryTemplate", OnTalentButtonReleased);

	local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0);
	self.currency = primaryCurrency;


		-- setup portrait texture
	local _, class = UnitClass("player");
	self.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
	local x1, x2, y1, y2 = unpack(CLASS_ICON_TCOORDS[strupper(class)]);
	local height = y2 - y1;
	y1 = y1 + 0.25 * height;
	y2 = y2 - 0.25 * height;
	self.ClassIcon:SetTexCoord(x1, x2, y1, y2);
end

function OrderHallCommandBarMixin:OnShow()
	UIParent_UpdateTopFramePositions();

	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("GARRISON_TALENT_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED");
	self:RegisterEvent("GARRISON_FOLLOWER_ADDED");
	self:RegisterEvent("GARRISON_FOLLOWER_REMOVED");


	self:RequestCategoryInfo();
	self:RefreshAll();
end

function OrderHallCommandBarMixin:OnHide()
	self:UnregisterEvent("UNIT_AURA");
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("UI_SCALE_CHANGED");
	self:UnregisterEvent("GARRISON_TALENT_UPDATE");
	self:UnregisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED");
	self:UnregisterEvent("GARRISON_FOLLOWER_ADDED");
	self:UnregisterEvent("GARRISON_FOLLOWER_REMOVED");


	self.categoryPool:ReleaseAll();
	UIParent_UpdateTopFramePositions();
end

function OrderHallCommandBarMixin:OnEvent(event)
	if (event == "CURRENCY_DISPLAY_UPDATE") then
		self:RefreshCurrency();
	elseif ( event == "DISPLAY_SIZE_CHANGED" 
		or event == "UI_SCALE_CHANGED" 
		or event == "GARRISON_FOLLOWER_CATEGORIES_UPDATED" 
		or event == "GARRISON_FOLLOWER_ADDED" 
		or event == "GARRISON_FOLLOWER_REMOVED") then

		self:RefreshCategories();
	elseif ( event == "UNIT_AURA" ) then
		local inOrderHall = C_Garrison.IsPlayerInGarrison(LE_GARRISON_TYPE_7_0);
		self:SetShown(inOrderHall);
	elseif ( event == "GARRISON_TALENT_UPDATE" ) then
		self:RequestCategoryInfo();
	end
end

function OrderHallCommandBarMixin:RequestCategoryInfo()
	C_Garrison.RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0);
end

function OrderHallCommandBarMixin:RefreshAll()
	self:RefreshCurrency();
	self:RefreshCategories();
end

function OrderHallCommandBarMixin:RefreshCategories()
	self.categoryPool:ReleaseAll();
	local categoryInfo = C_Garrison.GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0);

	local numCategories = #categoryInfo;
	local prevCategory, firstCategory;
	for index, category in pairs(categoryInfo) do
		local categoryInfo = self.categoryPool:Acquire();
		categoryInfo.Icon:SetTexture(category.icon);
		categoryInfo.Icon:SetTexCoord(0, 1, 0.25, 0.75);
		categoryInfo.name = category.name;

		categoryInfo.Count:SetText(string.format("%d/%d", category.count, category.limit));
		categoryInfo:ClearAllPoints();
		if (not firstCategory) then
			categoryInfo:SetPoint("LEFT", self, "LEFT", (self:GetWidth() - (numCategories * categoryInfo:GetWidth()))/2, 0);
			firstCategory = categoryInfo;
		else
			categoryInfo:SetPoint("LEFT", prevCategory, "RIGHT");
		end
		categoryInfo:Show();
		prevCategory = categoryInfo;
	end

end

function OrderHallCommandBarMixin:RefreshCurrency()
	local currencyName, amount, currencyTexture = GetCurrencyInfo(self.currency);
	amount = BreakUpLargeNumbers(amount);
	self.Currency:SetText(amount);
	self.CurrencyIcon:SetTexture(currencyTexture);
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
		GameTooltip:Show();
	end
end

function OrderHallClassSpecCategory:OnLeave()
	GameTooltip:Hide();
end

