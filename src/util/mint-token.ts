import dotenv from 'dotenv'
import jwt from 'jsonwebtoken'

dotenv.config()

const JWT_SECRET = process.env.JWT_SECRET || null
const JWT_TOKEN_EXPIRATION = process.env.JWT_TOKEN_EXPIRATION || '1h'

// Function to mint JWT token
function mintToken(payload: any): string | undefined {
  if (!JWT_SECRET) {
    console.error('JWT_SECRET is not defined in the environment variables')
    return
  }

  try {
    // Sign the token with expiresIn option
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_TOKEN_EXPIRATION })

    return token
  } catch (error) {
    console.error('Error minting token:', error.message)
    return
  }
}

// Example usage
const token = mintToken({ userId: '123', role: 'admin' })
console.log(token)
