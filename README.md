# AppHotkeys.spoon

Enables and disables hotkeys as applications get and lose focus.
A Spoon for Hammerspoon.


## Install

Copy directory as AppHotkeys.spoon to ~/.hammerspoon/Spoons/


## Use

In your `~/.hammerspoon/init.lua`, ...  
Add `hs.loadSpoon("AppHotkeys")`.  
Add `spoon.AppHotkeys.hotkeys["<hs.application:name()>"][<n>] = hs.hotkey.new(...)` (not `.bind`)
for each app hotkey you want to include.  
Start the app watcher with `spoon.AppHotkeys:start()`.

Example `~/.hammerspoon/init.lua`:

    hs.loadSpoon("AppHotkeys")

    -- Terminal ⌘1-9 to tab focus
    logger.i("Terminal hotkeys for switching ⌘1-9 to Tab focus")
    for i=1,8 do
      table.insert(spoon.AppHotkeys.hotkeys["Terminal"], hs.hotkey.new('⌘', tostring(i), function()
        hs.osascript.applescript('tell application "Terminal" to set selected of tab ' .. i .. ' of first window to true')
      end))
    end
    table.insert(spoon.AppHotkeys.hotkeys["Terminal"], hs.hotkey.new('⌘', "9", function()
      hs.osascript.applescript('tell application "Terminal" to set selected of last tab of first window to true')
    end))

    -- Slack usability improvements
    logger.i("Slack usability hotkeys")
    table.insert(spoon.AppHotkeys.hotkeys["Slack"], hs.hotkey.new('⌘', 'w', function()
      hs.eventtap.keyStrokes("/leave ")
      hs.timer.doAfter(0.3, function() hs.application.get("Slack"):activate(); hs.eventtap.keyStroke({}, "return") end)
    end))
    table.insert(spoon.AppHotkeys.hotkeys["Slack"],
      hs.hotkey.new('⌘⇧', ']', function() hs.eventtap.keyStroke({'alt'}, 'down') end))
    table.insert(spoon.AppHotkeys.hotkeys["Slack"],
      hs.hotkey.new('⌘⇧', '[', function() hs.eventtap.keyStroke({'alt'}, 'up') end))

    spoon.AppHotkeys:start()
