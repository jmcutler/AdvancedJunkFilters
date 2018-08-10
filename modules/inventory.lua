addon('JunkFilters', function()

  local function bagitem (bag, slot)

    local item     = {}
    local itemLink = GetItemLink(bag, slot, 1)

    -- (string) serialized representation
    function item.link ()
      return itemLink
    end

    -- (string) display name of item
    function item.name ()
      return GetItemName(bag, slot)
    end

    -- (string) file path to icon image
    function item.icon ()
      local icon = GetItemInfo(bag, slot)
      return icon
    end

      -- (string) gear set name
    function item.set ()
      local hasSet, name = GetItemLinkSetInfo(itemLink)
      if hasSet then return name 
      else return GetString('SI_ITEMTYPE', 0) end
    end

    -- (string, int) general type name and id
    function item.type ()
      local num = GetItemType(bag, slot)
      return GetString('SI_ITEMTYPE', num), num
    end

    -- (string, int) specific type name and id
    function item.stype ()
      local _, num = GetItemType(bag, slot)
      return GetString('SI_SPECIALIZEDITEMTYPE', num), num
    end

    -- (string, int) filter type name and id
    function item.ftype ()
      local num = GetItemFilterTypeInfo(bag, slot)
      return GetString('SI_ITEMFILTERTYPE', num), num
    end

    -- (string, int) trait name and id
    function item.trait ()
      local num = GetItemTrait(bag, slot)
      if num == 0 then return GetString('SI_ITEMTYPE', 0), num end
      return GetString('SI_ITEMTRAITTYPE', num), num
    end

    -- (string, int) armor type name and id
    function item.armortype ()
      local num = GetItemArmorType(bag, slot)
      return GetString('SI_ARMORTYPE', num), num
    end

    -- (string, int) weapon type name and id
    function item.weapontype ()
      local num = GetItemWeaponType(bag, slot)
      return GetString('SI_WEAPONTYPE', num), num
    end

    -- (int, string) quality level 0-5 and name
    function item.qaulity ()
      local _, _, _, _, _, _, _, num = GetItemInfo(bag, slot)
      return num, GetString('SI_ITEMQUALITY', num)
    end

    -- (int) item id, not instance id
    function item.id ()
      return GetItemUniqueId(bag, slot)
    end

    -- (int) main stat like armor or damage
    function item.stat ()
      return GetItemStatValue(bag, slot)
    end

    -- (int) gear item level 0-50
    function item.level ()
      return GetItemRequiredLevel(bag, slot)
    end

    -- (int) gear champion point level 0-160
    function item.cp ()
      return GetItemRequiredChampionPoints(bag, slot)
    end

    -- (int) condition 0-100 where 0 is broken
    function item.condition ()
      return GetItemCondition(bag, slot)
    end

    -- (int) this stack size
    function item.stack ()
      local num = GetSlotStackSize(bag, slot)
      return num
    end

    -- (int) max stacking size of this item
    function item.maxStack ()
      local _, num = GetSlotStackSize(bag, slot)
      return num
    end

    -- (int) how many of this item are in the backpack
    function item.inBackpack ()
      local num = GetItemLinkStacks(itemLink)
      return num
    end

    -- (int) how many of this item are in the bank
    function item.inBank ()
      local _, num = GetItemLinkStacks(itemLink)
      return num
    end

    -- (int) how many of this item are in the craftbag
    function item.inCraftbag ()
      local _, _, num = GetItemLinkStacks(itemLink)
      return num
    end

    -- (boolean) does this item have a set?
    function item.hasSet ()
      local hasSet = GetItemLinkSetInfo(itemLink)
      return hasSet
    end

    -- (boolean) is this item researcahble by the currnet character?
    function item.isResearchable ()
      local info = GetItemTraitInformation(bag, slot)
      return info == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED
    end

    -- (boolean) is this item crafted?
    function item.isCrafted ()
      return IsItemLinkCrafted(itemLink)
    end

    -- (boolean) is this item consumable for the player?
    function item.isConsumable ()
      return IsItemConsumable(bag, slot)
    end

    -- (boolean) is this item in a quickslot?
    function item.isQuickslotted ()
      local index = GetItemCurrentActionBarSlot(bag, slot)
      return index ~= nil
    end

    -- (boolean) is this item bound to acount or character?
    function item.isBound ()
      return IsItemBound(bag, slot)
    end

    -- (boolean) is this item usable for the player?
    function item.isUsable ()
      return IsItemUsable(bag, slot)
    end

    -- (boolean) is this item marked as stolen?
    function item.isStolen ()
      return IsItemStolen(bag, slot)
    end

    -- (boolean) is this item equipable by the player?
    function item.isEquipable ()
      return IsEquipable(bag, slot)
    end

    -- (boolean) is this item marked as junk?
    function item.isJunk ()
      return IsItemJunk(bag, slot)
    end

    -- (boolean) is this item marked as locked by the player?
    function item.isLocked ()
      return IsItemPlayerLocked(bag, slot)
    end

    -- (nil) try to use the item
    function item.use ()
      return CallSecureProtected('UseItem', bag, slot) 
    end

    -- (nil) try to reapir the item
    function item.repair ()
      return RepairItem(bag, slot)
    end

    -- (nil) try to sell item at an npc merchant
    function item.sell ()
      return EquipItem(bag, slot)
    end

    -- (nil) try to launder item at a fence npc
    function item.launder ()
      return LaunderItem(bag, slot)
    end

    -- (nil) try to destory the item
    function item.destroy ()
      return DestroyItem(bag, slot)
    end

    -- (nil) try to equip the item
    function item.equip ()
      return EquipItem(bag, slot)
    end
      
    -- (nil) set item junk status
    function item.junk (isjunk)
      if CanItemBeMarkedAsJunk(bag, slot) 
      then SetItemIsJunk(bag, slot, isjunk) end
    end

    -- (nil) set item locked status 
    function item.locked (islocked)
      if CanItemBePlayerLocked(bag, slot) 
      then SetItemIsPlayerLocked(bag, slot, islocked) end
    end

    -- (nil) try to enchant item with a glyph
    function item.enchant (glyphSlot)
      if CanItemTakeEnchantment(bag, slot, glyphBag, glyphSlot) 
      then EnchantItem(bag, slot, bag, glyphSlot) end
    end

    -- (nil) try to charge item with a soul gem
    function item.charge (gemSlot)
      if IsItemChargeable(bag, slot) 
      then ChargeItemWithSoulGem(bag, slot, bag, gemSlot) end
    end

    return item
  end

  local function bag (name)

    local function getid (value)
      local map = { backpack = 1, bank = 2, craftbag = 3 }
      if type(value) == 'number' then return value end
      if map[value] then return map[value] end
      return 1
    end

    local bag = {}
    local id  = getid(name)

    -- (item) get an item in this bag
    function bag.item (slot)
      return bagitem(id, slot)
    end

    -- (int) total number of slots this bag has
    function bag.size ()
      return GetBagSize(id)
    end

    -- (int) number of slots without an item
    function bag.empty ()
      return GetNumBagFreeSlots(id)
    end

    -- (int) number of slots with an item
    function bag.filled ()
      return GetNumBagUsedSlots(id)
    end

    -- (int) slot number of the next empty slot
    function bag.next ()
      return FristEmptySlot(id)
    end

    -- (boolean) does this bag have items marked as junk in it?
    function bag.hasJunk ()
      return HasAnyJunk(id, true)
    end

    -- (boolean) does this bag have stolen items?
    function bag.hasStolen ()
      return AreAnyItemsStolen(id)
    end

    -- (boolean) is a slot in this bag filled or not?
    function bag.isFilled (slot)
      return HasItemInSlot(id, slot)
    end

    -- (nil) try to sell all junk at a vendor
    function bag.sellJunk ()
      if GetInteractionType() == INTERACTION_VENDOR then
        if HasAnyJunk(id, true) then SellAllJunk() end
      end
    end

    return bag
  end

  export('inventory', bag)
end)