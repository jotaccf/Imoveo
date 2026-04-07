import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  outputFileTracingIncludes: {
    "/api/contratos/pdf": ["./node_modules/@react-pdf/**/*"],
    "/api/analise/pdf": ["./node_modules/@react-pdf/**/*"],
    "/api/auth/*": ["./node_modules/bcryptjs/**/*"],
  },
};

export default nextConfig;
