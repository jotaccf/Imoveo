import pkg from '../../../../package.json'

export async function GET() {
  return Response.json({
    status: 'ok',
    version: pkg.version,
    timestamp: new Date().toISOString(),
  })
}
