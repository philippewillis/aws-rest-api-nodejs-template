export type PolicyDocument = {
  Version: string
  Statement: Statement[]
}
export type Statement = {
  Action: string
  Effect: string
  Resource: string
}

export type AuthResponse = {
  principalId: string
  policyDocument: PolicyDocument
  context: {
    [key: string]: string
  }
}
