-- Temp
PROFESSIONS_EXPIRATION_SECONDS = SECONDS_PER_MIN * 30;

-- Temp to distinguish fake orders in the list.
local orderIDCounter = CreateCounter(999);

local ProfessionsOrderMixin = {};

function ProfessionsOrderMixin:IsStatus(status)
	return self.status == status;
end

function ProfessionsOrderMixin:IsRecipient(recipient)
	return self.recipient == recipient;
end


function ProfessionsOrderMixin:GetRecipeID()
	return self.transaction:GetRecipeID();
end

function ProfessionsOrderMixin:GetName()
	local recipeSchematic = self.transaction:GetRecipeSchematic();
	return recipeSchematic.name;
end

function ProfessionsOrderMixin:Start()
	if self:IsStatus(Enum.TradeskillOrderStatus.Unclaimed) then
		self.status = Enum.TradeskillOrderStatus.Started;

		self.startTime = GetTime();
		self.expiration = self.startTime + PROFESSIONS_EXPIRATION_SECONDS;
	end
end

function ProfessionsOrderMixin:Cancel()
	if self:IsStatus(Enum.TradeskillOrderStatus.Started) then
		self.status = Enum.TradeskillOrderStatus.Unclaimed;
	end
end

function ProfessionsOrderMixin:Complete(message)
	if self:IsStatus(Enum.TradeskillOrderStatus.Started) then
		self.status = Enum.TradeskillOrderStatus.Completed;
		self.finalizedMessage = message;
	end
end

function ProfessionsOrderMixin:GetSecondsUntilExpiration()
	if self:IsStatus(Enum.TradeskillOrderStatus.Started) then
		return math.max(self.expiration - GetTime(), 0);
	end
end

function ProfessionsOrderMixin:HasExpired()
	local seconds = self:GetSecondsUntilExpiration();
	if seconds and seconds <= 0 then
		return true;
	end
	return false;
end

function ProfessionsOrderMixin:Expire()
	if self:IsStatus(Enum.TradeskillOrderStatus.Started) then
		self.status = Enum.TradeskillOrderStatus.Expired;
	end
end

local function CreateOrder()
	return CreateFromMixins(ProfessionsOrderMixin);
end

function Professions.CreateSampleOrderBySchematic(recipeSchematic)
	local order = CreateOrder();
	order.id = orderIDCounter();

	order.transaction = CreateProfessionsRecipeTransaction(recipeSchematic);
	Professions.AllocateAllBasicReagents(order.transaction, Professions.ShouldAllocateBestQualityReagents());
	
	for index, reagentTbl in order.transaction:Enumerate() do
		local allocations = reagentTbl.allocations;
		if math.random(1, 3) == 1 then
			allocations:Clear();
		elseif allocations:HasAllocations() then
			local reagentSlotSchematic = reagentTbl.reagentSlotSchematic;
			if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
				allocations.customer = true;
			end
		end
	end

	local required, allocated = 0, 0;
	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
			required = required + 1;
			if order.transaction:HasAllocations(slotIndex) then
				allocated = allocated + 1;
			end
		end
	end

	if required == allocated then
		order.reagentContents = Professions.ReagentContents.All;
	elseif allocated > 0 then
		order.reagentContents = Professions.ReagentContents.Partial;
	else
		order.reagentContents = Professions.ReagentContents.None;
	end

	order.recommendedTip = math.random(20000, 30000);
	order.tip = math.ceil(math.random(20000, 100000) / 10000) * 10000;
	order.fee = math.random(20000, 60000);
	
	order.recipient = GetRandomTableValue(Enum.TradeskillOrderRecipient);
	order.quality = order:IsRecipient(Enum.TradeskillOrderRecipient.Public) and 1 or math.random(1, 5);

	order.duration = GetRandomTableValue(Enum.TradeskillOrderDuration);
	order.message = "Make my stuff, thanks!";
	order.customer = "ARandomPlayer"..math.random(1, 100);

	order.status = GetRandomTableValue(Enum.TradeskillOrderStatus);
	if order.status == Enum.TradeskillOrderStatus.Completed then
		order.status = Enum.TradeskillOrderStatus.Unclaimed;
	end

	return order;
end

function Professions.CreateNewOrderBySchematic(recipeSchematic)
	local order = CreateOrder();
	order.id = orderIDCounter();
	order.transaction = CreateProfessionsRecipeTransaction(recipeSchematic);
	testme = order.transaction;
	order.tip = 0;
	order.recommendedTip = math.random(20000, 30000);
	order.fee = math.random(20000, 60000);
	order.recipient = Professions.GetDefaultOrderRecipient();
	order.quality = 1;
	order.duration = Professions.GetDefaultOrderDuration();
	order.message = "";
	order.status = nil;
	order.customer = UnitName("player");
	return order;
end