# ARF-Hypothesis
Preregistration and open-science framework for the Anthropocene Resonance Framework (ARF), including hypotheses, design, and code hooks for RI nowcasting.
Anthropocene Resonance Framework (ARF)
What is ARF?

The Anthropocene Resonance Framework (ARF) is a hypothesis and design study that seeks to explain abrupt and non-linear climate system changes through resonance processes at the interfaces of atmosphere, ocean, and land.
It proposes that anthropogenic inputs (aerosols, nanoplastics, greenhouse gases) alter interfacial physics and chemistry, creating pre-resonant air volumes that amplify rapid intensification (RI) of tropical cyclones and destabilize large-scale circulation.

ARF is operationalized through:

Two diagnostic indices (PCI⋆ and IRB)

A preregistered falsifiability suite (T1–T25)

Hooks for implementation in weather/climate models (e.g., WRF, ICON)

Files and References

Hypothesis & Design Paper (Zenodo DOI: 10.5281/zenodo.17235213
)

One-pager (operational decision rule for RI nowcasting)

Preregistration protocol (OSF, T1–T25 hypotheses and methods)

Licenses:

Text & figures → CC-BY 4.0

Code & configs → MIT License

Reproducibility

This repository provides code hooks, YAML configurations, and Fortran routines for offline diagnostics and replication of the preregistered analyses.

To reproduce:

Review the preregistration protocol (see OSF registration).

Use the provided YAML/Fortran hooks with reanalysis data (ERA5, IBTrACS, MODIS/VIIRS, TROPOMI).

Run case-based diagnostics for tropical cyclone RI events (2002–2024).

Compare results against the preregistered pass/fail criteria.

Citation

If you use this work, please cite:

Hans Mund (2025). The Anthropocene Resonance Framework (ARF): Hypothesis & Design. Zenodo. DOI: 10.5281/zenodo.17235213

And refer to the OSF preregistration for study protocol and hypotheses.
