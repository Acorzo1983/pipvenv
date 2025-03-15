#!/bin/bash
# Script to install pipvenv locally

VERSION="1.0.1"

# Function to display error messages
error() {
    echo -e "\e[91m[ERROR] $1\e[0m" >&2
    exit 1
}

# Function to display success messages
success() {
    echo -e "\e[92m[SUCCESS] $1\e[0m"
}

# Function to display warning messages
warning() {
    echo -e "\e[93m[WARNING] $1\e[0m"
}

# Detect if running with sudo
USING_SUDO=false
if [ -n "$SUDO_USER" ]; then
    USING_SUDO=true
    REAL_USER="$SUDO_USER"
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER="$(whoami)"
    REAL_HOME="$HOME"
fi

# Step 1: Update the system and ensure python3-venv is installed
echo "Updating system and installing dependencies..."
if ! command -v python3 &> /dev/null || ! python3 -m venv --help &> /dev/null; then
    echo "Installing python3-venv..."
    if $USING_SUDO; then
        if ! apt update > /dev/null 2>&1 || ! apt install -y python3-venv > /dev/null 2>&1; then
            error "Failed to install python3-venv."
        fi
    else
        warning "This script needs to install python3-venv but you're not running with sudo."
        warning "Please run: sudo apt update && sudo apt install -y python3-venv"
        warning "Then run this script again."
        exit 1
    fi
fi
success "Dependencies installed successfully."

# Step 2: Define installation directory
INSTALL_DIR="$REAL_HOME/.local/bin"

# Ensure the installation directory exists
mkdir -p "$INSTALL_DIR" || error "Failed to create installation directory $INSTALL_DIR."

# Step 3: Create the pipvenv script
echo "Creating the pipvenv script in $INSTALL_DIR..."
cat << 'EOF' > "$INSTALL_DIR/pipvenv"
#!/bin/bash

VERSION="1.0.1"

# Define help function
show_help() {
    echo "pipvenv - A simple virtual environment manager for Python"
    echo ""
    echo "Usage: pipvenv <command> [options]"
    echo ""
    echo "Commands:"
    echo "  install       Install packages (e.g., pipvenv install requests)"
    echo "  uninstall     Uninstall packages (e.g., pipvenv uninstall requests)"
    echo "  list          List installed packages"
    echo "  freeze        Output installed packages in requirements format"
    echo "  -h, --help    Show this help message and exit"
    echo "  -v, --version Show version information and exit"
    echo ""
    echo "Examples:"
    echo "  pipvenv install -r requirements.txt"
    echo "  pipvenv install pandas==1.3.0"
    echo "  pipvenv list"
    echo ""
    echo "Note: All commands are passed directly to pip within a virtual environment."
    echo ""
    echo "Made With Love By AlbertC @yz9yt"
}

# Define version function
show_version() {
    echo "pipvenv version $VERSION"
    echo "Made With Love By AlbertC @yz9yt"
}

# Check for help or version flags first
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

if [ "$1" == "-v" ] || [ "$1" == "--version" ]; then
    show_version
    exit 0
fi

# Check if arguments are provided
if [ -z "$1" ]; then
    show_help
    exit 1
fi

# Define the virtual environment directory
VENV_DIR=".venv"

# Create the virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Execute pip with the provided arguments
echo "Running pip $*..."
pip "$@"

# Deactivate the virtual environment after execution
deactivate
EOF

# Set correct ownership if running with sudo
if $USING_SUDO; then
    chown "$REAL_USER:$(id -gn "$REAL_USER")" "$INSTALL_DIR/pipvenv"
fi

# Step 4: Make the pipvenv script executable
chmod +x "$INSTALL_DIR/pipvenv" || error "Failed to make the script executable."

# Step 5: Ensure ~/.local/bin is in the PATH
BASHRC_FILE="$REAL_HOME/.bashrc"
BASHRC_ENTRY='export PATH="$HOME/.local/bin:$PATH"'

# Check if PATH entry already exists
if ! grep -q "$BASHRC_ENTRY" "$BASHRC_FILE"; then
    echo "Adding ~/.local/bin to PATH in $BASHRC_FILE..."
    
    if $USING_SUDO; then
        # With sudo, we need to use a different approach to write to the user's .bashrc
        echo "$BASHRC_ENTRY" | sudo -u "$REAL_USER" tee -a "$BASHRC_FILE" > /dev/null
    else
        # Without sudo, we can write directly
        echo "$BASHRC_ENTRY" >> "$BASHRC_FILE"
    fi
    
    success "~/.local/bin has been added to your PATH."
    echo "Please run 'source ~/.bashrc' or start a new terminal session to use pipvenv."
fi

# Step 6: Create global symlink if running with sudo
if $USING_SUDO; then
    echo "Creating global symlink for system-wide access..."
    if [ ! -d "/usr/local/bin" ]; then
        mkdir -p "/usr/local/bin"
    fi
    # Create symlink to user's .local/bin version
    ln -sf "$INSTALL_DIR/pipvenv" "/usr/local/bin/pipvenv"
    success "Created global symlink in /usr/local/bin/pipvenv"
fi

# Step 7: Display success message
success "pipvenv has been installed successfully to $INSTALL_DIR"
echo "You can now use 'pipvenv' to manage your Python projects."
echo "Usage examples:"
echo "  pipvenv install -r requirements.txt"
echo "  pipvenv -h (for help)"
echo "  pipvenv -v (for version)"
echo ""
echo -e "\e[96mMade With Love By AlbertC @yz9yt\e[0m"

if ! $USING_SUDO; then
    warning "Note: For system-wide access, rerun this script with sudo."
fi
