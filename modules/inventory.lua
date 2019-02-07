Addon('JunkFilters', function()

  local Map = Require('Map')

  local function Item (bag, slot)

    local Item = {}
    local link = GetItemLink(bag, slot, 1)

    -- (int, string) general type id
    function Item.Type ()
      local num = GetItemType(bag, slot)
      return num, GetString('SI_ITEMTYPE', num)
    end

    -- (int, string) specific type id
    function Item.SpecialType ()
      local _, num = GetItemType(bag, slot)
      if num == 0 then return num, GetString('SI_ITEMTYPE', num) end
      return num, GetString('SI_SPECIALIZEDITEMTYPE', num)
    end

    -- ({int}) filter type ids
    function Item.FilterTypes ()
      return { GetItemFilterTypeInfo(bag, slot) }
    end

    -- ({string}) filter type names
    function Item.FilterNames ()
      return Map(Item.FilterTypes(), function(num) 
        return GetString('SI_ITEMFILTERTYPE', num) 
      end)
    end

    -- (int, string) trait id
    function Item.Trait ()
      local num = GetItemTrait(bag, slot)
      if num == 0 then return num, GetString('SI_ITEMTYPE', num) end
      return num, GetString('SI_ITEMTRAITTYPE', num)
    end

    -- (int, string) armor type id
    function Item.ArmorType ()
      local num = GetItemArmorType(bag, slot)
      return num, GetString('SI_ARMORTYPE', num)
    end

    -- (int, string) weapon type id
    function Item.WeaponType ()
      local num = GetItemWeaponType(bag, slot)
      if num == 0 or num == 7 then return num, GetString('SI_ITEMTYPE', num) end
      return num, GetString('SI_WEAPONTYPE', num)
    end

    -- (int, string) quality level 0-5
    function Item.Qaulity ()
      local _, _, _, _, _, _, _, num = GetItemInfo(bag, slot)
      return num, GetString('SI_ITEMQUALITY', num)
    end

    -- (string) gear set name
    function Item.Set ()
      local hasSet, name = GetItemLinkSetInfo(link)
      if hasSet then return name 
      else return GetString('SI_ITEMTYPE', 0) end
    end

    -- (string) file path to icon image
    function Item.Icon ()
      local icon = GetItemInfo(bag, slot)
      return icon
    end

    -- (int) this stack size
    function Item.Stack ()
      local num = GetSlotStackSize(bag, slot)
      return num
    end

    -- (int) max stacking size of this Item
    function Item.MaxStack ()
      local _, num = GetSlotStackSize(bag, slot)
      return num
    end

    -- (int) how many of this Item are in the backpack
    function Item.InBackpack ()
      local num = GetItemLinkStacks(link)
      return num
    end

    -- (int) how many of this Item are in the bank
    function Item.InBank ()
      local _, num = GetItemLinkStacks(link)
      return num
    end

    -- (int) how many of this Item are in the craftbag
    function Item.InCraftbag ()
      local _, _, num = GetItemLinkStacks(link)
      return num
    end

    -- (boolean) does this Item have a set?
    function Item.HasSet ()
      local hasSet = GetItemLinkSetInfo(link)
      return hasSet
    end

    -- (boolean) is this Item in a quickslot?
    function Item.IsQuickslotted ()
      local index = GetItemCurrentActionBarSlot(bag, slot)
      return index ~= nil
    end

    -- (boolean) is this Item researcahble by the currnet character?
    function Item.IsResearchable ()
      local info = GetItemTraitInformation(bag, slot)
      return info == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED
    end

    -- (string) serialized representation
    function Item.Link () 
      return link 
    end

    -- (string) display name of item
    function Item.Name () 
      return GetItemName(bag, slot) 
    end

    -- (int) Item id, not instance id
    function Item.ID () 
      return GetItemId(bag, slot) 
    end

    -- (int) main stat like armor or damage
    function Item.Stat () 
      return GetItemStatValue(bag, slot) 
    end

    -- (int) gear Item level 0-50
    function Item.Level () 
      return GetItemRequiredLevel(bag, slot) 
    end

    -- (int) gear champion point level 0-160
    function Item.CP () 
      return GetItemRequiredChampionPoints(bag, slot) 
    end

    -- (int) craft skill level 1-10
    function Item.CraftRank () 
      return GetItemLinkRequiredCraftingSkillRank(link) 
    end

    -- (int) condition 0-100 where 0 is broken
    function Item.Condition () 
      return GetItemCondition(bag, slot) 
    end

    -- (boolean) is this Item crafted?
    function Item.IsCrafted () 
      return IsItemLinkCrafted(link) 
    end

    -- (boolean) is this Item consumable for the player?
    function Item.IsConsumable () 
      return IsItemConsumable(bag, slot) 
    end

    -- (boolean) is this Item bound to acount or character?
    function Item.IsBound () 
      return IsItemBound(bag, slot) 
    end

    -- (boolean) is this Item usable for the player?
    function Item.IsUsable () 
      return IsItemUsable(bag, slot) 
    end

    -- (boolean) is this Item marked as stolen?
    function Item.IsStolen () 
      return IsItemStolen(bag, slot) 
    end

    -- (boolean) is this Item equipable by the player?
    function Item.IsEquipable () 
      return IsEquipable(bag, slot) 
    end

    -- (boolean) is this Item marked as junk?
    function Item.IsJunk () 
      return IsItemJunk(bag, slot) 
    end

    -- (boolean) is this Item marked as locked by the player?
    function Item.IsLocked () 
      return IsItemPlayerLocked(bag, slot) 
    end

    -- (boolean) is this a recipe/book that is known by the character?
    function Item.IsKnown () 
      return IsItemLinkRecipeKnown(link) or IsItemLinkBookKnown(link) 
    end

    -- (nil) try to use the Item
    function Item.Use () 
      return CallSecureProtected('UseItem', bag, slot) 
    end

    -- (nil) try to reapir the Item
    function Item.Repair () 
      return RepairItem(bag, slot) 
    end

    -- (nil) try to sell Item at an npc merchant
    function Item.Sell () 
      return EquipItem(bag, slot) 
    end

    -- (nil) try to launder Item at a fence npc
    function Item.Launder () 
      return LaunderItem(bag, slot) 
    end

    -- (nil) try to destory the Item
    function Item.Destroy () 
      return DestroyItem(bag, slot) 
    end

    -- (nil) try to equip the Item
    function Item.Equip () 
      return EquipItem(bag, slot) 
    end
      
    -- (nil) set Item junk status
    function Item.Junk (isjunk)
      if CanItemBeMarkedAsJunk(bag, slot) 
      then SetItemIsJunk(bag, slot, isjunk) end
    end

    -- (nil) set Item locked status 
    function Item.Locked (islocked)
      if CanItemBePlayerLocked(bag, slot) 
      then SetItemIsPlayerLocked(bag, slot, islocked) end
    end

    -- (nil) try to enchant Item with a glyph
    function Item.Enchant (glyphSlot)
      if CanItemTakeEnchantment(bag, slot, glyphBag, glyphSlot) 
      then EnchantItem(bag, slot, bag, glyphSlot) end
    end

    -- (nil) try to charge Item with a soul gem
    function Item.Charge (gemSlot)
      if IsItemChargeable(bag, slot) 
      then ChargeItemWithSoulGem(bag, slot, bag, gemSlot) end
    end

    -- (nil) try to move an item to another bag/bank
    function Item.MoveTo (bag2, count, slot2)
      if not slot2 then slot2 = FristEmptySlot(bag) end
      if not count then count = GetSlotStackSize(bag, slot) end
      if IsBankOpen() and DoesBagHaveSpaceFor(bag2, bag, slot)
      then CallSecureProtected('RequestMoveItem', bag, slot, bag2, slot2, count) end
    end

    return Item
  end

  local function Bag (id)

    local Bag = {}

    -- (Item) get an Item in this Bag
    function Bag.Item (slot) 
      return Item(id, slot) 
    end

    -- (int) total number of slots this Bag has
    function Bag.Size () 
      return GetBagSize(id) 
    end

    -- (int) number of slots without an Item
    function Bag.Empty () 
      return GetNumBagFreeSlots(id) 
    end

    -- (int) number of slots with an Item
    function Bag.Filled () 
      return GetNumBagUsedSlots(id) 
    end

    -- (int) slot number of the next empty slot
    function Bag.Next () 
      return FristEmptySlot(id) 
    end

    -- (boolean) does this Bag have Items marked as junk in it?
    function Bag.HasJunk () 
      return HasAnyJunk(id, true) 
    end

    -- (boolean) does this Bag have stolen Items?
    function Bag.HasStolen () 
      return AreAnyItemsStolen(id) 
    end

    -- (boolean) is a slot in this Bag filled or not?
    function Bag.IsFilled (slot) 
      return HasItemInSlot(id, slot) 
    end

    -- (boolean) try to sell all junk at a vendor
    function Bag.SellJunk ()
      if GetInteractionType() == INTERACTION_VENDOR then
        if HasAnyJunk(id, true) then SellAllJunk(); return true end
      end return false
    end

    return Bag
  end

  Export('Bag', Bag)
  
end)