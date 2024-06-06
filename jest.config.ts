import type { Config } from '@jest/types'

const environment = process.env.NODE_ENV || 'development'
if (environment === 'test') {
  require('dotenv').config({ path: '.env.test' })
} else {
  require('dotenv').config()
}

const config: Config.InitialOptions = {
  preset: 'ts-jest',
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
  testEnvironment: 'node',
}

export default config
