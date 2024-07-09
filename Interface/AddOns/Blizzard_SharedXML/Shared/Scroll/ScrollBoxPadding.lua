---------------
--NOTE - Please do not change this section without talking to the UI team
local _, tbl = ...;
if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	setfenv(1, tbl);

end
---------------

ScrollBoxPaddingMixin = {};

function ScrollBoxPaddingMixin:Init(top, bottom, left, right)
	self:SetTop(top or 0);
	self:SetBottom(bottom or 0);
	self:SetLeft(left or 0);
	self:SetRight(right or 0);
end

function ScrollBoxPaddingMixin:GetTop()
	return self.top;
end

function ScrollBoxPaddingMixin:SetTop(top)
	self.top = top;
end

function ScrollBoxPaddingMixin:GetBottom()
	return self.bottom;
end

function ScrollBoxPaddingMixin:SetBottom(bottom)
	self.bottom = bottom;
end

function ScrollBoxPaddingMixin:GetLeft()
	return self.left;
end

function ScrollBoxPaddingMixin:SetLeft(left)
	self.left = left;
end

function ScrollBoxPaddingMixin:GetRight()
	return self.right;
end

function ScrollBoxPaddingMixin:SetRight(right)
	self.right = right;
end

function CreateScrollBoxPadding(top, bottom, left, right)
	return CreateAndInitFromMixin(ScrollBoxPaddingMixin, top, bottom, left, right);
end
