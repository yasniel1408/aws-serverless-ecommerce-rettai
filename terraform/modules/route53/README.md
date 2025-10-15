# Route53 Module

Módulo para crear una hosted zone en Route53.

## Uso

```hcl
module "route53" {
  source = "./modules/route53"

  domain_name  = "example.com"
  project_name = "myproject"
  environment  = "prod"
  
  tags = {
    CostCenter = "engineering"
  }
}
```

## Variables

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| domain_name | string | - | Nombre del dominio (requerido) |
| project_name | string | - | Nombre del proyecto (requerido) |
| environment | string | - | Ambiente: dev, staging, prod (requerido) |
| tags | map(string) | {} | Tags adicionales |

## Outputs

| Output | Descripción |
|--------|-------------|
| zone_id | ID de la hosted zone |
| name_servers | Lista de nameservers |
| zone_arn | ARN de la hosted zone |

## Recursos Creados

- `aws_route53_zone`: Hosted zone para el dominio

## Notas

- Configurar los nameservers en tu registrador de dominio después de crear la zona
- El dominio debe ser válido y estar registrado
