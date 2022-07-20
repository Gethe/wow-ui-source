BUFF_WARNING_TIME = 31;
BUFF_DURATION_WARNING_TIME = 60;
BUFF_MAX_DISPLAY = 32;
DEBUFF_MAX_DISPLAY = 16
DEBUFF_CRITICAL_TIME_REMAINING = 15;
DEFAULT_AURA_DURATION_FONT = "GameFontNormalSmall";

--Aubrie TODO move these.. to something else
DebuffTypeColor = { };
DebuffTypeColor["none"]	= { r = 0.80, g = 0, b = 0 };
DebuffTypeColor["Magic"]	= { r = 0.20, g = 0.60, b = 1.00 };
DebuffTypeColor["Curse"]	= { r = 0.60, g = 0.00, b = 1.00 };
DebuffTypeColor["Disease"]	= { r = 0.60, g = 0.40, b = 0 };
DebuffTypeColor["Poison"]	= { r = 0.00, g = 0.60, b = 0 };
DebuffTypeColor[""]	= DebuffTypeColor["none"];

DebuffTypeSymbol = { };
DebuffTypeSymbol["Magic"] = DEBUFF_SYMBOL_MAGIC;
DebuffTypeSymbol["Curse"] = DEBUFF_SYMBOL_CURSE;
DebuffTypeSymbol["Disease"] = DEBUFF_SYMBOL_DISEASE;
DebuffTypeSymbol["Poison"] = DEBUFF_SYMBOL_POISON;

CVarCallbackRegistry:SetCVarCachable("buffDurations");

--AubrieTODO: These texture mappings are sort of bad so for temp enchantments we are only showing temp enchants for weapon.. 
--Which just seems wrong, so I still have to talk to designers and see if we want to invest in a system to show temp enchants other than weapon
local textureMapping = {
	[1] = 16,	--Main hand
	[2] = 17,	--Off-hand
	[3] = 18,	--Ranged
};

BuffFrameMixin = { };
function BuffFrameMixin:OnLoad()
	self.isExpanded = true; 
	self:RegisterUnitEvent("UNIT_AURA", "player", "vehicle");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self.numEnchants = 0;
	self.buffsPool = CreateFramePoolCollection();
	self.buffsPool:CreatePool("Button", self.BuffsContainer, "BuffButtonTemplate");
	self.buffsPool:CreatePool("Button", self.BuffsContainer, "TempEnchantButtonTemplate");
	self.debuffPool = CreateFramePoolCollection();
	self.debuffPool:CreatePool("BUTTON", self.DebuffsContainer, "DebuffButtonTemplate");
	self.debuffPool:CreatePool("BUTTON", self.DeadlyDebuffContainer, "DeadlyDebuffButtonTemplate");
	self.bottomEdgeExtent = 0;
end

function BuffFrameMixin:SetBuffsExpandedState(expanded) 
	self.isExpanded = expanded; 
	self:Update(); 
end 

function BuffFrameMixin:OnEvent(event, ...)
	if ( event == "UNIT_AURA" ) then
		local unit = ...;
		if ( unit == PlayerFrame.unit ) then
			self:Update();
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		self:Update();
	end
end

function BuffFrameMixin:UpdateWithSlots(unit, filter, maxCount)
	local index = 1;
	local shownBuffsIndex = 1; 
	AuraUtil.ForEachAura(unit, filter, maxCount, function(...)
		local _, texture, count, debuffType, duration, expirationTime, _, _, _, spellID, _, _, _, _, timeMod = ...;
		local timeLeft = (expirationTime - GetTime());
		local hideBuff = (duration == 0) or (expirationTime == 0) or ((timeLeft) > BUFF_DURATION_WARNING_TIME); --Aubrie TODO filter with a flag on the aura.
		
		if(filter == "HELPFUL") then 
			self.buffInfo[index] = {index = index, texture = texture, count = count, debuffType = debuffType, duration = duration,  expirationTime = expirationTime, timeMod = timeMod, hideUnlessExpanded = hideUnlessExpanded };
			if(not hideBuff) then 
				self.shownBuffs[shownBuffsIndex] = {index = index, texture = texture, count = count, debuffType = debuffType, duration = duration,  expirationTime = expirationTime, timeMod = timeMod, hideUnlessExpanded = hideUnlessExpanded };
				shownBuffsIndex = shownBuffsIndex + 1; 
			end 
		else 
			local deadlyDebuffInfo = C_SpellBook.GetDeadlyDebuffInfo(spellID); 
			if(deadlyDebuffInfo) then 
				table.insert(self.deadlyDebuffInfo, {index = index, texture = texture, count = count, debuffType = debuffType, duration = duration, expirationTime = expirationTime, timeMod = timeMod, warningText = deadlyDebuffInfo.warningText, soundKitID = deadlyDebuffInfo.soundKitID }); 
			else 
				table.insert(self.debuffInfo, {index = index, texture = texture, count = count, debuffType = debuffType, duration = duration, expirationTime = expirationTime, timeMod = timeMod, }); 
			end 
		end
		index = index + 1;
		return index > maxCount;
	end);
end

function BuffFrameMixin:ManageDeadlyDebuffs()
	local mostCriticalDebuffIndex = nil; 
	for i = 1, #self.deadlyDebuffInfo do 
		if(not mostCriticalDebuffIndex) then 
			mostCriticalDebuffIndex = i; 
		else
			local currentTime = GetTime(); 
			local timeRemaining1 = self.deadlyDebuffInfo[i].expirationTime - currentTime; 
			local timeRemaining2 = self.deadlyDebuffInfo[mostCriticalDebuffIndex].expirationTime - currentTime; 
			if (timeRemaining1 < timeRemaining2) then 
				mostCriticalDebuffIndex = i; 
			else
				local priority1 = self.deadlyDebuffInfo[i].priority;
				local priority2 = self.deadlyDebuffInfo[mostCriticalDebuffIndex].priority;
				if(priorty1 > priority2) then 
					mostCriticalDebuffIndex = i; 
				end
			end		
		end		
	end
	if (mostCriticalDebuffIndex) then 
		DeadlyDebuffFrame:Setup(self.deadlyDebuffInfo[mostCriticalDebuffIndex]);
		table.remove(self.deadlyDebuffInfo, mostCriticalDebuffIndex); --Only want to show the debuff in one place. 
	else 
		DeadlyDebuffFrame:Hide(); 
	end
end

--AubrieTODO: Figure out how we want to refactor this function to include non-weapon enchants..
function BuffFrameMixin:UpdateTemporaryEnchantments(...)
	local RETURNS_PER_ITEM = 4;
	local numVals = select("#", ...);
	local numItems = numVals / RETURNS_PER_ITEM;

	if ( numItems == 0 ) then
		return;
	end

	local enchantIndex = 0;
	for itemIndex = numItems, 1, -1 do	--Loop through the items from the back.
		local hasEnchant, enchantExpiration, enchantCharges = select(RETURNS_PER_ITEM * (itemIndex - 1) + 1, ...);
		if ( hasEnchant ) then
			enchantIndex = enchantIndex + 1;
			-- Show buff durations if necessary
			if ( enchantExpiration ) then
				enchantExpiration = enchantExpiration/1000;
			end
			local hideUnlessExpanded = enchantExpiration > BUFF_DURATION_WARNING_TIME;
			self.wepEnchantInfo[enchantIndex] = {textureName = GetInventoryItemTexture("player", textureMapping[itemIndex]), ID = textureMapping[itemIndex], expirationTime = enchantExpiration, hideUnlessExpanded = hideUnlessExpanded };
		end
	end
end

function BuffFrameMixin:Update()
	self.buffInfo = { }; 
	self.shownBuffs = { };
	self.debuffInfo = { };
	self.deadlyDebuffInfo = { };
	self.wepEnchantInfo = { };
	self:UpdateWithSlots(PlayerFrame.unit, "HELPFUL", BUFF_MAX_DISPLAY);
	self:UpdateWithSlots(PlayerFrame.unit, "HARMFUL", DEBUFF_MAX_DISPLAY);
	self:UpdateTemporaryEnchantments(GetWeaponEnchantInfo());
	self:ManageDeadlyDebuffs(); 
	self:UpdateAllBuffAnchors();
end

function BuffFrameMixin:UpdatePositions()
	self:Update();
end

function BuffFrameMixin:GetExpanded()
	return self.isExpanded; 
end

local function BuffsSortFunction(a, b)
	local aTimeLeft = (a.expirationTime - GetTime());
	if(a.timeMod > 0) then
		aTimeLeft = aTimeLeft / a.timeMod;
	end

	local bTimeLeft = (b.expirationTime - GetTime());
	if(b.timeMod > 0) then
		bTimeLeft = bTimeLeft / b.timeMod;
	end
	return aTimeLeft < bTimeLeft;
end

function BuffFrameMixin:SetupBuffs(expanded)
	local buffInfo = expanded and self.buffInfo or self.shownBuffs
	local function BuffsFactoryFunction(index)
		if(index > #buffInfo) then 
			local totalBuffs = #buffInfo; 
			local tempWepEnchantIndex = (totalBuffs - index) + 2;
			if(self.wepEnchantInfo[tempWepEnchantIndex]) then
				local buff = self.buffsPool:Acquire("TempEnchantButtonTemplate");
				buff:Update(self.wepEnchantInfo[tempWepEnchantIndex], self:GetExpanded());
				return buff;
			end
			return nil; 
		end
		
		local buff = self.buffsPool:Acquire("BuffButtonTemplate");
		buff:Update(buffInfo[index], self:GetExpanded());
		return buff;
	end

	--Aubrie ToDO: The width and the layout will need to come from edit mode. 
	local totalWidth = 376
	local totalHeight = 200;
	local anchor = AnchorUtil.CreateAnchor("RIGHT", self.CollapseAndExpandButton, "LEFT", -10);
	AnchorUtil.GridLayoutFactory(BuffsFactoryFunction, anchor, totalWidth, totalHeight, GridLayoutMixin.Direction.TopRightToBottomLeft, 5, 15);
end 

function BuffFrameMixin:SetupDebuffs(deadlyDebuffs)
	local debuffTable = deadlyDebuffs and self.deadlyDebuffInfo or self.debuffInfo; 
	local debuffContainer = deadlyDebuffs and self.DeadlyDebuffContainer or self.DebuffsContainer; 
	local debuffTemplate = deadlyDebuffs and "DeadlyDebuffButtonTemplate" or "DebuffButtonTemplate"
	local function DebuffFactoryFunction(index)
		if(index > #debuffTable) then 
			return; 
		end
		local debuffInfo = debuffTable[index];
		local buff = self.debuffPool:Acquire(debuffTemplate);
		buff:Update(debuffTable[index], self:GetExpanded());
		return buff;
	end

	--Aubrie ToDO: The width and the layout will need to come from edit mode. 
	local anchor = AnchorUtil.CreateAnchor("TOPRIGHT", debuffContainer, "TOPRIGHT");
	local layout = AnchorUtil.CreateGridLayout( GridLayoutMixin.Direction.TopRightToBottomLeft, 4, 5, 15);
	
	AnchorUtil.GridLayoutFactoryByCount(DebuffFactoryFunction, #debuffTable, anchor,  layout);
	debuffContainer:Layout(); 
end

function BuffFrameMixin:UpdateAllBuffAnchors()
	self.debuffPool:ReleaseAll(); 
	self.buffsPool:ReleaseAll(); 
	--table.sort(self.buffInfo, BuffsSortFunction); 
	--table.sort(self.shownBuffs, BuffSortFunction);
	self:SetupBuffs(self:GetExpanded());
	self:SetupDebuffs(false);
	self:SetupDebuffs(true);
end

AuraButtonMixin = { }; 
function AuraButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetFrameLevel(self:GetFrameLevel() + 2);
	GameTooltip:SetUnitAura(PlayerFrame.unit, self.buttonInfo.index, self:GetFilter());
end

function AuraButtonMixin:OnLeave()
	GameTooltip:Hide();
end 

function AuraButtonMixin:UpdateExpirationTime(buttonInfo)
	if ( (buttonInfo.duration and buttonInfo.duration > 0) and buttonInfo.expirationTime ) then
		self.duration:SetShown(CVarCallbackRegistry:GetCVarValueBool("buffDurations"));
			
		local timeLeft = (buttonInfo.expirationTime - GetTime());
		if(buttonInfo.timeMod > 0) then
			self.timeMod = buttonInfo.timeMod;
			timeLeft = timeLeft / buttonInfo.timeMod;
		end

		if ( not self.timeLeft ) then
			self.timeLeft = timeLeft;
			self:SetScript("OnUpdate", self.OnUpdate);
		else
			self.timeLeft = timeLeft;
		end
	else
		self.duration:Hide();
		self:SetScript("OnUpdate", nil);
		self.timeLeft = nil;
	end
end

function AuraButtonMixin:Update(buttonInfo, expanded)
	if(not buttonInfo) then
		return; 
	end 
	local helpful = (self:GetFilter() == "HELPFUL");
	self.unit = PlayerFrame.unit;
	self.buttonInfo = buttonInfo; 
	
	local canShow = (not buttonInfo.hideUnlessExpanded) or expanded; 
	self:SetShown(canShow); 
	if ( not helpful ) then
		if ( self.Border ) then
			local color;
			if ( debuffType ) then
				color = DebuffTypeColor[buttonInfo.debuffType];
				if ( ENABLE_COLORBLIND_MODE == "1" ) then
					self.symbol:Show();
					self.symbol:SetText(DebuffTypeSymbol[buttonInfo.debuffType] or "");
				else
					self.symbol:Hide();
				end
			else
				self.symbol:Hide();
				color = DebuffTypeColor["none"];
			end
			self.Border:SetVertexColor(color.r, color.g, color.b);
		end
	end

	self:UpdateExpirationTime(buttonInfo); 
	self.Icon:SetTexture(buttonInfo.texture);

	if ( buttonInfo.count > 1 ) then
		self.count:SetText(buttonInfo.count);
		self.count:Show();
	else
		self.count:Hide();
	end

	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetUnitAura(self.unit, buttonInfo.index, self:GetFilter());
	end
end

function AuraButtonMixin:OnUpdate()
	local index = self.buttonInfo.index; 
	if ( self.timeLeft and self.timeLeft < BUFF_WARNING_TIME ) then
		self:SetAlpha(1.0);
	else
		self:SetAlpha(1.0);
	end

	-- Update duration
	securecall(self.UpdateDuration, self, self.timeLeft); -- Taint issue with SecondsToTimeAbbrev 
	
	-- Update our timeLeft
	local timeLeft = self.buttonInfo.expirationTime - GetTime();
	if ( self.buttonInfo.timeMod and self.buttonInfo.timeMod > 0 ) then
		timeLeft = timeLeft / self.buttonInfo.timeMod;
	end
	self.timeLeft = max( timeLeft, 0 );
	if ( SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD ) then
		local aboveMinThreshold = self.timeLeft > SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD;
		local belowMaxThreshold = not SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD or self.timeLeft < SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD;
		if ( aboveMinThreshold and belowMaxThreshold ) then
			self.duration:SetFontObject(SMALLER_AURA_DURATION_FONT);
			self.duration:SetPoint("TOP", self, "BOTTOM", 0, SMALLER_AURA_DURATION_OFFSET_Y);
		else
			self.duration:SetFontObject(DEFAULT_AURA_DURATION_FONT);
			self.duration:SetPoint("TOP", self, "BOTTOM");
		end
	end

	if ( GameTooltip:IsOwned(self) and not self:GetID() ) then
		GameTooltip:SetUnitAura(PlayerFrame.unit, index, self:GetFilter());
	end
end

function AuraButtonMixin:UpdateDuration(timeLeft)
	local duration = self.duration;
	if ( timeLeft and CVarCallbackRegistry:GetCVarValueBool("buffDurations") ) then
		duration:SetFormattedText(SecondsToTimeAbbrev(timeLeft));
		if ( timeLeft < BUFF_DURATION_WARNING_TIME ) then
			duration:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		else
			duration:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
		duration:Show();
	else
		duration:Hide();
	end
end

BuffButtonMixin = CreateFromMixins(AuraButtonMixin);
function BuffButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function BuffButtonMixin:GetFilter()
	return "HELPFUL";
end

function BuffButtonMixin:OnClick(button)
    EventRegistry:TriggerEvent("BuffButton.OnClick", self, button);

    if(button == "RightButton") then
        CancelUnitBuff(PlayerFrame.unit, self.buttonInfo.index, self:GetFilter());
    end
end

DebuffButtonMixin = CreateFromMixins(AuraButtonMixin);
function DebuffButtonMixin:GetFilter()
	 return "HARMFUL";
end

function DebuffButtonMixin:OnClick(button)
    EventRegistry:TriggerEvent("BuffButton.OnClick", self, button);
end


function DebuffButtonMixin:OnLoad()
	self.duration:SetPoint("TOP", self, "BOTTOM", 0, -1);
end

TempEnchantButtonMixin = CreateFromMixins(AuraButtonMixin);
function TempEnchantButtonMixin:OnLoad()
	self:RegisterForClicks("RightButtonUp");
end

function TempEnchantButtonMixin:OnUpdate(elapsed)
	-- Update duration
	if( not PlayerFrame.unit or PlayerFrame.unit ~= "player") then 
		self:Hide(); 
		return; 
	end		
	if ( GameTooltip:IsOwned(self) ) then
		self:OnEnter();
	end
	AuraButtonMixin.OnUpdate(self, elapsed);
end

function TempEnchantButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetInventoryItem("player", self:GetID());
end

function TempEnchantButtonMixin:GetID()
	return self.buttonInfo.ID; 
end

function TempEnchantButtonMixin:Update(buttonInfo, expanded)
	if (not buttonInfo) then
		return; 
	end 
	
	self.buttonInfo = buttonInfo; 
	self.Icon:SetTexture(self.buttonInfo.textureName); 
	self:UpdateExpirationTime(buttonInfo); 
	local canShow = (not buttonInfo.hideUnlessExpanded) or expanded; 
	self:SetShown(canShow); 
end

--AubrieTODO: Figure out what we want to do with temp item enchants. 
function TempEnchantButtonMixin:OnClick()
	if ( self:GetID() == 16 ) then
		CancelItemTempEnchantment(1);
	elseif ( self:GetID() == 17 ) then
		CancelItemTempEnchantment(2);
	elseif ( self:GetID() == 18 ) then
		CancelItemTempEnchantment(3);
	end
end

CollapseAndExpandButtonMixin = { };
function CollapseAndExpandButtonMixin:OnClick()
	self:GetParent():SetBuffsExpandedState(self:GetChecked()); 
	local collapseState = self:GetChecked() and math.pi or 0;
	self:GetNormalTexture():SetRotation(collapseState);
	self:GetHighlightTexture():SetRotation(collapseState);
end

function CollapseAndExpandButtonMixin:OnLoad()
	self:SetChecked(true);
	self:GetNormalTexture():SetRotation(math.pi);
	self:GetHighlightTexture():SetRotation(math.pi);
end

DeadlyDebuffFrameMixin = { };
function DeadlyDebuffFrameMixin:Setup(deadlyDebuffInfo)
	self.Debuff:Update(deadlyDebuffInfo);
	self.WarningText:SetText(deadlyDebuffInfo.warningText)
	if(deadlyDebuffInfo.soundKitID) then 
		PlaySound(deadlyDebuffInfo.soundKitID);
	end
	self:Show(); 
end 