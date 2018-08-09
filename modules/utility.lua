addon('JunkFilters', function() 

  local function contains (list, value)
    for _, v in pairs(list) do 
      if value == v then return true end
    end return false
  end

  local function sortinsert (list, value, func)
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

  export('contains', contains)
  export('sortinsert', sortinsert)
end)