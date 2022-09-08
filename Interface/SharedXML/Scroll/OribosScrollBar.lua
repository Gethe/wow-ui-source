OribosScrollBarButtonScriptsMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function OribosScrollBarButtonScriptsMixin:OnEnter()
	if ButtonStateBehaviorMixin.OnEnter(self) then
		self.Enter:Show();
	end
end

function OribosScrollBarButtonScriptsMixin:OnLeave()
	if ButtonStateBehaviorMixin.OnLeave(self) then
		self.Enter:Hide();
	end
end

function OribosScrollBarButtonScriptsMixin:OnMouseDown()
	if ButtonStateBehaviorMixin.OnMouseDown(self) then
		self.Down:Show();
	end
end

function OribosScrollBarButtonScriptsMixin:OnMouseUp()
	if ButtonStateBehaviorMixin.OnMouseUp(self) then
		self.Down:Hide();
	end
end

function OribosScrollBarButtonScriptsMixin:OnEnable()
	self:DesaturateHierarchy(0);
end

function OribosScrollBarButtonScriptsMixin:OnDisable()
	ButtonStateBehaviorMixin.OnDisable(self);
	self:DesaturateHierarchy(1);
end
