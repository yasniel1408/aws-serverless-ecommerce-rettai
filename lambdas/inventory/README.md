# Inventory Service

NestJS-based inventory management microservice for e-commerce platform. Manages products, warehouses, and warehouse addresses with PostgreSQL (Aurora Serverless).

## Features

- **Product Management**: CRUD operations for products with SKU tracking
- **Warehouse Management**: Manage multiple warehouses with addresses
- **Stock Control**: Real-time inventory tracking
- **Low Stock Alerts**: Monitor products below minimum stock levels
- **Capacity Reports**: Warehouse utilization analytics
- **Admin-Only Access**: Protected by authentication and authorization
- **TypeORM**: Database management with migrations
- **Swagger Documentation**: Auto-generated API docs

## Architecture

- **Framework**: NestJS 10
- **Database**: PostgreSQL (Aurora Serverless v2)
- **ORM**: TypeORM
- **Authentication**: JWT via Identity Lambda
- **Authorization**: Admin role required
- **Deployment**: AWS Lambda with Serverless Express

## Entities

### Product
- id, name, description, sku
- price, cost, quantity, minStock
- category, brand, unit
- warehouseId, isActive
- metadata (JSONB for extensibility)

### Warehouse
- id, name, code, description
- type, capacity, isActive
- managerName, phone, email
- address (one-to-one)
- products (one-to-many)

### WarehouseAddress
- id, street, city, state, zipCode, country
- latitude, longitude, notes
- warehouseId

## API Endpoints

All endpoints require **Admin authentication** via Bearer token.

### Products
- `POST /api/products` - Create product
- `GET /api/products` - List products (with filters)
- `GET /api/products/low-stock` - Get low stock products
- `GET /api/products/:id` - Get product by ID
- `GET /api/products/sku/:sku` - Get product by SKU
- `PATCH /api/products/:id` - Update product
- `PATCH /api/products/:id/stock` - Update stock quantity
- `DELETE /api/products/:id` - Delete product

### Warehouses
- `POST /api/warehouses` - Create warehouse
- `GET /api/warehouses` - List warehouses (with filters)
- `GET /api/warehouses/:id` - Get warehouse by ID
- `GET /api/warehouses/code/:code` - Get warehouse by code
- `GET /api/warehouses/:id/capacity` - Get capacity report
- `PATCH /api/warehouses/:id` - Update warehouse
- `DELETE /api/warehouses/:id` - Delete warehouse

## Environment Variables

```bash
# Database
DB_HOST=your-aurora-cluster.region.rds.amazonaws.com
DB_PORT=5432
DB_USERNAME=admin
DB_PASSWORD=your-password
DB_NAME=inventory_db

# Authentication
IDENTITY_API_URL=https://api.yourdomain.com/auth

# Application
NODE_ENV=production
PORT=3001
CORS_ORIGIN=*

# AWS (for Lambda)
AWS_REGION=us-east-1
```

## Installation

```bash
npm install
```

## Development

```bash
# Start in development mode
npm run start:dev

# Build
npm run build

# Run tests
npm run test
```

## Deployment

The service is deployed as an AWS Lambda function. Build and deploy:

```bash
# Build
npm run build

# Deploy via Terraform (from terraform directory)
cd ../../terraform
terraform apply
```

## Authentication

All endpoints require a valid JWT token from the Identity service with `admin` role.

Example request:
```bash
curl -X GET https://api.yourdomain.com/api/products \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

The AdminGuard validates:
1. Token is present
2. Token is valid (via Identity Lambda)
3. User has `admin` role

## Database Migrations

TypeORM synchronize is enabled in development. For production:

```bash
# Generate migration
npm run typeorm migration:generate -- -n MigrationName

# Run migrations
npm run typeorm migration:run
```

## Swagger Documentation

When running locally, access Swagger UI at:
```
http://localhost:3001/api/docs
```

## Error Handling

- `400` - Bad Request (validation errors)
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (not admin)
- `404` - Not Found
- `409` - Conflict (duplicate SKU/code)

## Security

- All endpoints protected by AdminGuard
- JWT token validation via Identity Lambda
- Role-based access control (Admin only)
- SQL injection prevention via TypeORM
- Input validation via class-validator
- CORS configuration

## Performance

- Connection pooling via TypeORM
- Lambda cold start optimization with serverless-express
- Database indexes on frequently queried fields
- Aurora Serverless auto-scaling

## Future Enhancements

- [ ] Inventory transactions log
- [ ] Stock movement tracking
- [ ] Multi-warehouse inventory sync
- [ ] Batch operations
- [ ] Export reports (CSV/PDF)
- [ ] Advanced analytics
- [ ] Barcode scanning support
- [ ] Integration with shipping services
