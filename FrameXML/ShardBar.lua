WarlockPowerBar = {};
SHARDBAR_SHOW_LEVEL = 10;

function WarlockPowerBar:OnLoad()
	self:SetTooltip(SOUL_SHARDS_POWER, SOUL_SHARDS_TOOLTIP);
	self:SetPowerTokens("SOUL_SHARDS");
	self.class = "WARLOCK";
	self.spec = nil;
	self.Shards = {};

	ClassPowerBar.OnLoad(self);
end

function WarlockPowerBar:Setup()
	local showBar = ClassPowerBar.Setup(self);
	if showBar then
		if UnitLevel("player") < SHARDBAR_SHOW_LEVEL then
			self:RegisterEvent("PLAYER_LEVEL_UP");
			self:SetAlpha(0);
		end
	end
end

function WarlockPowerBar:OnEvent(event, ...)
	local handled = ClassPowerBar.OnEvent(self, event, ...);
	if handled then
		return true;
	elseif event == "PLAYER_LEVEL_UP" then
		local level = ...;
		if level >= SHARDBAR_SHOW_LEVEL then
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			self:SetAlpha(1);
			self:UpdatePower();
		end
	else
		return false;
	end

	return true;
end

function WarlockPowerBar:CreateShards()
	local maxShards = UnitPowerMax(self:GetUnit(), Enum.PowerType.SoulShards);

	while #self.Shards < maxShards do
		local shard = CreateFrame("FRAME", nil, self, "ShardTemplate");
		shard:Setup(#self.Shards - 1);

		if self.previousShard then
			shard:SetPoint("TOPLEFT", self.previousShard, "TOPLEFT", 25, 0);
		else
			shard:SetPoint("TOPLEFT", self, "TOPLEFT", -6, 0);
		end

		self.previousShard = shard;
	end
end

function WarlockPowerBar:UpdatePower()
	WarlockPowerBar_UpdatePower(self);
end

function WarlockPowerBar_UpdatePower(self)
	self:CreateShards();

	local shardPower = WarlockPowerBar_UnitPower(self:GetUnit());

	-- Bug ID: 496542: Destruction is supposed to show partial soulshards, but Affliction and Demonology should only show full ones.
	if GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION then
		shardPower = math.floor(shardPower);
	end

	for i, shard in ipairs(self.Shards) do
		shard:Update(shardPower);
	end
end

function WarlockPowerBar_UnitPower(unit)
	local shardPower = UnitPower(unit, Enum.PowerType.SoulShards, true);
	local shardModifier = UnitPowerDisplayMod(Enum.PowerType.SoulShards);
	return (shardModifier ~= 0) and (shardPower / shardModifier) or 0;
end

WarlockShardMixin = {};

function WarlockShardMixin:Setup(shardIndex)
	self.shardIndex = shardIndex;
	self.widthByFillAmount = {
		[0] = 0,
		[1] = 6,
		[2] = 12,
		[3] = 14,
		[4] = 18,
		[5] = 22,
		[6] = 22,
		[7] = 24,
		[8] = 20,
		[9] = 18,
		[10] = 0,
	};
end

function WarlockShardMixin:Update(powerAmount)
	local fillAmount = Saturate(powerAmount - self.shardIndex);
	local active = fillAmount >= 1;

	if active then
		if self.animOut:IsPlaying() then
			self.animOut:Stop();
		end

		if not self.active and not self.animIn:IsPlaying() then
			self.animIn:Play();
			self.active = true;
		end

		self.PartialFill:SetValue(0);
	else
		if self.animIn:IsPlaying() then
			self.animIn:Stop();
		end

		if self.active and not self.animOut:IsPlaying() then
			self.animOut:Play();
			self.active = false;
		end

		self.PartialFill:SetValue(fillAmount);
	end
	self:UpdateSpark(fillAmount);
end

function WarlockShardMixin:UpdateSpark(fillAmount)
	self.Spark:SetShown(fillAmount > 0 and fillAmount < 1);
	if (self.Spark:IsShown()) then
		local sparkWidthIndex = math.floor(fillAmount * 10);
		local fullOffset = self.widthByFillAmount[sparkWidthIndex];
		self.Spark:SetPoint("TOPLEFT", self.PartialFill:GetStatusBarTexture(), "TOP", -(fullOffset/2), 2);
		self.Spark:SetPoint("BOTTOMRIGHT", self.PartialFill:GetStatusBarTexture(), "TOP", fullOffset/2, -2);
	end
end