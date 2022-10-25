WarlockPowerBar = {};
function WarlockPowerBar:UpdatePower()
	local shardPower = self:UnitPower(self:GetUnit() or self.unit);

	-- Bug ID: 496542: Destruction is supposed to show partial soulshards, but Affliction and Demonology should only show full ones.
	if GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION then
		shardPower = math.floor(shardPower);
	end

	for shard in self.classResourceButtonPool:EnumerateActive() do
		shard:Update(shardPower);
	end
end

function WarlockPowerBar:UnitPower(unit)
	local shardPower = UnitPower(unit, Enum.PowerType.SoulShards, true);
	local shardModifier = UnitPowerDisplayMod(Enum.PowerType.SoulShards);
	return (shardModifier ~= 0) and (shardPower / shardModifier) or 0;
end

WarlockShardMixin = {};
function WarlockShardMixin:Setup()
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
	local fillAmount = Saturate(powerAmount - (self.layoutIndex - 1));
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