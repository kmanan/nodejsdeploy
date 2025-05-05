# Node.js Deployment Script

A simple yet powerful deployment script for Node.js applications running with PM2 process manager.

![Script Banner](https://img.shields.io/badge/NodeJS-Deployment-green)
![PM2](https://img.shields.io/badge/PM2-Process%20Manager-blue)
![Bash](https://img.shields.io/badge/Bash-Script-orange)

## Features

- 🚀 **Simple Deployment**: Deploy your Node.js application with a single command
- 🔄 **Multiple Deployment Methods**: Support for both local and git-based deployments
- 🛠️ **Customizable**: Configure all aspects of the deployment process
- 🪝 **Hooks**: Add custom commands to run before or after deployment
- 🔍 **Logging**: Clear, colorful output showing each step of the process
- 🧪 **Error Handling**: Robust error detection and reporting
- 📊 **Status Monitoring**: Verify application status after deployment

## Prerequisites

- Bash shell environment (Linux, macOS, WSL on Windows)
- Node.js and npm installed
- PM2 process manager (`npm install -g pm2`)

## Installation

1. Download the script:

```bash
curl -o nodejsdeploy.sh https://raw.githubusercontent.com/yourusername/nodejsdeploy/main/nodejsdeploy.sh
```

2. Make it executable:

```bash
chmod +x nodejsdeploy.sh
```

3. (Optional) Place it somewhere in your PATH for easy access:

```bash
sudo mv nodejsdeploy.sh /usr/local/bin/nodejsdeploy
```

## Quick Start

1. Edit the configuration section at the top of the script to match your application.
2. Run the script:

```bash
./nodejsdeploy.sh
```

## Configuration

The script can be configured in two ways:

1. **Edit the configuration section** at the top of the script:

```bash
# Application name (used for PM2)
APP_NAME="my-nodejs-app"

# Application directory (absolute path or relative to home)
APP_DIR="~/my-nodejs-app"

# Build command (default: npm run build)
BUILD_CMD="npm run build"

# Install command (default: npm install)
INSTALL_CMD="npm install --legacy-peer-deps"

# Start command (default: npm start)
START_CMD="npm start"

# Deployment method: "local" or "git"
DEPLOY_METHOD="local"
```

2. **Use command line arguments** to override defaults:

```bash
./nodejsdeploy.sh --name my-app --dir ~/projects/my-app --git
```

## Usage Examples

### Basic Local Deployment

Deploy from local files (no git pull):

```bash
./nodejsdeploy.sh --name my-app --dir ~/my-app
```

### Git-Based Deployment

Pull latest changes from git before deploying:

```bash
./nodejsdeploy.sh --git --name my-api --dir ~/projects/my-api --branch main
```

### With Custom Application Directory

```bash
./nodejsdeploy.sh --name dashboard --dir /var/www/dashboard
```

## Command Line Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Display help message |
| `-l, --local` | Use local deployment method (default) |
| `-g, --git` | Use git deployment method |
| `-n, --name NAME` | Set application name for PM2 |
| `-d, --dir PATH` | Set application directory |
| `-b, --branch BRANCH` | Set git branch (for git method) |

## Advanced Configuration

### Custom Commands

You can define custom commands to run before or after the deployment process:

```bash
# Custom pre-deploy commands
PRE_DEPLOY_CMDS=("npm run clean" "npm run lint")

# Custom post-deploy commands
POST_DEPLOY_CMDS=("npm run db:migrate" "echo 'Deployment complete!'")
```

### Custom Start Command

If your application uses a custom start command (not `npm start`):

```bash
# For Next.js applications
START_CMD="npm start -- -p 3000"

# For custom Node scripts
START_CMD="node server.js"
```

## Common Use Cases

### Next.js Application

```bash
APP_NAME="nextjs-app"
APP_DIR="~/nextjs-app"
BUILD_CMD="npm run build"
START_CMD="npm start"
```

### Express API Server

```bash
APP_NAME="express-api"
APP_DIR="~/express-api"
BUILD_CMD="npm run build"
START_CMD="node dist/server.js"
```

### NestJS Application

```bash
APP_NAME="nest-app"
APP_DIR="~/nest-app"
BUILD_CMD="npm run build"
START_CMD="node dist/main.js"
```

## Best Practices

1. **Use Environment Variables**: Don't hardcode sensitive information in the script
2. **PM2 Ecosystem**: For complex applications, consider using a PM2 ecosystem file
3. **Backup**: Always backup your application before deployment
4. **Set Memory Limits**: Specify memory limits for your PM2 processes
5. **Logging**: Configure PM2 logs path for easier troubleshooting

## Troubleshooting

### Script fails with "PM2 is not installed"

Install PM2 globally:

```bash
npm install -g pm2
```

### Git pull fails with authentication error

Configure git credentials or use SSH keys for authentication.

### Application crashes after deployment

Check application logs with:

```bash
pm2 logs APP_NAME
```

## Contributing

Contributions are welcome! Feel free to submit a Pull Request.

## License

MIT

---

Created by [Kryton Labs](https://krytonlabs.com) - Making deployment simple for Node.js developers. 
