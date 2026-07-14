-- Frame providers let containers decide how aura frames are supplied for each
-- aura group.

AuraContainerFramePoolProviderMixin = {};

function AuraContainerFramePoolProviderMixin:Init(framePool)
	self.framePool = framePool;
end

function AuraContainerFramePoolProviderMixin:AcquireFrame()
	return self.framePool:Acquire();
end

function AuraContainerFramePoolProviderMixin:ReleaseFrame(frame)
	self.framePool:Release(frame);
end

function AuraContainerUtil.CreateFramePoolProvider(framePool)
	local provider = CreateFromMixins(AuraContainerFramePoolProviderMixin);
	provider:Init(framePool);
	return provider;
end

AuraContainerCustomFrameProviderMixin = {};

function AuraContainerCustomFrameProviderMixin:Init(parent, description)
	assert(parent ~= nil, "Custom aura frame providers require a parent.");
	assert(type(description) == "table", "description must be a table.");
	assert(type(description.batchSize) == "number" and description.batchSize > 0 and description.batchSize == math.floor(description.batchSize), "batchSize must be a positive integer.");
	assert(description.templateNames == nil or type(description.templateNames) == "table", "templateNames must be a table or nil.");
	assert(description.initializeFrame == nil or type(description.initializeFrame) == "function", "initializeFrame must be a function or nil.");

	self.parent = parent;
	self.templateString = string.join(", ", "CustomAuraButtonTemplate", unpack(description.templateNames or {}));
	self.initializeFrame = description.initializeFrame;
	self.batchSize = description.batchSize;
	self.accessRestrictions = description.accessRestrictions;

	self.ownedFrames = {};
	self.activeFrames = {};
	self.availableFrames = {};
end

function AuraContainerCustomFrameProviderMixin:GetParent()
	return self.parent;
end

function AuraContainerCustomFrameProviderMixin:GetTemplateString()
	return self.templateString;
end

function AuraContainerCustomFrameProviderMixin:GetBatchSize()
	return self.batchSize;
end

function AuraContainerCustomFrameProviderMixin:GetOwnedFrameCount()
	return #self.ownedFrames;
end

function AuraContainerCustomFrameProviderMixin:GetAvailableFrameCount()
	return #self.availableFrames;
end

function AuraContainerCustomFrameProviderMixin:IsFrameActive(frame)
	return self.activeFrames[frame] == true;
end

function AuraContainerCustomFrameProviderMixin:CreateFrame()
	local auraFrame = CreateFrame("AuraButton", nil, self:GetParent(), self:GetTemplateString());

	if self.initializeFrame ~= nil then
		securecallfunction(self.initializeFrame, auraFrame:GetObjectTable());
	end

	-- Access restrictions should be applied immediately after (potentially
	-- tainted) post-creation callbacks.
	if self.accessRestrictions then
		auraFrame:AddAccessRestrictions(self.accessRestrictions);
	end

	-- Force an immediate display update to apply initial secrets and suitable
	-- default values.
	auraFrame:UpdateAuraDisplay();

	table.insert(self.ownedFrames, auraFrame);
	table.insert(self.availableFrames, auraFrame);
end

function AuraContainerCustomFrameProviderMixin:CreateFrameBatch()
	for _index = 1, self:GetBatchSize() do
		self:CreateFrame();
	end
end

function AuraContainerCustomFrameProviderMixin:AcquireFrame()
	if #self.availableFrames == 0 then
		self:CreateFrameBatch();
	end

	local auraFrame = table.remove(self.availableFrames);
	assert(auraFrame ~= nil, "Custom aura frame provider failed to acquire a frame.");

	self.activeFrames[auraFrame] = true;

	return auraFrame;
end

function AuraContainerCustomFrameProviderMixin:ReleaseFrame(auraFrame)
	if not assertsafe(self:IsFrameActive(auraFrame), "Attempted to release an inactive custom aura frame.") then
		return;
	end

	self.activeFrames[auraFrame] = nil;

	auraFrame:ClearAuraInstance();
	auraFrame:ClearAllPoints();
	auraFrame:Hide();

	table.insert(self.availableFrames, auraFrame);
end

function AuraContainerCustomFrameProviderMixin:ReleaseAllFrames()
	self.availableFrames = {};
	self.activeFrames = {};

	for _index, auraFrame in ipairs(self.ownedFrames) do
		auraFrame:ClearAuraInstance();
		auraFrame:ClearAllPoints();
		auraFrame:Hide();

		table.insert(self.availableFrames, auraFrame);
	end
end

function AuraContainerUtil.CreateCustomFrameProvider(parent, description)
	local provider = CreateFromMixins(AuraContainerCustomFrameProviderMixin);
	provider:Init(parent, description);
	return provider;
end

AuraContainerSingleFrameProviderMixin = {};

function AuraContainerSingleFrameProviderMixin:Init(auraFrame)
	assert(auraFrame ~= nil, "Single frame providers require a frame.");

	self.auraFrame = auraFrame;
	self.isFrameAvailable = true;
end

function AuraContainerSingleFrameProviderMixin:AcquireFrame()
	assert(self.isFrameAvailable, "Single frame provider cannot acquire an active frame.");
	self.isFrameAvailable = false;
	return self.auraFrame;
end

function AuraContainerSingleFrameProviderMixin:ReleaseFrame(auraFrame)
	if not assertsafe(auraFrame == self.auraFrame, "Single frame provider cannot release an unknown frame.") then
		return;
	end

	if not assertsafe(not self.isFrameAvailable, "Single frame provider cannot release an inactive frame.") then
		return;
	end

	self.isFrameAvailable = true;
end

function AuraContainerUtil.CreateSingleFrameProvider(auraFrame)
	local provider = CreateFromMixins(AuraContainerSingleFrameProviderMixin);
	provider:Init(auraFrame);
	return provider;
end
