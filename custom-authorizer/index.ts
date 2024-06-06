import jwt, { Secret } from 'jsonwebtoken'

import type { AuthResponse } from './types.d'

const JWT_SECRET = (process.env.JWT_SECRET as Secret) || ''

export const handler = async (event: any) => {
  const token = event.authorizationToken || ''
  const methodArn = event.methodArn

  try {
    // Verify the token
    const decoded = jwt.verify(token, JWT_SECRET) as jwt.JwtPayload

    // Create an response IAM policy
    const policy = generatePolicy(decoded.sub as string, 'Allow', methodArn)

    // Add additional context
    policy.context = {
      user: JSON.stringify(decoded),
    }

    return policy
  } catch (err) {
    // Create an IAM policy denying access if token is invalid
    return generatePolicy('user', 'Deny', methodArn)
  }
}

// Helper function to generate an IAM policy
const generatePolicy = (principalId: string, effect: string, resource: string): AuthResponse => {
  const authResponse: AuthResponse = {
    principalId: principalId,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: effect,
          Resource: resource,
        },
      ],
    },
  }

  return authResponse
}
