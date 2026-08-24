-- v3.2.0 Part 2c: All JEE and NEET science topics

-- JEE MAIN: Circular Motion
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000140-0000-0000-0000-000000000001', 'Uniform Circular Motion', 'Centripetal acceleration = v^2/r = w^2*r. Directed towards center. Period T = 2*pi*r/v = 2*pi/w.', 1),
('aa000140-0000-0000-0000-000000000001', 'Non-Uniform Circular Motion', 'Total acceleration has centripetal (v^2/r) and tangential (dv/dt) components. Banking: tan(theta) = v^2/rg.', 2);

-- JEE MAIN: Gravitation
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000141-0000-0000-0000-000000000001', 'Universal Law of Gravitation', 'F = GMm/r^2. G = 6.674x10^-11. g = GM/r^2. Escape v = sqrt(2gR). Orbital v = sqrt(gR).', 1),
('aa000141-0000-0000-0000-000000000001', 'Keplers Laws', 'Elliptical orbits. Equal areas in equal times. T^2 proportional to a^3.', 2);

-- JEE MAIN: Rotational Motion
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000142-0000-0000-0000-000000000001', 'Moment of Inertia', 'I = sum(mi*ri^2). Parallel axis: I = Icm+Md^2. Perpendicular: Iz = Ix+Iy.', 1),
('aa000142-0000-0000-0000-000000000001', 'Angular Momentum', 'L = Iw = mvr. Torque = dL/dt. Conservation if net torque = 0.', 2);

-- JEE MAIN: Properties of Solids and Liquids
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000143-0000-0000-0000-000000000001', 'Elastic Moduli', 'Youngs Y = stress/strain. Bulk B = -V(dP/dV). Shear G = F/A/tan(theta). B > Y > G.', 1),
('aa000143-0000-0000-0000-000000000001', 'Fluid Statics', 'P = rho*g*h. Buoyancy = weight displaced fluid. Archimedes: Fb = rho_fluid*V*g.', 2);

-- JEE MAIN: Laws of Thermodynamics
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000148-0000-0000-0000-000000000001', 'First Law of Thermodynamics', 'dQ = dU + dW. Isothermal: dU=0, dQ=dW. Adiabatic: dQ=0, dU=-dW. Isobaric: W=P(V2-V1).', 1),
('aa000148-0000-0000-0000-000000000001', 'Second Law and Carnot', 'Entropy increases. Carnot efficiency = 1-Tcold/Thot. Reversible: no entropy change.', 2),
('aa000148-0000-0000-0000-000000000001', 'Entropy Changes', 'dS = dQrev/T. Isothermal: dS=nRln(V2/V1). Adiabatic reversible: dS=0.', 3);

-- JEE MAIN: Heat Transfer
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000149-0000-0000-0000-000000000001', 'Conduction Fourier Law', 'dQ/dt = -kA(dT/dx). Composite wall: same heat current. R = L/kA.', 1),
('aa000149-0000-0000-0000-000000000001', 'Convection and Radiation', 'Newton cooling: dQ/dt=hA(T-Tenv). Stefan-Boltzmann: P=e*sigma*A*T^4.', 2);

-- JEE MAIN: Kinetic Theory of Gases
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000150-0000-0000-0000-000000000001', 'Ideal Gas Equation', 'PV=nRT=NkT. Avg KE = (3/2)kT. VRMS = sqrt(3RT/M).', 1),
('aa000150-0000-0000-0000-000000000001', 'Degrees of Freedom', 'Monatomic: 3. Diatomic at room: 5. Cv=(f/2)R. Cp=Cv+R. Gamma=Cp/Cv.', 2);

-- JEE MAIN: Electrostatics
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000151-0000-0000-0000-000000000001', 'Coulombs Law', 'F = kQq/r^2. k=9x10^9. E = F/q = kQ/r^2. Superposition: vector sum.', 1),
('aa000151-0000-0000-0000-000000000001', 'Gauss Law', 'Flux = Qenc/eps0. Spherical: E=kQr/R^3 inside, kQ/r^2 outside.', 2),
('aa000151-0000-0000-0000-000000000001', 'Capacitance', 'C=Q/V. Parallel: C=eps0A/d. Series: 1/C=sum(1/Ci). U=(1/2)CV^2.', 3);

-- JEE MAIN: Current Electricity
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000152-0000-0000-0000-000000000001', 'Ohms Law and Circuits', 'V=IR. Series: R=R1+R2. Parallel: 1/R=1/R1+1/R2. P=VI=I^2R=V^2/R.', 1),
('aa000152-0000-0000-0000-000000000001', 'Wheatstone Bridge', 'Balanced when R1/R2=R3/R4. No galvanometer current. Meter bridge for unknown R.', 2);

-- JEE MAIN: Magnetic Effects of Current
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000153-0000-0000-0000-000000000001', 'Biot-Savart Law', 'dB = (mu0/4pi)*Idlxr^2/r^3. Loop center: B=mu0I/2R. Solenoid: B=mu0nI.', 1),
('aa000153-0000-0000-0000-000000000001', 'Ampere Circuital Law', 'Integral B.dl = mu0*Ienc. Wire: B=mu0I/(2*pi*r). Parallel wires: F/L = mu0I1I2/(2*pi*d).', 2);

-- JEE MAIN: Electromagnetic Induction
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000154-0000-0000-0000-000000000001', 'Faraday Law', 'EMF = -dPhi/dt. Lenz: opposes cause. Motional: EMF = Blv.', 1),
('aa000154-0000-0000-0000-000000000001', 'Self and Mutual Inductance', 'Self: EMF = -L(dI/dt). L=mu0n^2Al. Energy=(1/2)LI^2. M=k*sqrt(L1L2).', 2);

-- JEE MAIN: AC Circuits
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000155-0000-0000-0000-000000000001', 'AC Fundamentals', 'V=Vm*sin(wt). I=Im*sin(wt-phi). Avg=2Vm/pi. RMS=Vm/sqrt(2). PF=cos(phi).', 1),
('aa000155-0000-0000-0000-000000000001', 'Resonance in LCR', 'XL=XC. w0=1/sqrt(LC). Zmin=R. Current max. BW=R/L. Q=w0L/R.', 2);

-- JEE MAIN: Ray Optics
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000156-0000-0000-0000-000000000001', 'Reflection and Refraction', 'Snell: n1sin(i)=n2sin(r). TIR when i>ic. sin(ic)=n2/n1. Mirror: 1/v+1/u=1/f.', 1),
('aa000156-0000-0000-0000-000000000001', 'Lens Formula', '1/v-1/u=1/f. m=v/u. Power=1/f(m). 1/F=1/f1+1/f2.', 2);

-- JEE MAIN: Wave Optics
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000157-0000-0000-0000-000000000001', 'Young Double Slit', 'Bright: d*sin(theta)=n*lambda. Dark: d*sin(theta)=(n+1/2)*lambda. Width=lambdaD/d.', 1),
('aa000157-0000-0000-0000-000000000001', 'Diffraction', 'Single slit dark: a*sin(theta)=n*lambda. Rayleigh: 1.22*lambda/D.', 2);

-- JEE MAIN: Dual Nature
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000158-0000-0000-0000-000000000001', 'Photoelectric Effect', 'E=hf. KEmax=hf-phi. Threshold: f0=phi/h. Stopping: eV0=KEmax.', 1),
('aa000158-0000-0000-0000-000000000001', 'de Broglie Wavelength', 'lambda=h/p=h/(mv). Electron: 12.27/sqrt(V) angstrom.', 2);

-- JEE MAIN: Atoms and Nuclei
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000159-0000-0000-0000-000000000001', 'Bohr Model', 'L=nh/2pi. En=-13.6Z^2/n^2. 1/lambda=R(1/n1^2-1/n2^2). Lyman, Balmer, Paschen.', 1),
('aa000159-0000-0000-0000-000000000001', 'Nuclear Physics', 'Mass defect, BE = defect*c^2. BE/nucleon: stability. N=N0*e^(-lambda*t).', 2);

-- JEE MAIN: Semiconductors
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000160-0000-0000-0000-000000000001', 'p-n Junction Diode', 'Forward: low resistance. Reverse: high resistance. Zener/Avalanche breakdown.', 1),
('aa000160-0000-0000-0000-000000000001', 'Transistors', 'BJT: NPN/PNP. Active=amplification. Saturation=ON. Cutoff=OFF. beta=Ic/Ib.', 2);

-- JEE MAIN Chemistry: Organic Chemistry
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000170-0000-0000-0000-000000000001', 'General Organic Chemistry', 'Hybridization: sp3(tetrahedral), sp2(trigonal), sp(linear). Inductive effect: +/-I. Resonance: delocalization.', 1),
('aa000170-0000-0000-0000-000000000001', 'Electronic Effects', 'Inductive: sigma bond, permanent. Resonance: pi bond, delocalization. Hyperconjugation: no-bond resonance.', 2),
('aa000171-0000-0000-0000-000000000001', 'Hydrocarbons', 'Alkanes: substitution. Alkenes: addition (Markovnikov). Alynes: addition. Aromatic: electrophilic substitution.', 1),
('aa000171-0000-0000-0000-000000000001', 'Markovnikov Rule', 'H adds to carbon with more H. Anti-Markovnikov: peroxide effect (HBr only). Stability: 3>2>1 carbocation.', 2),
('aa000172-0000-0000-0000-000000000001', 'Haloalkanes', 'SN1: 2-step, racemization, 3>2>1. SN2: 1-step, inversion, 1>2>3. Elimination: E1/E2.', 1),
('aa000173-0000-0000-0000-000000000001', 'Alcohols and Ethers', 'Alcohols: acidic, H-bonding. Williamson: ROH + Na -> RONa. Dehydration: H2SO4. Lucas test.', 1),
('aa000174-0000-0000-0000-000000000001', 'Aldehydes and Ketones', 'Nucleophilic addition. Tollen test (silver mirror). Fehling test (Cu2O). Cannizzaro: no alpha-H.', 1),
('aa000175-0000-0000-0000-000000000001', 'Carboxylic Acids', 'Acidic due to resonance stabilization. Derivatives: acid chloride, anhydride, ester, amide. Hell-Volhard-Zelinsky.', 1),
('aa000176-0000-0000-0000-000000000001', 'Amines', 'Basic: lone pair on N. Aromatic: less basic. Diazotization: NaNO2+HCl. Carbylamine test.', 1),
('aa000177-0000-0000-0000-000000000001', 'Biomolecules', 'Carbohydrates: mono/di/polysaccharides. Proteins: amino acids, peptide bonds. DNA/RNA.', 1);

-- JEE MAIN: Inorganic Chemistry
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000179-0000-0000-0000-000000000001', 'Periodic Table', 'Trends: atomic radius decreases across, increases down. IE increases across. EA increases across. Electronegativity (Pauling).', 1),
('aa000180-0000-0000-0000-000000000001', 's-Block Elements', 'Group 1 (alkali): highly reactive, +1. Group 2 (alkaline): +2. Flame tests. Diagonal relationship.', 1),
('aa000181-0000-0000-0000-000000000001', 'p-Block Elements', 'Groups 13-18. Inert pair effect: heavier elements prefer lower oxidation state. Allotropy common.', 1),
('aa000182-0000-0000-0000-000000000001', 'd-Block Elements', 'Transition metals: variable oxidation states, colored compounds, catalytic, paramagnetic. Complex formation.', 1),
('aa000183-0000-0000-0000-000000000001', 'Coordination Compounds', 'Werner theory. IUPAC naming. CFT: t2g and eg. VBT: inner/outer orbital. Isomerism.', 1),
('aa000184-0000-0000-0000-000000000001', 'Environmental Chemistry', 'Air pollution: SO2, NOx, CO. Water pollution: BOD, COD. Greenhouse effect. Ozone depletion.', 1);

-- JEE MAIN: Physical Chemistry
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000161-0000-0000-0000-000000000001', 'Atomic Structure', 'Bohr model, quantum numbers (n,l,m,ms). Aufbau, Hund, Pauli. Photoelectric effect.', 1),
('aa000162-0000-0000-0000-000000000001', 'Chemical Bonding', 'VSEPR: shapes. VBT: sigma/pi. MO theory: bonding/antibonding. Bond order = (nb-na)/2.', 1),
('aa000163-0000-0000-0000-000000000001', 'Thermochemistry', 'Hess law. Enthalpy of formation, combustion. Bond enthalpy. Hess cycle.', 1),
('aa000164-0000-0000-0000-000000000001', 'Equilibrium', 'Le Chatelier principle. Kc and Kp. Kw = 10^-14. Buffer: Henderson-Hasselbalch.', 1),
('aa000165-0000-0000-0000-000000000001', 'Electrochemistry', 'Nernst: E = E0 - (RT/nF)lnQ. Faraday laws. Galvanic vs electrolytic cell.', 1),
('aa000166-0000-0000-0000-000000000001', 'Chemical Kinetics', 'Rate = k[A]^n. Order from experiment. Arrhenius: k=Ae^(-Ea/RT). Half-life.', 1),
('aa000167-0000-0000-0000-000000000001', 'Solutions', 'Raoult law. Colligative: deltaTb, deltaTf, pi. van Hoff factor. Osmotic pressure.', 1),
('aa000168-0000-0000-0000-000000000001', 'Surface Chemistry', 'Adsorption: physisorption/chemisorption. Colloids: Tyndall, Brownian. Emulsions.', 1);

-- JEE MAIN Math: Trigonometry
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000194-0000-0000-0000-000000000001', 'Trigonometric Functions', 'sin, cos, tan, cot, sec, cosec. Identities: sin^2+cos^2=1. Sum/difference formulas.', 1),
('aa000195-0000-0000-0000-000000000001', 'Inverse Trigonometry', 'Domain and range. Principal values. sin^-1(x)+cos^-1(x)=pi/2.', 1),
('aa000196-0000-0000-0000-000000000001', 'Trigonometric Equations', 'General solution: sin(x)=sin(alpha). General: x=n*pi+(-1)^n*alpha.', 1);

-- JEE MAIN Math: Coordinate Geometry
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000197-0000-0000-0000-000000000001', 'Straight Lines', 'Slope = (y2-y1)/(x2-x1). Equation forms: point-slope, two-point, intercept. Parallel/perpendicular.', 1),
('aa000198-0000-0000-0000-000000000001', 'Circles', 'Center-radius: (x-h)^2+(y-k)^2=r^2. Tangent: perpendicular to radius at point of contact.', 1),
('aa000199-0000-0000-0000-000000000001', 'Conic Sections', 'Parabola: y^2=4ax. Ellipse: x^2/a^2+y^2/b^2=1. Hyperbola: x^2/a^2-y^2/b^2=1.', 1);

-- JEE MAIN Math: Calculus
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000200-0000-0000-0000-000000000001', 'Limits Continuity', 'Limit: approaching value. LHopital for 0/0 or inf/inf. Continuous: limit=value. Discontinuities.', 1),
('aa000201-0000-0000-0000-000000000001', 'Differentiation', 'Chain rule, product rule, quotient rule. Implicit. Logarithmic. Higher order.', 1),
('aa000202-0000-0000-0000-000000000001', 'Integration', 'Indefinite: antiderivative. Definite: area. Techniques: substitution, parts, partial fractions.', 1),
('aa000203-0000-0000-0000-000000000001', 'Differential Equations', 'Order, degree. Variable separable. Homogeneous. Linear: integrating factor.', 1);

-- JEE MAIN Math: Probability and Statistics
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000204-0000-0000-0000-000000000001', 'Probability', 'P(A or B) = P(A)+P(B)-P(A and B). Independent: P(A)*P(B). Conditional: P(A|B)=P(A and B)/P(B).', 1),
('aa000205-0000-0000-0000-000000000001', 'Statistics', 'Mean, median, mode. Variance, SD. Coefficient of variation.', 1);

-- JEE MAIN Math: Vectors and 3D
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000206-0000-0000-0000-000000000001', 'Vectors', 'Dot product = |a||b|cos(theta). Cross product = |a||b|sin(theta)n. Collinear, coplanar.', 1),
('aa000207-0000-0000-0000-000000000001', '3D Geometry', 'Direction cosines. Line: r=a+tb. Plane: r.n=d. Distance from point to plane.', 1);

-- JEE MAIN Math: Algebra
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000185-0000-0000-0000-000000000001', 'Sequences and Series', 'AP: a+(n-1)d. GP: ar^(n-1). HP: reciprocals in AP. Sum formulas.', 1),
('aa000186-0000-0000-0000-000000000001', 'Permutations Combinations', 'nPr=n!/(n-r)!. nCr=n!/(r!(n-r)!). Circular: (n-1)!.', 1),
('aa000187-0000-0000-0000-000000000001', 'Binomial Theorem', '(a+b)^n expansion. General term. Middle term for even/odd n.', 1),
('aa000188-0000-0000-0000-000000000001', 'Matrices and Determinants', 'Addition, multiplication. Det(2x2) = ad-bc. Inverse if det!=0. Singular/non-singular.', 1);

-- JEE ADVANCED: Fluid Mechanics
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000210-0000-0000-0000-000000000001', 'Bernoulli Equation', 'P+(1/2)rho*v^2+rho*gh = constant. Venturi meter. Torricelli: v=sqrt(2gh).', 1),
('aa000210-0000-0000-0000-000000000001', 'Viscosity and Flow', 'Stokes: F=6*pi*eta*r*v. Terminal velocity. Reynolds: rho*v*d/eta. Laminar<2000, turbulent>4000.', 2);

-- JEE ADVANCED: SHM and Waves
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000211-0000-0000-0000-000000000001', 'Simple Harmonic Motion', 'x=A*sin(wt+phi). v=Aw*cos(wt+phi). a=-w^2*x. T=2pi*sqrt(m/k). Energy=(1/2)kA^2.', 1),
('aa000211-0000-0000-0000-000000000001', 'Wave Properties', 'y=A*sin(kx-wt). v=f*lambda. Standing waves: nodes/antinodes. Beats: f_beat=|f1-f2|.', 2);

-- JEE ADVANCED: Electrostatics Advanced
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000215-0000-0000-0000-000000000001', 'Electric Potential', 'V=kQ/r. U=qV. Equipotential surfaces. Potential due to dipole: V=kp*cos(theta)/r^2.', 1),
('aa000215-0000-0000-0000-000000000001', 'Conductors in Electrostatics', 'E inside = 0. Charge on surface. sigma=eps0*E. Shielding.', 2);

-- JEE ADVANCED: Magnetism
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000216-0000-0000-0000-000000000001', 'Magnetic Force', 'F=qvxB. Cyclotron: r=mv/(qB), f=qB/(2pim). Torque: NIAB*sin(theta).', 1);

-- JEE ADVANCED: EM Waves
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000217-0000-0000-0000-000000000001', 'Maxwell Equations', 'Gauss E, Gauss B, Faraday, Ampere-Maxwell. EM waves at c=1/sqrt(mu0*eps0).', 1);

-- JEE ADVANCED: Calorimetry
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000218-0000-0000-0000-000000000001', 'Heat and Calorimetry', 'Q=mc*deltaT. Latent heat Q=mL. Mixture: heat lost = heat gained.', 1);

-- JEE ADVANCED: Thermodynamics Advanced
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000219-0000-0000-0000-000000000001', 'Carnot Cycle', '4 reversible processes. Efficiency = 1-T2/T1. Cannot be 100%.', 1);

-- JEE ADVANCED: Wave Optics Advanced
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000220-0000-0000-0000-000000000001', 'Polarization', 'Malus: I=I0*cos^2(theta). Brewster: tan(theta_B)=n2/n1.', 1);

-- JEE ADVANCED: Nuclear Physics
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000221-0000-0000-0000-000000000001', 'Radioactive Decay', 'N=N0*e^(-lambda*t). t1/2=0.693/lambda. Mean life=1/lambda. A=lambda*N.', 1);

-- JEE ADVANCED: Stereochemistry
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000222-0000-0000-0000-000000000001', 'Optical Isomerism', 'Chiral: non-superimposable mirror. Enantiomers: equal/opposite rotation. R/S config.', 1),
('aa000222-0000-0000-0000-000000000001', 'Geometric Isomerism', 'Cis-trans. E/Z notation. Restricted rotation in alkenes, cycloalkanes.', 2);

-- JEE ADVANCED: Polymers
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000223-0000-0000-0000-000000000001', 'Polymer Classification', 'Addition: PE, PP, PVC. Condensation: nylon, polyester. Cross-linked: vulcanized rubber.', 1);

-- JEE ADVANCED: Chemistry in Everyday Life
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000224-0000-0000-0000-000000000001', 'Medicines and Drugs', 'Analgesics: pain relief. Antibiotics: kill bacteria. Antiseptics: living tissue. Tranquilizers: anxiety.', 1);

-- JEE ADVANCED: Solid State
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000227-0000-0000-0000-000000000001', 'Crystal Systems', '7 systems, 14 Bravais lattices. SC:1, BCC:2, FCC:4, HCP:6 atoms/cell.', 1),
('aa000227-0000-0000-0000-000000000001', 'Packing Efficiency', 'SC:52%. BCC:68%. FCC:74%. HCP:74%. Void types by radius ratio.', 2);

-- JEE ADVANCED: Solutions Advanced
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000228-0000-0000-0000-000000000001', 'Colligative Properties', 'Depend on particle number. DeltaTb=Kb*m. DeltaTf=Kf*m. pi=CRT. van Hoff factor.', 1);

-- JEE ADVANCED: Metallurgy
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000229-0000-0000-0000-000000000001', 'Extraction of Metals', 'Pyrometallurgy: high temp. Hydrometallurgy: aqueous. Electrometallurgy: electrolysis. Refining methods.', 1);

-- JEE ADVANCED: Qualitative Analysis
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000230-0000-0000-0000-000000000001', 'Salt Analysis', 'Group reagents: HCl (I), H2S (II), NH4OH (III), (NH4)2CO3 (IV), KHPO4 (V). Confirmatory tests.', 1);

-- JEE ADVANCED: s and p Block Advanced
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000231-0000-0000-0000-000000000001', 'p-Block Chemistry', 'Group 14-18 trends. Inert pair effect. Allotropy. Ozone: powerful oxidizer.', 1);

-- JEE ADVANCED Math: Integration Advanced
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000232-0000-0000-0000-000000000001', 'Integration Techniques', 'Substitution, parts, partial fractions, trig substitutions. Standard integrals.', 1),
('aa000232-0000-0000-0000-000000000001', 'Definite Integrals', 'Properties: reversal, additivity. Leibniz rule for differentiation under integral.', 2);

-- JEE ADVANCED Math: Differential Equations
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000233-0000-0000-0000-000000000001', 'ODE Solution Methods', 'Variable separable, homogeneous, linear first order, exact, Bernoulli.', 1),
('aa000233-0000-0000-0000-000000000001', 'Higher Order Linear ODE', 'CF + PI. Auxiliary equation. PI by undetermined coefficients or variation.', 2);

-- JEE ADVANCED Math: Area
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000234-0000-0000-0000-000000000001', 'Area Between Curves', 'Integral |f(x)-g(x)|dx. Find intersections first. Polar: (1/2)integral r^2 dtheta.', 1);

-- JEE ADVANCED Math: Complex Numbers
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000236-0000-0000-0000-000000000001', 'Complex Number Geometry', 'Argand plane. Modulus, argument. Polar form. De Moivre theorem.', 1),
('aa000236-0000-0000-0000-000000000001', 'Roots of Unity', 'nth roots: e^(2pik/n). Regular n-gon. Sum = 0. Product = (-1)^(n-1).', 2);

-- JEE ADVANCED Math: Quadratic Advanced
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000237-0000-0000-0000-000000000001', 'Quadratic Roots Properties', 'Sum=-b/a. Product=c/a. D>0 real, D=0 equal, D<0 complex.', 1),
('aa000237-0000-0000-0000-000000000001', 'Location of Roots', 'Both >k if D>=0, af(k)>0, -b/2a>k. Between alpha-beta if f(alpha)*f(beta)<0.', 2);

-- JEE ADVANCED Math: Progressions
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000238-0000-0000-0000-000000000001', 'AM GM HM Relationship', 'AM>=GM>=HM. Equality when all equal. AM*HM=GM^2.', 1);

-- JEE ADVANCED Math: Probability
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000239-0000-0000-0000-000000000001', 'Conditional Probability', 'P(A|B)=P(A and B)/P(B). Bayes: P(Ai|B)=P(B|Ai)*P(Ai)/sum.', 1),
('aa000239-0000-0000-0000-000000000001', 'Random Variables', 'Mean=E(X). Var=E(X^2)-[E(X)]^2. Binomial, Poisson distributions.', 2);

-- JEE ADVANCED Math: Coordinate Advanced
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000241-0000-0000-0000-000000000001', 'Family of Lines', 'L1+kL2=0 through intersection. Parallel: m1=m2. Perp: m1*m2=-1.', 1),
('aa000242-0000-0000-0000-000000000001', 'Circles Advanced', 'General: x^2+y^2+2gx+2fy+c=0. Center(-g,-f). Radius=sqrt(g^2+f^2-c).', 1),
('aa000243-0000-0000-0000-000000000001', 'Conics Advanced', 'Ellipse, hyperbola, parabola properties. Eccentricity, focus, directrix.', 1);

-- NEET: Laws of Motion
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000250-0000-0000-0000-000000000001', 'Newtons Laws', 'First: inertia. Second: F=ma. Third: action-reaction. Friction: f=mu*N.', 1),
('aa000250-0000-0000-0000-000000000001', 'Free Body Diagrams', 'Isolate body. Identify all forces. Resolve into components. Apply F=ma in each direction.', 2);

-- NEET: Work Energy Power
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000251-0000-0000-0000-000000000001', 'Work Energy Theorem', 'Wnet = Delta KE. Work = Fd*cos(theta). Conservative: W=-Delta PE. Power = dW/dt = Fv.', 1),
('aa000251-0000-0000-0000-000000000001', 'Conservation of Energy', 'KE+PE = constant (no friction). Spring PE = (1/2)kx^2. Elastic: KE and momentum conserved.', 2);

-- NEET: Gravitation
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000252-0000-0000-0000-000000000001', 'Gravitational Laws', 'F=GMm/r^2. g=GM/R^2. Escape v=sqrt(2gR). Orbital v=sqrt(gR). T^2 prop to r^3.', 1);

-- NEET: Properties of Matter
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000264-0000-0000-0000-000000000001', 'Elasticity', 'Stress/strain = modulus. Youngs, Bulk, Shear. Poisson ratio. Elastic limit.', 1),
('aa000265-0000-0000-0000-000000000001', 'Surface Tension', 'Force per unit length. Capillary rise: h=2Tcos(theta)/(rho*g*r). Drops and bubbles.', 2),
('aa000266-0000-0000-0000-000000000001', 'Viscosity', 'Force per unit area per unit velocity gradient. Stokes: F=6*pi*eta*r*v.', 3);

-- NEET: Thermodynamics
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000267-0000-0000-0000-000000000001', 'Thermal Properties', 'Thermal expansion: alpha, beta, gamma. Conduction, convection, radiation.', 1),
('aa000268-0000-0000-0000-000000000001', 'Laws of Thermodynamics', 'First: dQ=dU+dW. Second: entropy increases. Carnot efficiency.', 2),
('aa000269-0000-0000-0000-000000000001', 'Kinetic Theory', 'PV=nRT. KE=(3/2)kT. RMS=sqrt(3RT/M). Degrees of freedom.', 3);

-- NEET: Waves and Oscillations
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000270-0000-0000-0000-000000000001', 'SHM', 'x=A*sin(wt+phi). Period=2pi*sqrt(l/g) for pendulum. T=2pi*sqrt(m/k). Energy conserved.', 1),
('aa000271-0000-0000-0000-000000000001', 'Waves', 'y=A*sin(kx-wt). v=f*lambda. Standing waves. Beats. Doppler effect.', 2);

-- NEET: Electrostatics
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000272-0000-0000-0000-000000000001', 'Electric Charges and Fields', 'Coulomb: F=kQq/r^2. E field lines. Gauss law. Dipole moment.', 1),
('aa000273-0000-0000-0000-000000000001', 'Capacitors', 'C=Q/V. Parallel: eps0A/d. Series: 1/C=sum. Energy=(1/2)CV^2. Dielectric: K*eps0.', 2);

-- NEET: Current Electricity
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000274-0000-0000-0000-000000000001', 'Current and Resistance', 'I=Q/t. V=IR. Resistivity. Temperature dependence. Ohmic and non-ohmic.', 1),
('aa000275-0000-0000-0000-000000000001', 'DC Circuits', 'Series/parallel. Kirchhoff laws. Wheatstone bridge. Potentiometer.', 2);

-- NEET: Magnetism
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000276-0000-0000-0000-000000000001', 'Magnetic Effects', 'Biot-Savart. Ampere law. Solenoid: B=mu0nI. Toroid.', 1),
('aa000277-0000-0000-0000-000000000001', 'Earth Magnetism', 'Magnetic meridian. Declination, dip, horizontal component.', 2);

-- NEET: EMI and AC
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000278-0000-0000-0000-000000000001', 'Electromagnetic Induction', 'Faraday: EMF=-dPhi/dt. Lenz law. Motional EMF. Self/mutual inductance.', 1),
('aa000279-0000-0000-0000-000000000001', 'AC Circuits', 'V=Vm*sin(wt). Impedance. Resonance. Transformer. Power factor.', 2);

-- NEET: Optics
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000280-0000-0000-0000-000000000001', 'Ray Optics', 'Reflection, refraction, TIR. Mirror/lens formula. Prism: deviation. Optical instruments.', 1),
('aa000281-0000-0000-0000-000000000001', 'Wave Optics', 'Young double slit. Diffraction. Polarization. Malus law.', 2);

-- NEET: Dual Nature
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000282-0000-0000-0000-000000000001', 'Photoelectric Effect', 'E=hf. KEmax=hf-phi. Threshold frequency. Stopping potential.', 1);

-- NEET: Atoms and Nuclei
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000283-0000-0000-0000-000000000001', 'Atomic Models', 'Bohr model. Energy levels. Hydrogen spectrum. X-rays.', 1),
('aa000284-0000-0000-0000-000000000001', 'Nuclear Physics', 'Mass defect, BE. Fission, fusion. Radioactivity: alpha, beta, gamma.', 2);

-- NEET: Semiconductors
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000285-0000-0000-0000-000000000001', 'p-n Junction Diode', 'Forward/reverse bias. Rectification. Zener diode as voltage regulator.', 1),
('aa000286-0000-0000-0000-000000000001', 'Transistors and Logic Gates', 'BJT as switch/amplifier. Logic gates: AND, OR, NOT, NAND, NOR.', 2);

-- NEET Chemistry: Organic
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000287-0000-0000-0000-000000000001', 'General Organic Chemistry', 'Hybridization, isomerism, inductive/resonance effects, IUPAC naming.', 1),
('aa000288-0000-0000-0000-000000000001', 'Hydrocarbons', 'Alkanes: substitution. Alkenes: addition. Alkynes. Aromatic: substitution.', 2),
('aa000289-0000-0000-0000-000000000001', 'Haloalkanes', 'SN1/SN2 mechanisms. Elimination. Grignard reagent. Wurtz reaction.', 3),
('aa000290-0000-0000-0000-000000000001', 'Alcohols and Phenols', 'Preparation, properties. Acidity of phenols. Williamson synthesis.', 4),
('aa000291-0000-0000-0000-000000000001', 'Aldehydes and Ketones', 'Nucleophilic addition. Tollen/Fehling tests. Aldol condensation.', 5),
('aa000292-0000-0000-0000-000000000001', 'Carboxylic Acids', 'Acidity. Derivatives: acid chloride, anhydride, ester, amide.', 6),
('aa000293-0000-0000-0000-000000000001', 'Amines', 'Basicity. Diazotization. Coupling reactions.', 7),
('aa000294-0000-0000-0000-000000000001', 'Biomolecules', 'Carbohydrates, proteins, nucleic acids, vitamins.', 8),
('aa000295-0000-0000-0000-000000000001', 'Polymers', 'Addition/condensation polymers. Natural/synthetic rubber.', 9),
('aa000296-0000-0000-0000-000000000001', 'Chemistry in Everyday Life', 'Drugs, food additives, cleansing agents.', 10);

-- NEET Chemistry: Physical
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000299-0000-0000-0000-000000000001', 'Basic Concepts', 'Mole concept, stoichiometry, empirical formula, limiting reagent.', 1),
('aa000300-0000-0000-0000-000000000001', 'Atomic Structure', 'Bohr model, quantum numbers, Aufbau principle, electronic configuration.', 2),
('aa000301-0000-0000-0000-000000000001', 'Chemical Bonding', 'Ionic, covalent, coordinate bonds. VSEPR, VBT, MO theory.', 3),
('aa000302-0000-0000-0000-000000000001', 'States of Matter', 'Gases: PV=nRT. Liquids: viscosity, surface tension. Solids: crystal systems.', 4),
('aa000303-0000-0000-0000-000000000001', 'Thermodynamics', 'Enthalpy, entropy, Gibbs energy. Hess law. Spontaneity.', 5),
('aa000304-0000-0000-0000-000000000001', 'Equilibrium', 'Le Chatelier. Kc, Kp. Ionic equilibrium. pH, buffers.', 6),
('aa000305-0000-0000-0000-000000000001', 'Redox Reactions', 'Oxidation states. Balancing. Electrochemical series.', 7),
('aa000306-0000-0000-0000-000000000001', 'Electrochemistry', 'Nernst equation. Faraday laws. Corrosion prevention.', 8),
('aa000307-0000-0000-0000-000000000001', 'Chemical Kinetics', 'Rate law, order. Arrhenius equation. Half-life. Catalyst effect.', 9),
('aa000308-0000-0000-0000-000000000001', 'Surface Chemistry', 'Adsorption, catalysis, colloids, emulsions.', 10);

-- NEET Chemistry: Inorganic
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000309-0000-0000-0000-000000000001', 'Classification of Elements', 'Periodic table. Periodic properties: radius, IE, EA, EN.', 1),
('aa000310-0000-0000-0000-000000000001', 'Hydrogen', 'Isotopes. Water. Heavy water. Hydrogen peroxide.', 2),
('aa000311-0000-0000-0000-000000000001', 's-Block Elements', 'Alkali and alkaline earth metals. Diagonal relationship.', 3),
('aa000312-0000-0000-0000-000000000001', 'p-Block Elements', 'Groups 13-18. Inert pair effect. Allotropy.', 4),
('aa000313-0000-0000-0000-000000000001', 'd and f Block', 'Transition metals: variable oxidation, colors, catalysis. Lanthanoid contraction.', 5),
('aa000314-0000-0000-0000-000000000001', 'Coordination Compounds', 'Werner theory, IUPAC naming, CFT, isomerism.', 6),
('aa000315-0000-0000-0000-000000000001', 'Environmental Chemistry', 'Air/water/soil pollution. Greenhouse effect. Ozone depletion.', 7);

-- NEET Biology: Botany
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000316-0000-0000-0000-000000000001', 'Morphology of Plants', 'Root, stem, leaf, flower, fruit morphology. Venation, placentation.', 1),
('aa000317-0000-0000-0000-000000000001', 'Anatomy of Plants', 'Tissues: meristematic, permanent. Vascular bundles. Dicot vs monocot.', 2),
('aa000318-0000-0000-0000-000000000001', 'Transport in Plants', 'Xylem: water/minerals. Phloem: food. Transpiration pull. Root pressure.', 3),
('aa000319-0000-0000-0000-000000000001', 'Mineral Nutrition', 'Essential minerals. Deficiency symptoms. Nitrogen cycle. Biological fixation.', 4),
('aa000320-0000-0000-0000-000000000001', 'Photosynthesis', 'Light reaction: PS I/II, photolysis. Calvin cycle. Factors affecting.', 5),
('aa000321-0000-0000-0000-000000000001', 'Respiration in Plants', 'Glycolysis, Krebs cycle, ETC. Anaerobic: fermentation. Respiratory quotient.', 6),
('aa000322-0000-0000-0000-000000000001', 'Plant Growth', 'Phases of growth. Growth regulators: auxins, gibberellins, cytokinins.', 7),
('aa000323-0000-0000-0000-000000000001', 'Cell Biology', 'Cell structure: organelles. Prokaryotic vs eukaryotic. Cell wall.', 8),
('aa000324-0000-0000-0000-000000000001', 'Cell Cycle and Division', 'Mitosis, meiosis. Phases: prophase, metaphase, anaphase, telophase.', 9),
('aa000325-0000-0000-0000-000000000001', 'Biomolecules', 'Carbohydrates, proteins, nucleic acids, lipids.', 10),
('aa000326-0000-0000-0000-000000000001', 'Genetics', 'Mendels laws. Monohybrid, dihybrid crosses. Linkage. Sex determination.', 11),
('aa000327-0000-0000-0000-000000000001', 'Molecular Biology of Gene', 'DNA structure, replication. Transcription, translation. Genetic code.', 12),
('aa000328-0000-0000-0000-000000000001', 'Evolution', 'Darwin theory. Evidence: fossil, comparative anatomy. Hardy-Weinberg.', 13),
('aa000329-0000-0000-0000-000000000001', 'Ecology', 'Organisms and environment. Population ecology. Community ecology.', 14),
('aa000330-0000-0000-0000-000000000001', 'Ecosystem', 'Structure, function. Energy flow. Nutrient cycling. Ecological pyramids.', 15),
('aa000331-0000-0000-0000-000000000001', 'Biodiversity', 'Types, importance. Threats. Conservation strategies.', 16);

-- NEET Biology: Zoology
INSERT INTO topics (chapter_id, name, description, display_order) VALUES
('aa000333-0000-0000-0000-000000000001', 'Animal Kingdom', 'Classification: porifera to chordata. Symmetry, body cavity, segmentation.', 1),
('aa000334-0000-0000-0000-000000000001', 'Structural Organisation', 'Tissues, organs, organ systems. Epithelial, connective, muscular, nervous.', 2),
('aa000335-0000-0000-0000-000000000001', 'Digestion and Absorption', 'Alimentary canal. Enzymes. Absorption mechanisms. Disorders.', 3),
('aa000336-0000-0000-0000-000000000001', 'Breathing and Gases', 'Respiratory system. Mechanism of breathing. Gas exchange. Disorders.', 4),
('aa000337-0000-0000-0000-000000000001', 'Body Fluids', 'Blood components. Heart structure. Cardiac cycle. Blood pressure.', 5),
('aa000338-0000-0000-0000-000000000001', 'Excretory Products', 'Kidney structure. Nephron. Urine formation. Regulation.', 6),
('aa000339-0000-0000-0000-000000000001', 'Locomotion and Movement', 'Skeletal system. Muscle contraction. Types of movement.', 7),
('aa000340-0000-0000-0000-000000000001', 'Neural Control', 'Nervous system. Neuron structure. Synapse. Reflex action. Brain.', 8),
('aa000341-0000-0000-0000-000000000001', 'Chemical Coordination', 'Endocrine glands. Hormones. Feedback mechanism.', 9),
('aa000342-0000-0000-0000-000000000001', 'Human Reproduction', 'Male/female reproductive systems. Gametogenesis. Fertilization.', 10),
('aa000343-0000-0000-0000-000000000001', 'Reproductive Health', 'Birth control. STDs. Assisted reproductive technology.', 11),
('aa000344-0000-0000-0000-000000000001', 'Immune System', 'Innate and adaptive immunity. Antibodies. Vaccines. HIV/AIDS.', 12),
('aa000345-0000-0000-0000-000000000001', 'Cancer', 'Uncontrolled cell division. Types. Detection. Treatment.', 13);
