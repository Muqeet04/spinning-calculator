Build "Spin Logic": an offline-first calculator suite for cotton spinning mills (blow room to winding), as ONE Flutter codebase that ships as (1) an Android APK/AAB and (2) a Flutter Web site deployable to Vercel. Target Android phones first, but the web layout must also look good on desktop (content centred, max width ~1040px, 2-column home grid; 1 column on phones).

## Tech and architecture
- Flutter (stable), Dart, null-safe. State: Riverpod. Navigation: go_router. Storage: shared_preferences (or Hive) for saved inputs and the user profile. No backend, works fully offline.
- Packages: pdf + printing (Print and Save PDF), share_plus (share on mobile), shared_preferences, flutter_riverpod, go_router, intl.
- Strict separation: ALL calculations live in lib/core/calc/*.dart as pure Dart functions/classes with no Flutter imports, each with unit tests in test/. UI only calls them.
- Reference data (OPS, twist multipliers, spindle speeds, efficiencies, machine speeds, ring-doff table, cotton length/micronaire potential, etc.) lives in assets/data/*.json, loaded at startup, editable without touching code. Use the values visible in the examples below as seed data, mark every placeholder clearly, and at the end list exactly which tables I still have to fill in with my mill's real numbers.
- Every screen has the same top bar: "← Back to Home" (white pill), "Save data" (green), "Print" (dark outline), "Save PDF" (amber). Save data persists the module's inputs; they restore on reopen. Print/Save PDF produce a clean PDF of the module's inputs and results.
- Android hardware back returns to Home.

## Look and feel (match the original)
- Page background: soft lavender-grey gradient. Header banner: deep navy gradient (#18214F to #2A3A8C) with a thin amber (#F5B82E) bottom border, white bold title, light-blue subtitle.
- Cards: white, rounded 16px, amber top border, soft shadow, bold navy section titles with a short amber underline.
- Result tiles: light lavender gradient, rounded, small navy label on top, large bold navy value below, "-" when there is no valid result.
- Inputs: white, rounded, light border, label above. Numeric inputs use the decimal keyboard. Error text in red under the card, e.g. "Enter valid positive numbers in all fields."
- Wide tables scroll horizontally with a frozen first column. Navy table headers with white text, amber-tinted Total rows.
- A faint spindle/cone watermark logo in the page background.
- Results update live while typing, no Calculate button.

## Start and Home
- First launch: a sign-in form asking Login name, Organization name, Designation, button "Open Spin Logic →". Stored locally only. Home shows a user card (name, "Organization · Designation") with a "Switch user" button.
- Home: header "Spin Logic", subtitle "Plan, balance and cost your spinning mill, from blow room to winding." Then a card grid (2 columns, amber left border, emoji icon, title, one-line description, chevron) for these 10 modules in this order:
  1 Production Calculation (Carding, draw frame, comber, simplex, ring frame, winding)
  2 Count Conversion (Ne, Nm, Tex, Denier, convert between yarn count systems)
  3 Blow Room & Card Waste (Waste %, lap/sliver output, combined process loss)
  4 Profit/Loss Calculations (Cotton blend table, spindle-cost making charges & per-count cost, profit-loss per day/month/year)
  5 Pressure Conversion (Bar, PSI, kg/cm², kPa, mmHg, atm, for compressor, suction & nozzle pressure)
  6 Relative Humidity Calculator (Dry & wet bulb °F to °C, RH% from a sling/aspirated psychrometer reading)
  7 Target Count Feasibility (Screen a cotton lot (HVI) against a target Ne count, practical count range, TPI and a trial recommendation)
  8 Ring Doff and Roving Consumption Calculations (Ring doff time, roving packages consumed per day / shift / doff, OPS and yarn production, from yarn count)
  9 New Mills Plan (Bags required (Combed/Carded, by count) to Blow Room lines, Cards & Simplex machines/flyers)
  10 Spin Plan (auto-balance) (Enter ring frames count-wise with OPS & spindles/frame, the system balances every department, machines and speeds)
- Footer: "Works fully offline."

## Modules, build in this order, with tests and a commit after each

### 2. Count Conversion (2 cards)
Card "Count converter": Value + Count system dropdown (Ne English cotton (indirect), Nm, Tex, Denier, Dtex, Ktex, Worsted Nw, Linen lea Nel, Woollen Ny (Yorkshire), Grains/yard). Tiles: Ne, Nm, Tex, Denier, Dtex, Ktex (g/m), Worsted (Nw), Linen lea (Nel), Woollen (Ny), Grains/yard. Everything goes via Tex: Ne = 590.5/Tex, Nm = 1000/Tex, Denier = Tex*9, Dtex = Tex*10, Ktex = Tex/1000, Worsted = 885.75/Tex, Linen lea = 1653.4/Tex, Woollen = 1937.6/Tex, Grains/yd = Tex/70.865. Indirect systems: higher = finer; direct: higher = coarser. Error: "Enter a valid positive number."
Card "Linear density calculator": "What do you want to find?" (Count/linear density from length and weight, or Weight from count and length), Common sample length (Lea 120 yd, Hank 840 yd, 100 m, 10 m, 1 m, 1 yd) which fills Length, Length + unit (m, yd default, cm, in, ft), Weight of that length + unit (g default, mg, kg, grain, oz, lb), then the same 10 tiles. Tex = weight in grams / length in km. Test: 120 yd, 5.67 g gives Tex about 51.7, Ne about 11.4. Error: "Enter a length greater than zero."

### 5. Pressure Conversion
Value + Unit dropdown (Bar default, PSI, kg/cm², kPa, mmHg, Atm, mBar). Tiles with decimals: Bar 4, PSI 3, kg/cm² 4, kPa 2, mmHg 1, Atm 4 (also show mBar). Base is bar: 1 bar = 14.5038 PSI = 1.01972 kg/cm² = 100 kPa = 750.062 mmHg = 0.98692 atm = 1000 mBar.

### 6. Relative Humidity
Inputs: Dry bulb °F, Wet bulb °F, Atmospheric pressure hPa (default 1013.25, never leave it 0), Psychrometer type (Aspirated/sling A=0.000662, Natural draft A=0.0008). Tiles: Dry bulb °C, Wet bulb °C, RH %. °C = (F-32)*5/9. Es(T) = 6.112*exp(17.62T/(243.12+T)) hPa. e = Es(wet) - A*P*(Tdry - Twet). RH = e/Es(dry)*100, clamped 0 to 100. Show a note with typical targets: blow room/carding 55 to 60%, ring spinning 45 to 55%, winding 60 to 70%.

### 8. Ring Doff and Roving Consumption
Inputs and defaults: Yarn count Ne 40, Calculation mode (Auto from count / Manual parameters), Spindle speed rpm 22712, TPI 22.96, Ring bobbin weight g 45.1, Roving package weight g 1500, Ring cup diameter mm 38, Frame spindles 1824, Shift length hours 8. In Auto mode, speed, TPI, bobbin weight and roving weight are interpolated from a reference table (20 to 80.2 Ne; extrapolate outside with a warning "Count is outside the reference-sheet range (20–80.2 Ne). Values are extrapolated from the nearest reference segment."); in Manual they are editable. Auto-mode inputs are shown greyed.
Expected results for the defaults (use as unit-test targets, tolerance 0.01): TM 3.630 (= TPI/√Ne); OPS 6.09 oz/spindle/8-hour shift; yarn output/spindle/hour 21.58 g; ring doff time 125.37 min/doff (= bobbin g / output g per hour * 60); doffs/day 11.22 (this implies about 3 min per doff change: 1440/(125.37+3)); roving packages/day/frame 629.89; per shift/frame 314.95; per doff change 56.15; yarn production/day/frame 944.84 kg; time to consume one roving package 69.50 h (= roving g / output g per hour); days to consume 2.90.
Layout: cards "Inputs", "Ring doff time calculation" (tiles: Ring doff time, Ring cup diameter, Yarn production/spindle/hour, Roving packages per day/frame, per doff change, per shift/frame, Yarn production/day/frame), "Roving consumption per day", "Intermediate calculations" (TM, Output/spindle/sec, Output/spindle/hour, Ounce/spindle/shift, Doff run time, Doffs/day, Time to consume roving, Days to consume roving, Roving package). Highlight the key tiles in amber.

### 1. Production Calculation
Department dropdown: Carding, Draw frame, Comber, Simplex (speed frame), Ring frame (spinning) (default), Winding (autoconer). The fields change per department. For Ring frame: Spindle speed (RPM), Count (Ne), Twist multiplier (TM), No. of spindles, Efficiency (%), Shift hours, plus Bag weight kg (45.36 = 100 lbs) and Shifts/day (3). Tiles: Lbs/shift, Kg/shift, Bags/day (also show TPI, OPS, and winding positions required where relevant). Formulas: TPI = TM*√Ne; OPS = (rpm*60*hours*eff) / (TPI*36*Ne*840) * 16; lbs/shift = OPS*spindles/16. For Carding, Draw frame, Comber, Simplex and Winding use the standard textile production formulas (delivery/flyer/drum speed, grains per yard or hank, efficiency). If any formula is ambiguous, ask me before assuming.

### 3. Blow Room & Card Waste
Card "Cotton mixing, yield & waste": table columns Cotton | Blend1 % | Yield % | Moist. % | Blend2 % | Yield % | delete. Default rows: USA, PAK, Greek, Tencel, Ivory, Brazilian, Spanish; "+ Add cotton"; Total row (0.00). Validation message when Blend1 % or Blend2 % totals are not 100, and when Blend %age Wt. doesn't add to 100. Inputs: Blend %age Wt. for Blend1 and Blend2. Tiles: Overall yield % = (Blend1 yield * Blend1 wt) + (Blend2 yield * Blend2 wt), Avg moisture %.
Card "Non-useable wastages (%)": Roving, Sweeping, Hard waste, AC fan, Wt. loss (moisture/invisible loss %). Tiles: Non-useable total %, Grand total % (= non-useable + wt loss), B.Room+Card waste % = 100 - overall yield - grand total (shows 100.00% when all zero).
Card "Blow room (measured, kg basis)": Mixing fed (kg), Total waste extracted (kg); tiles Waste %, Yield %, Output (kg); error "Enter valid values (waste cannot exceed feed)."
Card "Card (measured, kg basis)" with button "↧ Use blow room output as feed": Material fed to card, Total card waste (droppings + flat strips + fly); tiles Waste %, Yield %, Sliver out (kg).
Card "Combined (blow room → card)": Combined yield % = (blow yield/100)*(card yield/100)*100; Combined waste % = 100 - combined yield.

### 7. Target Count Feasibility
Banner: "Engineering screening only: this does not guarantee spinnability. Final suitability depends on the complete HVI profile, blend variation, preparation quality, machine condition, twist, drafting, humidity and actual mill trials."
Inputs: Target yarn count (Ne), Spinning route (Carded ring / Combed ring default / Combed compact), Fibre length mm, Length uniformity %, Micronaire µg/in, Fibre strength g/tex, Short fibre content %, Maturity index, Twist multiplier (TM). Tiles: Target count assessment, Suggested practical count range, Estimated fibres/cross-section, Target TPI. Then cards "Recommended trial" and "Limiting factors (Review these first)" with bullet lists, and the line "Enter values to calculate." when empty. Formulas: yarn tex = 590.5/Ne; fibre tex = micronaire/25.38; fibres/cross-section = yarn tex/fibre tex; TPI = TM*√Ne. Reference count potential comes from length and micronaire (table in assets/data, placeholder until I supply mine); strength, uniformity, SFC, maturity and route then adjust it to a practical ceiling.

### 4. Profit/Loss Calculations (5 sections)
1. Raw material cost: "1 maund = how many kg" (37.3242). Table: Cotton | Rate/Kg | Rate/Maund | CD-Yield % | CM-Yield % | Comber Noil % ((CD-CM)*%age) | Cost/Lb CD | Cost/Lb CM | %age | delete. Default rows: Pak, Usa, Greek, Ivory, Brazilian, Spanish; "+ Add cotton"; Avg/Total row weighted by %age; warning "%age does not add up to 100". Rate/Maund = Rate/Kg * maund factor. Cost/Lb = (Rate/Kg / 2.20462) / Yield%.
2. Noil deduction & net raw-material cost: inputs Noil price/kg, Working days per month, Export packing rate/lb, Local packing rate/lb. Tiles: Blend avg rate/lb, Avg CM yield (combed), Avg comber noil % (blend), Noil price/lb (= /2.20462), Noil deduction/lb of cotton, Net Carded cost/lb (= avg Cost/Lb CD), Net Combed cost/lb (= avg Cost/Lb CM minus noil deduction).
3. Making charges: Shifts per day, Spindle cost /spindle/shift (manual). Table: Count | Blend (Combed/Carded) | Channel (Export/Local) | O.P.S | Frames | Spindles/Frame | Total Spindles | Lbs/Frame/Day | Lbs/Day | Making Cost/Day | Making/Lb | delete. Default rows "40/1 Combed" (Combed, Export) and "30/1 Carded" (Carded, Local); "+ Add count". Total spindles = frames*spindles/frame; Lbs/frame/day = spindles/frame*(OPS/16)*shifts; Lbs/day = frames*that; Making cost/day = spindle cost * total spindles * shifts; Making/lb = making cost/day / lbs/day.
4. Cost per lb & profit/loss per count: Count | Channel | Lbs/Day | Making/Lb | Raw Material/Lb | Total (Making+Raw) | Packing/Lb (Export or Local rate by channel) | Grand Total Cost/Lb | Sale/Lb (input) | Diff/Lb | Diff.Total; footer "Profit-Loss Per Day".
5. Summary tiles: Per day, Per month (= day * working days), Per year (= month * 12).

### 9. New Mills Plan
0. Mill setup: Mill name, No. of spindles (informational), Spindles/Frame (Ring), Compact/Non-Compact (informational only), Card feed width (Wider 100 kg/hr / Narrow 55), Flyer (New faster / Old), Combers (New 475–500 nips/min 5.2 mm feed / Old per reference table), Lap Former (New 150 m/min / Old 100), Winders (New 1400 m/min / Old 1000), Bag weight lbs, Working hours/day, "Match actual bags to required by" (Reducing speed (whole machines) / Decimal machines (full speed)).
1. Bags required: rows of Quality (Combed/Carded) | Application (Warp/Hosiery) | Count (Ne) | Bags Req.; defaults Combed Warp 40 and Carded Warp 30; "+ Add count"; tiles Combed Bags Total, Carded Bags Total, Total Bags.
2. Ring & Autocone (horizontally scrollable): Count, Req.Bags, Manual OPS?, A.Count (Count + 0.5 Warp, Count - 0.2 Hosiery), T.M (lookup), TPI = TM*√A.Count, Spindle Speed, Eff%, OPS = rpm*60*8*eff/(TPI*36*A.Count*840)*16, Bags/Frame, Frames Req. (2 dec), Ring Spindles Req., Actual Bags (Ring), W.Speed, A.Cone Eff%, Lbs/Spindle = W.Speed*1.0936*(hours*60)*eff/(A.Count*840), Winder Spindles Req., Actual Bags (Winder), Frames Used, Run OPS, Run Spindle Speed, Run W.Speed. Summary tiles: Total Bags Required, Total Frames Required, Total Ring Spindles Req., Total Winder Spindles Req., Actual Bags (Ring), Actual Bags (Winder).
   Seed/test values from the original for 40s combed warp and 30s carded warp: A.Count 40.5 / 30.5, TM 3.6 / 3.85, TPI 22.910 / 21.262, spindle speed 23000 / 19500, eff 0.95 / 0.94, OPS 5.981 / 7.178, W.Speed 1400, A.Cone eff 0.68 / 0.66.
3. Simplex: Req.Roving Bags = bags*1.03; Bags/Mc/Day = FlyerSpeed/TPI/36/840*1440*Eff/H.Roving*Spindles/100; machines = ROUNDUP(req/bags per machine); flyers = machines*spindles/mc. Seeds: H.Roving 0.95/0.75, TPI 1.3/1.05, eff 0.88/0.86, flyer 1200 rpm, 144 spindles/mc, giving 58.63 / 89.86 bags/mc/day.
4. Finisher drawing: Req.Bags = Req.Roving*1.01; hanks = 8.33/GrYd; Bags/Mc/Day = 60*24*1.0936/840/hanks/100*speed*eff; delivery speed max 450. Seeds: 60/70 gr/yd, eff 0.85, 450 m/min, giving 51.65 / 60.26.
5. Comber & Lap former (combed rows only): Req.Comber Bags = Finisher*1.01; Comber Bags/Mc/Day = 60*24*Eff*Feed/1000/1.05*LapGrains/7000*Nips*8/100*(100-Noil)/100; Req.Lap Bags = Comber/0.84*Noil%/100 + Comber; Lap Bags/Mc/Day = 60*24*1.0936*LapGrains/7000*LapEff*LapSpeed/100. Seeds: lap grains 1000, nips 475, feed 5.2, noil 18, eff 0.88, lap speed 150, lap eff 0.6, giving 27.94 and 202.47. New combers: 500 nips up to 36s, 475 above.
6. Breaker drawing: Req.Bags = (Lap for combed, Finisher for carded)*1.01, same formula as finisher, max 500 m/min. Seeds give 57.39 / 66.96.
7. Blow room line design: Blend (Single blend / Two blends), Waste margin %. Required kg/hr = total card bags*bag weight*0.4536/working hours; Card kg/day; Blow room kg/day = card kg/(1-margin); throughput = required/(1-margin); lines = ROUNDUP(throughput/1000), min 1 (two blends: min 2); beating points = lines*2.5; 1 foreign particle separator per line.
8. Carding: Capacity/card kg/hr; Cards required, Run output per card.
9. Summary table: Department | Required (machines) | Required Bags | Actual Bags | Difference, for total bags, ring frames, ring spindles, autocone spindles, simplex (flyers), finisher, comber, lap former, breaker, cards, blow room lines (beating points).
"Reducing speed" mode installs whole machines and shows the lower run speed so actual equals required; "Decimal machines" keeps full speed with 2-decimal machine counts.

### 10. Spin Plan (auto-balance)
0. Plant setup: Mill name, Bag weight lbs, Working hours/day, Blow room waste margin %, Card waste margin %, Balance by (Reducing speed / Increasing speed / Decimal machines), Max speed increase allowed %, efficiencies (blow room 88 max, card 88 max, drawing 85, simplex 85), Card rated production 100 kg/hr, Card sliver weight 60 gr/yd.
1. Ring frames count-wise: rows Count (Ne) | Quality | Application | Compact/Non-compact | Blend (1/2/3) | Frames | Spindles/Frame | O.P.S (prefilled from reference, e.g. 6.02 for 40s combed, 7.35 for 40s carded) | Total spindles | Bags/day. Bags/day = frames*spindles/frame*(OPS/16)*(hours/8)/bag wt. Tiles: Combed/Carded/Total bags/day, total frames, total spindles, winder spindles needed, average count (all/combed/carded, production-weighted = total bags / sum(bags/count)), Blend 1/2/3 ring bags/day.
2. Machines available (all optional; blank = system decides): Autocone spindles (New 1400 / Old 1000), Ring spindles, Simplex flyers (New/Old), Drawing finisher, Combers (New 500 nips/min / Old), Lap former (New 150 / Old 100), Breakers, Cards (Wider 100 / Narrow 55), Blow room lines (1000 kg/hr). Each has a Type, a custom machine speed (blank = standard) and "+ Add more machines" for mixed fleets (all run at the same % of their own speed).
3. Balanced plan by department: tiles Card output kg/day, Card feed kg/day, Blow room feed kg/day, Combined blow room + card waste %; table Department | Required bags/day | Machines needed @ set speed | Available | Machines in plan | Efficiency % | Set speed | Production balanced at speed | Run speed (% of set) | Actual bags/day | Diff | Status (OK in green, shortfall in red). Rows: Blow room lines (+ per-blend sub-rows), Cards, Breaker drawing (+ blend rows), Lap former, Comber, Finisher drawing (+ blend rows), Simplex (+ blend rows), Ring frames, Autocone winders. Backward flow from ring bags: Winder = ring; Simplex x1.03; Finisher x1.01; Comber x1.01 (combed only); Lap = Comber/0.84*Noil%+Comber; Breaker x1.01 of Lap (combed) or Finisher (carded); Cards = Breaker x1.01. Card feed = card output/(1-card waste); Blow room = card feed/(1-blow room waste). Efficiency is fixed; speed is always the lever (up to Max speed increase %, never above 450/500 m/min for drawing). Breaker, Finisher and Simplex are always whole machines, planned per blend.
4. Count-wise spin plan: one column per count plus a Total column, grouped rows RING FRAME (production bags/kg, frames, spindles, spindle speed, TM, TPI, efficiency, OPS), WINDER, SIMPLEX, FINISHER DRAWING, COMBER, LAP FORMER, BREAKER DRAWING, CARDS, BLOW ROOM, RAW MATERIAL. Editable ✎ cells override standards (blank = standard in grey), plus a "↺ Reset all variables to standard" button.
Module 10 is the biggest. Build a simplified but correct version first, make the department chain data-driven, and ask me before changing any formula.

## Deliverables
- Android: `flutter build apk --release` and `flutter build appbundle`, with app name "Spin Logic", a spindle/cone launcher icon, navy splash.
- Web: `flutter build web --release`, deployable to Vercel (include vercel.json with an SPA rewrite and instructions).
- README: how to run, test, build APK, and deploy web. List every placeholder reference table I need to replace.
- After each module: run `flutter analyze` and `flutter test`, then summarise what's done and what's left. Start with scaffolding, theme, home, sign-in, then modules 2, 5, 6, 8.
