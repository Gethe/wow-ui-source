HoverVisibilityControllerMixin = {};

function HoverVisibilityControllerMixin:OnLoad()
	self.affectedFrames = {};
end

function HoverVisibilityControllerMixin:SetOnSetControllerEnabled(onSetControllerEnabled)
	self.onSetControllerEnabled = onSetControllerEnabled;
end

function HoverVisibilityControllerMixin:OnEnter()
	self:SetAffectedFramesVisibility(false);
end

function HoverVisibilityControllerMixin:OnLeave()
	self:SetAffectedFramesVisibility(true);
end

function HoverVisibilityControllerMixin:SetAffectedFramesVisibility(shown)
	local affectedFrames = self:GetAffectedFrames();
	if not affectedFrames then
		return;	
	end

	for _i, affectedFrame in ipairs(affectedFrames) do
		affectedFrame:SetShown(shown);
	end
end

function HoverVisibilityControllerMixin:GetAffectedFrames()
	return self.affectedFrames;
end

function HoverVisibilityControllerMixin:AddAffectedFrame(frame)
	table.insert(self.affectedFrames, frame);
end

function HoverVisibilityControllerMixin:RemoveAffectedFrame(frame)
	tDeleteItem(self.affectedFrames, frame);
end

function HoverVisibilityControllerMixin:SetControllerEnabled(enabled)
	self:SetMouseMotionEnabled(enabled);
	if self.onSetControllerEnabled then
		self.onSetControllerEnabled(enabled);
	end
end

HoverFadeVisibilityControllerMixin = {}

function HoverFadeVisibilityControllerMixin:SetAffectedFramesVisibility(shown)
	local affectedFrames = self:GetAffectedFrames();
	if not affectedFrames then
		return;	
	end

	for _i, affectedFrame in ipairs(affectedFrames) do
		if not affectedFrame.alphaAnim then
			affectedFrame.fadeFrameGroup = affectedFrame:CreateAnimationGroup();
			affectedFrame.fadeFrameGroup:SetToFinalAlpha(true);

			affectedFrame.alphaAnim = affectedFrame.fadeFrameGroup:CreateAnimation("Alpha");
			affectedFrame.alphaAnim:SetSmoothing("IN_OUT");
	
			affectedFrame.fadeFrameGroup:SetScript("OnFinished", function(frame, requested)
				if affectedFrame:GetAlpha() == 0 then
					affectedFrame:Hide();
				end
			end);
		end

		if shown then
			affectedFrame:Show();
		end

		affectedFrame.alphaAnim:SetFromAlpha(affectedFrame:GetAlpha());
		affectedFrame.alphaAnim:SetToAlpha(shown and 1 or 0);

		affectedFrame.alphaAnim:SetDuration(self.fadeDuration * (shown and (1 - affectedFrame:GetAlpha()) or affectedFrame:GetAlpha()));

		if affectedFrame.fadeFrameGroup:IsPlaying() then
			affectedFrame.fadeFrameGroup:Restart();
		else
			affectedFrame.fadeFrameGroup:Play();
		end
	end
end
