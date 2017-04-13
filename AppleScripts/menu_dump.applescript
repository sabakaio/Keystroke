-- I was trying to make a recursive walker here
on parseMenu(theMenu)
	set menuMapItem to {}
	try
		repeat with m in every menu item of theMenu
			try
				set innerMenu to (every menu of m)
				set end of menuMapItem to parseMenu(innerMenu)
			on error
				set end of menuMapItem to name of m
			end try
		end repeat
	on error
		return false
	end try
	return {name of theMenu, menuMapItem}
end parseMenu

tell application "System Events"
	tell process "Google Chrome"
		--get position of menu item "New Tab" of menu "File" of menu bar item "File" of menu bar 1
		set topLevelMenus to {}
		repeat with m in every menu of every menu bar item of menu bar 1
			set end of topLevelMenus to m
		end repeat
		
		set menuMap to {}
		repeat with topLevelMenu in topLevelMenus
			set menuMapItem to {}
			repeat with m in every menu item of topLevelMenu
				set end of menuMapItem to name of m
			end repeat
			
			set end of menuMap to {name of topLevelMenu, menuMapItem}
		end repeat
		
		menuMap
	end tell
end tell