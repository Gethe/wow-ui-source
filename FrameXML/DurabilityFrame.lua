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
INVENTORY_ALERT_COLORS[1] = {r = 1, g = 0.82, b = 0.18};
INVENTORY_ALERT_COLORS[2] = {r = 0.93, g = 0.07, b = 0.07};

function DurabilityFrame_SetAlerts()
	local numAlerts = 0;
	local texture, color, showDurability;
	for index, value in pairs(INVENTORY_ALERT_STATUS_SLOTS) do
		texture = _G["Durability"..value.slot];
		if ( value.slot == "Shield" ) then
			if ( OffhandHasWeapon() ) then
				DurabilityShield:Hide();
				texture = DurabilityOffWeapon;
			else
				DurabilityOffWeapon:Hide();
				texture = DurabilityShield;
			end
		end

		color = INVENTORY_ALERT_COLORS[GetInventoryAlertStatus(index)];
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
	for index, value in pairs(INVENTORY_ALERT_STATUS_SLOTS) do
		if ( not value.showSeparate ) then
			if ( showDurability ) then
				_G["Durability"..value.slot]:Show();
			else
				_G["Durability"..value.slot]:Hide();
			end
		end
	end

	if ( numAlerts > 0 and (not VehicleSeatIndicator:IsShown()) and ((not ArenaEnemyFrames) or (not ArenaEnemyFrames:IsShown())) ) then
		DurabilityFrame:Show();
	else
		DurabilityFrame:Hide();
	end
end
