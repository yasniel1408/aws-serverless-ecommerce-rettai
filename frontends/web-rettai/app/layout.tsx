import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Rettai E-Commerce',
  description: 'Welcome to Rettai E-Commerce Platform',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  )
}
