
function OpenStackSplitFrame(maxStack, parent, anchor, anchorTo)
	if ( StackSplitFrame.owner ) then
		StackSplitFrame.owner.hasStackSplit = 0;
	end
	
	if ( not maxStack ) then
		maxStack = 0;
	end

	StackSplitFrame.maxStack = maxStack;
	if ( StackSplitFrame.maxStack < 2 ) then
		StackSplitFrame:Hide();
		return;
	end

	StackSplitFrame.owner = parent;
	parent.hasStackSplit = 1;
	StackSplitFrame.split = 1;
	StackSplitFrame.typing = 0;
	StackSplitText:SetText(StackSplitFrame.split);
	StackSplitLeftButton:Disable();
	StackSplitRightButton:Enable();

	StackSplitFrame:ClearAllPoints();
	StackSplitFrame:SetPoint(anchor, parent, anchorTo, 0, 0);
	StackSplitFrame:Show();
end

function UpdateStackSplitFrame(maxStack)
	StackSplitFrame.maxStack = maxStack;
	if ( StackSplitFrame.maxStack < 2 ) then
		if ( StackSplitFrame.owner ) then
			StackSplitFrame.owner.hasStackSplit = 0;
		end
		StackSplitFrame:Hide();
		return;
	end

	if ( StackSplitFrame.split > StackSplitFrame.maxStack ) then
		StackSplitFrame.split = StackSplitFrame.maxStack;
		StackSplitText:SetText(StackSplitFrame.split);
	end

	if ( StackSplitFrame.split == StackSplitFrame.maxStack ) then
		StackSplitRightButton:Disable();
	else
		StackSplitRightButton:Enable();
	end

	if ( StackSplitFrame.split == 1 ) then
		StackSplitLeftButton:Disable();
	else
		StackSplitLeftButton:Enable();
	end
end

function StackSplitFrame_OnChar(self,text)
	if ( text < "0" or text > "9" ) then
		return;
	end

	if ( self.typing == 0 ) then
		self.typing = 1;
		self.split = 0;
	end

	local split = (self.split * 10) + text;
	if ( split == self.split ) then
		if( self.split == 0 ) then
			self.split = 1;
		end
		return;
	end

	if ( split <= self.maxStack ) then
		self.split = split;
		StackSplitText:SetText(split);
		if ( split == self.maxStack ) then
			StackSplitRightButton:Disable();
		else
			StackSplitRightButton:Enable();
		end
		if ( split == 1 ) then
			StackSplitLeftButton:Disable();
		else
			StackSplitLeftButton:Enable();
		end
	elseif ( split == 0 ) then
		self.split = 1;
	end
end

function StackSplitFrame_OnKeyDown(self,key)
	local numKey = gsub(key, "NUMPAD", "");
	if ( key == "BACKSPACE" or key == "DELETE" ) then
		if ( self.typing == 0 or self.split == 1 ) then
			return;
		end

		self.split = floor(self.split / 10);
		if ( self.split <= 1 ) then
			self.split = 1;
			self.typing = 0;
			StackSplitLeftButton:Disable();
		else
			StackSplitLeftButton:Enable();
		end
		StackSplitText:SetText(self.split);
		if ( self.money == self.maxStack ) then
			StackSplitRightButton:Disable();
		else
			StackSplitRightButton:Enable();
		end
	elseif ( key == "ENTER" ) then
		StackSplitFrameOkay_Click();
	elseif ( GetBindingFromClick(key) == "TOGGLEGAMEMENU" ) then
		StackSplitFrameCancel_Click();
	elseif ( key == "LEFT" or key == "DOWN" ) then
		StackSplitFrameLeft_Click();
	elseif (key == "RIGHT" or key == "UP" ) then
		StackSplitFrameRight_Click();
	elseif ( not ( tonumber(numKey) ) and GetBindingAction(key) ) then
		--Running bindings not used by the StackSplit frame allows players to retain control of their characters.
		RunBinding(GetBindingAction(key));
	end
	
	self.down = self.down or {};
	self.down[key] = true;
end

function StackSplitFrame_OnKeyUp(self,key)
	local numKey = gsub(key, "NUMPAD", "");
	if ( not ( tonumber(numKey) ) and GetBindingAction(key) ) then
		--If we don't run the up bindings as well, interesting things happen (like you never stop moving)
		RunBinding(GetBindingAction(key), "up");
	end
	
	if ( self.down ) then
		self.down[key] = nil;
	end
end

function StackSplitFrameLeft_Click()
	if ( StackSplitFrame.split == 1 ) then
		return;
	end

	StackSplitFrame.split = StackSplitFrame.split - 1;
	StackSplitText:SetText(StackSplitFrame.split);
	if ( StackSplitFrame.split == 1 ) then
		StackSplitLeftButton:Disable();
	end
	StackSplitRightButton:Enable();
end

function StackSplitFrameRight_Click()
	if ( StackSplitFrame.split == StackSplitFrame.maxStack ) then
		return;
	end

	StackSplitFrame.split = StackSplitFrame.split + 1;
	StackSplitText:SetText(StackSplitFrame.split);
	if ( StackSplitFrame.split == StackSplitFrame.maxStack ) then
		StackSplitRightButton:Disable();
	end
	StackSplitLeftButton:Enable();
end

function StackSplitFrameOkay_Click()
	StackSplitFrame:Hide();
	
	if ( StackSplitFrame.owner ) then
		StackSplitFrame.owner.SplitStack(StackSplitFrame.owner, StackSplitFrame.split);
	end
end

function StackSplitFrameCancel_Click()
	StackSplitFrame:Hide();
end

function StackSplitFrame_OnHide (self)	
	for key in next, (self.down or {}) do
		if ( GetBindingAction(key) ) then
			RunBinding(GetBindingAction(key), "up");
		end
		self.down[key] = nil;
	end
	
	if ( StackSplitFrame.owner ) then
		StackSplitFrame.owner.hasStackSplit = 0;
	end
end
