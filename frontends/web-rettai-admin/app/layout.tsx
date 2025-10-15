import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Rettai Admin - Panel de Administración',
  description: 'Panel de administración para Rettai E-Commerce',
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
