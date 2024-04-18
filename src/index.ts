import { APIGatewayEvent, APIGatewayProxyResult, Context } from "aws-lambda";

import router from "./router"

export async function handler(event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResult>{
  context.callbackWaitsForEmptyEventLoop = false

  const result = await router.route(event, context)
  return result.response
}