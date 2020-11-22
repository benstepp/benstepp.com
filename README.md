# benstepp.com

My personal website

## Development

#### Running dev server

```bash
docker-compose build
docker-compose up
```

## Deploying

#### Setup Terraform
```bash
terraform init
```

#### Build the website

```bash
docker-compose build
docker-compose run --rm web yarn build
```

#### Deploy

```bash
terraform apply
```
