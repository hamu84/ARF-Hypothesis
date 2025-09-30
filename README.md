# ARF-Hypothesis

Preregistration and open-science framework for the **Anthropocene Resonance Framework (ARF)**, including hypotheses, design, and code hooks for RI nowcasting.

---

## What is ARF?

The **Anthropocene Resonance Framework (ARF)** is a hypothesis and design study that seeks to explain abrupt and non-linear climate system changes through resonance processes at the interfaces of atmosphere, ocean, and land.  

It proposes that anthropogenic inputs (aerosols, nanoplastics, greenhouse gases) alter interfacial physics and chemistry, creating *pre-resonant air volumes* that amplify rapid intensification (RI) of tropical cyclones and destabilize large-scale circulation.

ARF is operationalized through:

- Two diagnostic indices (**PCI⋆** and **IRB**)  
- A preregistered falsifiability suite (**T1–T25**)  
- Hooks for implementation in weather/climate models (e.g., **WRF**, **ICON**)  

---

## Files and References

- **Hypothesis & Design Paper** ([Zenodo DOI: 10.5281/zenodo.17235213](https://doi.org/10.5281/zenodo.17235213))  
- **One-pager** (operational decision rule for RI nowcasting)  
- **Preregistration protocol** ([OSF, T1–T25 hypotheses and methods](https://osf.io/r6p93/))  
- **Licenses**:  
  - Text & figures → **CC-BY 4.0**  
  - Code & configs → **MIT License**  

---

## Reproducibility

This repository provides **code hooks, YAML configurations, and Fortran routines** for offline diagnostics and replication of the preregistered analyses.

### To reproduce

1. Review the preregistration protocol (see [OSF registration](https://osf.io/r6p93/)).  
2. Use the provided **YAML/Fortran hooks** with reanalysis data (ERA5, IBTrACS, MODIS/VIIRS, TROPOMI).  
3. Run case-based diagnostics for tropical cyclone RI events (2002–2024).  
4. Compare results against the preregistered pass/fail criteria.  

---

## Reproducibility & Model Integration

This repository provides both **configuration files (YAML)** and **Fortran hooks** that enable reproducible evaluation of the preregistered ARF hypotheses in numerical weather/climate models (**WRF, ICON**).

### 1. YAML Configuration

- `anthropocene_resonance_suite_v1_2.yaml` – defines the preregistered falsifiability suite (T1–T25).  
- `anthropocene_resonance_v3.yml` – defines the operational resonance gates (PCI⋆, IRB thresholds, OLR minima).  

These YAML files specify:  
- Variables required (e.g., ERA5 reanalysis fields, AOD, OLR, OHC).  
- Thresholds and quantiles (e.g., PCI⋆ ≥ Q90, IRB ≥ 0.15 K/day).  
- Analysis windows (Δt = 6–18 h, 100–300 km inflow ring).  
- Pass/fail criteria for each preregistered test.  

### 2. Fortran Hooks

- `wrf_icon_patches_v1_2.F90` – Fortran source code patch for WRF/ICON.  

This module provides:  
- Runtime calculation of ARF indices (PCI⋆, IRB).  
- Integration into the model physics/dynamics loop.  
- Output hooks for writing resonance diagnostics alongside standard model outputs.  

### 3. Workflow

1. Add the Fortran patch (`*.F90`) to your WRF or ICON source tree and recompile.  
2. Configure experiments using the YAML files, which define thresholds and variables.  
3. Run simulations or reanalysis-driven hindcasts.  
4. Compare outcomes against preregistered T1–T25 falsifiability suite.  

### 4. Expected Outcome

By combining YAML configs with the Fortran hooks, other researchers can:  
- Reproduce preregistered tests on archival datasets (ERA5, MODIS/VIIRS, IBTrACS).  
- Integrate ARF resonance indices into operational forecast experiments.  
- Extend the suite for additional basins, time periods, or mechanisms.  

---

## Citation

If you use this work, please cite:

> Hans Mund (2025). *The Anthropocene Resonance Framework (ARF): Hypothesis & Design.* Zenodo. DOI: [10.5281/zenodo.17235213](https://doi.org/10.5281/zenodo.17235213)  

And refer to the [OSF preregistration](https://osf.io/r6p93/) for study protocol and hypotheses.  

---

