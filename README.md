# Python Geoprocessing Devcontainer

A VS Code devcontainer template for Python geoprocessing with GDAL, and optionally ESA SNAP/esa_snappy.

## Prerequisites

### Required Software

1. **WSL2 (Windows Subsystem for Linux) or Linux**
   - **Windows users**: Install WSL2 with Ubuntu
     ```powershell
     wsl --install
     ```
     See [WSL Installation Guide](https://docs.microsoft.com/en-us/windows/wsl/install)
   - **Linux users**: Any modern Linux distribution

2. **Docker Desktop**
   - Download from [Docker Desktop](https://www.docker.com/products/docker-desktop/)
   - Enable WSL2 backend (Windows)

3. **Visual Studio Code**
   - Download from [VS Code](https://code.visualstudio.com/)
   - Install extensions:
     - **Dev Containers** (`ms-vscode-remote.remote-containers`) - Required
     - **WSL** (`ms-vscode-remote.remote-wsl`) - Required for Windows

### WSL Setup (Windows)

**Important**: Always clone repositories into the WSL filesystem, not Windows.

1. **Set ONEDRIVE environment variable** in `~/.bashrc`:
   ```bash
   echo 'export ONEDRIVE="$(wslpath "$(cmd.exe /c echo %ONEDRIVE% 2>/dev/null | tr -d '\''\r'\'')")"' >> ~/.bashrc && source ~/.bashrc
   ```

2. **Copy SSH keys from Windows to WSL**:
   ```bash
   cp -r "$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")/.ssh" ~/.ssh && chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
   ```

3. **Copy git config**:
   ```bash
   cp "$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")/.gitconfig" ~/.gitconfig
   ```

4. **Fix git credential helper for WSL**:
   ```bash
   git config --global credential.helper "/mnt/c/Users/$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')/AppData/Local/Programs/Git/mingw64/bin/git-credential-manager.exe"
   ```

5. **Create bash_aliases if it doesn't exist**:
   ```bash
   touch ~/.bash_aliases
   ```

## Quick Start

1. **Connect to WSL** (Windows users):
   - Press `Ctrl+Shift+P` → "WSL: Connect to WSL"
2. Clone the repository into WSL filesystem
3. Open the folder in VS Code
4. When prompted, click **"Reopen in Container"** (or `Ctrl+Shift+P` → `Dev Containers: Reopen in Container`)
5. Wait for the container to build (first time takes longer)
6. Start coding!

## Two Configurations

### With SNAP (default)

The default configuration includes ESA SNAP and esa_snappy for Sentinel data processing. This is a larger image (~2GB+) but includes everything for satellite imagery processing.

**Dockerfile**: `.devcontainer/Dockerfile`

```bash
# Verify installation
uv run python -c "from osgeo import gdal; print(f'GDAL {gdal.__version__}')"
uv run python -c "import esa_snappy; print('esa_snappy OK')"
```

### Without SNAP (lite)

For projects that only need GDAL/rasterio without SNAP, use the lite configuration for faster builds:

1. Edit `.devcontainer/devcontainer.json`
2. Change the dockerfile line:
   ```json
   "build": {
       "dockerfile": "Dockerfile.lite"
   }
   ```
3. Rebuild the container

## Development Workflow

### Adding Dependencies

```bash
# Add a package
uv add pandas

# Add a dev dependency
uv add --dev pytest

# Sync dependencies
uv sync
```

### Running Code

```bash
# Run a script
uv run python main.py

# Run with arguments
uv run python script.py --input /data/image.tif

# Start a Python REPL
uv run python
```

### Running Tests

```bash
# Run all tests
uv run pytest

# Run with coverage
uv run pytest --cov
```

### Linting and Formatting

Ruff is configured as the default formatter. Files are auto-formatted on save.

```bash
# Manual lint check
uv run ruff check .

# Manual format
uv run ruff format .

# Fix auto-fixable issues
uv run ruff check --fix .
```

## Project Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json    # Container configuration
│   ├── Dockerfile           # Full image with SNAP
│   └── Dockerfile.lite      # Lightweight GDAL-only image
├── pyproject.toml           # Project config and dependencies
├── main.py                  # Entry point
└── README.md
```

## Mounted Directories

| Host Path | Container Path | Description |
|-----------|----------------|-------------|
| `~/.ssh` | `/home/vscode/.ssh` | SSH keys for git |
| `~/.gitconfig` | `/home/vscode/.gitconfig` | Git configuration |
| `~/.bash_aliases` | `/home/vscode/.bash_aliases` | Shell aliases |
| `$ONEDRIVE/...` | `/data` | OneDrive data folder |

## Pre-installed Packages

- **gdal** - Geospatial Data Abstraction Library
- **rasterio** - Raster I/O
- **numpy** - Numerical computing
- **scipy** - Scientific computing
- **pyproj** - Cartographic projections
- **shapely** - Geometric operations
- **fiona** - Vector I/O
- **esa_snappy** - ESA SNAP Python bindings (full image only)

## VS Code Extensions

- **Ruff** - Fast Python linter/formatter
- **Pylance** - Python language server
- **Even Better TOML** - TOML syntax highlighting
- **Git Graph** - Git history visualization
- **Better Comments** - Comment highlighting
- **Code Spell Checker** - Spell checking

## Troubleshooting

### "Could not resolve Feature" / registry credentials error

If you see an error like:
```
Could not resolve Feature manifest for 'ghcr.io/devcontainers/features/...'.
If necessary, provide registry credentials with 'docker login <registry>'.
```

This is a GitHub Container Registry authentication issue. Solutions:

1. **Login to GitHub Container Registry**:
   ```bash
   # Create a GitHub Personal Access Token with read:packages scope
   # Then login:
   echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
   ```

2. **Or remove the problematic feature** from `devcontainer.json` and install it directly in the Dockerfile (this template already does this for uv).

### SNAP download fails

ESA SNAP downloads can be slow or fail. If the build fails at the SNAP download step:

1. **Try again** - ESA servers can be temporarily unavailable
2. **Manual download** - Download the installer from [ESA STEP](https://step.esa.int/main/download/snap-download/) and place it in `.devcontainer/`, then modify the Dockerfile to use `COPY` instead of `curl`
3. **Use lite image** - Switch to `Dockerfile.lite` if you don't need SNAP

### GDAL import errors

Ensure the GDAL Python version matches the system library:
```bash
gdal-config --version
uv run python -c "from osgeo import gdal; print(gdal.__version__)"
```

### esa_snappy not found

esa_snappy is only available in the full image. Check you're using `Dockerfile`, not `Dockerfile.lite`.

### Mount errors

Ensure the `ONEDRIVE` environment variable is set on your host system, or remove/modify the OneDrive mount in `devcontainer.json`.

### uv not found

If `uv` command is not found, the PATH may not be set correctly. Run:
```bash
export PATH="$HOME/.local/bin:$PATH"
```
Or restart your terminal.

## Resources

- [uv documentation](https://docs.astral.sh/uv/)
- [Ruff documentation](https://docs.astral.sh/ruff/)
- [GDAL Python documentation](https://gdal.org/api/python.html)
- [ESA SNAP documentation](https://step.esa.int/main/toolboxes/snap/)
- [Dev Containers specification](https://containers.dev/)
