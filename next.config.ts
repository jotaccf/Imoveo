import type { NextConfig } from "next";
import pkg from "./package.json";

const nextConfig: NextConfig = {
  output: "standalone",
  env: {
    NEXT_PUBLIC_APP_VERSION: pkg.version,
  },
  outputFileTracingIncludes: {
    "/api/contratos/pdf": ["./node_modules/@react-pdf/**/*"],
    "/api/analise/pdf": ["./node_modules/@react-pdf/**/*"],
    "/api/auth/*": ["./node_modules/bcryptjs/**/*"],
  },
};

export default nextConfig;
