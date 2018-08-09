addon('JunkFilters', function() 

  local function setupMenu (save, delete)

    local editFont = 'JunkFilters/ui/fonts/inconsolata.otf|16|soft-shadow-thin'
    local docsLink = 'https://github.com/eromelcm/AdvancedJunkFilters/wiki'
    local editing, name, test, priority = false, '', '', 1

    local function names ()
      local names = {}
      local compare = function(a, b)
        return data.filters[a].priority < data.filters[b].priority
      end
      for name in pairs(data.filters) do sortinsert(names, name, compare) end
      return names
    end

    local function updateUI ()
      JF_SliderPriority:UpdateValue()
      JF_EditboxFilter:UpdateValue()
      JF_EditboxName:UpdateValue()
      JF_EditboxName:UpdateDisabled()
      JF_ButtonDelete:UpdateDisabled()
    end

    local function update ()
      editing, name, test, priority = false, '', '', 1
      JF_DrwopdownFilters:UpdateChoices(names())
      updateUI()
    end

    local function select (selection)
      local filter = data.filters[selection]
      if filter then
        editing, name, test, priority = true, selection, filter.test, filter.priority
        updateUI()
      end
    end

    local LAM = LibStub("LibAddonMenu-2.0")

    LAM:RegisterAddonPanel('junkfilters', { 
      type = 'panel',
      name = 'Advanced Junk Filters',
    })

    LAM:RegisterOptionControls('junkfilters', {
      [1] = {
        type        = 'dropdown',
        name        = 'Edit Filter',
        reference   = 'JF_DrwopdownFilters',
        choices     = names(),
        getFunc     = function() return nil end,
        setFunc     = function(filter) select(filter) end,
      },
      [2] = {
        type        = 'divider',
        width       = 'full',
        alpha       = 0.4,
      },
      [3] = {
        type        = 'slider',
        name        = 'Filter Priority',
        reference   = 'JF_SliderPriority',
        min         = 1,
        max         = 100,
        getFunc     = function() return priority end,
        setFunc     = function(num) priority = num end,
      },
      [4] = {
        type        = 'editbox',
        name        = 'Filter Name',
        reference   = 'JF_EditboxName',
        isExtraWide = true,
        disabled    = function() return editing end,
        getFunc     = function() return name end,
        setFunc     = function(str) name = str end,
      },
      [5] = {
        type        = 'editbox',
        name        = 'Filter',
        reference   = 'JF_EditboxFilter',
        isExtraWide = true,
        isMultiline = true,
        getFunc     = function() JF_EditboxFilter.editbox:SetFont(editFont); return test end,
        setFunc     = function(str) test = str end, 
      },
      [6] = {
        type        = 'button',
        name        = 'Delete Filter',
        reference   = 'JF_ButtonDelete',
        width       = 'half',
        disabled    = function() return not editing end,
        func        = function() delete(name); update() end,
      },
      [7] = {
        type        = 'button',
        name        = 'Save Filter',
        width       = 'half',
        func        = function() save(name, priority, test); update() end,
      },
      [8] = {
        type        = 'divider',
        width       = 'full',
        alpha       = 0.4,
      },
      [9] = {
        type        = 'description',
        text        = 'You can use "|cACC0E0/filternow|r" to run your filters on your entire inventory if needed. How to write a filter is documented online.',
        width       = 'full',
      },
      [10] = {
        type        = 'button',
        name        = 'View Documentation',
        func        = function() RequestOpenUnsafeURL(docsLink) end,
      }
    })

  end

  export('setupMenu', setupMenu)
end)