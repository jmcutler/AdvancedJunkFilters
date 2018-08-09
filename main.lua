addon('JunkFilters', function() 

  local filters = {}

  local function loadFilter (name, priority, test)
    sortinsert(filters, { 
      name     = name, 
      priority = priority,
      test     = loadstring('return '..test)
    }, function(a, b) return a.priority < b.priority end)
  end

  local function deleteFilter (name)
    data.filters[name] = nil
    for i, filter in pairs(filters) do
      if filter.name == name then
        table.remove(filters, i); return
      end
    end
  end

  local function saveFilter (name, priority, test)
    data.filters[name] = { priority = priority, test = test }
    loadFilter(name, priority, test)
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
      hasSet         = item.hasSet,
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
    setupMenu(saveFilter, deleteFilter)
  end)

  event.on('player loaded', function() 
    for name, filter in pairs(data.filters) do 
      loadFilter(name, filter.priority, filter.test)
    end
  end)

  event.on('inventory update', function(code, bag, slot) 
    local item = inventory(bag).item(slot)
    filterItem(item)
  end)

  event.on('store opened', function() 
    inventory().sellJunk()
  end)

  event.filter('inventory update', 'bag', 'backpack')
  event.filter('inventory update', 'reason', 'default')

  SLASH_COMMANDS['/filternow'] = function() 
    local bag = inventory('backpack')
    for slot = 1, bag.size() do 
      if bag.isFilled(slot) then filterItem(bag.item(slot)) end 
    end
  end

end)