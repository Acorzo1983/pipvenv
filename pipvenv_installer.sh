
#!/bin/bash

# Script to install pipvenv locally without requiring sudo

# Function to display error messages
error() {
    echo -e "\e[91m[ERROR] $1\e[0m" >&2
    exit 1
}

# Function to display success messages
success() {
    echo -e "\e[92m[SUCCESS] $1\e[0m"
}

# Step 1: Update the system and ensure python3-venv is installed
echo "Updating system and installing dependencies..."
if ! command -v python3 &> /dev/null || ! python3 -m venv --help &> /dev/null; then
    echo "Installing python3-venv..."
    if ! sudo apt update > /dev/null 2>&1 || ! sudo apt install -y python3-venv > /dev/null 2>&1; then
        error "Failed to install python3-venv. Please ensure you have sudo privileges."
    fi
fi

success "Dependencies installed successfully."

# Step 2: Define installation directory
INSTALL_DIR="$HOME/.local/bin"

# Ensure the installation directory exists
mkdir -p "$INSTALL_DIR" || error "Failed to create installation directory."

# Step 3: Create the pipvenv script
echo "Creating the pipvenv script in $INSTALL_DIR..."

cat << 'EOF' > "$INSTALL_DIR/pipvenv"
#!/bin/bash

# Check if arguments are provided
if [ -z "$1" ]; then
    echo "Usage: pipvenv <command> [options]"
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

# Step 4: Make the pipvenv script executable
chmod +x "$INSTALL_DIR/pipvenv" || error "Failed to make the script executable."

# Step 5: Ensure ~/.local/bin is in the PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
    success "~/.local/bin has been added to your PATH. Please restart your terminal or run 'source ~/.bashrc'."
fi

# Step 6: Display success message
success "pipvenv has been installed successfully."
echo "You can now use 'pipvenv' to manage your Python projects."
echo "Example: pipvenv install -r requirements.txt"
