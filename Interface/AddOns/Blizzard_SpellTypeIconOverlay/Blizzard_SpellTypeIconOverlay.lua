SpellTypeIconOverlayPoolManagerMixin = {}

function SpellTypeIconOverlayPoolManagerMixin:GetOrCreatePipPool(useSmallPips)
	if not self.pipPool then
		self.smallPipPool = CreateFramePool("Frame", nil, "SpellTypeIconOverlaySmallManaPipTemplate");
		self.pipPool = CreateFramePool("Frame", nil, "SpellTypeIconOverlayManaPipTemplate");
	end

	return useSmallPips and self.smallPipPool or self.pipPool;
end

local SpellTypeIconOverlayPoolManager = CreateFromMixins(SpellTypeIconOverlayPoolManagerMixin);

SpellTypeIconOverlayMixin = {};

function SpellTypeIconOverlayMixin:OnLoad()
	self.pips = {};
end

function SpellTypeIconOverlayMixin:Attach(button)
	self:SetParent(button);
	self:ClearAllPoints();
	self:SetPoint("LEFT", button, "BOTTOMLEFT", 0, 3);
	self:SetPoint("RIGHT", button, "BOTTOMRIGHT", 0, 3);
	self:SetFrameLevel(button:GetFrameLevel() + 100);
end

function SpellTypeIconOverlayMixin:Update(button)
	local spellID = self:ResolveSpellID(button);
	self:UpdateForSpellID(spellID);
end

function SpellTypeIconOverlayMixin:ResolveSpellID(button)
	if button.GetSpellID then
		return button:GetSpellID();
	end

	if button.action then
		local actionType, actionID = GetActionInfo(button.action);
		if actionType == "spell" then
			return actionID;
		end
	end

	return nil;
end

function SpellTypeIconOverlayMixin:UpdateForSpellID(spellID)
	local strategy = GameRulesUtil.GetActionButtonTypeOverlayStrategy();
	if strategy == GameRulesUtil.ActionButtonTypeOverlayStrategy.None then
		self:HideAll();
		return;
	end

	if strategy == GameRulesUtil.ActionButtonTypeOverlayStrategy.ManaPipsAndEnergy then
		self:UpdateManaPipsAndEnergy(spellID);
		return;
	end

	self:ReleaseAllPips();
	local atlas = self:GetAtlasForSpell(spellID, strategy);
	if atlas then
		self.Texture:SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
		self.Texture:Show();
		self:Show();
	else
		self:Hide();
	end
end

function SpellTypeIconOverlayMixin:GetAtlasForSpell(spellID, strategy)
	if strategy == GameRulesUtil.ActionButtonTypeOverlayStrategy.HighlightMana then
		local atlas = "plunderstorm-icon-utility";

		if spellID then
			local costTable = C_Spell.GetSpellPowerCost(spellID);
			if costTable then
				for _i, costInfo in pairs(costTable) do
					if costInfo.type == Enum.PowerType.Mana then
						atlas = "plunderstorm-icon-offensive";
						break;
					end
				end
			end
		end

		return atlas;
	elseif strategy == GameRulesUtil.ActionButtonTypeOverlayStrategy.ManaAndEnergy then
		if not spellID then
			return nil;
		end

		local atlas = nil;
		local costTable = C_Spell.GetSpellPowerCost(spellID);
		if costTable then
			for _i, costInfo in pairs(costTable) do
				-- Mana is high priority if a spell costs both.
				if costInfo.type == Enum.PowerType.Mana then
					return "plunderstorm-icon-offensive";
				elseif costInfo.type == Enum.PowerType.Energy then
					atlas = "plunderstorm-icon-utility";
				end
			end
		end

		return atlas;
	end

	return nil;
end

function SpellTypeIconOverlayMixin:HideAll()
	self:Hide();
	self:ReleaseAllPips();
end

function SpellTypeIconOverlayMixin:ReleaseAllPips()
	local pipPool = self:GetPipPool();
	for _i, pip in ipairs(self.pips) do
		-- Pip release hides and clears anchors
		pipPool:Release(pip);
	end

	self.pips = {};
end

local MANA_PIP_COST = 10;
local MANA_PIP_SPACING = 1;

function SpellTypeIconOverlayMixin:GetPipPool()
	return SpellTypeIconOverlayPoolManager:GetOrCreatePipPool(self.useSmallPips);
end

function SpellTypeIconOverlayMixin:UpdateManaPipsAndEnergy(spellID)
	if not spellID then
		self:HideAll();
		return;
	end

	local manaCost = 0;
	local hasEnergy = false;
	local costTable = C_Spell.GetSpellPowerCost(spellID);
	if costTable then
		for _i, costInfo in pairs(costTable) do
			if costInfo.type == Enum.PowerType.Mana then
				manaCost = costInfo.cost;
			elseif costInfo.type == Enum.PowerType.Energy then
				hasEnergy = true;
			end
		end
	end

	if manaCost > 0 then
		self.Texture:Hide();
		self:ReleaseAllPips();
		local numPips = math.ceil(manaCost / MANA_PIP_COST);
		self:ShowPips(numPips);
		self:Show();
	elseif hasEnergy then
		self:ReleaseAllPips();
		self.Texture:SetAtlas("talebound-hud-actionbar-icon-energy", TextureKitConstants.IgnoreAtlasSize);
		self.Texture:Show();
		self:Show();
	else
		self:HideAll();
	end
end

function SpellTypeIconOverlayMixin:ShowPips(numPips)
	local pool = self:GetPipPool();
	for i = #self.pips, numPips do
		local pip = pool:Acquire();
		pip:SetParent(self);
		table.insert(self.pips, pip);
	end

	for i = 1, numPips do
		self.pips[i]:Show();
	end

	-- Layout pips centered horizontally.
	local pipWidth = self.pips[1]:GetWidth();
	local spacing = MANA_PIP_SPACING;
	local totalWidth = (numPips - 1) * spacing + pipWidth * numPips;
	local startOffset = -totalWidth / 2;
	for i = 1, numPips do
		local pip = self.pips[i];
		pip:ClearAllPoints();
		pip:SetPoint("LEFT", self, "CENTER", startOffset + (i - 1) * spacing + (i-1) * pipWidth, -3);
	end
end

function SpellTypeIconOverlayMixin:OnRelease()
	self:HideAll();
	self:ClearAllPoints();

	local parent = self:GetParent();
	if parent and parent.SetButtonOverlay then
		parent:SetButtonOverlay(nil);
	end
	self:SetParent(nil);
end
