# VeriPDE Constraint Types Reference

## Overview

This document catalogs all constraint types supported by VeriPDE, their mathematical definitions, validation criteria, and usage examples.

## Physical Parameter Constraints

### Mass Validation
**Mathematical Definition**: Ensures mass values are physically meaningful
```json
{
  "constraint_type": "mass_validation",
  "parameter": "mass",
  "threshold": 0.001,
  "units": "kg"
}
```

**Validation Logic**:
- **PASS**: mass > threshold
- **CRITICAL**: mass ≤ threshold (physically impossible)

**Example Usage**:
```json
{
  "model_id": "fluid_flow_validation",
  "parameters": {
    "mass": 1.500
  },
  "contracts": [
    {
      "type": "mass_validation",
      "threshold": 0.001,
      "severity": "CRITICAL"
    }
  ]
}
```

### Temperature Range Validation
**Mathematical Definition**: Validates temperature within specified operational bounds
```json
{
  "constraint_type": "temperature_range",
  "parameter": "temperature", 
  "min_value": 0.0,
  "max_value": 500.0,
  "units": "celsius"
}
```

**Validation Logic**:
- **PASS**: min_value ≤ temperature ≤ max_value
- **WARNING**: temperature > max_value (operational concern)
- **CRITICAL**: temperature < min_value (physical impossibility for most applications)

**Example Usage**:
```json
{
  "model_id": "thermal_analysis",
  "parameters": {
    "temperature": 450.0
  },
  "contracts": [
    {
      "type": "temperature_range",
      "min_value": 0.0,
      "max_value": 500.0,
      "warning_threshold": 400.0
    }
  ]
}
```

### Pressure Validation
**Mathematical Definition**: Ensures pressure values are non-negative and within operational limits
```json
{
  "constraint_type": "pressure_validation",
  "parameter": "pressure",
  "min_value": 0.0,
  "max_value": null,
  "units": "Pa"
}
```

**Validation Logic**:
- **PASS**: pressure ≥ 0
- **CRITICAL**: pressure < 0 (physically impossible for most systems)
- **WARNING**: pressure > operational_threshold (if specified)

### Displacement Bounds
**Mathematical Definition**: Validates mechanical displacement within structural limits
```json
{
  "constraint_type": "displacement_bounds",
  "parameter": "displacement",
  "max_displacement": 0.1,
  "units": "m"
}
```

**Validation Logic**:
- **PASS**: |displacement| ≤ max_displacement
- **WARNING**: |displacement| > max_displacement (structural concern)

## Boundary Condition Constraints

### Dirichlet Boundary Consistency
**Mathematical Definition**: Ensures Dirichlet boundary conditions are mathematically consistent
```json
{
  "constraint_type": "dirichlet_consistency",
  "boundary_conditions": [
    {"location": "x=0", "value": 0.0},
    {"location": "x=1", "value": 1.0}
  ]
}
```

**Validation Logic**:
- **PASS**: No contradictory values at same boundary point
- **CRITICAL**: Conflicting values specified for same location

### Neumann Boundary Validation
**Mathematical Definition**: Validates flux boundary conditions for physical consistency
```json
{
  "constraint_type": "neumann_validation", 
  "boundary_fluxes": [
    {"location": "boundary_1", "flux": 0.5},
    {"location": "boundary_2", "flux": -0.3}
  ]
}
```

**Validation Logic**:
- **PASS**: Net flux satisfies conservation requirements
- **WARNING**: Flux imbalance may indicate modeling issues

### Mixed Boundary Compatibility
**Mathematical Definition**: Ensures mixed (Robin) boundary conditions are well-posed
```json
{
  "constraint_type": "robin_compatibility",
  "robin_conditions": [
    {"alpha": 1.0, "beta": 0.5, "gamma": 2.0}
  ]
}
```

**Validation Logic**:
- **PASS**: Coefficients satisfy well-posedness conditions (α > 0, β ≥ 0)
- **CRITICAL**: Coefficients lead to ill-posed problems

## Domain and Geometry Constraints

### Domain Validity
**Mathematical Definition**: Ensures computational domain is geometrically valid
```json
{
  "constraint_type": "domain_validity",
  "domain": {
    "type": "rectangle",
    "dimensions": [1.0, 1.0],
    "mesh_size": 0.01
  }
}
```

**Validation Logic**:
- **PASS**: Domain has positive measure, mesh size appropriate
- **CRITICAL**: Degenerate domain or invalid mesh parameters

### Mesh Quality Constraints
**Mathematical Definition**: Validates computational mesh quality metrics
```json
{
  "constraint_type": "mesh_quality",
  "quality_metrics": {
    "aspect_ratio_max": 10.0,
    "skewness_max": 0.8,
    "orthogonality_min": 0.1
  }
}
```

**Validation Logic**:
- **PASS**: All quality metrics within acceptable ranges
- **WARNING**: Some metrics exceed recommended values
- **CRITICAL**: Mesh quality may compromise solution accuracy

## Time-Dependent Constraints

### Temporal Stability
**Mathematical Definition**: Ensures time-stepping parameters satisfy stability conditions
```json
{
  "constraint_type": "temporal_stability",
  "time_step": 0.001,
  "cfl_condition": {
    "max_velocity": 10.0,
    "mesh_size": 0.01,
    "cfl_number": 0.5
  }
}
```

**Validation Logic**:
- **PASS**: CFL condition satisfied for stability
- **WARNING**: CFL number close to stability limit
- **CRITICAL**: Time step violates stability requirements

### Initial Condition Consistency
**Mathematical Definition**: Validates initial conditions are compatible with boundary conditions
```json
{
  "constraint_type": "initial_consistency",
  "initial_values": [1.0, 0.5, 0.0],
  "boundary_values": [1.0, 0.0]
}
```

**Validation Logic**:
- **PASS**: Initial and boundary conditions are consistent
- **WARNING**: Minor inconsistencies that may cause transients
- **CRITICAL**: Major inconsistencies leading to ill-posed problems

## Composite Constraint Validation

### Multi-Parameter Consistency
**Mathematical Definition**: Validates relationships between multiple parameters
```json
{
  "constraint_type": "multi_parameter_consistency",
  "relationships": [
    {
      "type": "reynolds_number",
      "velocity": 5.0,
      "density": 1000.0,
      "viscosity": 0.001,
      "length_scale": 0.1,
      "expected_range": [5000, 50000]
    }
  ]
}
```

**Validation Logic**:
- **PASS**: Derived quantities within expected ranges
- **WARNING**: Unusual parameter combinations
- **CRITICAL**: Physically inconsistent parameter relationships

### Conservation Law Validation
**Mathematical Definition**: Ensures parameter sets satisfy fundamental conservation laws
```json
{
  "constraint_type": "conservation_validation",
  "conservation_laws": [
    {
      "type": "mass_conservation",
      "inflow": 10.0,
      "outflow": 9.8,
      "accumulation": 0.2,
      "tolerance": 0.01
    }
  ]
}
```

**Validation Logic**:
- **PASS**: Conservation laws satisfied within tolerance
- **WARNING**: Small conservation violations
- **CRITICAL**: Major violations of fundamental physical laws

## Constraint Composition and Hierarchies

### Constraint Dependencies
Some constraints depend on others being satisfied first:
1. **Physical Parameters** (mass, temperature, pressure) - validated first
2. **Boundary Conditions** - validated after parameters
3. **Domain Properties** - validated after boundary conditions
4. **Composite Relationships** - validated last

### Severity Propagation
- **CRITICAL** constraints block all subsequent validation
- **WARNING** constraints are noted but don't prevent further validation
- **PASS** constraints enable dependent constraint checking

### Custom Constraint Definition
VeriPDE supports user-defined constraints through the plugin system:
```json
{
  "constraint_type": "custom",
  "plugin": "my_custom_validator",
  "parameters": {
    "custom_param_1": 5.0,
    "custom_param_2": "user_defined"
  }
}
```

This extensible framework allows domain experts to add specialized validation logic while maintaining the mathematical rigor of the core system.