export type PolicyDocument = {
  Version: string
  Statement: {
    Action: string
    Effect: string
    Resource: string
  }[]
}

export type AuthResponse = {
  principalId: string
  policyDocument: PolicyDocument
  context?: {
    [key: string]: string | number | boolean
  }
}
