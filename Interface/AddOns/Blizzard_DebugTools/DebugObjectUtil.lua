-- This file is executed at the end of addon load
function CanAccessObject(obj)
	return issecure() or not obj:IsForbidden();
end
