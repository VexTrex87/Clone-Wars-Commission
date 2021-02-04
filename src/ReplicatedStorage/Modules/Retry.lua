local DEFAULT_ATTEMPTS = 3

return function(callback, attempts)
    local status = {}
    
    for _ = 1, attempts or DEFAULT_ATTEMPTS do
        local success, errorMessage = pcall(callback)

        table.insert(status, {
            Success = success,
            ErrorMessage = errorMessage
        })

        if success then
            return nil
        end
    end

    return status
end