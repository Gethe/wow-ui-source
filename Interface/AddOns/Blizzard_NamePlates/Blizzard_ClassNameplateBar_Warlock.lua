ClassNameplateBarWarlock = {};

function ClassNameplateBarWarlock:OnLoad()
	ClassResourceBarMixin.OnLoad(self);
end 

function ClassNameplateBarWarlock:SetupWarlock()
	self:ShowNameplateBar();
	return true; 
end

function ClassNameplateBarWarlock:UpdateMaxPower()
	ClassResourceBarMixin.UpdateMaxPower(self);
end

function ClassNameplateBarWarlock:UpdatePower()
	WarlockPowerBar.UpdatePower(self);
end 

ClassNameplateBarWarlockShardMixin = CreateFromMixins(WarlockShardMixin);

function ClassNameplateBarWarlockShardMixin:Setup()
	WarlockShardMixin.Setup(self, self.layoutIndex);
	self.widthByFillAmount = {
		[0] = 0,
		[1] = 2,
		[2] = 8,
		[3] = 10,
		[4] = 14,
		[5] = 18,
		[6] = 18,
		[7] = 20,
		[8] = 16,
		[9] = 12,
		[10] = 0,
	};
end

function ClassNameplateBarWarlockShardMixin:Update(powerAmount)
	local fillAmount = Saturate(powerAmount - (self.layoutIndex - 1));
	local active = fillAmount >= 1;

	local bar = self:GetParent();
	if fillAmount ~= self.fillAmount then
		self.fillAmount = fillAmount;

		if active then
			bar:TurnOn(self, self.ShardOn, 1);
			self.PartialFill:SetValue(0);
		else
			bar:TurnOff(self, self.ShardOn, 0);
			self.PartialFill:SetValue(fillAmount);
		end
		self:UpdateSpark(fillAmount);
	end
end
