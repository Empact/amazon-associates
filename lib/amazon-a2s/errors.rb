module Amazon
  class RequestError < StandardError; end
  
  class InvalidParameterValue < ArgumentError; end
  class ParameterOutOfRange < InvalidParameterValue; end
  class RequiredParameterMissing < ArgumentError; end
  class ItemNotFound < StandardError; end
  
  # Map AWS error types to ruby exceptions
  ERROR = {
    'AWS.InvalidParameterValue' => InvalidParameterValue,
    'AWS.MissingParameters' => RequiredParameterMissing,
    'AWS.MinimumParameterRequirement' => RequiredParameterMissing,
    'AWS.ECommerceService.NoExactMatches' => ItemNotFound,
    'AWS.ParameterOutOfRange' => ParameterOutOfRange,
    'AWS.InvalidOperationParameter'=> InvalidParameterValue,
    'AWS.InvalidResponseGroup' => InvalidParameterValue,
    'AWS.RestrictedParameterValueCombination' => InvalidParameterValue
  }
  
  IGNORE_ERRORS = ['AWS.ECommerceService.NoSimilarities']  
end