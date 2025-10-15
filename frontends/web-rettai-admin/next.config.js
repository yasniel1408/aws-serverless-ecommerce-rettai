/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  images: {
    unoptimized: true,
  },
  basePath: '/admin',
  trailingSlash: true,
}

module.exports = nextConfig
