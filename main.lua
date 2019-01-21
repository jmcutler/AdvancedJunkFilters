Addon('JunkFilters', function() 

  local Bag        = Require('Bag')
  local Contains   = Require('Contains')
  local SortInsert = Require('SortInsert')
  local Settings   = Require('Settings')
  local Backpack   = Bag(BAG_BACKPACK)

  local Filters = {}

  local function LoadFilters ()
    Filters = {}
    for name, Filter in pairs(Data.Filters) do 
      SortInsert(Filters, { 
        Name     = name, 
        Priority = Filter.Priority,
        Test     = LoadString('return '..Filter.Test),
      }, function(A, B) return A.Priority < B.Priority end)
    end
  end

  local function SaveFilter (name, priority, test)
    Data.Filters[name] = { Priority = priority, Test = test }
    LoadFilters()
  end

  local function DeleteFilter (name)
    Data.Filters[name] = nil
    LoadFilters()
  end

  local function FilterItem (code, bag, slot)

    local Item = Backpack.Item(slot)
    if Item.IsLocked() or Item.Qaulity() > 4 then return end

    local function FilterType (...)
      local nums  = Item.FilterTypes()
      local names = Item.FilterNames()
      return Contains({...}, unpack(nums)) or Contains({...}, unpack(names))
    end

    local API = {
      stat           = Item.Stat,
      level          = Item.Level,
      cp             = Item.CP,
      condition      = Item.Condition,
      craftRank      = Item.CraftRank,
      stack          = Item.Stack,
      maxStack       = Item.MaxStack,
      inBackpack     = Item.InBackpack,
      inBank         = Item.InBank,
      inCraftbag     = Item.InCraftbag,
      isResearchable = Item.IsResearchable,
      isBound        = Item.IsBound,
      isCrafted      = Item.IsCrafted,
      isStolen       = Item.IsStolen,
      isQuickslotted = Item.IsQuickslotted,
      isKnown        = Item.IsKnown,
      qaulity        = Item.Qaulity,
      ftype          = FilterType,
      set            = function(...) return Contains({...}, Item.Set()) end,
      name           = function(...) return Contains({...}, Item.Name()) end,
      trait          = function(...) return Contains({...}, Item.Trait()) end,
      type           = function(...) return Contains({...}, Item.Type()) end,
      stype          = function(...) return Contains({...}, Item.SpecialType()) end,
      armortype      = function(...) return Contains({...}, Item.ArmorType()) end,
      weapontype     = function(...) return Contains({...}, Item.WeaponType()) end,
    } 

    for _, Filter in pairs(Filters) do 
      local Filter = setfenv(Filter.Test, API) 
      local ok, result = pcall(Filter)
      if ok then if result then Item.Junk(true) end
      else Print('Error Running Junk Filter') end
    end
  end

  Event.OnLoad(function() 
    Data.Filters = Data.Filters or {}
    LoadFilters()
    Settings(SaveFilter, DeleteFilter)
  end)

  Event.On(EVENT_OPEN_STORE, function() 
    if Backpack.SellJunk() then Print('Junk Items Sold') end
  end)

  Event.On(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, FilterItem)
  .Filter(REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
  .Filter(REGISTER_FILTER_INVENTORY_UPDATE_REASON, NVENTORY_UPDATE_REASON_DEFAULT)

  SLASH_COMMANDS['/filternow'] = function() 
    for slot = 0, Backpack.Size() do 
      if Backpack.IsFilled(slot) then FilterItem(nil, nil, slot) end 
    end
    Print('Inventory Filtered')
  end

end)