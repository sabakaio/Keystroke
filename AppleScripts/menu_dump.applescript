tell application "System Events"
	tell process "iTerm2"
		set topLevelMenus to {}
		repeat with m in every menu of every menu bar item of menu bar 1
			set end of topLevelMenus to m
		end repeat
		
		set menuMap to {}
		repeat with topLevelMenu in topLevelMenus
			set menuMapItem to {}
			repeat with m in every menu item of topLevelMenu
				set innerLevelMenus to {}
				repeat with im in every menu item of every menu of m
					set end of innerLevelMenus to name of im
				end repeat
				if (count innerLevelMenus) > 0 then
					set end of menuMapItem to {name of m, innerLevelMenus}
				else
					set end of menuMapItem to {name of m}
				end if
			end repeat
			
			set end of menuMap to {name of topLevelMenu, menuMapItem}
		end repeat
		
		menuMap
	end tell
end tell