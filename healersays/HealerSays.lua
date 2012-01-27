--[[
HealerSays.lua
Copyright 2011 Patrick Meade

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

-- ==========================================================================
-- Events:
--    Leaving Combat
--       [X] Check mana, announce if low
--       [X] Check mana, whisper to Tank if low
--    Spell Failure
--       [ ] Check time since last notification
--          [ ] Whisper spell failure reason
--    Entering Instance
--       [X] Check for Warlocks
--          [X] Whisper health to mana conversion OK
--       [X] Check for Tanks
--          [X] Whisper to report bad DPS
-- ==========================================================================

local PROGRAM_NAME = "HealerSays 4.2.2 (alpha)"

local MANA_BREAK_REQUEST_BELOW_PERCENT = 33.0  -- mana at 33% or less
local MINIMUM_ANNOUNCE_DELAY = 15000           -- at least 15 seconds since last announcement
local MINIMUM_COMBAT_LENGTH = 3000             -- at least 3 seconds of combat

--[[
]]--
local HealerSays = CreateFrame("Frame", "HealerSaysEventFrame", UIParent)
_G["HealerSaysWowLua"] = HealerSays

-- initialize variables, just to be sure
HealerSays.combatStartTime = (GetTime() * 1000)
HealerSays.combatEndTime = (GetTime() * 1000)
HealerSays.lastAnnounceTime = (GetTime() * 1000)

--[[
]]--
function HealerSays:announceManaBreak(playerManaPercentInteger)
   -- create the message
   local message = "HealerSays: Healer Mana at " .. playerManaPercentInteger .. "% - MANA BREAK REQUESTED"
   -- announce it to the party at large
   SendChatMessage(message, "PARTY")
   -- whisper the tank to create a ding
   -- check if our party table contains any tanks
   for k, v in pairs(self.partyTable) do
      -- if we've got a tank, send a whisper
      if v.role == "TANK" then
         self:sendWhisper(v.name, v.realm, message)
      end
   end
end

--[[
]]--
function HealerSays:getUnitInfo(unit)
   local memberInfo = {}
   local playerName = nil
   local playerRealm = nil
   if unit == "player" then
      playerName = UnitName(unit)
      playerRealm = GetRealmName()
   else
      playerName, playerRealm = UnitName(unit)
   end
   local playerClass = UnitClass(unit)
   local playerLevel = UnitLevel(unit)
   local playerRole = UnitGroupRolesAssigned(unit)
   if playerName and playerRealm and playerClass and playerLevel then
      memberInfo.name = playerName
      memberInfo.realm = playerRealm
      memberInfo.class = playerClass
      memberInfo.level = playerLevel
      memberInfo.key = memberInfo.name.."-"..memberInfo.realm
      memberInfo.role = playerRole
   end
   return memberInfo
end

--[[
]]--
function HealerSays:loadPartyTable()
   local partyTable = {}
   
   local partyList = { "player", "party1", "party2", "party3", "party4" }
   for unitKey,unitValue in pairs(partyList) do
      local memberInfo = self:getUnitInfo(unitValue)
      if memberInfo.key then
         partyTable[memberInfo.key] = memberInfo;
      end
   end
   
   self.partyTable = partyTable
end

--[[
]]--
function HealerSays:notifyWarlocks()
   -- create a warlockTable if we don't already have one
   local warlockTable = {}
   if self.warlockTable then
      warlockTable = self.warlockTable
   end
   
   -- check if our party table contains any warlocks
   for k, v in pairs(self.partyTable) do
      if v.class == "Warlock" then
         -- if we haven't notified this warlock yet
         if warlockTable[v.key] == nil then
            warlockTable[v.key] = true;
            self:sendWhisper(v.name, v.realm, "HealerSays: Please feel free to convert Health to Mana as you need.")
         end
      end
   end
   
   -- keep a reference to the warlock table handy
   self.warlockTable = warlockTable
end

--[[
]]--
function HealerSays:notifyTanks()
   -- create a tankTable if we don't already have one
   local tankTable = {}
   if self.tankTable then
      tankTable = self.tankTable
   end
   
   -- check if our party table contains any tanks
   for k, v in pairs(self.partyTable) do
      if v.role == "TANK" then
         -- if we haven't notified this tank yet
         if tankTable[v.key] == nil then
            tankTable[v.key] = true;
            self:sendWhisper(v.name, v.realm, "HealerSays: Please let me know if the DPS give you any trouble.")
         end
      end
   end
   
   -- keep a reference to the tank table handy
   self.tankTable = tankTable
end

--[[
]]--
function HealerSays:sendWhisper(name, realm, message)
   local whisperName = name
   -- if they are not on the same realm
   if realm ~= GetRealmName() then
      -- append the realm name for the whisper
      whisperName = whisperName .. "-" .. realm
   end
   -- whisper the message to them
   SendChatMessage(message, "WHISPER", GetDefaultLanguage("player"), whisperName)
end

--[[
]]--
function HealerSays:PLAYER_REGEN_DISABLED(...)
   -- update the combat flag
   self.inCombat = true;
   self.combatStartTime = (GetTime() * 1000)
end

--[[
    Fired after ending combat, as regen rates return to normal. Useful for
    determining when a player has left combat. This occurs when you are not
    on the hate list of any NPC, or a few seconds after the latest pvp attack
    that you were involved with.
]]--
function HealerSays:PLAYER_REGEN_ENABLED(...)
   -- update the combat flag
   self.combatEndTime = (GetTime() * 1000)
   self.inCombat = false;
   -- determine if we need to request a mana break
   local playerCurrentMana = UnitPower("player");
   local playerMaximumMana = UnitPowerMax("player");
   local playerManaPercent = ((playerCurrentMana / playerMaximumMana) * 100.0);
   local playerManaPercentInteger = math.floor(playerManaPercent);
   
   -- if the combat lasted long enough
   local combatLengthTime = (self.combatEndTime - self.combatStartTime)
   if combatLengthTime > MINIMUM_COMBAT_LENGTH then
      -- if we are low enough on mana
      if playerManaPercent < MANA_BREAK_REQUEST_BELOW_PERCENT then
         -- if enough time has passed since the last announcement
         local lastAnnounceDelay = ((GetTime() * 1000) - self.lastAnnounceTime)
         if lastAnnounceDelay > MINIMUM_ANNOUNCE_DELAY then
            self.lastAnnounceTime = (GetTime() * 1000)
            self:announceManaBreak(playerManaPercentInteger)
         end
      end
   end
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
function HealerSays:PARTY_MEMBERS_CHANGED(...)
   self:loadPartyTable()
   self:notifyWarlocks()
   self:notifyTanks()
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
function HealerSays:PLAYER_ENTERING_WORLD(...)
   local inInstance, instanceType = IsInInstance()
   -- if we've entered a 5-man instance
   if inInstance and (instanceType == "party") then
      self.inInstance = true
   end
   -- initialize variables, just to be sure
   self.combatEndTime = (GetTime() * 1000)
   self.combatStartTime = (GetTime() * 1000)
   self.lastAnnounceTime = (GetTime() * 1000)
end

--[[
   Action: Set up the event handler function
]]--
HealerSays:SetScript("OnEvent", function(self, event, ...)
      -- call the registered event handler
      HealerSays[event](self, ...); 
end);

--[[
Action: Register all events for which handlers have been defined
]]--
for k, v in pairs(HealerSays) do
   if string.upper(k) == k then
      ChatFrame1:AddMessage("HealerSays registered for event "..k)
      HealerSays:RegisterEvent(k);
   end
end

-- end of script

-- ChatFrame1:AddMessage(PROGRAM_NAME .. " has been invoked from WowLua")

