# WooCommerce MCP Server - Docker Management
# ==========================================
#
# This Makefile provides convenient commands to manage the WooCommerce MCP Server
# using Docker and Docker Compose.
#
# Requirements:
#   - Docker and Docker Compose installed
#   - Environment variables set (see .env.example)
#
# Quick Start:
#   make up     # Build and start the application
#   make down   # Stop and remove containers
#   make logs   # View application logs

.PHONY: help build up down restart logs shell clean status env-check

# Default target - show help
help: ## Show this help message
	@echo "WooCommerce MCP Server - Docker Management"
	@echo "=========================================="
	@echo ""
	@echo "Available commands:"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "Environment variables needed:"
	@echo "  WORDPRESS_SITE_URL - Your WordPress site URL"
	@echo "  WORDPRESS_USERNAME - WordPress admin username" 
	@echo "  WORDPRESS_PASSWORD - WordPress admin password"
	@echo "  WOOCOMMERCE_CONSUMER_KEY - WooCommerce API consumer key"
	@echo "  WOOCOMMERCE_CONSUMER_SECRET - WooCommerce API consumer secret"

build: ## Build the Docker image
	@echo "Building WooCommerce MCP Server Docker image..."
	@docker-compose build

up: build ## Build and start the application
	@echo "Starting WooCommerce MCP Server..."
	@docker-compose up -d
	@echo "✅ WooCommerce MCP Server is running!"
	@echo "Use 'make logs' to view logs or 'make status' to check status"

down: ## Stop and remove containers
	@echo "Stopping WooCommerce MCP Server..."
	@docker-compose down
	@echo "✅ WooCommerce MCP Server stopped"

restart: down up ## Restart the application

logs: ## View application logs
	@echo "Showing logs for WooCommerce MCP Server..."
	@docker-compose logs -f woocommerce-mcp

logs-tail: ## View last 50 lines of logs
	@docker-compose logs --tail=50 woocommerce-mcp

shell: ## Open a shell in the running container
	@echo "Opening shell in WooCommerce MCP Server container..."
	@docker-compose exec woocommerce-mcp sh

run-mcp: ## Run the MCP server interactively in the container
	@echo "Running WooCommerce MCP Server..."
	@docker-compose exec woocommerce-mcp npm start

run-mcp-direct: ## Run MCP server directly with docker run (one-time)
	@echo "Building and running WooCommerce MCP Server directly..."
	@docker build -t woocommerce-mcp .
	@docker run -it --rm \
		-e WORDPRESS_SITE_URL="$$WORDPRESS_SITE_URL" \
		-e WORDPRESS_USERNAME="$$WORDPRESS_USERNAME" \
		-e WORDPRESS_PASSWORD="$$WORDPRESS_PASSWORD" \
		-e WOOCOMMERCE_CONSUMER_KEY="$$WOOCOMMERCE_CONSUMER_KEY" \
		-e WOOCOMMERCE_CONSUMER_SECRET="$$WOOCOMMERCE_CONSUMER_SECRET" \
		woocommerce-mcp npm start

status: ## Show container status
	@echo "WooCommerce MCP Server Status:"
	@echo "=============================="
	@docker-compose ps
	@echo ""
	@echo "Docker images:"
	@docker images | grep -E "(woocommerce|mcp)" || echo "No WooCommerce MCP images found"

clean: down ## Stop containers and remove images
	@echo "Cleaning up WooCommerce MCP Server resources..."
	@docker-compose down --rmi all --volumes --remove-orphans
	@echo "✅ Cleanup complete"

env-check: ## Check if required environment variables are set
	@echo "Checking environment variables..."
	@if [ -z "$$WORDPRESS_SITE_URL" ]; then echo "❌ WORDPRESS_SITE_URL not set"; else echo "✅ WORDPRESS_SITE_URL set"; fi
	@if [ -z "$$WORDPRESS_USERNAME" ]; then echo "❌ WORDPRESS_USERNAME not set"; else echo "✅ WORDPRESS_USERNAME set"; fi
	@if [ -z "$$WORDPRESS_PASSWORD" ]; then echo "❌ WORDPRESS_PASSWORD not set"; else echo "✅ WORDPRESS_PASSWORD set"; fi
	@if [ -z "$$WOOCOMMERCE_CONSUMER_KEY" ]; then echo "❌ WOOCOMMERCE_CONSUMER_KEY not set"; else echo "✅ WOOCOMMERCE_CONSUMER_KEY set"; fi
	@if [ -z "$$WOOCOMMERCE_CONSUMER_SECRET" ]; then echo "❌ WOOCOMMERCE_CONSUMER_SECRET not set"; else echo "✅ WOOCOMMERCE_CONSUMER_SECRET set"; fi

dev: ## Start in development mode (with source code mounted)
	@echo "Starting WooCommerce MCP Server in development mode..."
	@docker-compose -f docker-compose.yml up -d
	@echo "✅ Development mode started - source code is mounted from ./src"

# Hidden target to create .env file example
.env-example:
	@echo "Creating .env.example file..."
	@echo "# WordPress Site Configuration" > .env.example
	@echo "WORDPRESS_SITE_URL=https://your-wordpress-site.com" >> .env.example
	@echo "WORDPRESS_USERNAME=your-wp-admin-username" >> .env.example
	@echo "WORDPRESS_PASSWORD=your-wp-admin-password" >> .env.example
	@echo "" >> .env.example
	@echo "# WooCommerce API Configuration" >> .env.example
	@echo "WOOCOMMERCE_CONSUMER_KEY=ck_your_consumer_key_here" >> .env.example
	@echo "WOOCOMMERCE_CONSUMER_SECRET=cs_your_consumer_secret_here" >> .env.example
	@echo "✅ .env.example created - copy to .env and update with your values"