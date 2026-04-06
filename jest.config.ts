export default {
  testEnvironment: 'node',
  transform: { '^.+\\.tsx?$': ['ts-jest', { tsconfig: 'tsconfig.json' }] },
  testMatch: ['**/__tests__/**/*.test.ts', '**/__tests__/**/*.test.tsx'],
  moduleNameMapper: {
    '^@/lib/prisma$': '<rootDir>/__tests__/__mocks__/prisma.ts',
    '^@/generated/prisma/client$': '<rootDir>/__tests__/__mocks__/prisma-client.ts',
    '^@/(.*)$': '<rootDir>/src/$1',
  },
}
