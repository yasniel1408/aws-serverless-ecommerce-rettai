export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="z-10 max-w-5xl w-full items-center justify-center font-mono text-sm lg:flex flex-col">
        <div className="mb-8 text-center">
          <h1 className="text-6xl font-bold mb-4 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
            🚀 Rettai E-Commerce
          </h1>
          <p className="text-xl text-gray-600 dark:text-gray-300">
            Bienvenido a tu plataforma de comercio electrónico
          </p>
        </div>

        <div className="mb-32 grid text-center lg:max-w-5xl lg:w-full lg:mb-0 lg:grid-cols-3 lg:text-left gap-4">
          <div className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 dark:hover:border-neutral-700 dark:hover:bg-neutral-800/30">
            <h2 className="mb-3 text-2xl font-semibold">
              🛍️ Productos
            </h2>
            <p className="m-0 text-sm opacity-50">
              Catálogo completo de productos disponibles
            </p>
          </div>

          <div className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 dark:hover:border-neutral-700 dark:hover:bg-neutral-800/30">
            <h2 className="mb-3 text-2xl font-semibold">
              🔒 Seguro
            </h2>
            <p className="m-0 text-sm opacity-50">
              Protegido con AWS WAF y CloudFront
            </p>
          </div>

          <div className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 dark:hover:border-neutral-700 dark:hover:bg-neutral-800/30">
            <h2 className="mb-3 text-2xl font-semibold">
              ⚡ Rápido
            </h2>
            <p className="m-0 text-sm opacity-50">
              Serverless con Next.js y AWS Amplify
            </p>
          </div>
        </div>

        <div className="mt-16 flex gap-4">
          <a
            href="/admin"
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Ir al Admin
          </a>
          <a
            href="https://github.com/yourusername/rettai"
            target="_blank"
            rel="noopener noreferrer"
            className="px-6 py-3 border border-gray-300 dark:border-gray-700 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            Ver en GitHub
          </a>
        </div>

        <div className="mt-16 text-center text-sm text-gray-500 dark:text-gray-400">
          <p>Powered by AWS CloudFront + Amplify + Next.js</p>
          <p className="mt-2">Infrastructure as Code con Terraform</p>
        </div>
      </div>
    </main>
  )
}
