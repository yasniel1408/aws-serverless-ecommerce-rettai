export default function AdminHome() {
  return (
    <main className="flex min-h-screen flex-col">
      {/* Header */}
      <header className="bg-slate-800 text-white p-4 shadow-lg">
        <div className="container mx-auto flex justify-between items-center">
          <h1 className="text-2xl font-bold">🔐 Rettai Admin</h1>
          <nav className="flex gap-4">
            <a href="/admin" className="hover:text-blue-300">Dashboard</a>
            <a href="/" className="hover:text-blue-300">Ver Sitio</a>
          </nav>
        </div>
      </header>

      {/* Main Content */}
      <div className="flex-1 container mx-auto p-8">
        <div className="mb-8">
          <h2 className="text-4xl font-bold mb-2 text-slate-800 dark:text-slate-100">
            Panel de Administración
          </h2>
          <p className="text-slate-600 dark:text-slate-400">
            Gestiona tu tienda en línea desde aquí
          </p>
        </div>

        {/* Dashboard Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white dark:bg-slate-800 p-6 rounded-lg shadow-md border border-slate-200 dark:border-slate-700">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-slate-700 dark:text-slate-200">
                Productos
              </h3>
              <span className="text-3xl">📦</span>
            </div>
            <p className="text-3xl font-bold text-blue-600">0</p>
            <p className="text-sm text-slate-500 mt-2">Total de productos</p>
          </div>

          <div className="bg-white dark:bg-slate-800 p-6 rounded-lg shadow-md border border-slate-200 dark:border-slate-700">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-slate-700 dark:text-slate-200">
                Órdenes
              </h3>
              <span className="text-3xl">🛒</span>
            </div>
            <p className="text-3xl font-bold text-green-600">0</p>
            <p className="text-sm text-slate-500 mt-2">Órdenes totales</p>
          </div>

          <div className="bg-white dark:bg-slate-800 p-6 rounded-lg shadow-md border border-slate-200 dark:border-slate-700">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-slate-700 dark:text-slate-200">
                Clientes
              </h3>
              <span className="text-3xl">👥</span>
            </div>
            <p className="text-3xl font-bold text-purple-600">0</p>
            <p className="text-sm text-slate-500 mt-2">Clientes registrados</p>
          </div>

          <div className="bg-white dark:bg-slate-800 p-6 rounded-lg shadow-md border border-slate-200 dark:border-slate-700">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-slate-700 dark:text-slate-200">
                Ingresos
              </h3>
              <span className="text-3xl">💰</span>
            </div>
            <p className="text-3xl font-bold text-yellow-600">$0</p>
            <p className="text-sm text-slate-500 mt-2">Este mes</p>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="bg-white dark:bg-slate-800 p-6 rounded-lg shadow-md border border-slate-200 dark:border-slate-700">
          <h3 className="text-xl font-semibold mb-4 text-slate-800 dark:text-slate-100">
            Acciones Rápidas
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <button className="p-4 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-left">
              <div className="text-2xl mb-2">➕</div>
              <div className="font-semibold">Nuevo Producto</div>
              <div className="text-sm opacity-80">Añadir al catálogo</div>
            </button>

            <button className="p-4 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors text-left">
              <div className="text-2xl mb-2">📊</div>
              <div className="font-semibold">Ver Reportes</div>
              <div className="text-sm opacity-80">Análisis de ventas</div>
            </button>

            <button className="p-4 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors text-left">
              <div className="text-2xl mb-2">⚙️</div>
              <div className="font-semibold">Configuración</div>
              <div className="text-sm opacity-80">Ajustes de tienda</div>
            </button>
          </div>
        </div>

        {/* System Info */}
        <div className="mt-8 p-4 bg-blue-50 dark:bg-slate-900 rounded-lg border border-blue-200 dark:border-blue-900">
          <h4 className="font-semibold text-blue-900 dark:text-blue-100 mb-2">
            ℹ️ Información del Sistema
          </h4>
          <div className="text-sm text-blue-700 dark:text-blue-300 space-y-1">
            <p>• Frontend: Next.js 14 + Tailwind CSS</p>
            <p>• Hosting: AWS Amplify</p>
            <p>• CDN: CloudFront + WAF</p>
            <p>• Infrastructure: Terraform</p>
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="bg-slate-800 text-white p-4 mt-auto">
        <div className="container mx-auto text-center text-sm">
          <p>© 2024 Rettai E-Commerce. Powered by AWS Serverless Architecture</p>
        </div>
      </footer>
    </main>
  )
}
