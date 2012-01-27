--[[
NeedMonitor3.lua
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

-- 45678901234567890123456789012345678901234567890123456789012345678901234567890

--[[
]]--
local ARMOR_CHANGE_LEVEL = 40               -- armor changes at level 40
local ARMOR_CHANGE_WIGGLE_ROOM = 5          -- some levels of wiggle room

local PROGRAM_NAME = "NeedMonitor 4.2.0 (alpha)"

local NEED_MONITOR_ANNOUNCE = PROGRAM_NAME .. " is being tested. Please ignore spurious messages. Questions to: wowneedmonitor@gmail.com"

--[[
]]--
local NeedMonitor = CreateFrame("Frame", "NeedMonitorEventFrame", UIParent)
_G["NeedMonitorWowLua"] = NeedMonitor

--[[
]]--
function NeedMonitor:announce()
   SendChatMessage(NEED_MONITOR_ANNOUNCE, "PARTY")
end

--[[
]]--
function NeedMonitor:checkPartyTalents()
   if self.partyTable then
   else
   end
end


--[[
]]--
function NeedMonitor:getBestArmorChoice(itemSubType, itemMinLevel, playerClass, playerLevel)
   -- if it's a simple class; return the best armor they can wear
   if playerClass == "Death Knight" then
      return "Plate"
   end
   if playerClass == "Druid" then
      return "Leather"
   end
   if playerClass == "Mage" then
      return "Cloth"
   end
   if playerClass == "Priest" then
      return "Cloth"
   end
   if playerClass == "Rogue" then
      return "Leather"
   end
   if playerClass == "Warlock" then
      return "Cloth"
   end
   
   -- if it's a more complicated class; it's based on the item
   if playerClass == "Hunter" or playerClass == "Shaman" then
      if itemMinLevel < (ARMOR_CHANGE_LEVEL - ARMOR_CHANGE_WIGGLE_ROOM) then
         return "Leather"
      end
      if itemMinLevel > (ARMOR_CHANGE_LEVEL + ARMOR_CHANGE_WIGGLE_ROOM) then
         return "Mail"
      end
      if itemSubType == "Leather" or itemSubType == "Mail" then
         return itemSubType
      end
      if playerLevel < ARMOR_CHANGE_LEVEL then
         return "Leather"
      else
         return "Mail"
      end
   end
   
   if playerClass == "Paladin" or playerClass == "Warrior" then
      if itemMinLevel < (ARMOR_CHANGE_LEVEL - ARMOR_CHANGE_WIGGLE_ROOM) then
         return "Mail"
      end
      if itemMinLevel > (ARMOR_CHANGE_LEVEL + ARMOR_CHANGE_WIGGLE_ROOM) then
         return "Plate"
      end
      if itemSubType == "Mail" or itemSubType == "Plate" then
         return itemSubType
      end
      if playerLevel < ARMOR_CHANGE_LEVEL then
         return "Mail"
      else
         return "Plate"
      end
   end
end

--[[
]]--
function NeedMonitor:handleNeed(player, itemLinkArg)
   local itemStats = GetItemStats(itemLinkArg)
   ChatFrame1:AddMessage("Saved stats for "..itemLinkArg.." to the database for review")
   if NeedMonitor_DB["Stats"] == nil then
      ChatFrame1:AddMessage("Created NeedMonitor_DB[Stats]")
      NeedMonitor_DB["Stats"] = {}
   end
   table.insert(NeedMonitor_DB["Stats"], { player, self.partyTable[player], itemLinkArg, itemStats })
   
   local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLinkArg)
   
   -- load the party table if it doesn't exist yet
   if self.partyTable == nil then
      self:loadPartyTable()
   end
   
   local playerClass = self.partyTable[player].class
   local playerLevel = self.partyTable[player].level
   
   -- handle type:Armor
   if itemType == "Armor" then
      -- if we're dealing with a standard piece of armor
      if (itemSubType == "Cloth") or (itemSubType == "Leather") or (itemSubType == "Mail") or (itemSubType == "Plate") then
         -- cloaks are a special exception; they are always cloth
         if itemEquipLoc == "INVTYPE_CLOAK" then
            return
         end
         
         local canUse = NeedMonitor_Game_DB[itemType][playerClass][itemSubType]
         -- if this armor type is wholly inappropriate
         if canUse == false then
            self:notifyCannotUse(player, itemLinkArg, playerClass, itemSubType)
            return
         else
            local bestChoice = self:getBestArmorChoice(itemSubType, itemMinLevel, playerClass, playerLevel)
            if bestChoice ~= itemSubType then
               self:notifyPoorChoice(player, itemLinkArg, playerClass, itemSubType, bestChoice, itemMinLevel)
            end
            return
         end
      else
         -- otherwise, we're dealing with Miscellaneous, Shields, Librams, Idols, Totems, and Sigils
         
         -- if it's a shield, look it up like normal
         if (itemSubType == "Shields") then
            local appropriate = NeedMonitor_Game_DB[itemType][playerClass][itemSubType]
            -- if this class cannot use a shield
            if appropriate == false then
               self:notifyCannotUse(player, itemLinkArg, playerClass, itemSubType)
            end
            -- shields have been handled
            return
         end
         
         -- if it's a Libram and not a Paladin
         if (itemSubType == "Librams") and (playerClass ~= "Paladin") then
            -- notify everybody that it can't be used
            self:notifyCannotUse(player, itemLinkArg, playerClass, itemSubType)
            return
         end
         
         -- if it's an Idol and not a Druid
         if (itemSubType == "Idols") and (playerClass ~= "Druid") then
            -- notify everybody that it can't be used
            self:notifyCannotUse(player, itemLinkArg, playerClass, itemSubType)
            return
         end
         
         -- if it's a Totem and not a Shaman
         if (itemSubType == "Totems") and (playerClass ~= "Shaman") then
            -- notify everybody that it can't be used
            self:notifyCannotUse(player, itemLinkArg, playerClass, itemSubType)
            return
         end
         
         -- if it's a Sigil and not a Death Knight
         if (itemSubType == "Sigils") and (playerClass ~= "Death Knight") then
            -- notify everybody that it can't be used
            self:notifyCannotUse(player, itemLinkArg, playerClass, itemSubType)
            return
         end
         
         -- if it's a Miscellaneous, it's probably a necklace, ring, or something
         if (itemSubType == "Miscellaneous") then
            return
         end
         
         -- fall through to "I don't know how to handle"
      end
   end
   
   
   -- handle type:Weapon
   if itemType == "Weapon" then
      local appropriate = NeedMonitor_Game_DB[itemType][playerClass][itemSubType]
      -- if this weapon type is wholly inappropriate for this class
      if appropriate == false then
         self:notifyCannotUse(player, itemLinkArg, playerClass, itemSubType)
      end
      -- all weapons are handled
      return
   end
   
   -- handle type:Miscellaneous, subtype:Junk (i.e.: lockboxes)
   if itemType == "Miscellaneous" and itemSubType == "Junk" then
      self:notifyNeverNeed(player, itemLinkArg, playerClass, itemSubType)
      -- this type is handled
      return
   end
   -- handle type:Gem, subtype:Simple (i.e.: Tigerseye, Shadowgem, etc.)
   if itemType == "Gem" and itemSubType == "Simple" then
      self:notifyNeverNeed(player, itemLinkArg, playerClass, itemSubType)
      -- this type is handled
      return
   end
   -- handle type:Trade Goods (i.e.: commodity goods)
   if itemType == "Trade Goods" then
      self:notifyNeverNeed(player, itemLinkArg, playerClass, itemSubType)
      -- this type is handled
      return
   end
   
   -- we don't know how to handle this one yet   
   ChatFrame1:AddMessage("I don't know how to handle "..itemType.."/"..itemSubType.." for "..playerClass.." "..playerLevel)
   if NeedMonitor_DB["Unknown"] == nil then
      ChatFrame1:AddMessage("Created NeedMonitor_DB[Unknown]")
      NeedMonitor_DB["Unknown"] = {}
   end
   ChatFrame1:AddMessage("Saved "..itemLinkArg.." to the database for review")
   table.insert(NeedMonitor_DB["Unknown"], { player, self.partyTable[player], itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, itemLinkArg })
end

--[[
]]--
function NeedMonitor:loadPartyTable()
   local partyTable = {}
   if self.partyTable then
      partyTable = self.partyTable
   end
   
   local memberInfo = {}
   memberInfo.name = UnitName("player")
   memberInfo.realm = GetRealmName()
   memberInfo.class = UnitClass("player")
   memberInfo.level = UnitLevel("player")
   memberInfo.key = memberInfo.name.."-"..memberInfo.realm
   partyTable[memberInfo.name] = memberInfo
   
   local playerName, playerRealm = UnitName("party1")
   local playerClass = UnitClass("party1")
   local playerLevel = UnitLevel("party1")
   if playerName and playerRealm and playerClass and playerLevel then
      local memberInfo = {}
      memberInfo.name = playerName
      memberInfo.realm = playerRealm
      memberInfo.class = playerClass
      memberInfo.level = playerLevel
      memberInfo.key = memberInfo.name.."-"..memberInfo.realm
      partyTable[memberInfo.name] = memberInfo
   end
   
   local playerName, playerRealm = UnitName("party2")
   local playerClass = UnitClass("party2")
   local playerLevel = UnitLevel("party2")
   if playerName and playerRealm and playerClass and playerLevel then
      local memberInfo = {}
      memberInfo.name = playerName
      memberInfo.realm = playerRealm
      memberInfo.class = playerClass
      memberInfo.level = playerLevel
      memberInfo.key = memberInfo.name.."-"..memberInfo.realm
      partyTable[memberInfo.name] = memberInfo
   end
   
   local playerName, playerRealm = UnitName("party3")
   local playerClass = UnitClass("party3")
   local playerLevel = UnitLevel("party3")
   if playerName and playerRealm and playerClass and playerLevel then
      local memberInfo = {}
      memberInfo.name = playerName
      memberInfo.realm = playerRealm
      memberInfo.class = playerClass
      memberInfo.level = playerLevel
      memberInfo.key = memberInfo.name.."-"..memberInfo.realm
      partyTable[memberInfo.name] = memberInfo
   end
   
   local playerName, playerRealm = UnitName("party4")
   local playerClass = UnitClass("party4")
   local playerLevel = UnitLevel("party4")
   if playerName and playerRealm and playerClass and playerLevel then
      local memberInfo = {}
      memberInfo.name = playerName
      memberInfo.realm = playerRealm
      memberInfo.class = playerClass
      memberInfo.level = playerLevel
      memberInfo.key = memberInfo.name.."-"..memberInfo.realm
      partyTable[memberInfo.name] = memberInfo
   end
   
   self.partyTable = partyTable
end

--[[
    Notify that the player has selected Need on an item they cannot use.
]]--
function NeedMonitor:notifyCannotUse(player, itemLinkArg, playerClass, itemSubType)
   local fullName = self.partyTable[player].key
   SendChatMessage("NeedMonitor: "..fullName.." selected Need on "..itemLinkArg.." but "..playerClass.." cannot use "..itemSubType, "PARTY")
end

--[[
    Notify that the player has selected Need on an item that nobody should ever "Need"
]]--
function NeedMonitor:notifyNeverNeed(player, itemLinkArg, playerClass, itemSubType)
   local fullName = self.partyTable[player].key
   SendChatMessage("NeedMonitor: "..fullName.." selected Need on "..itemLinkArg.." but this isn't a "..playerClass.."-specific item.", "PARTY")
end

--[[
    Notify that the player has selected Need on a useable but poor choice
    for example, someone who can wear Plate but selects Need on Cloth
]]--
function NeedMonitor:notifyPoorChoice(player, itemLinkArg, playerClass, itemSubType, appropriateType, itemMinLevel)
   local fullName = self.partyTable[player].key
   SendChatMessage("NeedMonitor: "..fullName.." selected Need on "..itemLinkArg.."("..itemSubType..") but "..playerClass.." should need "..appropriateType.." items.", "PARTY")
end



--[[
Fired when loot text is sent to the chat window (someone selects need, greed,
passes, rolls, receives). This also fires messages like "Person creates <item>"
via tradeskills, and "Person receives <item>" via a trade window.

arg1
    Chat message 
arg11
    Chat lineID 
]]--
function NeedMonitor:CHAT_MSG_LOOT(...)
   --DEBUG:ChatFrame1:AddMessage("CHAT_MSG_LOOT called")
   local message, u2, u3, u4, u5, u6, u7, u8, u9, u10, lineId = ...
   
   -- load the party table if necessary
   if self.partyTable == nil then
      self:loadPartyTable()
   end
   
   local player, needOrGreed, itemLink = string.match(message, "(.+) has selected (.+) for: (.+)")
   if player and (needOrGreed == "Need") then
      --ninjaPoints = self:calculateNinjaPoints(player, itemLink)
      self:handleNeed(player, itemLink)
   end
   player, needOrGreed, itemLink = string.match(message, "(.+) have selected (.+) for: (.+)")
   if player and (needOrGreed == "Need") then
      player = UnitName("player")
      --ninjaPoints = self:calculateNinjaPoints(player, itemLink)
      self:handleNeed(player, itemLink)
   end
end

--[[
Fired when a player switches changes which talent group (dual specialization) is active.

arg1 
    Number - Index of the talent group that is now active. 
]]--
function NeedMonitor:ACTIVE_TALENT_GROUP_CHANGED(...)
   ChatFrame1:AddMessage("ACTIVE_TALENT_GROUP_CHANGED event received")
end

--[[
After a NotifyInspect(unit) is called, this is fired, indicating the Inspected player's talents have been loaded. 
]]--
function NeedMonitor:INSPECT_TALENT_READY(...)
   ChatFrame1:AddMessage("INSPECT_TALENT_READY event received")
end

--[[
Fired when the player's party changes.
         
         As of 1.8.3 this event also fires when players are moved around in a Raid and
         when a player leaves the raid. This holds true even if the changes do not
            affect your party within the raid.
            
            4-2-05 Edit: This event is called twice when the event PARTY_LOOT_METHOD_CHANGED
            is called.
            
            7-28-05 EDIT: This event is generated when someone joins or leaves the group,
            also generated whenever someone rejects an invite and you're in a group. Also,
if for instance you have 3 people in your group and you invite a 4th, it will
generate 4 events. If you call GetNumPartyMembers() it will return 0, 1, 2, and
3. First event returing zero, 2nd event returning 1, etc etc. 
]]--
function NeedMonitor:PARTY_MEMBERS_CHANGED(...)
   self:loadPartyTable()
   local numPartyMembers = GetNumPartyMembers()
   if (numPartyMembers == 4) and (self.inInstance == true) and (self.needMonitorAnnounced == false) then
      self.needMonitorAnnounced = true
      self:announce()
   end
   self:checkPartyTalents()
end

--[[
Fired when the player enters the world, enters/leaves an instance, or respawns at a graveyard. Also fires any other time the player sees a loading screen.

To check if the player is entering an instance, check GetPlayerMapPosition to see if both X and Y are zero.

Correction on the above comment: When PLAYER_ENTERING_WORLD fires, you'll notice that WORLD_MAP_UPDATE fires just before it. My instincts tell that leaving an instance puts the player in void space momentarily. So for the case that you are entering AND leaving an instance, GetPlayerMapPosition always returns the coordinates [0,0] and hence there is no way to determine using the event PLAYER_ENTERING_WORLD if the player is entering an instance or not. When leaving an instance the following events fire (ignoring party/raid events).
            
            WORLD_MAP_UPDATE 
            PLAYER_ENTERING_WORLD 
            WORLD_MAP_UPDATE <--- Player coordinates are non-zero here 
            
            Instances do have coordinates for units once the second WORLD_MAP_UPDATE event has fired. For the case of entering a battleground such as WSG, WORLD_MAP_UPDATE won't fire until you leave Silverwing Hold or Warsong Lumber Mill and you are outside. --Salanex
]]--
function NeedMonitor:PLAYER_ENTERING_WORLD(...)
   local inInstance, instanceType = IsInInstance()
   -- if we've entered a 5-man instance, announce ourselves
   if inInstance and (instanceType == "party") then
      self.inInstance = true
      self.needMonitorAnnounced = false
   end
end


--[[
Action: Set up the event handler function
]]--
NeedMonitor:SetScript("OnEvent", function(self, event, ...)
      -- call the registered event handler
      NeedMonitor[event](self, ...); 
end);

--[[
Action: Register all events for which handlers have been defined
]]--
for k, v in pairs(NeedMonitor) do
   if string.upper(k) == k then
      ChatFrame1:AddMessage("Registered for event "..k)
      NeedMonitor:RegisterEvent(k);
   end
end

-- end of script

ChatFrame1:AddMessage(PROGRAM_NAME .. " has been invoked from WowLua") 

if NeedMonitor_DB == nil then
   ChatFrame1:AddMessage("WARNING: NeedMonitor_DB is nil! -- Load this AddOn and restart!")
end

if NeedMonitor_Game_DB == nil then
   ChatFrame1:AddMessage("WARNING: NeedMonitor_Game_DB is nil! -- Run it on the next WowLua tab!")
end

