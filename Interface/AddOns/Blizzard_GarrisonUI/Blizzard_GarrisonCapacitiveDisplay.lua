UIPanelWindows["GarrisonCapacitiveDisplayFrame"] = { area = "left", pushable = 0, };

function GarrisonCapacitiveDisplayFrame_ToggleFrame()
	if (not GarrisonCapacitiveFrame:IsShown()) then
		ShowUIPanel(GarrisonCapacitiveDisplayFrame);
	else
		HideUIPanel(GarrisonCapacitiveDisplayFrame);
	end
end

function GarrisonCapacitiveDisplayFrame_OnLoad(self)
    self:RegisterEvent("SHIPMENT_CRAFTER_OPENED");
    self:RegisterEvent("SHIPMENT_CRAFTER_CLOSED");
    self:RegisterEvent("SHIPMENT_CRAFTER_INFO");
    self:RegisterEvent("SHIPMENT_CRAFTER_REAGENT_UPDATE");
    self:RegisterEvent("SHIPMENT_UPDATE");
	self.available = 0;
end

local shipmentUpdater;

function GarrisonCapacitiveDisplayFrame_TimerUpdate()
	local self = GarrisonCapacitiveDisplayFrame;
	GarrisonCapacitiveDisplayFrame_Update(self, true, self.maxShipments, self.ownedShipments, self.plotID);
end

function GarrisonCapacitiveDisplayFrame_Update(self, success, maxShipments, ownedShipments, plotID)
	if (success ~= 0) then
		self.maxShipments = maxShipments;
		self.ownedShipments = ownedShipments;
		self.plotID = plotID;

		local display = self.CapacitiveDisplay;

		local numPending = C_Garrison.GetNumPendingShipments();
		local display = self.CapacitiveDisplay;

		if (not numPending) then
			return;
		end

		if ( C_Garrison.IsOnShipmentQuestForNPC() ) then
			maxShipments = 1;
			self.maxShipments = 1;
		end

		local available = max(maxShipments - numPending - ownedShipments, 0);

		self.available = available;
		display.ShipmentIconFrame.itemId = nil;


	    local reagents = display.Reagents;

	    for i = 1, #reagents do
	    	reagents[i]:Hide();
	    end

	    for i = 1, C_Garrison.GetNumShipmentReagents() do
	    	local reagent = reagents[i];
	    	if (not reagent) then
	    		reagent = CreateFrame("Button", nil, display, "GarrisonCapacitiveItemButtonTemplate");
	    		reagent:SetID(i);
	    		reagent:SetPoint("TOP", reagents[i-1], "BOTTOM", 0, -6);
	    	end

	    	local name, texture, quality, needed, quantity, itemID = C_Garrison.GetShipmentReagentInfo(i);

	    	-- If we don't have a name here the data is not set up correctly, but this prevents lua errors later.
	    	if (not name) then
	    		break;
	    	end

			reagent.Icon:SetTexture(texture);
			reagent.Name:SetText(name);
			reagent.Name:SetTextColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b);
			-- Grayout items
			if ( quantity < needed ) then
				reagent.Icon:SetVertexColor(0.5, 0.5, 0.5);
				reagent.Name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				self.available = 0;
			else
				reagent.Icon:SetVertexColor(1.0, 1.0, 1.0);
				reagent.Name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				self.available = min(self.available, floor(quantity/needed));
			end
			quantity = AbbreviateNumbers(quantity);
			reagent.Count:SetText(quantity.." /"..needed);
			--fix text overflow when the reagent count is too high
			if (math.floor(reagent.Count:GetStringWidth()) > math.floor(reagent.Icon:GetWidth() + .5)) then
			--round count width down because the leftmost number can overflow slightly without looking bad
			--round icon width because it should always be an int, but sometimes it's a slightly off float
				reagent.Count:SetText(quantity.."\n/"..needed);
			end
	 	   	reagent.itemId = itemID;
	 	   	reagent.currencyID = nil;
	 	   	reagent:Show();
	    end

		local currencyCount = C_Garrison.GetNumShipmentCurrencies();
		local reagentCount = C_Garrison.GetNumShipmentReagents();
		for currencyIndex = 1, currencyCount do
			local currencyID, currencyNeeded = C_Garrison.GetShipmentReagentCurrencyInfo(currencyIndex);

			if (currencyID and currencyNeeded) then
				local i = reagentCount + currencyIndex;

				local reagent = reagents[i];
				if (not reagent) then
					reagent = CreateFrame("Button", nil, display, "GarrisonCapacitiveItemButtonTemplate");
					reagent:SetID(i);
					reagent:SetPoint("TOP", reagents[i-1], "BOTTOM", 0, -6);
				end

				local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);

				-- If we don't have currencyInfo here the data is not set up correctly, but this prevents lua errors later.
				if (currencyInfo) then
					local quantity = currencyInfo.quantity;
					local quality = currencyInfo.quality;
					reagent.Icon:SetTexture(currencyInfo.iconFileID);
					reagent.Name:SetText(currencyInfo.name);
					reagent.Name:SetTextColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b);
					-- Grayout items
					if ( quantity < currencyNeeded ) then
						reagent.Icon:SetVertexColor(0.5, 0.5, 0.5);
						reagent.Name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
						self.available = 0;
					else
						reagent.Icon:SetVertexColor(1.0, 1.0, 1.0);
						reagent.Name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
						self.available = min(self.available, floor(quantity / currencyNeeded));
					end
					quantity = AbbreviateNumbers(quantity);
					reagent.Count:SetText(quantity.." /"..currencyNeeded);
					--fix text overflow when the reagent count is too high
					if (math.floor(reagent.Count:GetStringWidth()) > math.floor(reagent.Icon:GetWidth() + .5)) then
					--round count width down because the leftmost number can overflow slightly without looking bad
					--round icon width because it should always be an int, but sometimes it's a slightly off float
						reagent.Count:SetText(quantity.."\n/"..currencyNeeded);
					end
					reagent.itemId = nil;
					reagent.currencyID = currencyID;
					reagent:Show();
				end
			end
		end

	    local name, texture, quality, itemID, followerID, duration = C_Garrison.GetShipmentItemInfo();
        if ( followerID ) then
            self.StartWorkOrderButton:SetText(CAPACITANCE_START_RECRUITMENT);
            self.CreateAllWorkOrdersButton:SetText(CAPACITANCE_RECRUIT_ALL);
		else
            self.StartWorkOrderButton:SetText(CAPACITANCE_START_WORK_ORDER);
            self.CreateAllWorkOrdersButton:SetText(CREATE_ALL);
        end

		-- Resize buttons to distribute space around text evenly
		local button1TextWidth = self.CreateAllWorkOrdersButton.Text:GetWidth();
		local button2TextWidth = self.StartWorkOrderButton.Text:GetWidth();
		local buttonDiffOverTwo = (button1TextWidth - button2TextWidth) / 2;
		local averageButtonWidth = 240 / 2;

		self.CreateAllWorkOrdersButton:SetWidth(averageButtonWidth + buttonDiffOverTwo);
		self.StartWorkOrderButton:SetWidth(averageButtonWidth - buttonDiffOverTwo);

		if (not quality) then
			quality = Enum.ItemQuality.Common;
		end

		if (not duration) then
			duration = 0;
		end

		local pendingText, description = C_Garrison.GetShipmentContainerInfo();

		local _, buildingName = C_Garrison.GetOwnedBuildingInfoAbbrev(self.plotID);

		self:SetTitle(buildingName);
		self.StartWorkOrderButton:SetEnabled(self.available > 0);

		if UnitExists("npc") then
			self:SetPortraitToUnit("npc");
		else
			self:SetPortraitToAsset("Interface\\QuestFrame\\UI-QuestLog-BookIcon");
		end

	    local followerName = C_Garrison.GetFollowerInfoForBuilding(self.plotID);

	    display.FollowerActive:SetShown(followerName ~= nil);

		display.Description:SetText(description);

		local followerInfo;
		if (followerID) then
			followerInfo = C_Garrison.GetFollowerInfo(followerID);
		end
		if (followerInfo) then
			display.ShipmentIconFrame.ShipmentName:SetText(followerInfo.name);
			display.ShipmentIconFrame.Follower:SetupPortrait(followerInfo);
			display.ShipmentIconFrame.Follower:SetNoLevel();
			display.ShipmentIconFrame.Follower:Show();
			display.ShipmentIconFrame.Icon:Hide();
		else
			display.ShipmentIconFrame.ShipmentName:SetText(name);
			display.ShipmentIconFrame.Follower:Hide();
			display.ShipmentIconFrame.Icon:Show();
		end

		-- check the original available here. we dont' want to say 0 if you don't have the reagents.
		-- should we say 0 if you can't make any due to follower limits?
		if (available > 0) then
			if (shipmentUpdater) then
				shipmentUpdater:Cancel();
				shipmentUpdater = nil;
			end
            if (followerID) then
                display.ShipmentIconFrame.ShipmentsAvailable:SetFormattedText(CAPACITANCE_RECRUIT_COUNT, available);
            else
    			display.ShipmentIconFrame.ShipmentsAvailable:SetFormattedText(CAPACITANCE_SHIPMENT_COUNT, available, maxShipments);
            end
		else
			local timeRemaining = select(7,C_Garrison.GetPendingShipmentInfo(1));
			if (timeRemaining ~= nil) then
				if (timeRemaining ~= 0) then
					if (not shipmentUpdater) then
						shipmentUpdater = C_Timer.NewTicker(1, GarrisonCapacitiveDisplayFrame_TimerUpdate);
					end
				end
				if (timeRemaining == 0) then
					display.ShipmentIconFrame.ShipmentsAvailable:SetText(GREEN_FONT_COLOR_CODE..CAPACITANCE_SHIPMENT_READY..FONT_COLOR_CODE_CLOSE);
				else
					display.ShipmentIconFrame.ShipmentsAvailable:SetText(RED_FONT_COLOR_CODE..CAPACITANCE_SHIPMENT_COOLDOWN:format(SecondsToTime(timeRemaining, false, true, 1))..FONT_COLOR_CODE_CLOSE);
				end
			else
				if (followerID) then
					display.ShipmentIconFrame.ShipmentsAvailable:SetFormattedText(CAPACITANCE_RECRUIT_COUNT, available);
				else
    				display.ShipmentIconFrame.ShipmentsAvailable:SetFormattedText(CAPACITANCE_SHIPMENT_COUNT, available, maxShipments);
				end
			end
		end

		display.Description:ClearAllPoints();
		if (numPending > 0) then
			local lastTimeRemaining = select(7, C_Garrison.GetPendingShipmentInfo(numPending));
			display.Description:SetPoint("TOPLEFT", display.LastComplete, "BOTTOMLEFT", 0, -12);
            if (followerID) then
                display.LastComplete:SetFormattedText(CAPACITANCE_ALL_RECRUITMENT_COMPLETE, SecondsToTime(lastTimeRemaining, false, true, 1));
            else
    			display.LastComplete:SetFormattedText(CAPACITANCE_ALL_COMPLETE, SecondsToTime(lastTimeRemaining, false, true, 1));
            end
			display.LastComplete:Show();
		else
			display.LastComplete:Hide();
			display.Description:SetPoint("TOPLEFT", display.IconBG, "BOTTOMLEFT", -48, -12);
		end

		display.ShipmentIconFrame.Icon:SetTexture(texture);
		display.ShipmentIconFrame.itemId = itemID;

		self.CreateAllWorkOrdersButton:SetEnabled(self.available > 0);

		ShowUIPanel(GarrisonCapacitiveDisplayFrame);
	end
end

function GarrisonCapacitiveDisplayFrame_OnEvent(self, event, ...)
	if (event == "SHIPMENT_CRAFTER_OPENED") then
		self.containerID = ...;
	elseif (event == "SHIPMENT_CRAFTER_INFO") then
		local success, _, maxShipments, ownedShipments, plotID = ...;

		GarrisonCapacitiveDisplayFrame_Update(self, success, maxShipments, ownedShipments, plotID);
	elseif (event == "SHIPMENT_CRAFTER_CLOSED") then
		self.containerID = nil;

		if (shipmentUpdater) then
			shipmentUpdater:Cancel();
		end
		shipmentUpdater = nil;

		HideUIPanel(GarrisonCapacitiveDisplayFrame);
	elseif (event == "SHIPMENT_CRAFTER_REAGENT_UPDATE") then
		if (self.plotID and self.maxShipments) then
			GarrisonCapacitiveDisplayFrame_Update(self, true, self.maxShipments, self.ownedShipments, self.plotID);
		end
	elseif (event == "SHIPMENT_UPDATE") then
		local shipmentStarted = ...;
		if (shipmentStarted) then
			self.FinishedGlow.FinishedAnim:Play();
		end
		C_Garrison.RequestShipmentInfo();
	end
end

function GarrisonCapacitiveDisplayFrame_OnShow(self)
	PlaySound(SOUNDKIT.UI_GARRISON_SHIPMENTS_WINDOW_OPEN);
	self.Count:SetNumber(1);
end

function GarrisonCapacitiveDisplayFrame_OnHide(self)
	if (shipmentUpdater) then
		shipmentUpdater:Cancel();
		shipmentUpdater = nil;
	end
	C_Garrison.CloseTradeskillCrafter();
	PlaySound(SOUNDKIT.UI_GARRISON_SHIPMENTS_WINDOW_CLOSE);
end

function GarrisonCapacitiveStartWorkOrder_OnClick(self)
	C_Garrison.RequestShipmentCreation(GarrisonCapacitiveDisplayFrame.requested);
	PlaySound(SOUNDKIT.UI_GARRISON_START_WORK_ORDER);
	GarrisonCapacitiveDisplayFrame.Count:SetNumber(1);
end

function GarrisonCapacitiveCreateAllWorkOrders_OnClick(self)
	local available = GarrisonCapacitiveDisplayFrame.available;
	if (available and available > 0) then
		C_Garrison.RequestShipmentCreation(available);
		PlaySound(SOUNDKIT.UI_GARRISON_START_WORK_ORDER);
	end
	GarrisonCapacitiveDisplayFrame.Count:SetNumber(1);
end

function GarrisonCapacitiveDisplayFrameIncrement_OnClick()
	local self = GarrisonCapacitiveDisplayFrame;
	if ( self.Count:GetNumber() < self.available ) then
		self.Count:SetNumber(self.Count:GetNumber() + 1);
	end
end

function GarrisonCapacitiveDisplayFrameDecrement_OnClick()
	local self = GarrisonCapacitiveDisplayFrame;
	if ( self.Count:GetNumber() > 1 ) then
		self.Count:SetNumber(self.Count:GetNumber() - 1);
	end
end

function GarrisonCapacitiveDisplay_SetRequestedNumber(num)
	local self = GarrisonCapacitiveDisplayFrame;
	self.requested = max(1, min(num, self.available));
end
