#!/bin/bash

# ============================================
# ZARPROJECT ADMIN THEME INSTALLER
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
THEME_DIR="/var/www/pterodactyl/resources/views"
THEME_ZIP_URL="https://github.com/ZarOffc11/admin-theme/archive/refs/heads/main.zip"
BACKUP_DIR="/tmp/zarproject_backup_$(date +%Y%m%d_%H%M%S)"
TEMP_DIR="/tmp/zarproject_install_$(date +%s)"

# ASCII Art
Show_banner() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
  ______          _____           _           _   
 |___  /         |  __ \         (_)         | |  
    / / __ _ _ __| |__) | __ ___  _  ___  ___| |_ 
   / / / _` | '__|  ___/ '__/ _ \| |/ _ \/ __| __|
  / /_| (_| | |  | |   | | | (_) | |  __/ (__| |_ 
 /_____\__,_|_|  |_|   |_|  \___/| |\___|\___|\__|
                                _/ |              
                               |__/               
EOF
    echo -e "                ADMIN THEME INSTALLER                "
    echo -e "${NC}"
    sleep 2
}


# Spinner animation
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⣾⣽⣻⢿⡿⣟⣯⣷'
    
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Print functions
print_step() {
    echo -e "\n${YELLOW}[•]${NC} ${CYAN}$1${NC}"
    sleep 0.8
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    sleep 0.5
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_zarlogo() {
    echo -e "${PURPLE}"
    echo '    ███████╗ █████╗ ██████╗     ██████╗ ██████╗  ██████╗      ██╗███████╗ ██████╗████████╗'
    echo '    ╚══███╔╝██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗     ██║██╔════╝██╔════╝╚══██╔══╝'
    echo '      ███╔╝ ███████║██████╔╝    ██████╔╝██████╔╝██║   ██║     ██║█████╗  ██║        ██║   '
    echo '     ███╔╝  ██╔══██║██╔══██╗    ██╔═══╝ ██╔══██╗██║   ██║██   ██║██╔══╝  ██║        ██║   '
    echo '    ███████╗██║  ██║██║  ██║    ██║     ██║  ██║╚██████╔╝╚█████╔╝███████╗╚██████╗   ██║   '
    echo '    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚════╝ ╚══════╝ ╚═════╝   ╚═╝   '
    echo -e "${NC}"
    sleep 1.5
}

# Check dependencies
check_dependencies() {
    print_step "Checking system requirements"
    
    echo -e "${YELLOW}[i]${NC} Looking for required tools..."
    sleep 1
    
    local missing=()
    
    # Check wget
    if command -v wget &> /dev/null; then
        echo -e "${GREEN}[+]${NC} wget is installed"
    else
        echo -e "${RED}[-]${NC} wget not found"
        missing+=("wget")
    fi
    
    # Check unzip
    if command -v unzip &> /dev/null; then
        echo -e "${GREEN}[+]${NC} unzip is installed"
    else
        echo -e "${RED}[-]${NC} unzip not found"
        missing+=("unzip")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing[*]}"
        echo -e "${YELLOW}[i]${NC} Installing missing packages..."
        
        if command -v apt &> /dev/null; then
            apt update > /dev/null 2>&1 &
            pid=$!
            spinner $pid
            apt install -y "${missing[@]}" > /dev/null 2>&1 &
            pid=$!
            spinner $pid
        fi
        
        print_success "Dependencies installed"
    else
        print_success "All dependencies found"
    fi
    sleep 1
}

# Create backup
create_backup() {
    print_step "Creating backup of current theme"
    
    if [ -d "$THEME_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        echo -e "${YELLOW}[i]${NC} Backing up files..."
        
        local dirs=("admin" "layouts" "partials" "templates")
        for dir in "${dirs[@]}"; do
            if [ -d "$THEME_DIR/$dir" ]; then
                cp -r "$THEME_DIR/$dir" "$BACKUP_DIR/" > /dev/null 2>&1 &
                pid=$!
                echo -ne "   ${CYAN}→${NC} $dir "
                spinner $pid
                echo -e "   ${GREEN}✓${NC}"
            fi
        done
        
        print_success "Backup created at: $BACKUP_DIR"
    else
        print_error "Theme directory not found"
        echo -e "${YELLOW}[i]${NC} Creating new directory..."
        mkdir -p "$THEME_DIR"
    fi
    sleep 1
}

# Download theme
download_theme() {
    print_step "Downloading ZarProject Theme"
    
    echo -e "${YELLOW}[i]${NC} Source: $THEME_ZIP_URL"
    sleep 1
    
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    echo -ne "${CYAN}[↓]${NC} Downloading "
    wget -q --show-progress -O zarproject-theme.zip "$THEME_ZIP_URL"
    
    if [ -f "zarproject-theme.zip" ]; then
        print_success "Download completed"
    else
        print_error "Download failed!"
        exit 1
    fi
    sleep 1
}

# Extract theme
extract_theme() {
    print_step "Extracting theme files"
    
    echo -e "${YELLOW}[i]${NC} Extracting archive..."
    unzip -q zarproject-theme.zip &
    pid=$!
    echo -ne "   ${CYAN}↻${NC} Extracting "
    spinner $pid
    
    rm zarproject-theme.zip
    print_success "Extraction complete"
    sleep 1
}

# Install theme
install_theme() {
    print_step "Installing ZarProject Theme"
    
    echo -e "${YELLOW}[i]${NC} Destination: $THEME_DIR"
    sleep 1
    
    # Create theme directory if not exists
    mkdir -p "$THEME_DIR"
    
    # Install each directory
    local dirs=("admin" "layouts" "partials" "templates")
    for dir in "${dirs[@]}"; do
        if [ -d "$TEMP_DIR/$dir" ]; then
            echo -ne "   ${CYAN}→${NC} Installing $dir "
            
            # Remove old directory
            if [ -d "$THEME_DIR/$dir" ]; then
                rm -rf "$THEME_DIR/$dir"
            fi
            
            # Copy new directory
            cp -r "$TEMP_DIR/$dir" "$THEME_DIR/" > /dev/null 2>&1 &
            pid=$!
            spinner $pid
            echo -e "   ${GREEN}✓${NC}"
        else
            echo -e "   ${RED}⚠${NC} $dir not found in package"
        fi
    done
    
    print_success "Installation complete"
    sleep 1
}

# Set permissions
set_permissions() {
    print_step "Setting file permissions"
    
    echo -e "${YELLOW}[i]${NC} Setting ownership to www-data..."
    chown -R www-data:www-data "$THEME_DIR" > /dev/null 2>&1 &
    pid=$!
    echo -ne "   ${CYAN}↻${NC} Changing ownership "
    spinner $pid
    
    echo -e "${YELLOW}[i]${NC} Setting directory permissions..."
    find "$THEME_DIR" -type d -exec chmod 755 {} \; > /dev/null 2>&1 &
    pid=$!
    echo -ne "   ${CYAN}↻${NC} Directories to 755 "
    spinner $pid
    
    echo -e "${YELLOW}[i]${NC} Setting file permissions..."
    find "$THEME_DIR" -type f -exec chmod 644 {} \; > /dev/null 2>&1 &
    pid=$!
    echo -ne "   ${CYAN}↻${NC} Files to 644 "
    spinner $pid
    
    print_success "Permissions configured"
    sleep 1
}

# Clear cache
clear_cache() {
    print_step "Clearing Pterodactyl cache"
    
    if [ -d "/var/www/pterodactyl" ]; then
        cd "/var/www/pterodactyl"
        
        echo -ne "   ${CYAN}↻${NC} Clearing application cache "
        php artisan cache:clear > /dev/null 2>&1 &
        pid=$!
        spinner $pid
        echo -e "   ${GREEN}✓${NC}"
        
        echo -ne "   ${CYAN}↻${NC} Clearing view cache "
        php artisan view:clear > /dev/null 2>&1 &
        pid=$!
        spinner $pid
        echo -e "   ${GREEN}✓${NC}"
        
        print_success "Cache cleared"
    else
        print_error "Pterodactyl directory not found"
    fi
    sleep 1
}

# Verify installation
verify_installation() {
    print_step "Verifying installation"
    
    sleep 1
    echo -e "${YELLOW}[i]${NC} Checking installed directories..."
    
    local dirs=("admin" "layouts" "partials" "templates")
    local all_ok=true
    
    for dir in "${dirs[@]}"; do
        if [ -d "$THEME_DIR/$dir" ]; then
            file_count=$(find "$THEME_DIR/$dir" -type f | wc -l)
            echo -e "   ${GREEN}✓${NC} $dir ($file_count files)"
        else
            echo -e "   ${RED}✗${NC} $dir (MISSING)"
            all_ok=false
        fi
    done
    
    echo ""
    sleep 1
    
    if [ "$all_ok" = true ]; then
        print_zarlogo
        
        echo -e "${GREEN}"
        echo '╔══════════════════════════════════════════════════════════╗'
        echo '║                   INSTALLATION SUCCESSFUL!               ║'
        echo '╚══════════════════════════════════════════════════════════╝'
        echo -e "${NC}"
        
        echo -e "${CYAN}┌──────────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│  📁 Theme Location: $THEME_DIR  │${NC}"
        echo -e "${CYAN}│  💾 Backup Location: $BACKUP_DIR │${NC}"
        echo -e "${CYAN}└──────────────────────────────────────────────────────┘${NC}"
        
        echo -e "\n${YELLOW}⚠ IMPORTANT:${NC}"
        echo -e "   1. Refresh your browser (Ctrl+F5)"
        echo -e "   2. Restart queue worker: ${CYAN}systemctl restart pteroq${NC}"
        echo -e "   3. If theme doesn't show, run: ${CYAN}php artisan optimize:clear${NC}"
        
    else
        print_error "Installation incomplete!"
        echo -e "${YELLOW}[i]${NC} Restore backup from: $BACKUP_DIR"
    fi
}

# Cleanup
cleanup() {
    print_step "Cleaning up temporary files"
    
    rm -rf "$TEMP_DIR" > /dev/null 2>&1 &
    pid=$!
    echo -ne "   ${CYAN}↻${NC} Removing temp files "
    spinner $pid
    
    print_success "Cleanup complete"
    sleep 1
}

# Countdown animation
countdown() {
    echo -e "\n${PURPLE}Starting installation in:${NC}"
    for i in {3..1}; do
        echo -ne "${RED}$i...${NC} "
        sleep 1
    done
    echo -e "${GREEN}GO!${NC}\n"
    sleep 1
}

# Main function
main() {
    show_banner
    countdown
    
    check_dependencies
    create_backup
    download_theme
    extract_theme
    install_theme
    set_permissions
    clear_cache
    cleanup
    verify_installation
    
    echo -e "\n${BLUE}────────────────────────────────────────────────────────────${NC}"
    echo -e "${GREEN}Thank you for choosing ZarProject Admin Theme!${NC}"
    echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
}

# Run
main "$@"
