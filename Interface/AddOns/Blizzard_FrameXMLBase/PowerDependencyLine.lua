PowerDependencyLineMixin = {};

PowerDependencyLineMixin.LINE_STATE_CONNECTED = 1;
PowerDependencyLineMixin.LINE_STATE_DISCONNECTED = 2;
PowerDependencyLineMixin.LINE_STATE_LOCKED = 3;

PowerDependencyLineMixin.LINE_FADE_ANIM_TYPE_CONNECTED = 1;
PowerDependencyLineMixin.LINE_FADE_ANIM_TYPE_UNLOCKED = 2;
PowerDependencyLineMixin.LINE_FADE_ANIM_TYPE_LOCKED = 3;

function PowerDependencyLineMixin:IsDeprecated()
	-- Optionally override in your mixin
	return false;
end

function PowerDependencyLineMixin:SetThickness(thickness)
	self.Background:SetThickness(thickness);
	self.Fill:SetThickness(thickness);
	self.FillScroll1:SetThickness(thickness);
	if not self.isCurved then
		self.FillScroll2:SetThickness(thickness);
	end
end

function PowerDependencyLineMixin:SetState(lineState)
	self.lineState = lineState;
	if lineState == self.LINE_STATE_CONNECTED then
		self:SetConnected();
	elseif lineState == self.LINE_STATE_DISCONNECTED then
		self:SetDisconnected();
	elseif lineState == self.LINE_STATE_LOCKED then
		self:SetLocked();
	end
end

function PowerDependencyLineMixin:SetConnected()
	self.Fill:SetVertexColor(self.connectedColor:GetRGB());
	self.FillScroll1:SetVertexColor(self.connectedColor:GetRGB());
	if not self.isCurved then
		self.FillScroll2:SetVertexColor(self.connectedColor:GetRGB());
	end

	self:PlayLineFadeAnim(self.LINE_FADE_ANIM_TYPE_CONNECTED);
end

function PowerDependencyLineMixin:SetDisconnected()
	self.Fill:SetVertexColor(self.disconnectedColor:GetRGB());

	self:PlayLineFadeAnim(self.LINE_FADE_ANIM_TYPE_UNLOCKED);
end

function PowerDependencyLineMixin:SetLocked()
	self.Fill:SetVertexColor(self.connectedColor:GetRGB());

	self:PlayLineFadeAnim(self.LINE_FADE_ANIM_TYPE_LOCKED);
end

function PowerDependencyLineMixin:PlayLineFadeAnim(lineAnimType)
	self.FadeAnim:Finish();

	self.FadeAnim.Background:SetFromAlpha(self.Background:GetAlpha());
	self.FadeAnim.Fill:SetFromAlpha(self.Fill:GetAlpha());
	self.FadeAnim.FillScroll1:SetFromAlpha(self.FillScroll1:GetAlpha());
	if not self.isCurved then
		self.FadeAnim.FillScroll2:SetFromAlpha(self.FillScroll2:GetAlpha());
	end

	local itemDeprecated = self:IsDeprecated();
	if itemDeprecated then
		self.FillScroll1:SetDesaturated(true);
		if not self.isCurved then
			self.FillScroll2:SetDesaturated(true);
		end
	end

	if lineAnimType == self.LINE_FADE_ANIM_TYPE_CONNECTED then
		if itemDeprecated then
			self.ScrollAnim:Stop();
		else
			self.ScrollAnim:Play(false, self.scrollElapsedOffset);
		end

		self.FadeAnim.Background:SetToAlpha(0.0);
		self.FadeAnim.Fill:SetToAlpha(1.0);
		self.FadeAnim.FillScroll1:SetToAlpha(1.0);
		if not self.isCurved then
			self.FadeAnim.FillScroll2:SetToAlpha(1.0);
		end
	elseif lineAnimType == self.LINE_FADE_ANIM_TYPE_UNLOCKED then
		self.ScrollAnim:Stop();

		self.FadeAnim.Background:SetToAlpha(1.0);
		self.FadeAnim.Fill:SetToAlpha(1.0);
		self.FadeAnim.FillScroll1:SetToAlpha(0.0);
		if not self.isCurved then
			self.FadeAnim.FillScroll2:SetToAlpha(0.0);
		end

	elseif lineAnimType == self.LINE_FADE_ANIM_TYPE_LOCKED then
		self.ScrollAnim:Stop();

		self.FadeAnim.Background:SetToAlpha(0.85);
		self.FadeAnim.Fill:SetToAlpha(0.0);
		self.FadeAnim.FillScroll1:SetToAlpha(0.0);
		if not self.isCurved then
			self.FadeAnim.FillScroll2:SetToAlpha(0.0);
		end
	end
	self.animType = lineAnimType;
	self.FadeAnim:Play();
end

function PowerDependencyLineMixin:SetEndPoints(fromButton, toButton)
	if self.isCurved then
		self.Fill:SetSize(2, 2);
		self.Fill:ClearAllPoints();
		self.Fill:SetPoint("CENTER", fromButton);

		self.Background:SetSize(2, 2);
		self.Background:ClearAllPoints();
		self.Background:SetPoint("CENTER", fromButton);

		self.FillScroll1:SetSize(2, 2);
		self.FillScroll1:ClearAllPoints();
		self.FillScroll1:SetPoint("CENTER", fromButton);
	else
		self.Fill:SetStartPoint("CENTER", fromButton);
		self.Fill:SetEndPoint("CENTER", toButton);

		self.Background:SetStartPoint("CENTER", fromButton);
		self.Background:SetEndPoint("CENTER", toButton);

		self.FillScroll1:SetStartPoint("CENTER", fromButton);
		self.FillScroll1:SetEndPoint("CENTER", toButton);

		self.FillScroll2:SetStartPoint("CENTER", fromButton);
		self.FillScroll2:SetEndPoint("CENTER", toButton);
	end
end

function PowerDependencyLineMixin:SetConnectedColor(color)
	self.connectedColor = color;
end

function PowerDependencyLineMixin:SetDisconnectedColor(color)
	self.disconnectedColor = color;
end

do
	local function OnLineRevealFinished(animGroup)
		local lineContainer = animGroup:GetParent();
		lineContainer:OnRevealFinished();
	end

	function PowerDependencyLineMixin:BeginReveal(delay, duration)
		if not self.RevealAnim then
			return;
		end
		self:SetAlpha(0.0);

		self.RevealAnim.Start1:SetEndDelay(delay);
		self.RevealAnim.Start2:SetEndDelay(delay);

		self.RevealAnim.LineScale:SetDuration(duration);

		self.RevealAnim:SetScript("OnFinished", OnLineRevealFinished);
		self.RevealAnim:Play();
	end
end

function PowerDependencyLineMixin:OnRevealFinished()
	if self.animType then
		self:PlayLineFadeAnim(self.animType);
	end
end

function PowerDependencyLineMixin:IsRevealing()
	return self.RevealAnim and self.RevealAnim:IsPlaying();
end

function PowerDependencyLineMixin:GetRevealDelay()
	return self.RevealAnim and self.RevealAnim.Start1:GetEndDelay() or 0.0;
end

function PowerDependencyLineMixin:SetScrollAnimationProgressOffset(progress)
	self.scrollElapsedOffset = (1 - progress) * self.ScrollAnim:GetDuration();
end

function PowerDependencyLineMixin:CalculateTiling(length)
	local TEXTURE_WIDTH = 128;
	local tileAmount = length / TEXTURE_WIDTH;
	self.Fill:SetTexCoord(0, tileAmount, 0, 1);
	self.Background:SetTexCoord(0, tileAmount, 0, 1);
	self.FillScroll1:SetTexCoord(0, tileAmount, 0, 1);
	if not self.isCurved then
		self.FillScroll2:SetTexCoord(0, tileAmount, 0, 1);
	end
end

function PowerDependencyLineMixin:SetVertexOffset(vertexIndex, x, y)
	self.Fill:SetVertexOffset(vertexIndex, x, y);
	self.Background:SetVertexOffset(vertexIndex, x, y);
	self.FillScroll1:SetVertexOffset(vertexIndex, x, y);
	if not self.isCurved then
		self.FillScroll2:SetVertexOffset(vertexIndex, x, y);
	end
end

function PowerDependencyLineMixin:SetAlpha(alpha, continueAnimating)
	if not continueAnimating then
		self.ScrollAnim:Stop();
		self.FadeAnim:Stop();
		if self.RevealAnim then
			self.RevealAnim:Stop();
		end
	end

	self.Background:SetAlpha(alpha);
	self.Fill:SetAlpha(alpha);
	self.FillScroll1:SetAlpha(alpha);
	if not self.isCurved then
		self.FillScroll2:SetAlpha(alpha);
	end
end

function PowerDependencyLineMixin:OnReleased()
	self.animType = nil;
	self:SetAlpha(0.0);
end
