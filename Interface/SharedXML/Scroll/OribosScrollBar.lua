OribosScrollBarButtonScriptsMixin = CreateFromMixins(ScrollBarButtonBehaviorMixin);

function OribosScrollBarButtonScriptsMixin:OnEnter()
	if ScrollBarButtonBehaviorMixin.OnEnter(self) then
		self.Enter:Show();
	end
end

function OribosScrollBarButtonScriptsMixin:OnLeave()
	if ScrollBarButtonBehaviorMixin.OnLeave(self) then
		self.Enter:Hide();
	end
end

function OribosScrollBarButtonScriptsMixin:OnMouseDown()
	if ScrollBarButtonBehaviorMixin.OnMouseDown(self) then
		self.Down:Show();
	end
end

function OribosScrollBarButtonScriptsMixin:OnMouseUp()
	if ScrollBarButtonBehaviorMixin.OnMouseUp(self) then
		self.Down:Hide();
	end
end

function OribosScrollBarButtonScriptsMixin:OnEnable()
	self:DesaturateHierarchy(0);
end

function OribosScrollBarButtonScriptsMixin:OnDisable()
	ScrollBarButtonBehaviorMixin.OnDisable(self);
	self:DesaturateHierarchy(1);
end
