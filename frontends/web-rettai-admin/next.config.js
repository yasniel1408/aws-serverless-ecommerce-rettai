/** @type {import('next').NextConfig} */
const nextConfig = {
  // Removed 'output: export' for SSR support
  // output: 'export', // This is for SSG only
  
  // Enable image optimization with Amplify
  images: {
    unoptimized: false, // Amplify supports optimized images with SSR
  },
  
  basePath: '/admin',
  trailingSlash: true,
}

module.exports = nextConfig
