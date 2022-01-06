function hasValue(tbl, value)
  for k, v in ipairs(tbl) do 
      if v == value or (type(v) == "table" and hasValue(v, value)) then 
          return true
      end
  end
  return false
end

function table.removebyKey(tab, val)
  for k, v in pairs(tab) do 
      if (v.id == val) then
        tab[k] = nil
      end
  end
end
