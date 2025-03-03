# pipvenv - Simplify Python Virtual Environments and Dependency Management

## Features
Fully automated creation, activation, and deactivation of virtual environments.
Easy-to-use commands for installing dependencies with a single command.
Ensures reproducible environments across different machines.
Keeps project dependencies isolated from the global system.

## Installation
To install pipvenv, run the following command in your terminal:

```bash
curl -s https://raw.githubusercontent.com/Acorzo1983/pipvenv/main/pipvenv_installer.sh | sudo bash
```

Note: This script installs pipvenv locally in ~/.local/bin. If this directory is not in your PATH, it will be added automatically to your ~/.bashrc.

## Requirements:

A Linux distribution (tested on Kali Linux).
Internet access to download the installation script.

## Usage
Once installed, you can use pipvenv from any project directory. Below are some basic commands:


## Basic Commands

| Command                  | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `pipvenv install <package>` | Installs the specified package inside the virtual environment.             |
| `pipvenv install -r <file>` | Installs dependencies listed in a `requirements.txt` file.                 |
| `pipvenv list`            | Lists all packages installed in the virtual environment.                   |
| `pipvenv freeze`          | Generates a list of installed packages in `requirements.txt` format.       |
| `pipvenv uninstall <package>` | Uninstalls the specified package from the virtual environment.            |


## How It Works

### Virtual Environment Creation:
  When you run pipvenv, it checks if a virtual environment exists in the current directory (default name: .venv).
  If the environment does not exist, it creates one using python3 -m venv.
### Activation and Deactivation:
  The script activates the virtual environment before running any pip commands.
After execution, it deactivates the environment automatically.
### Dependency Management:
  You can manage all project dependencies using requirements.txt or by specifying individual packages.


### License
This project is licensed under the MIT License. See the LICENSE file for more details.

### Download
You can download this repository directly from GitHub:

```bash
git clone https://github.com/Acorzo1983/pipvenv.git
```
## Contributing
Feel free to contribute to this project! Open an issue or submit a pull request.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

Made with ❤️ by Albert C.
