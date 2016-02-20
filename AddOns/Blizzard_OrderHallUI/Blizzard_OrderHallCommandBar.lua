---------------------------------------------------------------------------------
--- OrderHallCommandBarMixin                                                             ---
---------------------------------------------------------------------------------

OrderHallCommandBarMixin = { }

function OrderHallCommandBarMixin:OnLoad()

	self.troopSummaryPool = CreateFramePool("FRAME", self, "OrderHallTroopSummaryTemplate", OnTalentButtonReleased);

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
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");

	self:RefreshAll();
	UIParent_UpdateTopFramePositions();
end

function OrderHallCommandBarMixin:OnHide()
	self:UnregisterEvent("UNIT_AURA");
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("UI_SCALE_CHANGED");

	self.troopSummaryPool:ReleaseAll();
	UIParent_UpdateTopFramePositions();
end

function OrderHallCommandBarMixin:OnEvent(event)
	if (event == "CURRENCY_DISPLAY_UPDATE") then
		self:RefreshCurrency();
	elseif ( event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" ) then
		self:RefreshTroops();
	elseif ( event == "UNIT_AURA" ) then
		local inOrderHall = C_Garrison.IsPlayerInGarrison(LE_GARRISON_TYPE_7_0);
		self:SetShown(inOrderHall);
	end
end

function OrderHallCommandBarMixin:RefreshAll()
	self:RefreshCurrency();
	self:RefreshTroops();
end

function OrderHallCommandBarMixin:RefreshTroops()
	self.troopSummaryPool:ReleaseAll();
	local troopSummary = C_Garrison.GetFollowerTroopSummaryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0);

	local numTroopTypes = #troopSummary;
	local prevTroop, firstTroop;
	for index, troop in pairs(troopSummary) do
		local troopSummary = self.troopSummaryPool:Acquire();
		local followerID = troop.followerID;
		local followerInfo = C_Garrison.GetFollowerInfo(followerID);


		troopSummary.Icon:SetTexture(followerInfo.portraitIconID);
		troopSummary.Icon:SetTexCoord(0, 1, 0.25, 0.75);
		troopSummary.name = followerInfo.name;

		troopSummary.Count:SetText(string.format("%d/%d", troop.count, troop.limit));
		troopSummary:ClearAllPoints();
		if (not firstTroop) then
			troopSummary:SetPoint("LEFT", self, "LEFT", (self:GetWidth() - (numTroopTypes * troopSummary:GetWidth()))/2, 0);
			firstTroop = troopSummary;
		else
			troopSummary:SetPoint("LEFT", prevTroop, "RIGHT");
		end
		troopSummary:Show();
		prevTroop = troopSummary;
	end

end

function OrderHallCommandBarMixin:RefreshCurrency()
	local currencyName, amount, currencyTexture = GetCurrencyInfo(self.currency);
	amount = BreakUpLargeNumbers(amount);
	self.Currency:SetText(amount);
	self.CurrencyIcon:SetTexture(currencyTexture);
end


---------------------------------------------------------------------------------
--- OrderHallTroopSummary                                                     ---
---------------------------------------------------------------------------------

OrderHallTroopSummary = { }

function OrderHallTroopSummary:OnEnter()
	if (self.name) then
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("TOPLEFT", self.Count, "BOTTOMRIGHT", -20, -20);
		GameTooltip:AddLine(self.name);
		GameTooltip:Show();
	end
end

function OrderHallTroopSummary:OnLeave()
	GameTooltip:Hide();
end

