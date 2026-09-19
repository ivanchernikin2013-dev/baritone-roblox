local Feature = {}

function Feature.new(name, enabled)
    return {
        name = name or "feature",
        enabled = enabled ~= false,
        metadata = {},
    }
end

function Feature:SetEnabled(value)
    self.enabled = value
    return self.enabled
end

function Feature:IsEnabled()
    return self.enabled == true
end

function Feature:SetMetadata(key, value)
    self.metadata[key] = value
end

return Feature
