local RESOURCE_ATLAS = {
	[Enum.WarfrontResourceType.Iron] = "Warfront-HUD-Iron",
	[Enum.WarfrontResourceType.Lumber] = "Warfront-HUD-Lumber",
	[Enum.WarfrontResourceType.Essence] = "Warfront-HUD-ArmorScraps",
	[Enum.WarfrontResourceType.Food] = "Warfront-HUD-Food",
};

WarfrontResourceMixin = { };

function WarfrontResourceMixin:OnLoad()
	self.Icon:SetAtlas(RESOURCE_ATLAS[self.resourceType], true);
end

function WarfrontResourceMixin:OnEnter()
	local resourceInfo = C_Warfront.GetResourceInfo(self.resourceType);
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0);
	GameTooltip:SetText(resourceInfo.name);
	GameTooltip:AddLine(resourceInfo.description, 1, 1, 1, 1);
	GameTooltip:Show();
end

WarfrontCommandBarMixin = { };

function WarfrontCommandBarMixin:OnLoad()
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup == "Horde" ) then
		self.Background:SetAtlas("Warfront-Horde-HUD", true);
		self.Background:SetPoint("TOP", -1, 0);
	end

	self:RegisterEvent("WARFRONT_UPDATE");
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:Update();
end

function WarfrontCommandBarMixin:OnEvent(event)
	if ( event == "WARFRONT_UPDATE" or event == "UNIT_AURA" )  then
		self:Update();
	end
end

function WarfrontCommandBarMixin:OnShow()
	UIParent_UpdateTopFramePositions();
end

function WarfrontCommandBarMixin:OnHide()
	UIParent_UpdateTopFramePositions();
end

function WarfrontCommandBarMixin:Update()
	if ( C_Warfront.InWarfront() ) then
		self:Show();
		for i, resourceFrame in ipairs(self.Resources) do
			local resourceInfo = C_Warfront.GetResourceInfo(resourceFrame.resourceType);
			resourceFrame.Quantity:SetText(resourceInfo.quantity.."/"..resourceInfo.maxQuantity);
		end
	else
		self:Hide();
	end
end