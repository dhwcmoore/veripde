# VeriPDE Troubleshooting Guide

This guide helps you diagnose and resolve common issues when using VeriPDE.

## Quick Diagnosis

### Check Your Installation
```bash
# Verify VeriPDE is installed and accessible
veripde --version

# Check system information
veripde system-info

# Verify dependencies
veripde check-deps
```

### Test with Known Good Model
```bash
# Download and test a verified example
curl -O https://raw.githubusercontent.com/veripde/veripde/main/examples/basic_valid.json
veripde validate basic_valid.json
```

If this works, your installation is correct and the issue is likely with your model or configuration.

## Installation Issues

### Issue: `veripde: command not found`

**Cause**: VeriPDE not properly installed or not in PATH.

**Solutions**:
```bash
# Option 1: Verify opam environment
eval $(opam env)
veripde --version

# Option 2: Check if installed in opam
opam list | grep veripde

# Option 3: Reinstall from opam
opam uninstall veripde
opam install veripde

# Option 4: Install from source
git clone https://github.com/veripde/veripde.git
cd veripde
dune build
dune install
```

### Issue: OCaml/opam not found

**Cause**: OCaml development environment not installed.

**Solutions**:

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install ocaml opam
opam init
eval $(opam env)
opam install veripde
```

**macOS**:
```bash
brew install ocaml opam
opam init
eval $(opam env)
opam install veripde
```

**Windows (WSL)**:
```bash
# Install WSL and Ubuntu, then follow Ubuntu instructions
```

### Issue: Dependency conflicts during installation

**Cause**: Conflicting OCaml package versions.

**Solutions**:
```bash
# Create clean opam switch
opam switch create veripde-env 4.14.0
eval $(opam env)
opam install veripde

# Or update existing packages
opam update
opam upgrade
opam install veripde
```

### Issue: Build failures from source

**Error**: `dune: command not found`
```bash
# Install dune
opam install dune
```

**Error**: Missing dependencies
```bash
# Install all dependencies
opam install --deps-only .
```

**Error**: Coq extraction failures
```bash
# Ensure Coq is properly installed
opam install coq
# Rebuild with clean environment
dune clean
dune build
```

## Runtime Errors

### JSON Parsing Issues

#### Issue: "Invalid JSON syntax"
```
Error: Parse_Error "Invalid JSON syntax at line 15"
```

**Diagnosis**:
```bash
# Check JSON syntax
python -m json.tool your_model.json

# Or use jq
jq . your_model.json

# Or online validator: https://jsonlint.com/
```

**Common JSON Errors**:
- Missing commas between object properties
- Trailing commas (not allowed in JSON)
- Unquoted strings or property names
- Mismatched brackets/braces
- Invalid escape sequences

**Example Fix**:
```json
// ❌ Invalid JSON
{
  "model_id": my_model,        // Missing quotes
  "parameters": {
    "mass": 1.0,
    "temperature": 25.0,         // Trailing comma
  }
}

// ✅ Valid JSON
{
  "model_id": "my_model",
  "parameters": {
    "mass": 1.0,
    "temperature": 25.0
  }
}
```

#### Issue: "Required field missing"
```
Error: Invalid_Model "Missing required field 'model_type'"
```

**Solution**: Ensure all required fields are present:
```json
{
  "model_id": "required",
  "operator": "required: heat|elasticity|navier_stokes|wave",
  "domain": "required",
  "parameters": {"required": "object"},
  "contracts": ["required", "array"]
}
```

#### Issue: "Unknown constraint type"
```
Error: Constraint_Error "Unknown constraint type 'custom_validation'"
```

**Solutions**:
```bash
# List available constraint types
veripde list-constraints

# Check if plugin needed
veripde list-plugins

# Use built-in constraint types
```

**Available constraint types**:
- `mass_validation`
- `temperature_range`
- `pressure_validation`
- `displacement_bounds`
- `elastic_modulus_range`
- `poisson_ratio_bounds`
- `reynolds_number_check`
- `velocity_bounds`
- `wave_speed_validation`
- `frequency_range`
- `amplitude_bounds`

### Validation Logic Issues

#### Issue: Unexpected validation results

**Debugging Steps**:
```bash
# Enable verbose output
veripde validate --verbose your_model.json

# Enable debug mode
veripde validate --debug your_model.json

# Show constraint evaluation details
veripde validate --explain your_model.json
```

#### Issue: "Constraint evaluation failed"
```
Error: Constraint_Error "mass_validation" "Unable to evaluate constraint"
```

**Common Causes**:
- Parameter type mismatch (string instead of number)
- Missing required parameters
- Invalid threshold values

**Example Fix**:
```json
// ❌ Parameter type mismatch
{
  "parameters": {
    "mass": "1.5"  // String instead of number
  }
}

// ✅ Correct parameter type
{
  "parameters": {
    "mass": 1.5  // Number
  }
}
```

#### Issue: Threshold configuration errors
```
Error: Threshold_Error "Cannot load threshold file 'custom.json'"
```

**Solutions**:
```bash
# Use absolute path
veripde validate --thresholds /full/path/to/thresholds.json model.json

# Check file exists
ls -la thresholds.json

# Use default thresholds
veripde validate model.json

# Generate example threshold file
veripde generate-thresholds > example_thresholds.json
```

## Performance Issues

### Issue: Slow validation times

**Causes and Solutions**:

**Large model files**:
```bash
# Use streaming mode
veripde validate --stream large_model.json

# Enable parallel processing
veripde validate --parallel model.json
```

**Many constraint evaluations**:
```bash
# Optimize constraint order (critical first)
veripde validate --optimize model.json

# Use lazy evaluation
veripde validate --lazy model.json
```

**Debug mode overhead**:
```bash
# Disable debug output for production
veripde validate model.json  # (not --debug)
```

### Issue: High memory usage

**Solutions**:
```bash
# Limit memory usage
export VERIPDE_MEMORY_LIMIT=1024  # MB
veripde validate model.json

# Use streaming for large datasets
veripde validate --stream --batch-size 100 models/*.json

# Enable garbage collection tuning
export OCAMLRUNPARAM=s=1024k
veripde validate model.json
```

### Issue: Timeout errors
```
Error: System_Error "Validation timeout after 30 seconds"
```

**Solutions**:
```bash
# Increase timeout
veripde validate --timeout 120 model.json

# Enable parallel processing
veripde validate --parallel --timeout 120 model.json

# Simplify model for testing
veripde validate --quick-check model.json
```

## Plugin Issues

### Issue: Plugin loading failures
```
Error: Plugin_Error "my_plugin" "Failed to load plugin"
```

**Debugging Steps**:
```bash
# List available plugins
veripde list-plugins

# Check plugin paths
veripde show-config | grep plugin

# Test plugin individually
veripde test-plugin my_plugin

# Check plugin dependencies
veripde plugin-info my_plugin
```

### Issue: Plugin compatibility errors
```
Error: Plugin_Error "version_mismatch" "Plugin requires VeriPDE >= 0.2.0"
```

**Solutions**:
```bash
# Check VeriPDE version
veripde --version

# Update VeriPDE
opam update
opam upgrade veripde

# Check plugin compatibility
veripde plugin-compatibility my_plugin

# Use compatible plugin version
opam install my_plugin.0.1.0
```

## Configuration Issues

### Issue: Configuration file not found
```
Warning: Configuration file 'veripde.json' not found, using defaults
```

**Solutions**:
```bash
# Generate default configuration
veripde generate-config > veripde.json

# Specify configuration file
veripde validate --config /path/to/config.json model.json

# Check configuration search paths
veripde show-config-paths
```

### Issue: Invalid configuration format
```
Error: Config_Error "Invalid configuration format"
```

**Check configuration syntax**:
```bash
# Validate configuration JSON
python -m json.tool veripde.json

# Use configuration template
veripde generate-config --template > veripde.json

# Verify configuration
veripde validate-config veripde.json
```

## Environment Issues

### Issue: Permission denied errors
```
Error: System_Error "Permission denied: /usr/local/bin/veripde"
```

**Solutions**:
```bash
# Install to user directory
opam install --user veripde

# Fix permissions
sudo chmod +x /usr/local/bin/veripde

# Use local installation
./veripde validate model.json
```

### Issue: Path-related problems

**Linux/macOS**:
```bash
# Add opam environment to shell profile
echo 'eval $(opam env)' >> ~/.bashrc
source ~/.bashrc

# Or set PATH manually
export PATH=$HOME/.opam/default/bin:$PATH
```

**Windows (WSL)**:
```bash
# Add to .bashrc
echo 'eval $(opam env)' >> ~/.bashrc
source ~/.bashrc
```

### Issue: Locale/encoding problems
```
Error: System_Error "Invalid UTF-8 encoding in input file"
```

**Solutions**:
```bash
# Check file encoding
file -i your_model.json

# Convert to UTF-8
iconv -f ISO-8859-1 -t UTF-8 your_model.json > your_model_utf8.json

# Set locale environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
```

## Docker-Specific Issues

### Issue: Container fails to start
```
docker: Error response from daemon: failed to create shim
```

**Solutions**:
```bash
# Update Docker
sudo apt update && sudo apt upgrade docker.io

# Pull latest image
docker pull veripde/veripde:latest

# Check Docker service
sudo systemctl status docker
sudo systemctl start docker
```

### Issue: Volume mounting problems
```
Error: cannot access '/data/model.json': No such file or directory
```

**Solutions**:
```bash
# Use absolute paths
docker run -v /full/path/to/data:/data veripde/veripde validate /data/model.json

# Check file permissions
ls -la model.json
chmod 644 model.json

# Use current directory
docker run -v $(pwd):/data veripde/veripde validate /data/model.json
```

### Issue: Container networking problems
```
Error: Could not connect to validation service
```

**Solutions**:
```bash
# Use host networking
docker run --network host veripde/veripde

# Check port binding
docker run -p 8080:8080 veripde/veripde

# Inspect container networking
docker inspect container_name
```

## Integration Issues

### Issue: CI/CD pipeline failures

**GitHub Actions**:
```yaml
# Common solution: proper environment setup
- name: Setup OCaml
  uses: ocaml/setup-ocaml@v2
  with:
    ocaml-compiler: 4.14.x
    
- name: Install VeriPDE
  run: |
    eval $(opam env)
    opam install veripde
    
- name: Validate Models
  run: |
    eval $(opam env)  # Important: eval in each step
    veripde validate models/*.json
```

**GitLab CI**:
```yaml
# Add to .gitlab-ci.yml
validate:
  image: ocaml/opam:latest
  before_script:
    - eval $(opam env)
    - opam install veripde
  script:
    - eval $(opam env)
    - veripde validate models/*.json
```

### Issue: Python integration problems
```python
# Common issue: subprocess environment
import subprocess
import os

# ❌ Wrong way
result = subprocess.run(['veripde', 'validate', 'model.json'])

# ✅ Correct way
env = os.environ.copy()
# Ensure opam environment is available
result = subprocess.run(['veripde', 'validate', 'model.json'], 
                       env=env, cwd='/path/to/models')
```

### Issue: Makefile integration problems
```makefile
# Common issue: opam environment not available

# ❌ Wrong way
validate:
	veripde validate model.json

# ✅ Correct way
validate:
	eval $(opam env) && veripde validate model.json

# Or use shell environment
SHELL := /bin/bash
.ONESHELL:
validate:
	eval $(opam env)
	veripde validate model.json
```

## Debugging Strategies

### Enable Comprehensive Logging
```bash
# Full debug output
export VERIPDE_DEBUG=1
export VERIPDE_VERBOSE=1
veripde validate --debug --verbose model.json 2>&1 | tee debug.log

# Analyze the log
grep -i error debug.log
grep -i warning debug.log
```

### Isolate the Problem

**Test with minimal model**:
```json
{
  "model_id": "minimal_test",
  "operator": "heat",
  "domain": "unit_square",
  "parameters": {"mass": 1.0},
  "contracts": [{"type": "mass_validation", "threshold": 0.001}]
}
```

**Progressive complexity testing**:
```bash
# 1. Test basic functionality
veripde validate minimal_test.json

# 2. Add one constraint at a time
veripde validate model_with_temperature.json

# 3. Add complex constraints
veripde validate full_model.json
```

### System Information Collection
```bash
# Collect comprehensive system info
veripde system-info > system_info.txt
ocaml -version >> system_info.txt
opam --version >> system_info.txt
dune --version >> system_info.txt
uname -a >> system_info.txt
```

## Getting Help

### Before Requesting Support

1. **Check this troubleshooting guide**
2. **Review the documentation**:
   - [Getting Started Guide](getting_started.md)
   - [API Reference](api_reference.md)
   - [Examples Guide](examples.md)

3. **Search existing issues**:
   - [GitHub Issues](https://github.com/veripde/veripde/issues)
   - [GitHub Discussions](https://github.com/veripde/veripde/discussions)

### When Requesting Help

**Include this information**:
```bash
# System information
veripde system-info

# Version information
veripde --version --verbose

# Configuration details
veripde show-config

# Error reproduction
veripde validate --debug your_model.json
```

**Provide**:
- Complete error message
- Input model file (or simplified version)
- Steps to reproduce
- Expected vs actual behavior
- Operating system and version

### Community Resources

- **GitHub Discussions**: General questions and community support
- **GitHub Issues**: Bug reports and feature requests
- **Stack Overflow**: Technical questions (tag: `veripde`)
- **Reddit**: r/OCaml community discussions

### Professional Support

For commercial users requiring professional support:
- **Email**: support@veripde.org
- **Priority Support**: Available for enterprise customers
- **Consulting**: Custom integration and development services

## Common Workarounds

### Temporary Fixes for Known Issues

**Issue**: Large model validation timeout
```bash
# Workaround: Split into smaller models
split -l 1000 large_model.json model_part_
for part in model_part_*; do
  veripde validate "$part"
done
```

**Issue**: Memory constraints on small systems
```bash
# Workaround: Process models sequentially
for model in models/*.json; do
  veripde validate "$model"
  sleep 1  # Allow memory cleanup
done
```

**Issue**: Plugin loading in restricted environments
```bash
# Workaround: Use built-in constraints only
veripde validate --no-plugins model.json
```

## Prevention Best Practices

### Model Creation
- **Use JSON linting tools** during model creation
- **Start with simple models** and gradually add complexity
- **Test with known good examples** before custom models
- **Document parameter sources** and expected ranges

### Environment Management
- **Use consistent OCaml/opam versions** across team
- **Pin VeriPDE version** for production systems
- **Document installation steps** for your environment
- **Test in clean environments** before deployment

### Integration Planning
- **Test VeriPDE integration** early in development cycle
- **Use containerization** for consistent environments
- **Implement proper error handling** in automation scripts
- **Monitor validation performance** and set appropriate timeouts

### Maintenance
- **Regularly update** VeriPDE and dependencies
- **Monitor for security updates** in OCaml ecosystem
- **Backup working configurations** before changes
- **Test updates** in non-production environments first

This troubleshooting guide covers the most common issues encountered when using VeriPDE. If you encounter an issue not covered here, please refer to the community resources or file a detailed bug report.