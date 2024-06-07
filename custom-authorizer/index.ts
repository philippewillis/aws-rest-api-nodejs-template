import { APIGatewayTokenAuthorizerEvent, Context } from 'aws-lambda'
import jwt from 'jsonwebtoken'

import type { AuthResponse } from './types'

let COLD_START = true
const JWT_SECRET: string = process.env.JWT_SECRET || ''
const JWT_TOKEN_EXPIRATION: string = process.env.JWT_TOKEN_EXPIRATION || '1h'

export const handler = async (event: APIGatewayTokenAuthorizerEvent, context: Context): Promise<AuthResponse> => {
  const token: string = event.authorizationToken
  const methodArn: string = event.methodArn

  log({
    event: {
      ...event,
      authorizationToken: 'REDACTED',
    },
    context,
    COLD_START,
  })
  COLD_START = false

  try {
    if (!token || !JWT_SECRET) throw new Error('No token or JWT secret')

    // Sign the token with expiresIn option
    const signedToken = jwt.sign({}, JWT_SECRET, { expiresIn: JWT_TOKEN_EXPIRATION })

    // Verify the token
    const decoded: any = jwt.verify(token, JWT_SECRET)

    log({ decoded })

    // Create an IAM policy
    const policy: AuthResponse = generatePolicy(decoded.sub || 'user', 'Allow', methodArn)

    // Add additional context
    policy.context = {
      user: JSON.stringify(decoded),
      token: signedToken, // Include the signed token in the context
    }

    return policy
  } catch (error) {
    // If token is invalid, return a Deny policy
    return generatePolicy('user', 'Deny', methodArn)
  }
}

// Helper function to generate an IAM policy
const generatePolicy = (principalId: string, effect: string, resource: string): AuthResponse => {
  const authResponse: AuthResponse = {
    principalId,
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
    context: {},
  }

  return authResponse
}

function log(message: any): void {
  console.log('___LOGGING:authorizer___', message, '___LOGGING:end___')
}
