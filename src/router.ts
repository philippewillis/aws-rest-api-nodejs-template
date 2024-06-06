import HttpError from 'http-errors'
import { Router } from 'lambda-router'

import hello from './hello'

const router = Router({
  cors: true,
  logger: console,
  includeErrorStack: process.env.stage !== 'prod',
})

// Routes
router.get('/hello', hello.get)

// Other routes
router.unknown((_event: any, _context: any, _path: string) => {
  HttpError(404, 'Not found')
})

router.formatError((_statusCode: any, error: { message?: any; stack?: any }) => {
  console.error('[ERROR] ', error?.message, error?.stack)
  return error?.message
})

export default router
