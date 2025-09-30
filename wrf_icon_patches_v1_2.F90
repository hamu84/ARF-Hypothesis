!============================================================
!  WRF/ICON Patch Stubs v1.2 — Microplastics (PLF) integrated
!  NOTE: This is a conceptual stub. Actual implementation
!  requires adaptation to the specific model architecture.
!============================================================
MODULE micro_pv_resonance_v12
  IMPLICIT NONE
CONTAINS

  !> Clamps a real value to a specified range [lo, hi].
  PURE FUNCTION clamp(x, lo, hi) RESULT(y)
    REAL, INTENT(IN) :: x, lo, hi
    REAL :: y
    y = MAX(lo, MIN(hi, x))
  END FUNCTION clamp

  !> Calculates the regime-dependent gamma factor for mixed-phase processes.
  !> Positive in moist/LWC-rich, negative in dry/water-limited conditions.
  PURE FUNCTION gamma_regime(T_C, RH, LWC, gamma_max, gamma_min, RH_mid, RH_width, LWC_mid, LWC_width) RESULT(gam)
    REAL, INTENT(IN) :: T_C, RH, LWC
    REAL, INTENT(IN) :: gamma_max, gamma_min, RH_mid, RH_width, LWC_mid, LWC_width
    REAL :: theta_T, theta_RH, theta_LWC, gamma_pos, gamma_neg, gam

    ! Mixed-phase temperature gate (0 at T=0C, 1 at T=-38C)
    theta_T   = clamp((0.0 - T_C)/38.0, 0.0, 1.0)
    ! Moisture and liquid water content scaling factors
    theta_RH  = clamp((RH - RH_mid)/RH_width, 0.0, 1.0)
    theta_LWC = clamp((LWC - LWC_mid)/LWC_width, 0.0, 1.0)

    ! Calculate positive (invigoration) and negative (suppression) terms
    gamma_pos = gamma_max * (0.6*theta_RH + 0.4*theta_LWC) * theta_T
    gamma_neg = gamma_min * (1.0 - theta_RH) * (1.0 - theta_LWC) * theta_T
    gam = gamma_pos - gamma_neg
  END FUNCTION gamma_regime

  !> Computes the total Plastic Load Factor (PLF) profile.
  SUBROUTINE compute_PLF_profiles(AOD_MP_abs, AOD_MP_sca, T_C, RH, LWC, alpha, beta, &
                                  gamma_max, gamma_min, RH_mid, RH_width, LWC_mid, LWC_width, &
                                  Phi_IN_MP, PLF_total)
    REAL, INTENT(IN)  :: AOD_MP_abs(:), AOD_MP_sca(:), T_C(:), RH(:), LWC(:), Phi_IN_MP(:)
    REAL, INTENT(IN)  :: alpha, beta, gamma_max, gamma_min, RH_mid, RH_width, LWC_mid, LWC_width
    REAL, INTENT(OUT) :: PLF_total(:)
    INTEGER :: k, nz
    REAL :: gam
    nz = SIZE(AOD_MP_abs)
    DO k=1,nz
      gam = gamma_regime(T_C(k), RH(k), LWC(k), gamma_max, gamma_min, RH_mid, RH_width, LWC_mid, LWC_width)
      PLF_total(k) = alpha*AOD_MP_abs(k) + beta*AOD_MP_sca(k) + gam*Phi_IN_MP(k)
      PLF_total(k) = clamp(PLF_total(k), -0.8, 1.5)  ! Enforce sane bounds for stability
    END DO
  END SUBROUTINE compute_PLF_profiles

  !> Adds the additional shortwave heating tendency from the micro-PV effect.
  !> Hook for radiation driver (e.g., RRTMG_SW).
  SUBROUTINE add_shortwave_heating_tendency_v12(Iuv_peak, kappa, eta_eff, f_metal, QEF, SWF, FAF, &
                                                rho, cp, z, AOD_MP_abs, AOD_MP_sca, &
                                                theta_tend)
    REAL, INTENT(IN)  :: Iuv_peak, kappa, eta_eff, QEF, SWF, FAF
    REAL, INTENT(IN)  :: rho(:), cp, z(:)
    REAL, INTENT(IN)  :: f_metal(:), AOD_MP_abs(:), AOD_MP_sca(:)
    REAL, INTENT(INOUT) :: theta_tend(:)
    REAL :: I_uv_avg, Qdot_PV, Qdot_PV_MP, S_cluster, adjust
    INTEGER :: k, nz

    nz = SIZE(z)
    I_uv_avg = 0.08 * Iuv_peak * kappa

    DO k=1,nz
      S_cluster   = weight_layer_scalar(z(k), 950.0, 800.0) ! Weighting for aerosol layer
      Qdot_PV     = I_uv_avg * eta_eff * f_metal(k) * QEF * SWF * FAF * S_cluster
      ! Adjust heating based on microplastic optical properties
      adjust      = MAX(0.0, 1.0 + 1.0*AOD_MP_abs(k) - 0.4*AOD_MP_sca(k))   ! alpha=1.0, beta=-0.4
      Qdot_PV_MP  = Qdot_PV * adjust
      theta_tend(k) = theta_tend(k) + Qdot_PV_MP / (rho(k) * cp)
    END DO
    ! NOTE: Apply column cap externally to ensure <=5% of baseline SW heating.
  END SUBROUTINE add_shortwave_heating_tendency_v12

  !> Modifies the autoconversion threshold based on PCI_star to delay warm rain.
  !> Hook for microphysics driver.
  SUBROUTINE microphysics_autoconversion_v12(qc, qc_crit, PCI, PLF_total_avg, lambda, autoconvert_flag)
    REAL, INTENT(IN) :: qc, qc_crit, PCI, PLF_total_avg, lambda
    LOGICAL, INTENT(OUT) :: autoconvert_flag
    REAL :: PCI_star, qc_crit_prime
    PCI_star       = PCI * (1.0 + PLF_total_avg)
    qc_crit_prime  = qc_crit * (1.0 + lambda * PCI_star)
    autoconvert_flag = (qc > qc_crit_prime)
  END SUBROUTINE microphysics_autoconversion_v12

  !> Helper function to apply a triangular weighting profile for a specific atmospheric layer.
  PURE FUNCTION weight_layer_scalar(z_hPa, z_bot, z_top) RESULT(w)
    REAL, INTENT(IN) :: z_hPa, z_bot, z_top
    REAL :: mid, half, w
    mid  = 0.5*(z_bot + z_top)
    half = 0.5*ABS(z_bot - z_top)
    IF (z_hPa >= z_top .AND. z_hPa <= z_bot) THEN
      w = 1.0 - ABS(z_hPa - mid)/half
    ELSE
      w = 0.0
    END IF
  END FUNCTION weight_layer_scalar

END MODULE micro_pv_resonance_v12
