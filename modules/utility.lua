Addon('JunkFilters', function() 

  local function Contains (list, ...)
    for _, item in pairs(list) do
      for _, value in pairs{...} do 
        if value == item then return true end
      end
    end return false
  end

  local function Map (list, func)
    local new = {}
    for i, v in ipairs(list) do new[i] = func(v) end
    return new
  end

  local function SortInsert (list, value, func)
    local func = func or (function (a, b) return a < b end)
    local first, last, mid, state = 1, #list, 1, 0
    while first <= last do
      mid = math.floor((first + last) / 2)
      if func(value, list[mid]) then last, state = mid - 1, 0
      else first, state = mid + 1, 1 end
    end
    table.insert(list, (mid + state), value)
    return mid + state
  end

  Export('Contains', Contains)
  Export('SortInsert', SortInsert)
  Export('Map', Map)
  
end)