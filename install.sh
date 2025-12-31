#!/bin/bash

# ============================================
# INSTALLER THEME ADMIN PTERODACTYL
# Script untuk menginstal tema admin Pterodactyl
# ============================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_THEME_DIR="/var/www/pterodactyl/resources/views"
DEFAULT_ZIP_URL="https://github.com/user-attachments/files/24390941/ZarProject.AdminTheme.V1.zip" # Ganti dengan URL zip yang sebenarnya

# Function to print colored output
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_warning "Script tidak dijalankan sebagai root."
        read -p "Apakah Anda ingin melanjutkan? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to check dependencies
check_dependencies() {
    print_step "Memeriksa dependencies..."
    
    local missing_deps=()
    
    # Check wget
    if ! command -v wget &> /dev/null; then
        missing_deps+=("wget")
    fi
    
    # Check unzip
    if ! command -v unzip &> /dev/null; then
        missing_deps+=("unzip")
    fi
    
    # Check if any dependencies missing
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Dependencies berikut tidak ditemukan: ${missing_deps[*]}"
        
        # Try to install on Ubuntu/Debian
        if command -v apt &> /dev/null; then
            print_message "Mencoba menginstal dependencies menggunakan apt..."
            apt update
            apt install -y "${missing_deps[@]}"
        # Try to install on CentOS/RHEL
        elif command -v yum &> /dev/null; then
            print_message "Mencoba menginstal dependencies menggunakan yum..."
            yum install -y "${missing_deps[@]}"
        else
            print_error "Silakan instal dependencies secara manual: ${missing_deps[*]}"
            exit 1
        fi
    else
        print_message "Semua dependencies tersedia."
    fi
}

# Function to backup existing theme
backup_theme() {
    local theme_dir="$1"
    
    if [ -d "$theme_dir" ]; then
        print_step "Membuat backup tema yang ada..."
        
        local backup_dir="/tmp/pterodactyl_theme_backup_$(date +%Y%m%d_%H%M%S)"
        
        mkdir -p "$backup_dir"
        
        # Backup only specific directories
        for dir in admin layouts partials templates vendor; do
            if [ -d "$theme_dir/$dir" ]; then
                cp -r "$theme_dir/$dir" "$backup_dir/"
                print_message "✓ Backup $dir"
            fi
        done
        
        print_message "Backup disimpan di: $backup_dir"
    else
        print_warning "Direktori tema tidak ditemukan: $theme_dir"
        print_message "Membuat direktori baru..."
        mkdir -p "$theme_dir"
    fi
}

# Function to download and extract theme
install_theme() {
    local zip_url="$1"
    local theme_dir="$2"
    
    print_step "Mengunduh tema dari: $zip_url"
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download zip file
    if wget -O theme.zip "$zip_url" 2>/dev/null; then
        print_message "✓ File berhasil diunduh"
    else
        print_error "Gagal mengunduh file dari: $zip_url"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Extract zip file
    print_step "Mengekstrak file..."
    if unzip -o theme.zip 2>/dev/null; then
        print_message "✓ File berhasil diekstrak"
    else
        print_error "Gagal mengekstrak file zip"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Remove zip file
    rm theme.zip
    
    # Find and move extracted files
    print_step "Memindahkan file tema..."
    
    # Look for expected directories in the extracted content
    local extracted_dirs=()
    
    # Check root of extraction
    for dir in admin layouts partials templates vendor; do
        if [ -d "$temp_dir/$dir" ]; then
            extracted_dirs+=("$temp_dir/$dir")
        fi
    done
    
    # If not found in root, look in subdirectories
    if [ ${#extracted_dirs[@]} -eq 0 ]; then
        for subdir in "$temp_dir"/*/; do
            if [ -d "$subdir" ]; then
                for dir in admin layouts partials templates vendor; do
                    if [ -d "$subdir/$dir" ]; then
                        extracted_dirs+=("$subdir/$dir")
                    fi
                done
            fi
        done
    fi
    
    # Move directories to theme directory
    for source_path in "${extracted_dirs[@]}"; do
        local dir_name=$(basename "$source_path")
        
        # Remove old directory if exists
        if [ -d "$theme_dir/$dir_name" ]; then
            rm -rf "$theme_dir/$dir_name"
        fi
        
        # Move new directory
        mv "$source_path" "$theme_dir/"
        print_message "✓ $dir_name dipindahkan ke $theme_dir"
    done
    
    # Check if any directories were moved
    if [ ${#extracted_dirs[@]} -eq 0 ]; then
        print_error "Tidak ditemukan struktur tema yang diharapkan dalam file zip"
        print_warning "Struktur yang diharapkan: admin/, layouts/, partials/, templates/, vendor/"
        
        # List what was found
        print_message "Konten yang ditemukan:"
        find "$temp_dir" -maxdepth 2 -type d | sed 's|.*/||' | sort | uniq
    else
        print_message "✓ Semua direktori berhasil dipindahkan"
    fi
    
    # Cleanup
    cd /
    rm -rf "$temp_dir"
}

# Function to set permissions
set_permissions() {
    local theme_dir="$1"
    
    print_step "Mengatur permissions..."
    
    # Set ownership to web server user (common: www-data, nginx, apache)
    local web_user="www-data"
    
    if id "www-data" &>/dev/null; then
        chown -R www-data:www-data "$theme_dir"
        print_message "✓ Ownership diatur ke www-data"
    elif id "nginx" &>/dev/null; then
        chown -R nginx:nginx "$theme_dir"
        print_message "✓ Ownership diatur ke nginx"
    elif id "apache" &>/dev/null; then
        chown -R apache:apache "$theme_dir"
        print_message "✓ Ownership diatur ke apache"
    else
        print_warning "User web server tidak ditemukan, permissions tidak diubah"
    fi
    
    # Set directory permissions
    find "$theme_dir" -type d -exec chmod 755 {} \;
    find "$theme_dir" -type f -exec chmod 644 {} \;
    
    print_message "✓ Permissions diatur (755 untuk direktori, 644 untuk file)"
}

# Function to verify installation
verify_installation() {
    local theme_dir="$1"
    
    print_step "Memverifikasi instalasi..."
    
    local required_dirs=("admin" "layouts" "partials" "templates" "vendor")
    local missing_dirs=()
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$theme_dir/$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [ ${#missing_dirs[@]} -eq 0 ]; then
        print_message "✓ Semua direktori tema ditemukan"
        
        # Count files
        local total_files=0
        for dir in "${required_dirs[@]}"; do
            if [ -d "$theme_dir/$dir" ]; then
                local file_count=$(find "$theme_dir/$dir" -type f | wc -l)
                total_files=$((total_files + file_count))
                print_message "  - $dir: $file_count file"
            fi
        done
        
        print_message "✓ Total: $total_files file ditemukan"
        
        echo -e "\n${GREEN}============================================${NC}"
        print_message "INSTALASI BERHASIL!"
        print_message "Tema admin berhasil diinstal di:"
        print_message "  $theme_dir"
        echo -e "${GREEN}============================================${NC}"
        
    else
        print_error "Beberapa direktori tidak ditemukan: ${missing_dirs[*]}"
        print_warning "Instalasi mungkin tidak lengkap"
    fi
}

# Function to get user input
get_user_input() {
    print_step "Konfigurasi Instalasi"
    
    # Get zip URL
    read -p "Masukkan URL file .zip tema [default: $DEFAULT_ZIP_URL]: " zip_url
    zip_url=${zip_url:-$DEFAULT_ZIP_URL}
    
    # Get theme directory
    read -p "Masukkan direktori tema Pterodactyl [default: $DEFAULT_THEME_DIR]: " theme_dir
    theme_dir=${theme_dir:-$DEFAULT_THEME_DIR}
    
    # Ask for backup
    echo -e "\n${YELLOW}Peringatan:${NC} Script akan menimpa direktori berikut jika ada:"
    echo "  - $theme_dir/admin"
    echo "  - $theme_dir/layouts"
    echo "  - $theme_dir/partials"
    echo "  - $theme_dir/templates"
    echo "  - $theme_dir/vendor"
    
    read -p "Apakah Anda ingin membuat backup terlebih dahulu? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        DO_BACKUP=true
    else
        DO_BACKUP=false
        print_warning "Backup tidak akan dibuat. File lama akan ditimpa!"
    fi
    
    # Summary
    echo -e "\n${BLUE}=== RINGKASAN KONFIGURASI ===${NC}"
    echo "URL File ZIP: $zip_url"
    echo "Direktori Tema: $theme_dir"
    echo "Backup: $DO_BACKUP"
    
    read -p "Apakah konfigurasi sudah benar? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "Instalasi dibatalkan."
        exit 0
    fi
}

# Main function
main() {
    clear
    
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║  PTERODACTYL ADMIN THEME INSTALLER     ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Check if running as root (recommended)
    check_root
    
    # Check dependencies
    check_dependencies
    
    # Create theme directory if not exists
    mkdir -p "$theme_dir"
    
    # Backup if requested
    if [ "$DO_BACKUP" = true ]; then
        backup_theme "$theme_dir"
    fi
    
    # Install theme
    install_theme "$zip_url" "$theme_dir"
    
    # Set permissions
    set_permissions "$theme_dir"
    
    # Verify installation
    verify_installation "$theme_dir"
    
    # Clear view & Cache
    cd /var/www/pterodactyl
    php artisan cache:clear
    php artisan view:clear
    
    # Back to root folder
    cd ~
    
}

# Run main function
main "$@"