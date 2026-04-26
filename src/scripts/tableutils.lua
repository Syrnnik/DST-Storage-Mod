local TableUtils = {}

function TableUtils.CountEntries(t)
  local count = 0
  for _ in pairs(t or {}) do
    count = count + 1
  end
  return count
end

return TableUtils
