import jwt from 'jsonwebtoken'

import { handler } from '../index'

jest.mock('jsonwebtoken')

describe('Custom Authorizer', () => {
  const methodArn = 'arn:aws:execute-api:us-east-1:123456789012:example/prod/GET/resource'

  it('should allow access for a valid token', async () => {
    const token = 'valid-token'
    const decodedToken = { sub: 'user|1234' }

    ;(jwt.verify as jest.Mock).mockReturnValue(decodedToken)

    const event = { authorizationToken: token, methodArn }
    const result = await handler(event)

    expect(result).toEqual({
      principalId: 'user|1234',
      policyDocument: {
        Version: '2012-10-17',
        Statement: [
          {
            Action: 'execute-api:Invoke',
            Effect: 'Allow',
            Resource: methodArn,
          },
        ],
      },
      context: {
        user: JSON.stringify(decodedToken),
      },
    })
  })

  it('should deny access for an invalid token', async () => {
    const token = 'invalid-token'

    ;(jwt.verify as jest.Mock).mockImplementation(() => {
      throw new Error('Invalid token')
    })

    const event = { authorizationToken: token, methodArn }
    const result = await handler(event)

    expect(result).toEqual({
      principalId: 'user',
      policyDocument: {
        Version: '2012-10-17',
        Statement: [
          {
            Action: 'execute-api:Invoke',
            Effect: 'Deny',
            Resource: methodArn,
          },
        ],
      },
    })
  })
})
