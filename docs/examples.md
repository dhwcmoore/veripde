# VeriPDE Examples Guide

This guide showcases the 7 validated test models that demonstrate VeriPDE's capabilities across different PDE domains and constraint scenarios.

## Overview of Test Models

| Model Name | Domain | PDE Type | Key Parameters | Status | Use Case |
|------------|--------|----------|----------------|--------|-----------|
| `basic_valid` | Unit Square | Heat | mass, temperature | ✅ PASS | Basic validation |
| `basic_invalid` | Unit Square | Heat | negative mass, high temp | ❌ CRITICAL | Error detection |
| `heat_equation_valid` | Unit Square | Heat | thermal properties | ✅ PASS | Thermal analysis |
| `heat_equation_temp_violation` | Unit Square | Heat | excessive temperature | ⚠️ WARNING | Operational limits |
| `elasticity_critical_failure` | 3D Beam | Elasticity | negative mass, stress | ❌ CRITICAL | Structural analysis |
| `cfd_pressure_failure` | Pipe Flow | Navier-Stokes | negative pressure | ❌ CRITICAL | Fluid dynamics |
| `wave_equation_perfect` | Unit Interval | Wave | acoustic properties | ✅ PASS | Wave propagation |

## 1. Basic Validation Examples

### 1.1 Basic Valid Model
**File**: `examples/basic_valid.json`

This demonstrates fundamental constraint validation with physical parameters.

```json
{
  "model_id": "basic_valid",
  "operator": "heat",
  "domain": {
    "type": "unit_square",
    "dimensions": [1.0, 1.0]
  },
  "parameters": {
    "mass": 1.000,
    "temperature": 25.000
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
      "warning_threshold": 400.0
    }
  ],
  "expected_result": "PASS"
}
```

**Validation Output**:
```
=== Model: basic_valid ===
Parameter Validation:
✅ mass = 1.000 | ✔ mass valid
✅ temperature = 25.000 | ✔ temperature in range
Overall Status: ✅ PASS ✅ (matches expected)
```

**Learning Points**:
- Mass validation ensures physical reality (mass > 0.001 kg)
- Temperature range checking with operational limits
- All constraints satisfied, model is ready for simulation

### 1.2 Basic Invalid Model
**File**: `examples/basic_invalid.json`

This demonstrates critical failure detection for physically impossible parameters.

```json
{
  "model_id": "basic_invalid",
  "operator": "heat",
  "domain": {
    "type": "unit_square"
  },
  "parameters": {
    "mass": -0.500,
    "temperature": 600.000
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
      "warning_threshold": 400.0
    }
  ],
  "expected_result": "CRITICAL"
}
```

**Validation Output**:
```
=== Model: basic_invalid ===
Parameter Validation:
❌ mass = -0.500 | ❌ mass invalid (≤ 0.001)
⚠️ temperature = 600.000 | ⚠️ temperature > max
Overall Status: ❌ CRITICAL ❌ (matches expected)
```

**Learning Points**:
- Negative mass triggers CRITICAL failure (physically impossible)
- Temperature exceeds maximum threshold (operational concern)
- System correctly identifies fundamental vs operational issues

## 2. Heat Transfer Applications

### 2.1 Valid Heat Equation Model
**File**: `examples/heat_equation_valid.json`

This shows thermal analysis validation with comprehensive thermal properties.

```json
{
  "model_id": "heat_equation_valid",
  "operator": "heat",
  "domain": {
    "type": "unit_square",
    "mesh_size": 0.01
  },
  "parameters": {
    "mass": 2.5,
    "temperature": 85.0,
    "thermal_conductivity": 0.6,
    "specific_heat": 4180.0,
    "density": 1000.0
  },
  "contracts": [
    {
      "type": "mass_validation",
      "threshold": 0.001
    },
    {
      "type": "temperature_range",
      "min_value": 0.0,
      "max_value": 500.0,
      "warning_threshold": 100.0
    },
    {
      "type": "thermal_conductivity_range",
      "min_value": 0.1,
      "max_value": 500.0
    },
    {
      "type": "material_properties_consistency"
    }
  ],
  "expected_result": "PASS"
}
```

**Real-World Application**: Industrial heat exchanger design, building thermal analysis, electronic cooling systems.

### 2.2 Temperature Violation Model
**File**: `examples/heat_equation_temp_violation.json`

This demonstrates warning-level violations that don't prevent operation but indicate operational concerns.

```json
{
  "model_id": "heat_equation_temp_violation",
  "operator": "heat",
  "domain": {
    "type": "unit_square"
  },
  "parameters": {
    "mass": 1.8,
    "temperature": 550.0,
    "thermal_conductivity": 0.4
  },
  "contracts": [
    {
      "type": "temperature_range",
      "min_value": 0.0,
      "max_value": 500.0,
      "warning_threshold": 400.0
    }
  ],
  "expected_result": "WARNING"
}
```

**Validation Output**:
```
=== Model: heat_equation_temp_violation ===
Parameter Validation:
⚠️ temperature = 550.000 | ⚠️ temperature > max (500.0°C)
Overall Status: ⚠️ WARNING ⚠️ (matches expected)
```

**Learning Points**:
- Temperature exceeds safe operational limit but isn't physically impossible
- WARNING status allows simulation to proceed with caution
- Useful for exploring operational boundaries

## 3. Structural Mechanics Applications

### 3.1 Elasticity Critical Failure
**File**: `examples/elasticity_critical_failure.json`

This demonstrates structural analysis with fundamental violations.

```json
{
  "model_id": "elasticity_critical_failure",
  "operator": "elasticity",
  "domain": {
    "type": "beam_3d",
    "length": 2.0,
    "cross_section": "rectangular"
  },
  "parameters": {
    "mass": -1.2,
    "elastic_modulus": 200e9,
    "poisson_ratio": 0.3,
    "applied_load": 5000.0,
    "displacement": 0.15
  },
  "contracts": [
    {
      "type": "mass_validation",
      "threshold": 0.001
    },
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
  ],
  "expected_result": "CRITICAL"
}
```

**Validation Output**:
```
=== Model: elasticity_critical_failure ===
Parameter Validation:
❌ mass = -1.200 | ❌ mass invalid (≤ 0.001)
✅ elastic_modulus = 2.000e+11 | ✔ modulus in range
✅ poisson_ratio = 0.300 | ✔ ratio valid
⚠️ displacement = 0.150 | ⚠️ displacement > max (0.1m)
Overall Status: ❌ CRITICAL ❌ (matches expected)
```

**Real-World Application**: Bridge design, building structural analysis, mechanical component validation.

**Learning Points**:
- Multiple constraint types can be validated simultaneously
- Negative mass causes critical failure despite valid material properties
- Displacement warning is superseded by critical mass failure

## 4. Fluid Dynamics Applications

### 4.1 CFD Pressure Failure
**File**: `examples/cfd_pressure_failure.json`

This demonstrates fluid dynamics validation with pressure consistency checks.

```json
{
  "model_id": "cfd_pressure_failure",
  "operator": "navier_stokes",
  "domain": {
    "type": "pipe_flow",
    "diameter": 0.1,
    "length": 1.0
  },
  "parameters": {
    "density": 1000.0,
    "viscosity": 0.001,
    "inlet_velocity": 3.0,
    "pressure": -50000.0,
    "reynolds_number": 300000
  },
  "contracts": [
    {
      "type": "pressure_validation",
      "min_value": 0.0
    },
    {
      "type": "reynolds_number_check",
      "min_reynolds": 100,
      "max_reynolds": 1000000
    },
    {
      "type": "velocity_bounds",
      "max_velocity": 10.0
    }
  ],
  "expected_result": "CRITICAL"
}
```

**Validation Output**:
```
=== Model: cfd_pressure_failure ===
Parameter Validation:
❌ pressure = -50000.000 | ❌ pressure invalid (< 0.0 Pa)
✅ reynolds_number = 300000.000 | ✔ Reynolds number valid
✅ inlet_velocity = 3.000 | ✔ velocity in bounds
Overall Status: ❌ CRITICAL ❌ (matches expected)
```

**Real-World Application**: Pipeline flow analysis, pump design, HVAC systems, chemical process engineering.

**Learning Points**:
- Negative pressure is physically impossible in most fluid systems
- Reynolds number and velocity constraints are satisfied
- Critical failures prevent unsafe simulation attempts

## 5. Wave Propagation Applications

### 5.1 Perfect Wave Equation
**File**: `examples/wave_equation_perfect.json`

This demonstrates acoustic/electromagnetic wave validation.

```json
{
  "model_id": "wave_equation_perfect",
  "operator": "wave",
  "domain": {
    "type": "unit_interval",
    "length": 1.0,
    "boundary_conditions": "reflecting"
  },
  "parameters": {
    "wave_speed": 343.0,
    "frequency": 1000.0,
    "amplitude": 0.1,
    "medium_density": 1.225,
    "bulk_modulus": 142000.0
  },
  "contracts": [
    {
      "type": "wave_speed_validation",
      "min_speed": 100.0,
      "max_speed": 10000.0
    },
    {
      "type": "frequency_range",
      "min_frequency": 1.0,
      "max_frequency": 100000.0
    },
    {
      "type": "amplitude_bounds",
      "max_amplitude": 1.0
    },
    {
      "type": "medium_properties_consistency"
    }
  ],
  "expected_result": "PASS"
}
```

**Validation Output**:
```
=== Model: wave_equation_perfect ===
Parameter Validation:
✅ wave_speed = 343.000 | ✔ speed valid (air at 20°C)
✅ frequency = 1000.000 | ✔ frequency in range
✅ amplitude = 0.100 | ✔ amplitude bounded
✅ medium_density = 1.225 | ✔ density consistent
Overall Status: ✅ PASS ✅ (matches expected)
```

**Real-World Application**: Acoustic modeling, seismic analysis, electromagnetic wave propagation, musical instrument design.

**Learning Points**:
- Wave speed consistent with air at 20°C (343 m/s)
- All acoustic parameters within physical ranges
- Medium property consistency ensures realistic wave propagation

## 6. Running the Complete Test Suite

### 6.1 Basic Test Execution
```bash
# Run all examples
veripde validate examples/*.json

# Run with detailed output
veripde validate --verbose examples/*.json

# Generate JSON report
veripde validate --output json examples/*.json > test_results.json
```

### 6.2 Filtering by Model Type
```bash
# Only heat transfer models
veripde validate examples/heat_*.json

# Only failure cases
veripde validate examples/*_failure.json examples/*_invalid.json

# Only passing models
veripde validate examples/basic_valid.json examples/heat_equation_valid.json examples/wave_equation_perfect.json
```

### 6.3 Performance Testing
```bash
# Parallel execution
veripde validate --parallel examples/*.json

# Benchmark mode
veripde validate --benchmark examples/*.json

# Memory profiling
veripde validate --profile examples/*.json
```

## 7. Creating Your Own Examples

### 7.1 Model Template
```json
{
  "model_id": "your_model_name",
  "operator": "heat|elasticity|navier_stokes|wave|custom",
  "domain": {
    "type": "domain_type",
    "parameters": "domain_specific"
  },
  "parameters": {
    "param1": "value1",
    "param2": "value2"
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

### 7.2 Best Practices for Example Creation

**Physical Realism**:
- Use realistic parameter values from your domain
- Include units in comments for clarity
- Validate against known solutions when possible

**Constraint Coverage**:
- Test both positive and negative cases
- Include boundary conditions where appropriate
- Test parameter interactions

**Documentation**:
- Include comments explaining the physical scenario
- Document expected behavior
- Provide references for parameter values

### 7.3 Example Validation Checklist
```bash
# 1. JSON syntax validation
python -m json.tool your_model.json

# 2. Schema validation
veripde validate --check-schema your_model.json

# 3. Constraint verification
veripde validate --explain your_model.json

# 4. Performance check
veripde validate --benchmark your_model.json
```

## 8. Domain-Specific Example Collections

### 8.1 Aerospace Examples
- High-temperature structural analysis
- Supersonic flow validation
- Thermal protection system modeling

### 8.2 Oil & Gas Examples
- Reservoir flow modeling
- Pipeline pressure analysis
- Thermal enhanced oil recovery

### 8.3 Nuclear Engineering Examples
- Reactor thermal hydraulics
- Neutron diffusion validation
- Safety system modeling

### 8.4 Civil Engineering Examples
- Bridge structural analysis
- Foundation settlement modeling
- Earthquake response simulation

These examples provide a comprehensive foundation for understanding VeriPDE's capabilities and can be extended for domain-specific applications. Each example demonstrates different aspects of constraint validation and provides insight into real-world PDE modeling challenges.