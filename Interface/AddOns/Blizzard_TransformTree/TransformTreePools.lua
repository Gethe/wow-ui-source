function TransformTreeFrameNode_Reset(transformTreeFramePool, frame)
	frame:Unlink();
	frame:ClearAllPoints();
	frame:Hide();
end

function CreateTransformFrameNodePool(frameType, parent, frameTemplate, releaseFunc)
	local function Create()
		local frame = CreateFrame(frameType, nil, parent, frameTemplate);
		return CreateTransformTreeNodeFromWidget(frame, TransformTreeFrameNodeMixin);
	end

	return CreateRegionPool(frameTemplate, Create, releaseFunc or TransformTreeFrameNode_Reset);
end