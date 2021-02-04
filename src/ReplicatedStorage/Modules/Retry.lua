local DEFAULT_ATTEMPTS = 3

return function(callback, attempts)
    local didError = false
    local status = {}
    
    for x = 1, attempts or DEFAULT_ATTEMPTS do
        local success, errorMessage = pcall(callback)

        table.insert(status, {
            Success = success,
            ErrorMessage = errorMessage
        })

        if success then
            break
        else
            didError = true
        end
    end

    return didError and status or nil
end