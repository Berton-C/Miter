; AMA-1.1 bootstrap. Service membranes are added only after native operators
; have been syntax-checked and frozen. Relative imports are resolved from the
; repository working directory by the supported launcher.
!(import! &self (library lib_import))
!(import! &soul "./constitution/soul.metta")
!(import! &fact9 "./constitution/fact9_projection_v1.metta")
!(import! &compass "./constitution/soul_compass_v02.metta")
!(import! &self "./src/soul.metta")
!(import! &self "./src/constitutive_participation_v1.metta")
