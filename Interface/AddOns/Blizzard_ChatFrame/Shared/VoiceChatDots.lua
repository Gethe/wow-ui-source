VoiceChatDotsMixin = {};

function VoiceChatDotsMixin:OnLoad()
	self:StopAnimation();
end

function VoiceChatDotsMixin:PlayAnimation()
	self.Dot1:SetAlpha(0);
	self.Dot2:SetAlpha(0);
	self.Dot3:SetAlpha(0);
	self.PendingAnim:Play();
end

function VoiceChatDotsMixin:StopAnimation()
	self.PendingAnim:Stop();
	self.Dot1:SetAlpha(0);
	self.Dot2:SetAlpha(0);
	self.Dot3:SetAlpha(0);
end
