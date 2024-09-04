
ManagedLayoutFrameMixin = {};

function ManagedLayoutFrameMixin:OnLoad()
	if self.templateType then
		self:SetTemplate(self.frameType or "FRAME", self.templateType);
	end
end

function ManagedLayoutFrameMixin:SetTemplate(frameType, template)
	if self.contentFramePool and self.contentFramePool:GetTemplate() ~= template then
		-- You can't change the template type once it's been set. If you need to have multiple
		-- different types of frames in one container, consider changing this to a PoolCollection.
		error("Cannot change the template type once set", 2);
		return;
	end
	
	self.contentFramePool = CreateFramePool(frameType, self, template);
end

function ManagedLayoutFrameMixin:SetContents(contents)
	self.contentFramePool:ReleaseAll();
	for i, content in ipairs(contents) do
		local contentFrame = self.contentFramePool:Acquire();
		contentFrame:SetContent(content);
		contentFrame.layoutIndex = i;
		contentFrame:Show();
	end

	self:MarkDirty();
end

function ManagedLayoutFrameMixin:EnumerateActive()
	return self.contentFramePool:EnumerateActive();
end

ContentFrameMixin = {}

function ContentFrameMixin:SetContent(content)
	-- Override in your mixin.
end