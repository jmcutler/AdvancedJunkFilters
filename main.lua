addon('JunkFilters', function() 

  local filters = {}

  local function loadFilters ()
    filters = {}
    for name, filter in pairs(data.filters) do 
      sortinsert(filters, { 
        name     = name, 
        priority = filter.priority,
        test     = loadstring('return '..filter.test)
      }, function(a, b) return a.priority < b.priority end)
    end
  end

  local function deleteFilter (name)
    data.filters[name] = nil
    loadFilters()
  end

  local function saveFilter (name, priority, test)
    data.filters[name] = { priority = priority, test = test }
    loadFilters()
  end

  local function filterItem (item)

    if item.isLocked() or item.qaulity() > 4 then return end

    local api = {
      set            = function(...) return contains({...}, item.set()) end,
      type           = function(...) return contains({...}, item.type()) end,
      stype          = function(...) return contains({...}, item.stype()) end,
      ftype          = function(...) return contains({...}, item.ftype()) end,
      name           = function(...) return contains({...}, item.name()) end,
      trait          = function(...) return contains({...}, item.trait()) end,
      armortype      = function(...) return contains({...}, item.armortype()) end,
      weapontype     = function(...) return contains({...}, item.weapontype()) end,
      qaulity        = item.qaulity,
      stat           = item.stat,
      level          = item.level,
      cp             = item.cp,
      condition      = item.condition,
      stack          = item.stack,
      maxStack       = item.maxStack,
      inBackpack     = item.inBackpack,
      inBank         = item.inBank,
      inCraftbag     = item.inCraftbag,
      isResearchable = item.isResearchable,
      isBound        = item.isBound,
      isCrafted      = item.isCrafted,
      isStolen       = item.isStolen,
      isQuickslotted = item.isQuickslotted,
    } 

    for _, filter in pairs(filters) do 
      local filter = setfenv(filter.test, api) 
      local ok, result = pcall(filter)
      if ok and result then item.junk(true) end
    end
  end

  event.on('loaded', function() 
    data.filters = data.filters or {}
    loadFilters()
    setupMenu(saveFilter, deleteFilter)
  end)

  event.on('inventory update', function(code, bag, slot) 
    local item = inventory(bag).item(slot)
    filterItem(item)
  end)

  event.on('store opened', function() 
    inventory().sellJunk()
    print('|t16:16:EsoUI/Art/currency/currency_gold.dds|t Junk Items Sold')
  end)

  event.filter('inventory update', 'bag', 'backpack')
  event.filter('inventory update', 'reason', 'default')

  SLASH_COMMANDS['/filternow'] = function() 
    local bag = inventory('backpack')
    for slot = 1, bag.size() do 
      if bag.isFilled(slot) then filterItem(bag.item(slot)) end 
    end
    print('Inventory Filtered')
  end

end)