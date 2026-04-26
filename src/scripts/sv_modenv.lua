local ModEnv = {
  value = nil,
}

function ModEnv.Set(env)
  ModEnv.value = env
end

function ModEnv.Get()
  return ModEnv.value
end

return ModEnv
