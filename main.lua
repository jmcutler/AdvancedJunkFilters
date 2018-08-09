addon('JunkFilters', function() 

  local filters = {}

  -- LOAD
  -- parse filter strings from saved vars into usable functions

  local function load ()

    local filters = {}
    local compare = function(a, b) return a.priority < b.priority end

    for name, filter in pairs(data.filters) do 
      local test     = loadstring('return '..filter.test)
      local priority = filter.priority
      sortinsert(filters, { priority = priority, test = test }, compare)
    end

    return filters
  end

  -- SAVE
  -- save a new filter/rule into the saved vars, reload filters

  local function save (name, priority, test)
    data.filters[name] = { priority = priority, test = test }
    filters = load()
  end

  -- DELETE
  -- clear a filter/rule from the saved vars, reload filters

  local function delete (name)
    data.filters[name] = nil
    filters = load()
  end

  -- FILTERITEM
  -- compare an item to the filters and mark as junk if one returns true

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

  -- EVENTS
  -- setup, filter on inventory change, and auto sell junk at stores

  event.on('loaded', function() 
    data.filters = data.filters or {}
    filters = load()
    menu(save, delete)
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