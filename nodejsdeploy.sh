#!/bin/bash

#########################################################
#                                                       #
#  Node.js Application Deployment Script                #
#                                                       #
#  A simple deployment script for Node.js applications  #
#  running with PM2 process manager.                    #
#                                                       #
#  Author: Kryton Labs                                  #
#  License: MIT                                         #
#                                                       #
#########################################################

# ============================================================
# CONFIGURATION SECTION - Customize these variables
# ============================================================

# Application name (used for PM2)
APP_NAME="my-nodejs-app"

# Application directory (absolute path or relative to home)
APP_DIR="~/my-nodejs-app"

# Branch to checkout (if using git deployment method)
GIT_BRANCH="main"

# Git repository URL (if using git deployment method)
GIT_REPO="https://github.com/username/repo.git"

# Build command (default: npm run build)
BUILD_CMD="npm run build"

# Install command (default: npm install)
INSTALL_CMD="npm install --legacy-peer-deps"

# Start command (default: npm start)
START_CMD="npm start"

# Deployment method: "local" or "git"
# - "local": Deploy from local changes, no git pull
# - "git": Pull latest changes from git repository
DEPLOY_METHOD="local"

# Custom pre-deploy commands (optional)
# Example: PRE_DEPLOY_CMDS=("npm run clean" "npm run lint")
PRE_DEPLOY_CMDS=()

# Custom post-deploy commands (optional)
# Example: POST_DEPLOY_CMDS=("npm run db:migrate" "echo 'Deployment complete!'")
POST_DEPLOY_CMDS=()

# ============================================================
# END OF CONFIGURATION SECTION
# ============================================================

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print script banner
print_banner() {
  echo -e "${BLUE}"
  echo -e "  _   _           _        _      ____             _               "
  echo -e " | \ | | ___   __| | ___  (_)___ |  _ \  ___ _ __ | | ___  _   _  "
  echo -e " |  \| |/ _ \ / _\` |/ _ \ | / __|| | | |/ _ \ '_ \| |/ _ \| | | | "
  echo -e " | |\  | (_) | (_| |  __/ | \__ \| |_| |  __/ |_) | | (_) | |_| | "
  echo -e " |_| \_|\___/ \__,_|\___| |_|___/|____/ \___| .__/|_|\___/ \__, | "
  echo -e "                                            |_|            |___/  "
  echo -e "${NC}"
}

# Print help message
print_help() {
  echo -e "${CYAN}USAGE:${NC}"
  echo -e "  ./nodejsdeploy.sh [options]"
  echo ""
  echo -e "${CYAN}OPTIONS:${NC}"
  echo -e "  -h, --help     Display this help message"
  echo -e "  -l, --local    Use local deployment method (default)"
  echo -e "  -g, --git      Use git deployment method"
  echo -e "  -n, --name     Set application name for PM2"
  echo -e "  -d, --dir      Set application directory"
  echo -e "  -b, --branch   Set git branch (for git method)"
  echo ""
  echo -e "${CYAN}EXAMPLES:${NC}"
  echo -e "  ./nodejsdeploy.sh"
  echo -e "  ./nodejsdeploy.sh --git --name my-awesome-app --dir ~/apps/my-awesome-app"
  echo -e "  ./nodejsdeploy.sh --local --name api-server --dir /var/www/api"
  echo ""
  echo -e "${CYAN}CONFIGURATION:${NC}"
  echo -e "  You can edit the script to set default configuration values."
  echo -e "  See the CONFIGURATION SECTION at the top of the script."
  echo ""
}

# Parse command line arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        print_help
        exit 0
        ;;
      -l|--local)
        DEPLOY_METHOD="local"
        shift
        ;;
      -g|--git)
        DEPLOY_METHOD="git"
        shift
        ;;
      -n|--name)
        APP_NAME="$2"
        shift 2
        ;;
      -d|--dir)
        APP_DIR="$2"
        shift 2
        ;;
      -b|--branch)
        GIT_BRANCH="$2"
        shift 2
        ;;
      *)
        echo -e "${RED}Error: Unknown option $1${NC}"
        print_help
        exit 1
        ;;
    esac
  done
}

# Function to execute command and check result
execute_command() {
  local cmd="$1"
  local desc="$2"
  
  echo -e "${YELLOW}=====================================${NC}"
  echo -e "${YELLOW}STEP: $desc${NC}"
  echo -e "${BLUE}Command: $cmd${NC}"
  echo -e "${YELLOW}=====================================${NC}"
  
  eval "$cmd"
  local status=$?
  
  if [ $status -eq 0 ]; then
    echo -e "${GREEN}✓ SUCCESS: $desc${NC}"
    echo ""
    return 0
  else
    echo -e "${RED}✗ FAILED: $desc (Error code: $status)${NC}"
    echo -e "${RED}Script execution stopped.${NC}"
    exit $status
  fi
}

# Expand ~ to home directory
expand_path() {
  echo "${APP_DIR/#\~/$HOME}"
}

# Check if PM2 is installed
check_pm2() {
  if ! command -v pm2 &> /dev/null; then
    echo -e "${RED}Error: PM2 is not installed${NC}"
    echo -e "${YELLOW}Please install PM2 globally with: npm install -g pm2${NC}"
    exit 1
  fi
}

# Main deployment function
deploy_app() {
  print_banner
  
  # Start deployment
  echo -e "${GREEN}=====================================${NC}"
  echo -e "${GREEN}STARTING DEPLOYMENT: $(date)${NC}"
  echo -e "${GREEN}Application: ${APP_NAME}${NC}"
  echo -e "${GREEN}Directory: ${APP_DIR}${NC}"
  echo -e "${GREEN}Method: ${DEPLOY_METHOD}${NC}"
  echo -e "${GREEN}=====================================${NC}"
  
  # Check if PM2 is installed
  check_pm2
  
  # Navigate to project directory
  execute_command "cd $(expand_path)" "Navigate to project directory"
  
  # Git deployment method
  if [ "$DEPLOY_METHOD" = "git" ]; then
    if [ -d ".git" ]; then
      execute_command "git fetch" "Fetch latest changes"
      execute_command "git checkout ${GIT_BRANCH}" "Checkout branch: ${GIT_BRANCH}"
      execute_command "git pull origin ${GIT_BRANCH}" "Pull latest changes"
    else
      echo -e "${YELLOW}No git repository found in $(expand_path).${NC}"
      echo -e "${YELLOW}Would you like to clone the repository? (y/n)${NC}"
      read -r response
      if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        if [ -z "$GIT_REPO" ]; then
          echo -e "${RED}Error: GIT_REPO is not set. Please provide a git repository URL.${NC}"
          exit 1
        fi
        # Move to parent directory and clone
        execute_command "cd $(dirname $(expand_path))" "Navigate to parent directory"
        execute_command "git clone ${GIT_REPO} -b ${GIT_BRANCH} $(basename $(expand_path))" "Clone repository"
        execute_command "cd $(expand_path)" "Navigate to project directory"
      else
        echo -e "${YELLOW}Skipping git clone, continuing with local deployment...${NC}"
      fi
    fi
  fi
  
  # Stop the application
  execute_command "pm2 stop ${APP_NAME} || true" "Stop application (if running)"
  
  # Run pre-deploy commands
  if [ ${#PRE_DEPLOY_CMDS[@]} -gt 0 ]; then
    echo -e "${YELLOW}=====================================${NC}"
    echo -e "${YELLOW}STEP: Running pre-deploy commands${NC}"
    echo -e "${YELLOW}=====================================${NC}"
    
    for cmd in "${PRE_DEPLOY_CMDS[@]}"; do
      execute_command "$cmd" "Pre-deploy command: $cmd"
    done
  fi
  
  # Install dependencies
  execute_command "${INSTALL_CMD}" "Install dependencies"
  
  # Build the application
  execute_command "${BUILD_CMD}" "Build application"
  
  # Run post-deploy commands
  if [ ${#POST_DEPLOY_CMDS[@]} -gt 0 ]; then
    echo -e "${YELLOW}=====================================${NC}"
    echo -e "${YELLOW}STEP: Running post-deploy commands${NC}"
    echo -e "${YELLOW}=====================================${NC}"
    
    for cmd in "${POST_DEPLOY_CMDS[@]}"; do
      execute_command "$cmd" "Post-deploy command: $cmd"
    done
  fi
  
  # Start/restart the application with PM2
  echo -e "${YELLOW}=====================================${NC}"
  echo -e "${YELLOW}STEP: Starting application with PM2${NC}"
  echo -e "${YELLOW}=====================================${NC}"
  
  if pm2 describe ${APP_NAME} > /dev/null 2>&1; then
    # App exists, restart it
    execute_command "pm2 restart ${APP_NAME}" "Restart application"
  else
    # App doesn't exist, start it
    execute_command "pm2 start ${START_CMD} --name ${APP_NAME}" "Start application"
  fi
  
  # Check if application is running
  echo -e "${YELLOW}=====================================${NC}"
  echo -e "${YELLOW}STEP: Verify application status${NC}"
  echo -e "${YELLOW}=====================================${NC}"
  pm2 describe ${APP_NAME}
  echo ""
  
  # Show recent logs
  echo -e "${YELLOW}=====================================${NC}"
  echo -e "${YELLOW}STEP: Application logs (last 10 lines)${NC}"
  echo -e "${YELLOW}=====================================${NC}"
  pm2 logs ${APP_NAME} --lines 10 --nostream
  
  # Completion message
  echo -e "${GREEN}=====================================${NC}"
  echo -e "${GREEN}✓ DEPLOYMENT COMPLETED SUCCESSFULLY: $(date)${NC}"
  echo -e "${GREEN}=====================================${NC}"
  echo -e "${YELLOW}To view live logs run: pm2 logs ${APP_NAME}${NC}"
}

# Parse command line arguments
parse_args "$@"

# Run deployment
deploy_app 
