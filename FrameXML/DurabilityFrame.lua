INVENTORY_ALERT_STATUS_SLOTS = {};
INVENTORY_ALERT_STATUS_SLOTS[1] = {slot = "Head"};
INVENTORY_ALERT_STATUS_SLOTS[2] = {slot ="Shoulders"};
INVENTORY_ALERT_STATUS_SLOTS[3] = {slot ="Chest"};
INVENTORY_ALERT_STATUS_SLOTS[4] = {slot ="Waist"};
INVENTORY_ALERT_STATUS_SLOTS[5] = {slot ="Legs"};
INVENTORY_ALERT_STATUS_SLOTS[6] = {slot ="Feet"};
INVENTORY_ALERT_STATUS_SLOTS[7] = {slot ="Wrists"};
INVENTORY_ALERT_STATUS_SLOTS[8] = {slot ="Hands"};
INVENTORY_ALERT_STATUS_SLOTS[9] = {slot ="Weapon", showSeparate = 1};
INVENTORY_ALERT_STATUS_SLOTS[10] = {slot ="Shield", showSeparate = 1};
INVENTORY_ALERT_STATUS_SLOTS[11] = {slot ="Ranged", showSeparate = 1};

INVENTORY_ALERT_COLORS = {};
INVENTORY_ALERT_COLORS[0] = nil;
--INVENTORY_ALERT_COLORS[1] = {r = 0.18, g = 0.72, b = 0.18};
--INVENTORY_ALERT_COLORS[2] = {r = 0.18, g = 0.72, b = 1};
INVENTORY_ALERT_COLORS[1] = nil;
INVENTORY_ALERT_COLORS[2] = nil;
INVENTORY_ALERT_COLORS[3] = {r = 1, g = 0.82, b = 0.18};
INVENTORY_ALERT_COLORS[4] = {r = 0.93, g = 0.07, b = 0.07};

function DurabilityFrame_SetAlerts()
	DurabilityFrame.enchantTimer = nil;
	local numAlerts = 0;
	local texture, color, showDurability;
	for index, value in INVENTORY_ALERT_STATUS_SLOTS do
		texture = getglobal("Durability"..value.slot);
		if ( value.slot == "Shield" ) then
			if ( OffhandHasWeapon() ) then
				DurabilityShield:Hide();
				texture = DurabilityOffWeapon;
			else
				DurabilityOffWeapon:Hide();
				texture = DurabilityShield;
			end
		end

		local alertStatus = GetInventoryAlertStatus(index);
		color = INVENTORY_ALERT_COLORS[alertStatus];
		if ( alertStatus == 1 ) then
			--DurabilityFrame.enchantTimer = 1;
		end
		if ( color ) then
			texture:SetVertexColor(color.r, color.g, color.b, 1.0);
			if ( value.showSeparate ) then
				texture:Show();			
			else
				showDurability = 1;
			end
			numAlerts = numAlerts + 1;
		else
			texture:SetVertexColor(1.0, 1.0, 1.0, 0.5);
			if ( value.showSeparate ) then
				texture:Hide();			
			end
		end
	end
	for index, value in INVENTORY_ALERT_STATUS_SLOTS do
		if ( not value.showSeparate ) then
			if ( showDurability ) then
				getglobal("Durability"..value.slot):Show();
			else
				getglobal("Durability"..value.slot):Hide();
			end
		end
	end

	if ( numAlerts > 0 ) then
		DurabilityFrame:Show();
	else
		DurabilityFrame:Hide();
	end
end

function DurabilityFrame_OnUpdate(elapsed)
	if ( DurabilityFrame.enchantTimer ) then
		DurabilityFrame.enchantTimer = DurabilityFrame.enchantTimer - elapsed;
		if ( DurabilityFrame.enchantTimer < 0 ) then
			DurabilityFrame.enchantTimer = nil;
			UpdateInventoryAlertStatus();
		end
	end
end

--[[
function DurabilityFrame_UpdatePosition()
	if ( QuestTimerFrame:IsVisible() ) then
		DurabilityFrame:SetPoint("TOP", "QuestTimerFrame", "BOTTOM", 30, -5);
	elseif ( MultiBarLeft:IsVisible() ) then
		DurabilityFrame:SetPoint("TOP", "MinimapCluster", "BOTTOM", -40, 15);
	elseif ( MultiBarRight:IsVisible() ) then
		DurabilityFrame:SetPoint("TOP", "MinimapCluster", "BOTTOM", 0, 15);
	else
		DurabilityFrame:SetPoint("TOP", "MinimapCluster", "BOTTOM", 40, 15);
	end
end
]]