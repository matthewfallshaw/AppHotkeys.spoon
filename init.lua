--- === AppHotkeys ===
---
--- Enables and disables hotkeys as applications get and lose focus.
---
--- In your `~/.hammerspoon/init.lua`, ...  
--- Add `hs.loadSpoon("AppHotkeys")`.  
--- Add `table.insert(spoon.AppHotkeys.hotkeys["<hs.application:name()>"], hs.hotkey.new(...))`
--- for each app hotkey you want to include. (That's `.new(...)` not `.bind(...)` since hotkeys
--- shouldn't be enabled until each app gets focus.)
--- Start the app watcher with `spoon.AppHotkeys:start()`.
---
--- Example `~/.hammerspoon/init.lua`:
---
---     hs.loadSpoon("AppHotkeys")
---
---     -- Terminal ⌘1-9 to tab focus
---     logger.i("Terminal hotkeys for switching ⌘1-9 to Tab focus")
---     for i=1,8 do
---       table.insert(spoon.AppHotkeys.hotkeys["Terminal"], hs.hotkey.new('⌘', tostring(i), function()
---         hs.osascript.applescript('tell application "Terminal" to set selected of tab ' .. i .. ' of first window to true')
---       end))
---     end
---     table.insert(spoon.AppHotkeys.hotkeys["Terminal"], hs.hotkey.new('⌘', "9", function()
---       hs.osascript.applescript('tell application "Terminal" to set selected of last tab of first window to true')
---     end))
---
---     -- Slack usability improvements
---     logger.i("Slack usability hotkeys")
---     table.insert(spoon.AppHotkeys.hotkeys["Slack"], hs.hotkey.new('⌘', 'w', function()
---       hs.eventtap.keyStrokes("/leave ")
---       hs.timer.doAfter(0.3, function() hs.application.get("Slack"):activate(); hs.eventtap.keyStroke({}, "return") end)
---     end))
---     table.insert(spoon.AppHotkeys.hotkeys["Slack"],
---       hs.hotkey.new('⌘⇧', ']', function() hs.eventtap.keyStroke({'alt'}, 'down') end))
---     table.insert(spoon.AppHotkeys.hotkeys["Slack"],
---       hs.hotkey.new('⌘⇧', '[', function() hs.eventtap.keyStroke({'alt'}, 'up') end))
---
---     spoon.AppHotkeys:start()

local M = {}
M.__index = M

-- Metadata
M.name = "AppHotkeys"
M.version = "0.1"
M.author = "Matthew Fallshaw <m@fallshaw.me>"
M.license = "MIT - https://opensource.org/licenses/MIT"
M.homepage = "https://github.com/matthewfallshaw/AppHotkeys.spoon"

function M:init()
  self.window_filters = {}
  setmetatable(M.hotkeys, { __index = function(t,k) t[k]={}; return t[k] end }) -- initialise M.hotkeys.? = {}
end

--- AppHotkeys.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
local logger = hs.logger.new("App Hotkeys")
M.logger = logger


--- AppHotkeys.hotkeys
--- Variable
--- The hotkeys for each app. 
---
--- Notes:
---  * `table.insert(AppHotkeys.hotkeys["<hs.application:name()>"], <hs.hotkey.new(...)>)`
---  * eg. `table.insert(spoon.AppHotkeys.hotkeys["Slack"], hs.hotkey.new('⌘⇧', ']', function() hs.eventtap.keyStroke({'alt'}, 'down') end))`
---  * You don't need to initialise `AppHotkeys.hotkeys["<hs.application:name()>"] = {}`, that will be done for you.
M.hotkeys = {}


-- Utility functions
local function windowFocused(window, application_name, event)
  for _,hotkey in pairs(M.hotkeys[application_name]) do hotkey:enable() end
  logger.i(application_name .. " hotkeys enabled")
end
local function windowUnfocused(window, application_name, event)
  for _,hotkey in pairs(M.hotkeys[application_name]) do hotkey:disable() end
  logger.i(application_name .. " hotkeys disabled")
end


-- Module methods

--- AppHotkeys:start()
--- Method
--- Starts AppHotkeys, building a `hs.window.filter` for each app in `spoon.AppHotkeys.hotkeys`.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The AppHotkeys object
function M:start()
  for app,_ in pairs(self.hotkeys) do
    self.window_filters[app] = hs.window.filter.new(app)
    self.window_filters[app]:subscribe({
      [hs.window.filter.windowFocused] = windowFocused,
      [hs.window.filter.windowVisible] = windowFocused, -- because focusing a hidden app doesn't trigger windowFocused
      [hs.window.filter.windowUnfocused] = windowUnfocused,
    })
    local frontmost = hs.application.frontmostApplication()
    if frontmost and frontmost:name() == app then windowFocused(_, app, _) end
  end
end


--- AppHotkeys:stop()
--- Method
--- Stops AppHotkeys, disabling any hotkeys that are enabled and disabling each app `hs.window.filter`.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The AppHotkeys object
function M:stop()
  for _,f in pairs(self.window_filters) do
    for fn,_ in pairs(f.events.windowUnfocused) do fn() end
    f:unsubscribeAll()
  end
end


return M
