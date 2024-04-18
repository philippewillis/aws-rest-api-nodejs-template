import HttpError from 'http-errors'
import { Router } from 'lambda-router'

const router = Router({
  cors: true,
  logger: console,
  includeErrorStack: process.env.stage !== 'prod',
})

router.get('/hello', () => {
  return {
    hello: 'API',
  }
})
router.unknown((_event: any, _context: any, _path: string) => {
  HttpError(404, 'Not found')
})

router.formatError((_statusCode: any, error: { message?: any; stack?: any }) => {
  console.error('[ERROR] ', error?.message, error?.stack)
  return error?.message
})

export default router
