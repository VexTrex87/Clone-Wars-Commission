local TweenService = game:GetService("TweenService")

return function(object, tweenInfo, properties)
    local newTween = TweenService:Create(object, tweenInfo or TweenInfo.new(), properties)
    newTween:Play()
    return newTween
end