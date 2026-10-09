import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super(NumberedCanvas, self).__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_number(num_pages)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)

    def draw_page_number(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 9)
        self.setFillColor(colors.HexColor("#6B7280"))
        # Header
        self.drawString(54, 755, "Spin Logic — Industrial Mill Calculator Suite")
        self.setStrokeColor(colors.HexColor("#E5E7EB"))
        self.setLineWidth(0.5)
        self.line(54, 747, 558, 747)
        # Footer
        self.line(54, 45, 558, 45)
        self.drawString(54, 32, "Confidential & Proprietary — Spin Logic Documentation")
        self.drawRightString(558, 32, f"Page {self._pageNumber} of {page_count}")
        self.restoreState()

def build_pdf(filename="Spin_Logic_User_Guide.pdf"):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )
    
    styles = getSampleStyleSheet()
    
    # Custom styles
    primary_color = colors.HexColor("#18214F")
    secondary_color = colors.HexColor("#2A3A8C")
    amber_color = colors.HexColor("#F5B82E")
    text_dark = colors.HexColor("#1F2937")
    text_muted = colors.HexColor("#4B5563")
    
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=24,
        leading=28,
        textColor=primary_color,
        spaceAfter=6
    )
    
    subtitle_style = ParagraphStyle(
        'DocSubTitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=12,
        leading=16,
        textColor=secondary_color,
        spaceAfter=14
    )
    
    h1_style = ParagraphStyle(
        'H1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=15,
        leading=19,
        textColor=primary_color,
        spaceBefore=14,
        spaceAfter=8,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'H2',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=secondary_color,
        spaceBefore=10,
        spaceAfter=4,
        keepWithNext=True
    )
    
    body_style = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13.5,
        textColor=text_dark,
        spaceAfter=6
    )
    
    bullet_style = ParagraphStyle(
        'Bullet',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=13,
        textColor=text_dark,
        leftIndent=15,
        spaceAfter=3
    )

    callout_style = ParagraphStyle(
        'Callout',
        parent=styles['Normal'],
        fontName='Helvetica-Oblique',
        fontSize=9,
        leading=13,
        textColor=primary_color,
        spaceAfter=6
    )
    
    story = []
    
    # Title & Header
    story.append(Paragraph("Spin Logic — Comprehensive User & Installation Manual", title_style))
    story.append(Paragraph("Plan, Balance, and Cost Cotton Spinning Operations (Blow Room to Winding)", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=2, color=amber_color, spaceAfter=14))
    
    # Executive Overview
    story.append(Paragraph("1. System Overview & Architecture", h1_style))
    story.append(Paragraph(
        "<b>Spin Logic</b> is an industrial-grade, offline-first calculation and planning suite engineered "
        "specifically for cotton spinning mills. Built as a unified Flutter codebase, it provides real-time "
        "production calculations, raw material blend feasibility, ring frame doff timing, complete departmental "
        "balance, and full mill financial accounting from blow room to autoconer winding.",
        body_style
    ))
    story.append(Paragraph(
        "<b>Key Technical Characteristics:</b>",
        body_style
    ))
    story.append(Paragraph("• <b>Dual Target Platform:</b> Runs natively as an Android App (APK/AAB) and as a zero-latency responsive Web Application.", bullet_style))
    story.append(Paragraph("• <b>100% Offline Capable:</b> Calculations, unit conversions, and session data operate completely without internet connectivity.", bullet_style))
    story.append(Paragraph("• <b>Live Calculation Engine:</b> Outputs update continuously as values are typed — no recalculate buttons required.", bullet_style))
    story.append(Paragraph("• <b>Enterprise Top Bar:</b> Standardized actions on all module pages: <i>Back to Home</i>, <i>Save data</i>, <i>Print</i>, and <i>Save PDF</i>.", bullet_style))
    story.append(Spacer(1, 10))

    # Modules Breakdown
    story.append(Paragraph("2. Module-by-Module Functional Guide", h1_style))
    
    modules = [
        ("Module 1: Production Calculation",
         "Departmental production calculator covering Carding, Draw Frame, Comber, Simplex (Speed Frame), Ring Frame, and Winding (Autoconer).",
         [
             "<b>Dynamic Department Switcher:</b> Modifies all input parameters and reference constants based on selected department.",
             "<b>Ring Frame Spinning:</b> Computes TPI, OPS (oz/spindle/shift), Lbs/shift, Kg/shift, and Bags/day using exact mill twist and spindle speed formulas.",
             "<b>Carding & Drawing:</b> Models delivery speed (m/min), sliver hank / grains/yard, and machine efficiencies to output sliver weights and bags/day.",
             "<b>Comber:</b> Computes production based on nips/min, feed length (mm), noil extraction %, heads per machine, and lap grains/yard.",
             "<b>Simplex:</b> Calculates delivery rates, roving hank, flyer RPM, TPI, and flyer package outputs.",
             "<b>Winding:</b> Computes autoconer drum production at speeds up to 1400 m/min, efficiency, and winding spindles required."
         ]),
        ("Module 2: Count Conversion & Linear Density",
         "Universal textile count conversion engine and sample linear density analyzer.",
         [
             "<b>All Major Systems Supported:</b> Indirect systems (Ne English Cotton, Nm, Worsted Nw, Linen Lea, Woollen Yorkshire) and Direct systems (Tex, Denier, Dtex, Ktex, Grains/yd).",
             "<b>Unified Tex Pivot:</b> Mathematically rigorous bidirectional conversions: Ne = 590.5/Tex, Nm = 1000/Tex, Denier = Tex × 9, Dtex = Tex × 10.",
             "<b>Linear Density Calculator:</b> Computes yarn count directly from sample length and weight. Includes one-touch presets for Lea (120 yd), Hank (840 yd), 100m, 10m, 1m, and 1 yd with full unit conversions (g, mg, kg, grain, oz, lb)."
         ]),
        ("Module 3: Blow Room & Card Waste",
         "Comprehensive waste analysis and combined process loss auditor.",
         [
             "<b>Cotton Mixing Table:</b> Multi-component cotton blend matrix with individual yield and moisture percentages.",
             "<b>Non-Usable Wastages:</b> Tracks droppings, sweepings, hard waste, AC fan extraction, and invisible moisture loss.",
             "<b>Department Measured Yields:</b> Feed vs. waste inputs on a kg basis for Blow Room lines and Cards.",
             "<b>Combined Yield Calculation:</b> Computes compound blow room → card yield and net process waste."
         ]),
        ("Module 4: Profit/Loss Calculations",
         "Comprehensive cotton blend costing and mill profitability engine across 5 integrated sections.",
         [
             "<b>1. Raw Material Cost:</b> Maund to Kg conversions (37.3242 standard), Rate/Kg to Rate/Maund, Carded (CD) vs. Combed (CM) yields, Comber noil deductions, and cost/lb.",
             "<b>2. Net Raw Material Cost:</b> Evaluates comber noil market value credit to calculate net clean combed fiber costs.",
             "<b>3. Making Charges:</b> Spindle-cost making charges per shift/day, frame allocation, and per-lb manufacturing conversion cost.",
             "<b>4. Count-Wise P&L:</b> Combines raw material costs, making charges, and channel packing rates (Export vs. Local) against sale prices to compute net margin/lb.",
             "<b>5. Mill Summary:</b> Projected bottom-line mill profit or loss per Day, per Month (working days basis), and per Year."
         ]),
        ("Module 5: Pressure Conversion",
         "Precision pneumatic converter for mill utility systems.",
         [
             "<b>Utility Coverage:</b> Covers compressor lines, suction fans, blow room transport lines, and spinning nozzle pressures.",
             "<b>Units & Decimals:</b> Simultaneous output for Bar (4 dec), PSI (3 dec), kg/cm² (4 dec), kPa (2 dec), mmHg (1 dec), Atm (4 dec), and mBar."
         ]),
        ("Module 6: Relative Humidity (Psychrometer)",
         "Calculates air humidity from wet & dry bulb readings using psychrometric equations.",
         [
             "<b>Psychrometer Calibration:</b> Select between Aspirated / Sling psychrometers (A=0.000662) and Natural Draft psychrometers (A=0.0008).",
             "<b>Atmospheric Compensation:</b> Pressure-compensated vapor pressure calculations.",
             "<b>Mill Standards Guidance:</b> Built-in reference ranges for Blow Room / Carding (55–60%), Ring Spinning (45–55%), and Winding (60–70%)."
         ]),
        ("Module 7: Target Count Feasibility",
         "HVI fiber property screening against target yarn count (Ne).",
         [
             "<b>Input Screening:</b> Evaluates fiber length (mm), uniformity index (%), micronaire (µg/in), strength (g/tex), short fiber content (%), and maturity.",
             "<b>Cross-Section Analysis:</b> Computes fibers per yarn cross-section (Yarn Tex / Fiber Tex) and target TPI.",
             "<b>Risk & Trial Guidelines:</b> Evaluates spinnability safety thresholds and flags critical limiting factors (e.g., low fiber cross-section count or high short fiber content)."
         ]),
        ("Module 8: Ring Doff & Roving Consumption",
         "Production timing and roving package logistics calculator.",
         [
             "<b>Auto vs. Manual Modes:</b> Auto mode linearly interpolates spindle speed, TPI, bobbin weight, and roving package weight from 20s to 80.2s reference tables.",
             "<b>Ring Doff Timing:</b> Calculates runtime per doff change and total doff cycles per 24-hour day.",
             "<b>Roving Logistics:</b> Computes roving packages consumed per frame per day, per shift, and per doff cycle, plus package runtime hours."
         ]),
        ("Module 9: New Mills Plan",
         "End-to-end mill capacity planner from market bag demand to front-line machinery.",
         [
             "<b>Department Machine Sizing:</b> Sizes required Blow Room lines, Cards, Breaker drawing, Combers, Lap formers, Finisher drawing, Simplex flyers, Ring frames, and Autoconer spindles.",
             "<b>Speed Balancing Modes:</b> Toggle between 'Reducing speed (whole machines)' to align actual production to target bags or 'Decimal machines (full speed)'."
         ]),
        ("Module 10: Spin Plan (Auto-Balance)",
         "Departmental machine speed and count allocation balancing engine.",
         [
             "<b>Ring-to-Blow Room Flow:</b> Backwards balanced flow with waste allowances across every process stage.",
             "<b>Fleet Balancing:</b> Evaluates available fleet vs. required fleet and computes required operational run speeds (% of standard rated speed).",
             "<b>Status Indicators:</b> Live shortfall alerts when department capacity cannot meet production targets."
         ])
    ]
    
    for title, desc, bullets in modules:
        story.append(Paragraph(title, h2_style))
        story.append(Paragraph(desc, body_style))
        for b in bullets:
            story.append(Paragraph(f"• {b}", bullet_style))
        story.append(Spacer(1, 4))
        
    story.append(PageBreak())
    
    # Installation Guide
    story.append(Paragraph("3. App Installation & Deployment Guide", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=amber_color, spaceAfter=10))
    
    story.append(Paragraph("A. Web Deployment (Vercel)", h2_style))
    story.append(Paragraph(
        "The web application builds as a production-optimized Single Page Application (SPA). "
        "The project is pre-configured with <code>vercel.json</code> rewrites.",
        body_style
    ))
    story.append(Paragraph("1. <b>Build Command:</b> Run <code>flutter build web --release</code> in the project root directory.", bullet_style))
    story.append(Paragraph("2. <b>Output Directory:</b> The generated web distribution is located in <code>build/web</code>.", bullet_style))
    story.append(Paragraph("3. <b>Vercel CLI Deployment:</b> From the repository root, execute <code>vercel --prod</code> or connect your GitHub repository to Vercel.", bullet_style))
    story.append(Paragraph("4. <b>Vercel Project Settings:</b> Framework Preset: <i>Other</i>, Output Directory: <i>build/web</i>, Build Command: <i>flutter build web --release</i>.", bullet_style))
    story.append(Spacer(1, 8))
    
    story.append(Paragraph("B. Android Mobile App Installation (APK & AAB)", h2_style))
    story.append(Paragraph(
        "The Android version provides mill managers and technicians on the factory floor with "
        "a native, high-performance touch interface that works without internet connectivity.",
        body_style
    ))
    story.append(Paragraph("1. <b>Building APK (Direct Installation):</b> Execute <code>flutter build apk --release</code>. The installer APK will be generated at <code>build/app/outputs/flutter-apk/app-release.apk</code>.", bullet_style))
    story.append(Paragraph("2. <b>Sideloading on Android Phones:</b> Transfer <code>app-release.apk</code> to your device via USB cable, Google Drive, or WhatsApp. Tap the APK file and select 'Install' (ensure 'Install Unknown Apps' is permitted in Android Settings).", bullet_style))
    story.append(Paragraph("3. <b>Building App Bundle (Google Play Store):</b> Run <code>flutter build appbundle --release</code> to produce the Google Play publishing bundle at <code>build/app/outputs/bundle/release/app-release.aab</code>.", bullet_style))
    story.append(Paragraph("4. <b>Offline Cache:</b> All reference tables and calculating routines run purely in client memory — no network permissions are required for core calculations.", bullet_style))
    story.append(Spacer(1, 8))

    story.append(Paragraph("C. Developer & Desktop Testing", h2_style))
    story.append(Paragraph("• <b>Local Web Server:</b> Run <code>flutter run -d chrome</code> for interactive development.", bullet_style))
    story.append(Paragraph("• <b>Automated Test Suite:</b> Execute <code>flutter test</code> to verify calculation accuracy across all pure Dart logic modules.", bullet_style))
    story.append(Paragraph("• <b>Static Analysis:</b> Run <code>flutter analyze</code> to guarantee strict null-safety and lint compliance.", bullet_style))
    story.append(Spacer(1, 14))

    # Reference Data Customization Notice
    story.append(Paragraph("4. Customizing Mill Reference Data", h1_style))
    story.append(Paragraph(
        "All benchmark tables (spindle speeds, twist multipliers, efficiencies, cotton spinnability ranges) "
        "are externalized in editable JSON files located in <code>assets/data/</code>:<br/>"
        "• <code>ring_doff_reference.json</code>: Reference speeds, TPI, bobbin & roving weights for Ne 20 to 80.2.<br/>"
        "• <code>production_reference.json</code>: Machine efficiencies, twist multipliers, and departmental delivery speeds.<br/>"
        "• <code>count_potential.json</code>: Fiber length and micronaire screening matrices.<br/>"
        "Mill managers can modify these tables without altering Dart source code.",
        body_style
    ))
    
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF generated successfully at {filename}")

if __name__ == '__main__':
    build_pdf('/home/muqeet/Desktop/spinning-calculator/Spin_Logic_User_Guide.pdf')
