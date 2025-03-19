function TransformTreeFrameNode_Reset(transformTreeFramePool, frame)
	frame:Unlink();
	frame:ClearAllPoints();
	frame:Hide();
end

function CreateTransformFrameNodePool(frameType, parent, frameTemplate, resetFunc)
	local function FrameInitializer(frame)
		CreateTransformTreeNodeFromWidget(frame, TransformTreeFrameNodeMixin);
	end

	local forbidden = false;
	return CreateSecureFramePool(frameType, parent, frameTemplate, resetFunc or TransformTreeFrameNode_Reset, forbidden, FrameInitializer);
end