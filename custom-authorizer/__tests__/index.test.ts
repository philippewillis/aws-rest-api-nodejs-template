import { APIGatewayTokenAuthorizerEvent, Context } from 'aws-lambda'
import jwt from 'jsonwebtoken'

import { handler } from '..'

jest.mock('jsonwebtoken')

describe('Custom Authorizer', () => {
  const mockContext: Context = {
    awsRequestId: 'mock-aws-request-id',
    callbackWaitsForEmptyEventLoop: true,
    functionName: 'mock-function-name',
    functionVersion: 'mock-function-version',
    invokedFunctionArn: 'mock-function-arn',
    logGroupName: 'mock-log-group-name',
    logStreamName: 'mock-log-stream-name',
    memoryLimitInMB: '128',
    getRemainingTimeInMillis: () => 5000,
    done: () => {},
    fail: () => {},
    succeed: () => {},
  }

  const methodArn = 'arn:aws:execute-api:region:account-id:api-id/stage/method/resource'

  beforeEach(() => {
    process.env.JWT_SECRET = 'blah-blah-blah'
    jest.clearAllMocks()
  })

  it('should return an Allow policy for a valid token', async () => {
    const mockToken = 'valid-token'
    const mockEvent: APIGatewayTokenAuthorizerEvent = {
      type: 'TOKEN',
      authorizationToken: mockToken,
      methodArn,
    }
    const mockDecoded = { sub: 'user' }

    ;(jwt.verify as jest.Mock).mockReturnValue(mockDecoded)

    const result = await handler(mockEvent, mockContext)

    expect(jwt.verify).toHaveBeenCalledWith(mockToken, process.env.JWT_SECRET)
    expect(result).toEqual({
      principalId: 'user',
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
        user: JSON.stringify(mockDecoded),
      },
    })
  })

  it('should return a Deny policy for an invalid token', async () => {
    const mockToken = 'invalid-token'
    const mockEvent: APIGatewayTokenAuthorizerEvent = {
      type: 'TOKEN',
      authorizationToken: mockToken,
      methodArn,
    }

    ;(jwt.verify as jest.Mock).mockImplementation(() => {
      throw new Error('Invalid token')
    })

    const result = await handler(mockEvent, mockContext)

    expect(jwt.verify).toHaveBeenCalledWith(mockToken, process.env.JWT_SECRET)
    expect(result).toEqual({
      context: {},
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
