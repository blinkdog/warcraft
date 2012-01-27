--[[
NeedMonitor2.lua
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

--345678901234567890123456789012345678901234567890123456789012345678901234567890

-- Create NeedMonitor at the global scope if necessary
if NeedMonitor == nil then
   NeedMonitor = {}
end

-- Initialize static values on NeedMonitor; no need to surround with an
-- if-guard because the values are supposed to be immutable.
NeedMonitor.NEED_MONITOR_FRAME_NAME = "NeedMonitorEventFrame"

function NeedMonitor:showArgs(...)
   d
end



--[[
     Convert event names like CHAT_MSG_LOOT to camel case function names like
     OnChatMsgLoot. This is a utility function intended to enable dynamic event
     handler lookups.

     In:
          event - the name of the event to be converted
     Out:
          string - the name of the corresponding camel case function
]]--
function NeedMonitor:toCamelCase(event)
   -- validate parameters
   if event == nil then
      return nil
   end
   if type(event) ~= "string" then
      return ""
   end
   if string.len(event) < 2 then
      return event
   end
   -- convert the event name to a camel case function name
   local camelCase = event
   camelCase = string.lower(camelCase)
   camelCase = string.gsub(camelCase, "_(.)", string.upper)
   return "On"..string.sub(event, 1, 1)..string.sub(camelCase,2)
end

--[[
     Handle CHAT_MSG_LOOT events

     In:
          event - the name of the event (CHAT_MSG_LOOT)
          ... - the parameters provided with the event
]]--
function NeedMonitor:OnChatMsgLoot(
      event,
      arg1,
      arg2,
      arg3,
      arg4,
      arg5,
      arg6,
      arg7,
      arg8,
      arg9,
      arg10,
      arg11,
      arg12,
      arg13,
      arg14,
      arg15
   )
   ChatFrame1:AddMessage("OnChatMsgLoot() has been invoked")
   -- parse the variable args
   local lootMsg = arg1
   ChatFrame1:AddMessage("Before AddMessage...")
   ChatFrame1:AddMessage("Message: '"..tostring(lootMsg).."'")
   ChatFrame1:AddMessage("After AddMessage...")
   -- check to see if somebody selected Need on an item
   startPos, endPos, player, needOrGreed, itemLink =
   string.find(lootMsg, "(.+) has selected (.+) for: (.+)")
   -- if they did, send a message to chat and log it in the DB
   ChatFrame1:AddMessage("Before if player...")
   if player then
      ChatFrame1:AddMessage(player.." selected "..needOrGreed.." on "..itemLink)
      tinsert(NeedMonitor_DB, { event, player, needOrGreed, itemLink })
   else
      ChatFrame1:AddMessage(tostring(lootMsg))
      tinsert(NeedMonitor_DB, { event, lootMsg })
   end
   ChatFrame1:AddMessage("After if player...")
   ChatFrame1:AddMessage("OnChatMsgLoot() is exiting")
end

--
-- Initialize NeedMonitor
--

if _G[NeedMonitor.NEED_MONITOR_FRAME_NAME] == nil then
   if NeedMonitor_DB == nil then
      ChatFrame1:AddMessage("WARNING: NeedMonitor_DB did not exist!")
      NeedMonitor_DB = {}
   end
   
   local frame = CreateFrame("Frame", NeedMonitor.NEED_MONITOR_FRAME_NAME, UIParent)
   frame:RegisterAllEvents()
   NeedMonitor.frame = frame
   NeedMonitor.absoluteTime = 0;
   debugprofilestart();
   frame:SetScript('OnEvent',
      function(self, event, ...)
         -- update the high precision timer
         local elapsedMilliseconds = debugprofilestop();
         debugprofilestart();
         NeedMonitor.absoluteTime = NeedMonitor.absoluteTime + elapsedMilliseconds;
         -- inform if it was a looting message
         if event == "CHAT_MSG_LOOT" then
            ChatFrame1:AddMessage("CHAT_MSG_LOOT received");
         end
         -- call any functions interested in this event
         local functionName = NeedMonitor:toCamelCase(event)
         if NeedMonitor[functionName] then
            NeedMonitor[functionName](event, ...)
         end
      end
   )
else
   ChatFrame1:AddMessage(NeedMonitor.NEED_MONITOR_FRAME_NAME.." already exists: "..tostring(_G[NeedMonitor.NEED_MONITOR_FRAME_NAME]))
end

ChatFrame1:AddMessage("NeedMonitor has been invoked from WowLua")

-- end of script

