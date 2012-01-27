--[[
EventRecorder.lua
Copyright 2010 Patrick Meade

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

local frame = CreateFrame("Frame", "EventRecorderEventFrame", UIParent)
frame:RegisterAllEvents()
frame.absoluteTime = 0;
debugprofilestart();
frame:SetScript('OnEvent',
   function(self, event, ...)
      -- update the high precision timer
      local elapsedMilliseconds = debugprofilestop();
      debugprofilestart();
      frame.absoluteTime = frame.absoluteTime + elapsedMilliseconds;
      -- record all events in the NeedMonitor_DB
      table.insert(NeedMonitor_DB, { frame.absoluteTime, event, ... })
   end
)

ChatFrame1:AddMessage("Now recording all events to NeedMonitor_DB")

-- end of script

