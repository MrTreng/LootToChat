LOOT_TO_CHAT_SETTINGS = {
  enabled = true,
  threshold = 4 -- print epics and above by default
}

local function LootToChat()
  local self = {}

  local cache = {}

  function self.OnLootOpened()
    local _,masterlooterPartyID = GetLootMethod()
    local numLink = 0

    -- Only print loot if we are the master looter and there is loot
    if (not LOOT_TO_CHAT_SETTINGS.enabled) or masterlooterPartyID ~= 0 or GetNumLootItems() == 0 then
      return
    end

    local sourceGUID = GetLootSourceInfo(1)

    -- Don't print already printed items or opened items (disenchanted items, opened bags etc)
    if cache[sourceGUID] or sourceGUID:match("^Item-") then
      return
    end
    cache[sourceGUID] = true

    for i=1, GetNumLootItems() do
      local itemLink =  GetLootSlotLink(i)
      local _,_,_,_,quality = GetLootSlotInfo(i)

      if itemLink and quality and quality >= LOOT_TO_CHAT_SETTINGS.threshold then
        numLink = numLink + 1
        if IsInRaid() then
          SendChatMessage(numLink..": "..itemLink, "RAID")
        else
          SendChatMessage(numLink..": "..itemLink, "PARTY")
        end
      end
    end
  end

  function self.RegisterEvents()
    local frame = CreateFrame('frame', 'LootToChatEventFrame')
    frame:RegisterEvent('LOOT_OPENED')
    frame:SetScript('OnEvent', function (s, event, ...)
      if event == 'LOOT_OPENED' then
        self.OnLootOpened()
      end
    end)
  end

  function self.RegisterSlash()
    SLASH_LOOT_TO_CHAT1 = "/ltc"
    SLASH_LOOT_TO_CHAT2 = "/loottochat"
    SlashCmdList["LOOT_TO_CHAT"] = function(msg)
      if msg == "on" then
        if not LOOT_TO_CHAT_SETTINGS.enabled then
          LOOT_TO_CHAT_SETTINGS.enabled = true
          print("LootToChat enabled")
        end
      elseif msg == "off" then
        if LOOT_TO_CHAT_SETTINGS.enabled then
          LOOT_TO_CHAT_SETTINGS.enabled = false
          print("LootToChat disabled")
        end
      elseif msg:match("^set %d+$") then
        LOOT_TO_CHAT_SETTINGS.threshold = tonumber(msg:gsub("^set (%d+)$", "%1"), 10)
        print("Set loot threshold to "..LOOT_TO_CHAT_SETTINGS.threshold)
      else
        print("Usage: /loottochat on | off | set [threshold]")
        print("  threshold: 3 for blues, 4 for purples, etc.")
        print("  Current threshold: "..LOOT_TO_CHAT_SETTINGS.threshold)
      end
    end
  end

  self.RegisterEvents()
  self.RegisterSlash()
end

LootToChat()