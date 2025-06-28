# VeriPDE Getting Started Guide

This guide will take you from installation to running your first PDE constraint validation in under 10 minutes.

## Prerequisites

### System Requirements
- **Operating System**: Linux, macOS, or Windows (WSL recommended)
- **Memory**: Minimum 2GB RAM, recommended 4GB+ for large models
- **Disk Space**: 500MB for installation, additional space for models and results

### Required Software
- **OCaml**: Version 4.14 or later
- **opam**: OCaml package manager (latest version)
- **dune**: Build system (installed automatically with VeriPDE)

## Installation Options

### Option 1: Install from opam (Recommended)

This is the easiest method for most users:

```bash
# Update opam package list
opam update

# Install VeriPDE
opam install veripde

# Verify installation
veripde --version
```

### Option 2: Install from Source

For developers or users who need the latest features:

```bash
# Clone repository
git clone https://github.com/veripde/veripde.git
cd veripde

# Install dependencies
opam install --deps-only .

# Build VeriPDE
dune build

# Install locally
dune install

# Verify installation
dune exec bin/validator_main.exe -- --help
```

### Option 3: Docker Installation

For containerized environments:

```bash
# Pull Docker image
docker pull veripde/veripde:latest

# Run validation (mount your data directory)
docker run -v $(pwd):/data veripde/veripde validate /data/your_model.json

# Interactive mode
docker run -it -v $(pwd):/data veripde/veripde bash
```

## Setting Up Your Environment

### Creating a Project Directory
```bash
mkdir my_veripde_project
cd my_veripde_project

# Create standard directory structure
mkdir models
mkdir results
mkdir thresholds
```

### Configuration File (Optional)
Create `veripde.json` in your project directory:
```json
{
  "validation": {
    "parallel_workers": 4,
    "timeout_seconds": 30
  },
  "thresholds": {
    "default_file": "thresholds/default.json"
  },
  "output": {
    "default_format": "text",
    "verbosity": "normal"
  }
}
```

## Your First Model

### Step 1: Create a Simple Heat Equation Model

Create `models/first_model.json`:
```json
{
  "model_id": "my_first_heat_equation",
  "operator": "heat",
  "domain": {
    "type": "unit_square"
  },
  "parameters": {
    "mass": 2.0,
    "temperature": 30.0,
    "thermal_conductivity": 0.5
  },
  "contracts": [
    {
      "type": "mass_validation",
      "threshold": 0.001,
      "severity": "CRITICAL"
    },
    {
      "type": "temperature_range",
      "min_value": 0.0,
      "max_value": 500.0,
      "warning_threshold": 100.0
    }
  ],
  "expected_result": "PASS"
}
```

### Step 2: Run Your First Validation
```bash
veripde validate models/first_model.json
```

**Expected Output**:
```
🧪 VeriPDE Contract Validation System
====================================
Using thresholds: temp=500.0, disp=0.100, pressure=100.0, mass=0.001

[Test 1/1]=== Model: my_first_heat_equation ===
Parameter Validation:
✅ mass = 2.000 | ✔ mass valid
✅ temperature = 30.000 | ✔ temperature in range
✅ thermal_conductivity = 0.500 | ✔ parameter valid
Overall Status: ✅ PASS ✅ (matches expected)

June 28 Milestone: COMPLETE ✅
```

🎉 **Congratulations!** You've successfully run your first VeriPDE validation.

## Understanding the Output

### Status Indicators
- **✅ PASS**: All constraints satisfied, model is valid
- **⚠️ WARNING**: Model passes but with operational concerns
- **❌ CRITICAL**: Model has fundamental issues that prevent safe operation

### Detailed Information
- **Parameter Values**: Shows actual values being validated
- **Constraint Messages**: Explains why each constraint passed or failed
- **Overall Status**: Final validation result
- **Expected vs Actual**: Compares with your expected result (if provided)

## Exploring Different Model Types

### Elasticity Model
Create `models/beam_model.json`:
```json
{
  "model_id": "cantilever_beam",
  "operator": "elasticity",
  "domain": {
    "type": "beam_3d"
  },
  "parameters": {
    "elastic_modulus": 200e9,
    "poisson_ratio": 0.3,
    "applied_load": 1000.0,
    "displacement": 0.05
  },
  "contracts": [
    {
      "type": "elastic_modulus_range",
      "min_value": 1e9,
      "max_value": 500e9
    },
    {
      "type": "poisson_ratio_bounds",
      "min_value": 0.0,
      "max_value": 0.5
    },
    {
      "type": "displacement_bounds",
      "max_displacement": 0.1
    }
  ]
}
```

### Fluid Flow Model
Create `models/pipe_flow.json`:
```json
{
  "model_id": "turbulent_pipe_flow",
  "operator": "navier_stokes",
  "domain": {
    "type": "pipe_flow"
  },
  "parameters": {
    "density": 1000.0,
    "viscosity": 0.001,
    "inlet_velocity": 5.0,
    "pressure": 101325.0
  },
  "contracts": [
    {
      "type": "reynolds_number_check",
      "min_reynolds": 2300,
      "max_reynolds": 100000
    },
    {
      "type": "pressure_validation",
      "min_value": 0.0
    }
  ]
}
```

### Run Multiple Models
```bash
# Validate all models in directory
veripde validate models/*.json

# Generate JSON output for automation
veripde validate --output json models/*.json > results/validation_results.json
```

## Working with Constraints

### Built-in Constraint Types
VeriPDE supports these constraint types out of the box:

**Physical Parameters**:
- `mass_validation` - Ensures positive mass values
- `temperature_range` - Temperature within operational bounds
- `pressure_validation` - Non-negative pressure values
- `displacement_bounds` - Mechanical displacement limits

**Mathematical Properties**:
- `boundary_consistency` - Boundary condition compatibility
- `conservation_laws` - Mass/energy conservation
- `stability_check` - Numerical stability requirements

### Custom Thresholds
Create `thresholds/aerospace.json` for aerospace applications:
```json
{
  "temperature": {
    "max": 1500.0,
    "warning": 1200.0,
    "units": "celsius"
  },
  "pressure": {
    "max": 50000000.0,
    "warning": 40000000.0,
    "units": "pascals"
  },
  "stress": {
    "max": 800000000.0,
    "warning": 600000000.0,
    "units": "pascals"
  }
}
```

Use custom thresholds:
```bash
veripde validate --thresholds thresholds/aerospace.json models/aircraft_model.json
```

## Advanced Features

### Parallel Processing
For large datasets or multiple models:
```bash
# Use 8 parallel workers
veripde validate --parallel --workers 8 models/*.json

# Automatic worker detection
veripde validate --parallel models/*.json
```

### Batch Processing with Reports
```bash
# Generate comprehensive report
veripde validate \
  --batch \
  --output json \
  --audit-mode \
  models/*.json > results/audit_report.json

# Generate XML for regulatory systems  
veripde validate \
  --output xml \
  --audit-mode \
  models/regulatory_model.json > results/compliance_report.xml
```

### Interactive Mode
```bash
# Start interactive validation session
veripde interactive

# Commands available in interactive mode:
> load model.json
> validate
> set-thresholds custom.json
> show-constraints
> export-results results.json
> quit
```

## Integration Examples

### CI/CD Integration (GitHub Actions)
Create `.github/workflows/validation.yml`:
```yaml
name: Model Validation
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup OCaml
        uses: ocaml/setup-ocaml@v2
        with:
          ocaml-compiler: 4.14.x
          
      - name: Install VeriPDE
        run: opam install veripde
        
      - name: Validate Models
        run: |
          eval $(opam env)
          veripde validate --batch models/*.json
          
      - name: Generate Report
        run: |
          eval $(opam env)
          veripde validate --output json models/*.json > validation_report.json
          
      - name: Upload Results
        uses: actions/upload-artifact@v2
        with:
          name: validation-results
          path: validation_report.json
```

### Python Integration
```python
#!/usr/bin/env python3
import subprocess
import json
import sys

def validate_model(model_file, thresholds=None):
    """Validate a model using VeriPDE"""
    cmd = ['veripde', 'validate', '--output', 'json']
    if thresholds:
        cmd.extend(['--thresholds', thresholds])
    cmd.append(model_file)
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"Validation failed: {result.stderr}", file=sys.stderr)
        return None
        
    return json.loads(result.stdout)

# Usage example
if __name__ == "__main__":
    result = validate_model('models/my_model.json')
    if result:
        status = result['results'][0]['overall_status']
        print(f"Validation status: {status}")
        
        if status == 'CRITICAL':
            sys.exit(1)
```

### Makefile Integration
```makefile
# Makefile for automated validation

MODELS := $(wildcard models/*.json)
RESULTS := $(MODELS:models/%.json=results/%.result)

.PHONY: all validate clean report

all: validate

validate: $(RESULTS)

results/%.result: models/%.json
	@mkdir -p results
	veripde validate --output json $< > $@
	@echo "Validated $<"

report: $(RESULTS)
	@echo "=== Validation Summary ==="
	@for result in $(RESULTS); do \
		status=$(jq -r '.results[0].overall_status' $result); \
		model=$(jq -r '.results[0].model_name' $result); \
		echo "$model: $status"; \
	done

clean:
	rm -rf results/
```

## Troubleshooting

### Common Issues and Solutions

#### Installation Problems

**Issue**: `opam install veripde` fails with dependency errors
```bash
# Solution: Update opam and upgrade packages
opam update
opam upgrade
opam install veripde
```

**Issue**: OCaml version incompatibility
```bash
# Solution: Install compatible OCaml version
opam switch create 4.14.0
eval $(opam env)
opam install veripde
```

**Issue**: Build fails with "dune not found"
```bash
# Solution: Install dune explicitly
opam install dune
```

#### Runtime Problems

**Issue**: JSON parsing errors
```
Error: Parse_Error "Invalid JSON syntax at line 15"
```
**Solution**: Validate JSON syntax using online validator or:
```bash
# Check JSON syntax
python -m json.tool model.json

# Or use jq
jq . model.json
```

**Issue**: Missing constraint type errors
```
Error: Unknown constraint type 'custom_validation'
```
**Solution**: Check available constraint types:
```bash
veripde list-constraints
```

**Issue**: Threshold file not found
```
Error: Threshold file 'custom.json' not found
```
**Solution**: Use absolute path or check file location:
```bash
# Use absolute path
veripde validate --thresholds /full/path/to/thresholds.json model.json

# Or verify file exists
ls -la thresholds/
```

#### Performance Issues

**Issue**: Slow validation for large models
**Solution**: Enable parallel processing:
```bash
veripde validate --parallel --workers $(nproc) large_model.json
```

**Issue**: Memory usage too high
**Solution**: Use streaming mode for large datasets:
```bash
veripde validate --stream --batch-size 100 models/*.json
```

### Getting Help

#### Built-in Help
```bash
# General help
veripde --help

# Command-specific help
veripde validate --help

# List available constraint types
veripde list-constraints

# Show example models
veripde examples
```

#### Debug Mode
```bash
# Enable verbose debug output
veripde validate --debug --verbose model.json

# Save debug output to file
veripde validate --debug model.json 2> debug.log
```

#### Version Information
```bash
# Check version and build info
veripde --version --verbose

# Check dependencies
veripde system-info
```

## Next Steps

### Learn More About VeriPDE
- **[Constraint Types Reference](constraint_types.md)** - Complete catalog of available constraints
- **[API Reference](api_reference.md)** - Programmatic usage and integration
- **[Mathematical Foundation](mathematical_foundation.md)** - Understanding the formal verification
- **[Architecture Overview](architecture.md)** - System design and extensibility

### Advanced Usage
- **Plugin Development** - Create custom constraint validators
- **Domain-Specific Applications** - Aerospace, oil & gas, nuclear engineering
- **Integration Patterns** - CI/CD, automated testing, regulatory compliance

### Community Resources
- **[GitHub Discussions](https://github.com/veripde/veripde/discussions)** - Ask questions and share experiences
- **[Example Repository](https://github.com/veripde/examples)** - Real-world model examples
- **[Plugin Registry](https://github.com/veripde/plugins)** - Community-contributed plugins

### Contributing
- **[Contributing Guide](../CONTRIBUTING.md)** - How to contribute to VeriPDE
- **[Developer Setup](../docs/development.md)** - Setting up development environment
- **[Plugin Development Guide](../docs/plugin_development.md)** - Creating custom validators

## Quick Reference

### Essential Commands
```bash
# Basic validation
veripde validate model.json

# JSON output
veripde validate --output json model.json

# Custom thresholds
veripde validate --thresholds thresholds.json model.json

# Batch processing
veripde validate --batch models/*.json

# Parallel processing
veripde validate --parallel models/*.json

# Audit mode
veripde validate --audit-mode model.json
```

### JSON Schema Template
```json
{
  "model_id": "string",
  "operator": "heat|elasticity|navier_stokes|wave",
  "domain": "unit_square|unit_interval|beam_3d|pipe_flow",
  "parameters": {
    "parameter_name": "value"
  },
  "contracts": [
    {
      "type": "constraint_type",
      "parameters": "constraint_specific"
    }
  ],
  "expected_result": "PASS|WARNING|CRITICAL"
}
```

### Environment Variables
```bash
export VERIPDE_CONFIG_DIR=/path/to/config
export VERIPDE_PLUGIN_PATH=/path/to/plugins
export VERIPDE_PARALLEL_WORKERS=8
export VERIPDE_DEBUG=1
```

You're now ready to use VeriPDE for formal verification of your PDE models! Start with simple examples and gradually explore more advanced features as you become comfortable with the system.