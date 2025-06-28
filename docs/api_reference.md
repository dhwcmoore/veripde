# VeriPDE API Reference

## Overview

VeriPDE provides both command-line and programmatic interfaces for PDE constraint validation. This document covers all available APIs, JSON schemas, and integration patterns.

## Command-Line Interface

### Basic Validation
```bash
dune exec bin/validator_main.exe <input_file.json>
```

**Example**:
```bash
dune exec bin/validator_main.exe examples/simple_validation_test.json
```

### Advanced Options
```bash
dune exec bin/validator_main.exe [OPTIONS] <input_file.json>

Options:
  --thresholds FILE    Custom threshold configuration file
  --output FORMAT      Output format: text|json|xml (default: text)
  --verbose            Enable detailed validation reporting
  --parallel           Enable parallel constraint validation
  --audit-mode         Generate audit-ready documentation
  --help               Show this help message
```

**Examples**:
```bash
# Custom thresholds with JSON output
dune exec bin/validator_main.exe \
  --thresholds config/custom_thresholds.json \
  --output json \
  examples/complex_model.json

# Audit mode with verbose output
dune exec bin/validator_main.exe \
  --audit-mode \
  --verbose \
  examples/regulatory_compliance.json
```

## JSON Input Schema

### Basic Model Structure
```json
{
  "model_id": "string",
  "operator": "heat|elasticity|navier_stokes|wave|custom",
  "domain": {
    "type": "string",
    "geometry": "object"
  },
  "parameters": {
    "parameter_name": "value"
  },
  "contracts": [
    "constraint_object"
  ],
  "expected_result": "PASS|WARNING|CRITICAL"
}
```

### Domain Specification
```json
{
  "domain": {
    "type": "unit_square|unit_interval|beam_3d|pipe_flow|custom",
    "dimensions": [1.0, 1.0],
    "mesh_size": 0.01,
    "boundary_markers": {
      "inlet": 1,
      "outlet": 2,
      "walls": 3
    }
  }
}
```

### Parameter Types
```json
{
  "parameters": {
    "mass": 1.5,                    // kg
    "temperature": 25.0,            // celsius
    "pressure": 101325.0,           // Pa
    "displacement": 0.05,           // m
    "velocity": [1.0, 0.0, 0.0],   // m/s vector
    "density": 1000.0,              // kg/m³
    "viscosity": 0.001,             // Pa·s
    "thermal_conductivity": 0.6,    // W/(m·K)
    "elastic_modulus": 200e9,       // Pa
    "poisson_ratio": 0.3            // dimensionless
  }
}
```

### Constraint Specification
```json
{
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
      "warning_threshold": 400.0
    },
    {
      "type": "pressure_validation",
      "min_value": 0.0
    },
    {
      "type": "displacement_bounds",
      "max_displacement": 0.1
    }
  ]
}
```

## Threshold Configuration

### Default Thresholds
```json
{
  "temperature": {
    "max": 500.0,
    "warning": 400.0,
    "units": "celsius"
  },
  "displacement": {
    "max": 0.100,
    "units": "meters"
  },
  "pressure": {
    "min": 0.0,
    "warning": 100.0,
    "units": "pascals"
  },
  "mass": {
    "min": 0.001,
    "units": "kg"
  }
}
```

### Custom Threshold Configuration
```json
{
  "domain_specific": {
    "oil_gas": {
      "temperature": {"max": 200.0, "warning": 150.0},
      "pressure": {"min": 0.0, "max": 10000000.0}
    },
    "aerospace": {
      "temperature": {"max": 1500.0, "warning": 1200.0},
      "stress": {"max": 500000000.0, "warning": 400000000.0}
    }
  }
}
```

## Programmatic API (OCaml)

### Core Validation Functions
```ocaml
(* Load and validate a model from JSON *)
val validate_model_from_json : string -> validation_result

(* Validate with custom thresholds *)
val validate_with_thresholds : model -> thresholds -> validation_result

(* Batch validation *)
val validate_batch : model list -> validation_result list
```

### Type Definitions
```ocaml
type model = {
  name : string;
  model_type : model_type;
  domain : domain_spec;
  parameters : (string * parameter_value) list;
  constraints : constraint_spec list;
  expected : validation_status option;
}

type validation_result = {
  model_name : string;
  overall_status : validation_status;
  parameter_results : parameter_validation list;
  constraint_results : constraint_validation list;
  execution_time : float;
  timestamp : string;
}

type validation_status = PASS | WARNING | CRITICAL

type parameter_validation = {
  parameter_name : string;
  value : parameter_value;
  status : validation_status;
  message : string;
  details : string option;
}
```

### Example OCaml Usage
```ocaml
open Veripde.Validation

let () =
  let model_file = "examples/heat_equation.json" in
  let result = validate_model_from_json model_file in
  match result.overall_status with
  | PASS -> Printf.printf "✅ Model validation passed\n"
  | WARNING -> Printf.printf "⚠️ Model validation passed with warnings\n"
  | CRITICAL -> Printf.printf "❌ Model validation failed\n"
```

## Output Formats

### Text Output (Default)
```
🧪 VeriPDE Contract Validation System
====================================
Using thresholds: temp=500.0, disp=0.100, pressure=100.0, mass=0.001

[Test 1/1]=== Model: heat_equation_valid ===
Parameter Validation:
✅ mass = 1.000 | ✔ mass valid
✅ temperature = 25.000 | ✔ temperature in range
Overall Status: ✅ PASS ✅ (matches expected)

Validation Summary:
- Total models: 1
- Passed: 1
- Warnings: 0  
- Critical failures: 0
```

### JSON Output
```json
{
  "validation_session": {
    "timestamp": "2025-06-28T14:30:00Z",
    "veripde_version": "0.1.0",
    "total_models": 1,
    "summary": {
      "passed": 1,
      "warnings": 0,
      "critical": 0
    }
  },
  "results": [
    {
      "model_id": "heat_equation_valid",
      "overall_status": "PASS",
      "execution_time": 0.002,
      "parameter_validations": [
        {
          "parameter": "mass",
          "value": 1.0,
          "status": "PASS",
          "message": "mass valid",
          "constraint_type": "mass_validation"
        },
        {
          "parameter": "temperature", 
          "value": 25.0,
          "status": "PASS",
          "message": "temperature in range",
          "constraint_type": "temperature_range"
        }
      ]
    }
  ]
}
```

### XML Output (Audit Mode)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<veripde_validation_report>
  <session>
    <timestamp>2025-06-28T14:30:00Z</timestamp>
    <version>0.1.0</version>
    <audit_mode>true</audit_mode>
  </session>
  <model name="heat_equation_valid">
    <overall_status>PASS</overall_status>
    <execution_time>0.002</execution_time>
    <parameter name="mass" value="1.0" status="PASS" message="mass valid"/>
    <parameter name="temperature" value="25.0" status="PASS" message="temperature in range"/>
  </model>
</veripde_validation_report>
```

## Plugin System API

### Plugin Interface
```ocaml
module type VALIDATION_PLUGIN = sig
  type plugin_config
  type plugin_result
  
  val name : string
  val version : string
  val description : string
  
  val validate : plugin_config -> model -> plugin_result
  val supported_constraints : string list
end
```

### Custom Plugin Example
```ocaml
module My_Custom_Validator : VALIDATION_PLUGIN = struct
  type plugin_config = {
    custom_threshold : float;
    enable_advanced_checks : bool;
  }
  
  type plugin_result = {
    status : validation_status;
    message : string;
    metadata : (string * string) list;
  }
  
  let name = "my_custom_validator"
  let version = "1.0.0"
  let description = "Custom domain-specific validation"
  
  let validate config model =
    (* Custom validation logic *)
    { status = PASS; message = "Custom validation passed"; metadata = [] }
    
  let supported_constraints = ["custom_constraint_1"; "custom_constraint_2"]
end
```

## Error Handling

### Error Types
```ocaml
type validation_error =
  | Parse_Error of string
  | Invalid_Model of string
  | Constraint_Error of string * string
  | Threshold_Error of string
  | Plugin_Error of string * string
  | System_Error of string
```

### Error Response Format
```json
{
  "error": {
    "type": "Parse_Error",
    "message": "Invalid JSON syntax at line 15",
    "details": "Expected ',' after parameter definition",
    "suggestions": [
      "Check JSON syntax using a validator",
      "Ensure all string values are quoted",
      "Verify bracket and brace matching"
    ]
  }
}
```

## Integration Examples

### CI/CD Integration
```yaml
# .github/workflows/validation.yml
name: PDE Model Validation
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install VeriPDE
        run: opam install veripde
      - name: Validate Models
        run: |
          for model in models/*.json; do
            veripde-validate --output json "$model"
          done
```

### Python Integration
```python
import subprocess
import json

def validate_pde_model(model_file):
    """Validate a PDE model using VeriPDE"""
    result = subprocess.run([
        'dune', 'exec', 'bin/validator_main.exe',
        '--output', 'json',
        model_file
    ], capture_output=True, text=True)
    
    if result.returncode == 0:
        return json.loads(result.stdout)
    else:
        raise Exception(f"Validation failed: {result.stderr}")

# Usage
try:
    validation_result = validate_pde_model('model.json')
    print(f"Status: {validation_result['results'][0]['overall_status']}")
except Exception as e:
    print(f"Error: {e}")
```

This API reference provides complete integration guidance for both command-line usage and programmatic access to VeriPDE's validation capabilities.