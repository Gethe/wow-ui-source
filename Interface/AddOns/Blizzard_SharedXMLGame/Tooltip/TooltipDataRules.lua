
local LineTypeEnums = Enum.TooltipDataLineType;
local TooltipTypeEnums = Enum.TooltipDataType;

TooltipDataRules = { };

function TooltipDataRules.UnitName(tooltip, lineData)
	local unitToken = lineData.unitToken;
	if unitToken then
		local r, g, b = GameTooltip_UnitColor(unitToken);
		if r then
			lineData.leftColor = CreateColor(r, g, b);
		end
	end
end
TooltipDataProcessor.AddLinePreCall(LineTypeEnums.UnitName, TooltipDataRules.UnitName);

function TooltipDataRules.GemSocket(tooltip, lineData)
	local asset;
	local gemIcon = lineData.gemIcon;
	if gemIcon then
		asset = gemIcon;
	else
		local socketType = lineData.socketType;
		if socketType then
			asset = string.format("Interface\\ItemSocketingFrame\\UI-EmptySocket-%s", socketType);
		end
	end
	if asset then
		tooltip:AddTexture(asset);
	end
end
TooltipDataProcessor.AddLinePostCall(LineTypeEnums.GemSocket, TooltipDataRules.GemSocket);

function TooltipDataRules.UnitThreat(tooltip, lineData)
	local threatLevel = lineData.threatLevel;
	if threatLevel then
		local asset = "Interface\\RaidFrame\\UI-RaidFrame-Threat";
		local r, g, b = GetThreatStatusColor(threatLevel);
		local textureSettings = {
			vertexColor = { r = r, g = g, b = b };
		};
		tooltip:AddTexture(asset, textureSettings);
	end
end
TooltipDataProcessor.AddLinePostCall(LineTypeEnums.UnitThreat, TooltipDataRules.UnitThreat);

function TooltipDataRules.LearnableSpell(tooltip, lineData)
	local asset = lineData.spellIcon;
	if asset then
		tooltip:AddTexture(asset);
	end
end
TooltipDataProcessor.AddLinePostCall(LineTypeEnums.LearnableSpell, TooltipDataRules.LearnableSpell);

function TooltipDataRules.AzeriteEssencePower(tooltip, lineData)
	local powerState = lineData.powerState;
	if powerState then
		local asset = "heartofazeroth-tooltip-dash-"..powerState;
		local textureSettings = {
			width = 8,
			height = 4,
			verticalOffset = -6,
			margin = { right = 4, left = -3 },
		};
		tooltip:AddTexture(asset, textureSettings);
	end	
end
TooltipDataProcessor.AddLinePostCall(LineTypeEnums.AzeriteEssencePower, TooltipDataRules.AzeriteEssencePower);

function TooltipDataRules.AzeriteEssenceSlot(tooltip, lineData)
	local slotType = lineData.slotType;
	local disabled = lineData.disabled;
	if slotType then
		-- add the essence first if present
		local essenceIcon = lineData.essenceIcon;
		if essenceIcon then
			local textureSettings = {
				width = 10,
				height = 10,
				verticalOffset = -1,
				texCoords = { left = 0.171875, right = 0.828125, top = 0.171875, bottom = 0.828125 },
				desaturation = disabled and 1 or 0;
			};
			tooltip:AddTexture(essenceIcon, textureSettings);
		end
		-- then the border
		local asset = "tooltip-heartofazerothessence-"..slotType;
		local textureSettings = {
			width = 18,
			height = 12,
			margin = { right = 4 },
			desaturation = disabled and 1 or 0;
		};
		tooltip:AddTexture(asset, textureSettings);
	end
end
TooltipDataProcessor.AddLinePostCall(LineTypeEnums.AzeriteEssenceSlot, TooltipDataRules.AzeriteEssenceSlot);

local QUEST_OBJECTIVE_ICON_COMPLETED = 628564;
local QUEST_OBJECTIVE_ICON_INCOMPLETE = 3083385;
function TooltipDataRules.QuestObjective(tooltip, lineData)
	local completed = lineData.completed;
	local asset = completed and QUEST_OBJECTIVE_ICON_COMPLETED or QUEST_OBJECTIVE_ICON_INCOMPLETE;
	local textureSettings = {
		width = 16,
		height = 16,
		verticalOffset = 2,
		margin = { right = 2, top = -2, bottom = -2 },
	};
	tooltip:AddTexture(asset, textureSettings);
end
TooltipDataProcessor.AddLinePostCall(LineTypeEnums.QuestObjective, TooltipDataRules.QuestObjective);

local INDENTATION_OFFSET = 10;
function TooltipDataRules.LeftOffsetPowerDescription(tooltip, lineData)
	lineData.leftOffset = INDENTATION_OFFSET;
end
TooltipDataProcessor.AddLinePreCall(LineTypeEnums.AzeriteItemPowerDescription, TooltipDataRules.LeftOffsetPowerDescription);
TooltipDataProcessor.AddLinePreCall(LineTypeEnums.RuneforgeLegendaryPowerDescription, TooltipDataRules.LeftOffsetPowerDescription);

local GEM_ENCHANTMENT_OFFSET = 20;
function TooltipDataRules.GemSocketEnchantment(tooltip, lineData)
	-- Indent so it is aligned with the name of the gem and change text color from green to yellow
	lineData.leftOffset = GEM_ENCHANTMENT_OFFSET;
	lineData.leftColor = NORMAL_FONT_COLOR;
end
TooltipDataProcessor.AddLinePreCall(LineTypeEnums.GemSocketEnchantment, TooltipDataRules.GemSocketEnchantment);

function TooltipDataRules.HealthBar(tooltip, tooltipData)
	if tooltip.StatusBar then
		local healthGUID = tooltipData.healthGUID;
		if healthGUID then
			tooltip.StatusBar:SetWatch(healthGUID);
		else
			tooltip.StatusBar:ClearWatch();
		end
	end
end
TooltipDataProcessor.AddTooltipPostCall(TooltipTypeEnums.Unit, TooltipDataRules.HealthBar);
TooltipDataProcessor.AddTooltipPostCall(TooltipTypeEnums.Object, TooltipDataRules.HealthBar);

function TooltipDataRules.SellPrice(tooltip, lineData)
	local price = lineData.price;
	if price and not tooltip.isShopping then
		GameTooltip_OnTooltipAddMoney(tooltip, price, lineData.maxPrice);
	end
end
TooltipDataProcessor.AddLinePostCall(LineTypeEnums.SellPrice, TooltipDataRules.SellPrice);

function TooltipDataRules.FinalizeItemTooltip(tooltip, tooltipData)
	-- repair cost
	local repairCost = tooltipData.repairCost;
	if repairCost and InRepairMode() then
		tooltip:AddLine(REPAIR_COST, nil, nil, nil, true);
		SetTooltipMoney(tooltip, repairCost);
	end

	-- style
	if not tooltip.IsEmbedded then
		if tooltipData.isAzeriteEmpoweredItem or tooltipData.isAzeriteItem then
			tooltip:SetInfoBackdropStyle(GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM);
		elseif tooltipData.isCorruptedItem then
			tooltip:SetInfoBackdropStyle(GAME_TOOLTIP_BACKDROP_STYLE_CORRUPTED_ITEM);
		end
	end
	
	if tooltip.supportsItemComparison then
		local tooltipInfo = tooltip:GetProcessingTooltipInfo();
		if tooltipInfo.compareItem or TooltipUtil.ShouldDoItemComparison() then
			GameTooltip_ShowCompareItem(tooltip);
		else
			TooltipComparisonManager:Clear(tooltip);
		end
	end
end
TooltipDataProcessor.AddTooltipPostCall(TooltipTypeEnums.Item, TooltipDataRules.FinalizeItemTooltip);

function TooltipDataRules.BattlePet(tooltip, tooltipData)
	local battlePetSpeciesID = tooltipData.battlePetSpeciesID;
	local level = tooltipData.battlePetLevel;
	local breedQuality = tooltipData.battlePetBreedQuality;
	local maxHealth = tooltipData.battlePetMaxHealth;
	local power = tooltipData.battlePetPower;
	local speed = tooltipData.battlePetSpeed;
	local name = tooltipData.battlePetName;
	BattlePetToolTip_Show(battlePetSpeciesID, level, breedQuality, maxHealth, power, speed, name);
	return true;
end
TooltipDataProcessor.AddTooltipPreCall(TooltipTypeEnums.BattlePet, TooltipDataRules.BattlePet);

function TooltipDataRules.Separator(tooltip, lineData)
	local asset = "Interface\\Common\\UI-TooltipDivider-Transparent"
	local textureSettings = {
		width = 200,
		height = 10,
		margin = { right = 2, top = -2, bottom = -2 },
		texCoords = { left = 0, right = 1, top = 0, bottom = 1 },
	};
	tooltip:AddTexture(asset, textureSettings);
end
TooltipDataProcessor.AddLinePostCall(LineTypeEnums.Separator, TooltipDataRules.Separator);

function TooltipDataRules.WorldLootObjectPickUpIndicator(tooltip, tooltipData)
	local inventoryType = tooltipData.worldLootObjectInventoryType;
	if not inventoryType then
		return;
	end

	EventRegistry:TriggerEvent("WorldLootObjectTooltip.Shown", inventoryType, tooltip, tooltipData.id, tooltipData.worldLootObjectGUID); 
end
TooltipDataProcessor.AddTooltipPostCall(TooltipTypeEnums.Spell, TooltipDataRules.WorldLootObjectPickUpIndicator);
