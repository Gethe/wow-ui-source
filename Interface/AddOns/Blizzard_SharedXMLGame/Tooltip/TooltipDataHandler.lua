
-- =======================================================================
-- Tooltip data callback processor
-- =======================================================================

local issecure = issecure;
local forceinsecure = forceinsecure;

local SecureTooltipPreCalls = { };
local SecureTooltipPostCalls = { };
local SecureLinePreCalls = { };
local SecureLinePostCalls = { };

local InsecureTooltipPreCalls = { };
local InsecureTooltipPostCalls = { };
local InsecureLinePreCalls = { };
local InsecureLinePostCalls = { };

local secureTables = {
	tooltipPreCall = SecureTooltipPreCalls,
	tooltipPostCall = SecureTooltipPostCalls,
	linePreCall = SecureLinePreCalls,
	linePostCall = SecureLinePostCalls,
};

local insecureTables = {
	tooltipPreCall = InsecureTooltipPreCalls,
	tooltipPostCall = InsecureTooltipPostCalls,
	linePreCall = InsecureLinePreCalls,
	linePostCall = InsecureLinePostCalls,
};

local function InternalAddCall(tbl, keyType, func)
	if not keyType then
		return;
	end
	local calls = tbl[keyType];
	if not calls then
		tbl[keyType] = { };
		calls = tbl[keyType];
	end
	table.insert(calls, func);
end

local function MakeSecureCalls(funcTbl, canTerminate, ...)
	if not funcTbl then
		return;
	end
	for i, func in ipairs(funcTbl) do
		if func(...) and canTerminate then
			return true;
		end
	end
end

local function MakeInsecureCalls(funcTbl, canTerminate, ...)
	if not funcTbl then
		return;
	end
	for i, func in ipairs(funcTbl) do
		local result = securecallfunction(func, ...);
		if result and canTerminate then
			return true;
		end
	end
end

local function ProcessSecureCalls(tbl, canTerminate, keyType, ...)
	if MakeSecureCalls(tbl[TooltipDataProcessor.AllTypes], canTerminate, ...) and canTerminate then
		return true;
	end
	if MakeSecureCalls(tbl[keyType], canTerminate, ...) and canTerminate then
		return true;
	end
end

local function ProcessInsecureCalls(tbl, canTerminate, keyType, ...)
	if MakeInsecureCalls(tbl[TooltipDataProcessor.AllTypes], canTerminate, ...) and canTerminate then
		return true;
	end
	if MakeInsecureCalls(tbl[keyType], canTerminate, ...) and canTerminate then
		return true;
	end
end

local InsertCallbackAttributes = {
	[InsecureTooltipPreCalls] = "insert-tooltip-pre-call",
	[InsecureTooltipPostCalls] = "insert-tooltip-post-call",
	[InsecureLinePreCalls] = "insert-line-pre-call",
	[InsecureLinePostCalls] = "insert-line-post-call",
};

local InsertCallbackTables = tInvert(InsertCallbackAttributes);

local ProcessCallbackAttributes = {
	[InsecureTooltipPreCalls] = "process-tooltip-pre-call",
	[InsecureTooltipPostCalls] = "process-tooltip-post-call",
	[InsecureLinePreCalls] = "process-line-pre-call",
	[InsecureLinePostCalls] = "process-line-post-call",
};

local ProcessCallbackTables = tInvert(ProcessCallbackAttributes);
local ProcessCallbackResultAttribute = "process-callback-result";

local AttributeDelegate = CreateFrame("FRAME");
AttributeDelegate:SetForbidden();
AttributeDelegate:SetScript("OnAttributeChanged", function(self, attribute, value)
	local callTable = InsertCallbackTables[attribute];
	if callTable then
		local keyType, func = securecallfunction(unpack, value);
		InternalAddCall(callTable, keyType, func);
	end

	local processTable = ProcessCallbackTables[attribute];
	if processTable then
		local argCount = securecallfunction(rawget, value, "n");
		AttributeDelegate:SetAttribute(ProcessCallbackResultAttribute, ProcessInsecureCalls(processTable, securecallfunction(unpack, value, 1, argCount)));
	end
end);

local CAN_TERMINATE = true;

local function ProcessTooltipPreCalls(tooltipType, ...)
	local result = ProcessSecureCalls(SecureTooltipPreCalls, CAN_TERMINATE, tooltipType, ...);
	if result then
		return result;
	end

	if next(InsecureTooltipPreCalls) then
		AttributeDelegate:SetAttribute(ProcessCallbackAttributes[InsecureTooltipPreCalls], SafePack(CAN_TERMINATE, tooltipType, ...));
		return AttributeDelegate:GetAttribute(ProcessCallbackResultAttribute);
	end
end

local function ProcessTooltipPostCalls(tooltipType, ...)
	local result = ProcessSecureCalls(SecureTooltipPostCalls, not CAN_TERMINATE, tooltipType, ...);
	if result then
		return result;
	end

	if next(InsecureTooltipPostCalls) then
		AttributeDelegate:SetAttribute(ProcessCallbackAttributes[InsecureTooltipPostCalls], SafePack(not CAN_TERMINATE, tooltipType, ...));
		return AttributeDelegate:GetAttribute(ProcessCallbackResultAttribute);
	end
end

local function ProcessLinePreCalls(lineType, ...)
	local result = ProcessSecureCalls(SecureLinePreCalls, CAN_TERMINATE, lineType, ...);
	if result then
		return result;
	end

	if next(InsecureLinePreCalls) then
		AttributeDelegate:SetAttribute(ProcessCallbackAttributes[InsecureLinePreCalls], SafePack(CAN_TERMINATE, lineType, ...));
		return AttributeDelegate:GetAttribute(ProcessCallbackResultAttribute);
	end
end

local function ProcessLinePostCalls(lineType, ...)
	local result = ProcessSecureCalls(SecureLinePostCalls, not CAN_TERMINATE, lineType, ...);
	if result then
		return result;
	end

	if next(InsecureLinePostCalls) then
		AttributeDelegate:SetAttribute(ProcessCallbackAttributes[InsecureLinePostCalls], SafePack(not CAN_TERMINATE, lineType, ...));
		return AttributeDelegate:GetAttribute(ProcessCallbackResultAttribute);
	end
end

TooltipDataProcessor = {
	AllTypes = "ALL";
};

local function AddCall(callType, keyType, func)
	if issecure() then
		local tbl = secureTables[callType];
		InternalAddCall(tbl, keyType, func);
	else
		local tbl = insecureTables[callType];
		local function InsecureCallback(...)
			forceinsecure();
			return func(...);
		end
		AttributeDelegate:SetAttribute(InsertCallbackAttributes[tbl], { keyType, InsecureCallback });
	end
end

function TooltipDataProcessor.AddTooltipPreCall(tooltipType, func)
	AddCall("tooltipPreCall", tooltipType, func);
end

function TooltipDataProcessor.AddTooltipPostCall(tooltipType, func)
	AddCall("tooltipPostCall", tooltipType, func);
end

function TooltipDataProcessor.AddLinePreCall(lineType, func)
	AddCall("linePreCall", lineType, func);
end

function TooltipDataProcessor.AddLinePostCall(lineType, func)
	AddCall("linePostCall", lineType, func);
end

-- =======================================================================
-- Tooltip data parser that should be mixed in by any tooltip that wants :SetX functionality
-- =======================================================================

--[[ info table layout
	getterName		: If tooltipData is not set, the C_TooltipInfo function to call. The data returned will be set as tooltipData in this table.
	getterArgs		: Optional table of arguments for the C_TooltipInfo call.
	tooltipData		: In some places code already has this data, so it can set this key and leave the getterName nil.
	append			: If true, the tooltip will not be cleared and the backdrop style (Azerite and Corrupted) will not be set.
	appendSpacer	: If true and append is true, will add a blank line before appending
	compareItem		: If true, an item comparison will start automatically.
	excludeLines	: Table of line types to exclude from the tooltip.
	linePreCall		: Callback for each line before it's added.
	linePostCall	: Callback for each line after it's added.
	tooltipPostCall : Callback for the tooltip after it has processed the info.
	rebuildPreCall	: Callback before the tooltip is rebuilt from a TOOLTIP_DATA_UPDATE. Only checked for primary info in the case of multiple.
	rebuildPostCall	: Callback after the tooltip is rebuilt from a TOOLTIP_DATA_UPDATE. Only checked for primary info in the case of multiple.
]]--

function CreateBaseTooltipInfo(getterName, ...)
	local tooltipInfo = {
		getterName = getterName,
		getterArgs = { ... };
	};
	return tooltipInfo;
end

TooltipDataHandlerMixin = { };

function TooltipDataHandlerMixin:ProcessInfo(info)
	return securecallfunction(self.InternalProcessInfo, self, info);
end

function TooltipDataHandlerMixin:InternalProcessInfo(info)
	if not info then
		return false;
	end

	if not info.tooltipData then
		if not info.getterName then
			return false;
		end
		if info.getterArgs then
			info.tooltipData = C_TooltipInfo[info.getterName](unpack(info.getterArgs));
		else
			info.tooltipData = C_TooltipInfo[info.getterName]();
		end
	end
	
	local tooltipData = info.tooltipData;
	if not tooltipData then
		if not info.append then
			self:Hide();
		end
		return false;
	end

	if not info.append then
		self.infoList = { };
		self:ClearLines();
	elseif not self.infoList then
		-- infoList will be missing in append mode if the tooltip needs to start with non-data text
		self.infoList = { };
	end
	
	table.insert(self.infoList, info);
	self.processingInfo = info;
	
	local tooltipType = tooltipData.type;
	if ProcessTooltipPreCalls(tooltipType, self, tooltipData) then
		return false;
	end

	if info.append and info.appendSpacer then
		GameTooltip_AddBlankLineToTooltip(self);
	end

	self:ProcessLines();

	if self.processingInfo.tooltipPostCall then
		self.processingInfo.tooltipPostCall(self);
	end

	ProcessTooltipPostCalls(tooltipType, self, tooltipData);

	self:Show();

	if not info.append and info.backdropStyle then
		SharedTooltip_SetBackdropStyle(self, info.backdropStyle);
	end

	return true;
end

function TooltipDataHandlerMixin:ProcessLines()
	local info = self.processingInfo;
	local excludeLines = info.excludeLines;
	local linePreCall = info.linePreCall;
	local linePostCall = info.linePostCall;
	for i, lineData in ipairs(info.tooltipData.lines) do
		self:ProcessLineData(lineData, excludeLines, linePreCall, linePostCall);
	end	
end

function TooltipDataHandlerMixin:ProcessLineData(lineData, excludeLines, linePreCall, linePostCall)
	local lineConsumed = excludeLines and tContains(excludeLines, lineData.type) or false;
	if not lineConsumed and linePreCall then
		lineConsumed = linePreCall(self, lineData);
	end
	if not lineConsumed then
		lineConsumed = ProcessLinePreCalls(lineData.type, self, lineData);
	end

	if not lineConsumed then
		self:AddLineDataText(lineData);
		lineData.lineIndex = self:NumLines();
		if linePostCall then
			linePostCall(self, lineData);
		end
		ProcessLinePostCalls(lineData.type, self, lineData);
	end
end

function TooltipDataHandlerMixin:AddLineDataText(lineData)
	local leftText = lineData.leftText;
	local leftColor = lineData.leftColor or NORMAL_FONT_COLOR;
	local wrapText = lineData.wrapText or false;
	local rightText = lineData.rightText;
	local leftOffset = lineData.leftOffset;
	if rightText then
		local rightColor = lineData.rightColor or NORMAL_FONT_COLOR;
		GameTooltip_AddColoredDoubleLine(self, leftText, rightText, leftColor, rightColor, wrapText, leftOffset);
	elseif leftText then
		GameTooltip_AddColoredLine(self, leftText, leftColor, wrapText, leftOffset);
	end
end


function TooltipDataHandlerMixin:ClearHandlerInfo()
	self.infoList = nil;
	self.processingInfo = nil;
end

function TooltipDataHandlerMixin:RebuildFromTooltipInfo()
	local oldPrimaryInfo = self:GetPrimaryTooltipInfo();
	if not oldPrimaryInfo then
		return;
	end

	local infoList = self.infoList;
	self.infoList = { };
	
	if oldPrimaryInfo.rebuildPreCall then
		local skipRebuild = oldPrimaryInfo.rebuildPreCall(self);
		if skipRebuild then
			return;
		end
	end

	for i, info in ipairs(infoList) do
		-- Remove cached data if there's a getter, otherwise assume that data is complete
		if info.getterName then
			info.tooltipData = nil;
		end
		-- It's bad if append is set for the primary info and the rebuild wasn't handled by the rebuildPreCall
		-- Usually that mean the tooltip was started with AddLine instead of SetX
		-- Clear it out so at least the tooltip doesn't duplicate
		if i == 1 then
			info.append = false;
		end
		self:ProcessInfo(info);
	end

	if oldPrimaryInfo.rebuildPostCall then
		oldPrimaryInfo.rebuildPostCall(self);
	end
end

function TooltipDataHandlerMixin:GetPrimaryTooltipInfo()
	return self.infoList and self.infoList[1];
end

function TooltipDataHandlerMixin:GetProcessingTooltipInfo()
	return self.processingInfo;
end

function TooltipDataHandlerMixin:SetInfoBackdropStyle(backdropStyle)
	local info = self:GetPrimaryTooltipInfo();
	if info then
		info.backdropStyle = backdropStyle;
	end
end

function TooltipDataHandlerMixin:GetPrimaryTooltipData()
	local info = self:GetPrimaryTooltipInfo();
	return info and info.tooltipData;
end

-- to be deprecated
function TooltipDataHandlerMixin:GetTooltipData()
	return self:GetPrimaryTooltipData();
end

function TooltipDataHandlerMixin:IsTooltipType(tooltipType)
	local primaryInfo = self:GetPrimaryTooltipInfo();
	return primaryInfo and primaryInfo.tooltipData and primaryInfo.tooltipData.type == tooltipType;
end

function TooltipDataHandlerMixin:HasDataInstanceID(dataInstanceID)
	if self.infoList then
		for i, info in ipairs(self.infoList) do
			if info.tooltipData and info.tooltipData.dataInstanceID == dataInstanceID then
				return true;
			end
		end
	end
	return false;
end

function TooltipDataHandlerMixin:AppendInfo(...)
	local tooltipInfo = CreateBaseTooltipInfo(...);
	tooltipInfo.append = true;
	self:ProcessInfo(tooltipInfo);
end

function TooltipDataHandlerMixin:AppendInfoWithSpacer(...)
	local tooltipInfo = CreateBaseTooltipInfo(...);
	tooltipInfo.append = true;
	tooltipInfo.appendSpacer = true;
	self:ProcessInfo(tooltipInfo);
end

function AddTooltipDataAccessor(handler, accessor, getterName)
	handler[accessor] = function(self, ...)
		local tooltipInfo = {
			getterName = getterName,
			getterArgs = { ... };
		};
		return self:ProcessInfo(tooltipInfo);
	end	
end
		
do
	local accessors = {
		SetMerchantItem = "GetMerchantItem",
		SetCurrencyToken = "GetCurrencyToken",
		SetItemByID = "GetItemByID",
		SetItemByItemModifiedAppearanceID = "GetItemByItemModifiedAppearanceID",
		SetInventoryItem = "GetInventoryItem",
		SetRecipeReagentItem = "GetRecipeReagentItem",
		SetWeeklyReward = "GetWeeklyReward",
		SetVoidItem = "GetVoidItem",
		SetVoidDepositItem = "GetVoidDepositItem",
		SetVoidWithdrawalItem = "GetVoidWithdrawalItem",
		SetInboxItem = "GetInboxItem",
		SetSendMailItem = "GetSendMailItem",
		SetTradePlayerItem = "GetTradePlayerItem",
		SetTradeTargetItem = "GetTradeTargetItem",
		SetQuestItem = "GetQuestItem",
		SetQuestLogItem = "GetQuestLogItem",
		SetQuestLogSpecialItem = "GetQuestLogSpecialItem",
		SetLootItem = "GetLootItem",
		SetLootRollItem = "GetLootRollItem",
		SetGuildBankItem = "GetGuildBankItem",
		SetHeirloomByItemID = "GetHeirloomByItemID",
		SetRuneforgeResultItem = "GetRuneforgeResultItem",
		SetTransmogrifyItem = "GetTransmogrifyItem",
		SetArtifactItem = "GetArtifactItem",
		SetBagItem = "GetBagItem",
		SetBagItemChild = "GetBagItemChild",
		SetBuybackItem = "GetBuybackItem",
		SetExistingSocketGem = "GetExistingSocketGem",
		SetInventoryItemByID = "GetInventoryItemByID",
		SetItemKey = "GetItemKey",
		SetLFGDungeonReward = "GetLFGDungeonReward",
		SetLFGDungeonShortageReward = "GetLFGDungeonShortageReward",
		SetSocketGem = "GetSocketGem",
		SetSocketedItem = "GetSocketedItem",
		SetSocketedRelic = "GetSocketedRelic",
		SetUpgradeItem = "GetUpgradeItem",
		SetBackpackToken = "GetBackpackToken",
		SetCurrencyByID = "GetCurrencyByID",
		SetLootCurrency = "GetLootCurrency",
		SetQuestCurrency = "GetQuestCurrency",
		SetQuestLogCurrency = "GetQuestLogCurrency",
		SetSpellByID = "GetSpellByID",
		SetArtifactPowerByID = "GetArtifactPowerByID",
		SetShapeshift = "GetShapeshift",
		SetAzeritePower = "GetAzeritePower",
		SetAzeriteEssence = "GetAzeriteEssence",
		SetAzeriteEssenceSlot = "GetAzeriteEssenceSlot",
		SetTalent = "GetTalent",
		SetPvpTalent = "GetPvpTalent",
		SetMountBySpellID = "GetMountBySpellID",
		SetPetAction = "GetPetAction",
		SetConduit = "GetConduit",
		SetCompanionPet = "GetCompanionPet",
		SetPossession = "GetPossession",
		SetAchievementByID = "GetAchievementByID",
		SetEnhancedConduit = "GetEnhancedConduit",
		SetEquipmentSet = "GetEquipmentSet",
		SetInstanceLockEncountersComplete = "GetInstanceLockEncountersComplete",
		SetPvpBrawl = "GetPvpBrawl",
		SetRecipeRankInfo = "GetRecipeRankInfo",
		SetTotem = "GetTotem",
		SetToyByItemID = "GetToyByItemID",
		SetMerchantCostItem = "GetMerchantCostItem",
		SetUnit = "GetUnit",
		SetTrainerService = "GetTrainerService",
		SetRecipeResultItem = "GetRecipeResultItem",
		SetRecipeResultItemForOrder = "GetRecipeResultItemForOrder",
		SetAction = "GetAction",
		SetSpellBookItem = "GetSpellBookItem",
		SetOwnedItemByID = "GetOwnedItemByID",
		SetQuestPartyProgress = "GetQuestPartyProgress",
		SetHyperlink = "GetHyperlink",
		SetUnitAura = "GetUnitAura",
		SetUnitBuff = "GetUnitBuff",
		SetUnitDebuff = "GetUnitDebuff",
		SetMinimapMouseover = "GetMinimapMouseover",
		SetUnitBuffByAuraInstanceID = "GetUnitBuffByAuraInstanceID",
		SetUnitDebuffByAuraInstanceID = "GetUnitDebuffByAuraInstanceID",
		SetTraitEntry = "GetTraitEntry",
		SetSlottedKeystone = "GetSlottedKeystone",
		SetItemInteractionItem = "GetItemInteractionItem",
		SetItemByGUID = "GetItemByGUID",
		SetWorldLootObject = "GetWorldLootObject",
	};

	local handler = TooltipDataHandlerMixin;
	for accessor, getterName in pairs(accessors) do
		AddTooltipDataAccessor(handler, accessor, getterName);
	end
end