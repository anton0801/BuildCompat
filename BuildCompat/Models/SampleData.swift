import Foundation

// MARK: - Sample Materials
struct SampleData {
    static let materials: [Material] = [
        // PAINT
        Material(name: "Latex Wall Paint", category: .paint,
                 description: "Water-based paint ideal for interior walls. Breathable and easy to clean.",
                 properties: ["Base": "Water", "Finish": "Matte/Satin", "Dry Time": "2 hrs", "Coverage": "12 m²/L"],
                 tags: ["interior", "wall", "water-based"]),
        Material(name: "Oil-Based Paint", category: .paint,
                 description: "Solvent-based paint with high durability. Ideal for trim and furniture.",
                 properties: ["Base": "Solvent", "Finish": "Gloss", "Dry Time": "8 hrs", "Coverage": "10 m²/L"],
                 tags: ["trim", "furniture", "durable"]),
        Material(name: "Acrylic Paint", category: .paint,
                 description: "Fast-drying versatile paint suitable for most surfaces.",
                 properties: ["Base": "Water/Acrylic", "Finish": "Semi-gloss", "Dry Time": "1 hr", "Coverage": "11 m²/L"],
                 tags: ["versatile", "fast-dry", "interior"]),
        Material(name: "Epoxy Floor Paint", category: .paint,
                 description: "High-strength floor coating. Chemical and abrasion resistant.",
                 properties: ["Base": "Epoxy", "Finish": "Gloss", "Dry Time": "24 hrs", "Coverage": "8 m²/L"],
                 tags: ["floor", "industrial", "chemical-resistant"]),

        // TILES
        Material(name: "Ceramic Wall Tile", category: .tiles,
                 description: "Classic ceramic tile for bathroom and kitchen walls.",
                 properties: ["Material": "Ceramic", "Water Absorption": "High", "Size": "20×40 cm", "PEI Rating": "1-2"],
                 tags: ["bathroom", "kitchen", "wall"]),
        Material(name: "Porcelain Floor Tile", category: .tiles,
                 description: "Dense, low-absorption tile suitable for floors.",
                 properties: ["Material": "Porcelain", "Water Absorption": "Low (<0.5%)", "PEI Rating": "4-5", "Slip Resistance": "R10"],
                 tags: ["floor", "durable", "low-maintenance"]),
        Material(name: "Mosaic Tile", category: .tiles,
                 description: "Small format tiles for decorative accents and wet areas.",
                 properties: ["Material": "Glass/Ceramic", "Size": "2.5×2.5 cm", "Application": "Wall/Accent"],
                 tags: ["decorative", "bathroom", "accent"]),

        // WOOD
        Material(name: "Laminate Flooring", category: .wood,
                 description: "Engineered laminate with AC3+ wear rating for residential use.",
                 properties: ["AC Rating": "AC3", "Thickness": "8-12 mm", "Install": "Floating", "Moisture": "Low tolerance"],
                 tags: ["flooring", "residential", "floating"]),
        Material(name: "Hardwood Parquet", category: .wood,
                 description: "Solid oak parquet for premium floor installations.",
                 properties: ["Wood": "Oak", "Thickness": "18 mm", "Install": "Glue/Nail", "Janka": "1290"],
                 tags: ["premium", "solid", "oak"]),
        Material(name: "WPC Decking", category: .wood,
                 description: "Wood-polymer composite for outdoor decking.",
                 properties: ["Material": "Wood + PVC", "Use": "Outdoor", "Moisture": "Resistant"],
                 tags: ["outdoor", "deck", "composite"]),

        // CONCRETE
        Material(name: "Cement Screed", category: .concrete,
                 description: "Leveling compound for floor preparation.",
                 properties: ["Mix Ratio": "1:3", "Thickness": "25-50 mm", "Cure Time": "28 days"],
                 tags: ["subfloor", "leveling", "floor-prep"]),
        Material(name: "Gypsum Plaster", category: .concrete,
                 description: "Interior wall finishing plaster with smooth finish.",
                 properties: ["Base": "Gypsum", "Thickness": "5-20 mm", "Dry Time": "3-7 days"],
                 tags: ["wall", "interior", "smooth"]),
        Material(name: "Concrete Block", category: .concrete,
                 description: "Standard concrete masonry unit for structural walls.",
                 properties: ["Strength": "C15", "Size": "400×200×200 mm", "Weight": "12 kg"],
                 tags: ["structural", "masonry", "wall"]),

        // ADHESIVES
        Material(name: "Tile Adhesive C1", category: .adhesives,
                 description: "Standard cementitious adhesive for ceramic tiles on walls.",
                 properties: ["Class": "C1", "Open Time": "20 min", "Temp": "+5 to +35°C"],
                 tags: ["tile", "wall", "standard"]),
        Material(name: "Tile Adhesive C2", category: .adhesives,
                 description: "Improved cementitious adhesive for porcelain and large tiles.",
                 properties: ["Class": "C2", "Open Time": "30 min", "Slip": "T-anti slip"],
                 tags: ["porcelain", "large-format", "floor"]),
        Material(name: "Parquet Glue MS", category: .adhesives,
                 description: "MS-polymer adhesive for gluing hardwood parquet to concrete.",
                 properties: ["Type": "MS-Polymer", "Open Time": "60 min", "Flexible": "Yes"],
                 tags: ["parquet", "hardwood", "flexible"]),
        Material(name: "Contact Cement", category: .adhesives,
                 description: "Solvent-based contact adhesive for laminates and panels.",
                 properties: ["Type": "Neoprene", "Bond": "Instant", "Use": "Laminates"],
                 tags: ["laminate", "panel", "instant"]),

        // PRIMER
        Material(name: "Deep Penetrating Primer", category: .primer,
                 description: "Strengthens porous and crumbling surfaces before painting.",
                 properties: ["Type": "Acrylic", "Dilution": "1:3 water", "Coverage": "8-12 m²/L"],
                 tags: ["porous", "strengthening", "prep"]),
        Material(name: "Adhesion Primer", category: .primer,
                 description: "Improves adhesion on smooth non-absorbent surfaces.",
                 properties: ["Type": "Alkyd", "Use": "Smooth surfaces", "Dry Time": "4 hrs"],
                 tags: ["adhesion", "smooth", "prep"]),
        Material(name: "Waterproof Membrane", category: .primer,
                 description: "Flexible waterproofing for wet areas before tiling.",
                 properties: ["Type": "Polymer", "Thickness": "1-2 mm", "Coverage": "1.5 kg/m²"],
                 tags: ["waterproof", "bathroom", "wet-area"]),

        // METAL
        Material(name: "Metal Primer", category: .metal,
                 description: "Anti-corrosion primer for metal surfaces.",
                 properties: ["Type": "Alkyd", "Anti-corrosion": "Yes", "Dry Time": "6 hrs"],
                 tags: ["metal", "rust-prevention", "primer"]),
        Material(name: "Steel Lintel", category: .metal,
                 description: "Structural steel beam for window/door openings.",
                 properties: ["Material": "Mild Steel", "Grade": "S275", "Coating": "Galvanized"],
                 tags: ["structural", "opening", "steel"])
    ]

    // MARK: - Compatibility Rules
    static func getCompatibility(materialA: Material, materialB: Material) -> CompatibilityResult {
        let key = "\(materialA.category.rawValue)-\(materialB.category.rawValue)"
        let reverseKey = "\(materialB.category.rawValue)-\(materialA.category.rawValue)"

        let rules: [String: (CompatibilityStatus, String, [String])] = [
            "Paint-Concrete": (.compatible,
                "Latex and acrylic paints bond well to concrete and plaster surfaces when properly prepared.",
                ["Apply deep penetrating primer first", "Ensure surface is dry (< 4% moisture)", "Sand any rough areas before painting"]),

            "Paint-Tiles": (.warning,
                "Painting over tiles is possible but requires special preparation and adhesion primer.",
                ["Clean tiles thoroughly to remove grease and soap residue", "Apply adhesion primer before painting", "Use tile-specific paint or floor epoxy", "Avoid painting floor tiles in high-traffic areas"]),

            "Paint-Wood": (.compatible,
                "Paint adheres well to wood surfaces. Oil-based paint provides better durability on wood.",
                ["Sand wood to 120 grit before painting", "Apply wood primer or sealer first", "Use oil-based paint for trim and furniture"]),

            "Paint-Adhesives": (.warning,
                "Some adhesives contain solvents that can lift paint. Check compatibility before applying.",
                ["Test adhesive on small area first", "Allow paint to cure fully (7+ days) before applying adhesive", "Use water-based adhesives over water-based paint"]),

            "Paint-Metal": (.warning,
                "Standard wall paint is not suitable for metal. Metal-specific paint or primer is required.",
                ["Apply anti-corrosion metal primer first", "Use alkyd or epoxy paint formulated for metal", "Sand metal to bare and remove rust before painting"]),

            "Tiles-Concrete": (.compatible,
                "Tiles bond excellently to concrete and screed surfaces using appropriate adhesive.",
                ["Ensure screed is fully cured (minimum 28 days)", "Use C2 adhesive for large format tiles", "Apply waterproof membrane in wet areas first"]),

            "Tiles-Wood": (.warning,
                "Tiling over wood requires rigid substrate. Flex wood can cause tile cracking.",
                ["Install cement board (Hardiebacker) over wood subfloor", "Ensure floor deflection is less than L/360", "Use flexible C2S2 tile adhesive", "Avoid large format tiles over wood"]),

            "Tiles-Adhesives": (.compatible,
                "Tiles and cementitious adhesives are specifically designed to work together.",
                ["Match adhesive class to tile type (C1 for standard ceramic, C2 for porcelain)", "Allow adhesive to cure before grouting (24-48 hrs)", "Use anti-slip adhesive for floor tiles"]),

            "Tiles-Primer": (.compatible,
                "Applying waterproof primer/membrane under tiles in wet areas significantly improves durability.",
                ["Apply waterproof membrane in shower areas and around baths", "Allow membrane to dry fully before tiling", "Use primer on highly absorbent concrete surfaces"]),

            "Wood-Concrete": (.warning,
                "Direct contact between wood and concrete can lead to moisture damage and wood rot.",
                ["Install DPC (damp proof course) membrane between concrete and wood", "Use moisture-resistant parquet glue", "Ensure concrete moisture level is below 2% before installation"]),

            "Wood-Adhesives": (.compatible,
                "MS-polymer adhesives are excellent for gluing hardwood flooring to concrete subfloors.",
                ["Use MS-polymer adhesive for maximum flexibility", "Trowel adhesive in one direction only", "Leave expansion gaps around perimeter (10-15 mm)"]),

            "Wood-Metal": (.compatible,
                "Wood and metal can be combined structurally. Use corrosion-resistant fasteners.",
                ["Use stainless or galvanized fixings to prevent rust staining", "Apply sealant between wood and metal to prevent moisture trapping"]),

            "Concrete-Adhesives": (.compatible,
                "Cementitious adhesives bond chemically to concrete, creating a strong unified structure.",
                ["Prime highly porous concrete before applying adhesive", "Dampen concrete in hot weather to prevent premature drying"]),

            "Concrete-Primer": (.compatible,
                "Priming concrete is essential before most surface treatments. Greatly improves adhesion.",
                ["Apply penetrating primer to strengthen surface", "Allow primer to dry completely before next layer", "Re-prime if primer absorbs completely (surface is very porous)"]),

            "Adhesives-Metal": (.warning,
                "Many adhesives do not bond well to metal without surface preparation.",
                ["Degrease metal surfaces with acetone before applying adhesive", "Sand smooth metal surfaces for better grip", "Use epoxy or metal-specific adhesive"]),

            "Primer-Metal": (.compatible,
                "Metal primers are specifically formulated for metal surfaces and provide excellent adhesion.",
                ["Remove all rust with wire brush or chemical rust converter", "Apply primer within 4 hours of surface preparation", "Apply two coats for best corrosion resistance"]),

            "Paint-Primer": (.compatible,
                "Primer is designed to be painted over. This combination is best practice for all surfaces.",
                ["Apply paint within the primer's recoat window", "Match primer type to paint type (water-based over water-based)", "Sand primer lightly between coats for best finish"]),

            "Tiles-Metal": (.warning,
                "Tiling onto metal requires special preparation as metal expands and contracts with temperature.",
                ["Use epoxy-based tile adhesive for metal substrates", "Apply metal primer first", "Include movement joints every 2-3 m²"]),
        ]

        if let rule = rules[key] ?? rules[reverseKey] {
            return CompatibilityResult(materialA: materialA, materialB: materialB,
                                       status: rule.0, explanation: rule.1, suggestedFix: rule.2)
        }

        // Same category
        if materialA.category == materialB.category {
            return CompatibilityResult(
                materialA: materialA, materialB: materialB,
                status: .warning,
                explanation: "Both materials are in the same category. Combining them may cause issues depending on application order and compatibility of specific formulations.",
                suggestedFix: ["Check manufacturer specifications", "Test on small area first", "Consult a professional for specific product compatibility"]
            )
        }

        return CompatibilityResult(
            materialA: materialA, materialB: materialB,
            status: .compatible,
            explanation: "These materials are generally compatible. Follow standard installation practices and manufacturer guidelines.",
            suggestedFix: ["Follow manufacturer instructions", "Ensure surfaces are clean and prepared", "Allow adequate drying time between layers"]
        )
    }

    // MARK: - Sample Guides
    static let guides: [Guide] = [
        Guide(title: "How to Tile a Wall", category: "Tiling", icon: "square.grid.2x2.fill",
              steps: [
                GuideStep(stepNumber: 1, title: "Surface Preparation", description: "Clean the wall removing dust, grease, and old material. Check for levelness using a spirit level.", duration: "1-2 hrs", icon: "wrench.fill"),
                GuideStep(stepNumber: 2, title: "Apply Waterproof Membrane", description: "In wet areas (showers, bathrooms), apply flexible waterproof membrane. Allow to dry completely.", duration: "2-4 hrs", icon: "drop.fill"),
                GuideStep(stepNumber: 3, title: "Mark Layout Lines", description: "Find the center of the wall and mark horizontal/vertical guidelines. Plan your tile layout to avoid small cuts at corners.", duration: "30 min", icon: "ruler.fill"),
                GuideStep(stepNumber: 4, title: "Mix and Apply Adhesive", description: "Mix C2 tile adhesive to peanut butter consistency. Apply using notched trowel in one direction.", duration: "Ongoing", icon: "paintbrush.fill"),
                GuideStep(stepNumber: 5, title: "Set Tiles", description: "Press tiles firmly into adhesive with a twisting motion. Use spacers for consistent joints. Check alignment regularly.", duration: "4-8 hrs", icon: "square.grid.2x2.fill"),
                GuideStep(stepNumber: 6, title: "Allow Adhesive to Cure", description: "Do not grout for at least 24 hours. Avoid disturbing tiles during cure.", duration: "24 hrs", icon: "clock.fill"),
                GuideStep(stepNumber: 7, title: "Grout the Joints", description: "Remove spacers. Mix and apply grout using a rubber float. Work diagonally to fill joints completely.", duration: "2-3 hrs", icon: "pencil.tip"),
                GuideStep(stepNumber: 8, title: "Clean and Seal", description: "Clean excess grout with damp sponge. After 24 hrs, apply grout sealer for protection.", duration: "1 hr", icon: "sparkles")
              ],
              warnings: ["Never tile on wet or damp surfaces", "Ensure waterproofing in all wet areas", "Large format tiles (>60cm) require full-bed adhesive application"],
              tips: ["Soak ceramic tiles in water for 30 min before tiling to reduce adhesive absorption", "Start tiling from the center outward for best visual result"]),

        Guide(title: "How to Paint Walls", category: "Painting", icon: "paintbrush.fill",
              steps: [
                GuideStep(stepNumber: 1, title: "Prepare the Room", description: "Remove furniture or cover with dust sheets. Remove switch covers and outlet plates.", duration: "30 min", icon: "house.fill"),
                GuideStep(stepNumber: 2, title: "Repair Defects", description: "Fill holes and cracks with filler. Sand smooth when dry. Fill hairline cracks with flexible filler.", duration: "1-2 hrs", icon: "hammer.fill"),
                GuideStep(stepNumber: 3, title: "Clean the Surface", description: "Wash walls with sugar soap to remove grease and dirt. Allow to dry completely.", duration: "1-2 hrs", icon: "drop.fill"),
                GuideStep(stepNumber: 4, title: "Apply Primer", description: "Apply deep penetrating primer on porous or new plaster surfaces. This is critical for even paint absorption.", duration: "2 hrs", icon: "circle.hexagonpath.fill"),
                GuideStep(stepNumber: 5, title: "Mask Edges", description: "Apply masking tape to skirting boards, ceiling line, and window frames for clean edges.", duration: "30 min", icon: "pencil.tip"),
                GuideStep(stepNumber: 6, title: "Apply First Coat", description: "Cut in edges with brush first. Roll main areas using W or M pattern. Apply evenly.", duration: "2-3 hrs", icon: "paintbrush.fill"),
                GuideStep(stepNumber: 7, title: "Sand Between Coats", description: "Lightly sand with 220 grit when fully dry. Wipe dust before second coat.", duration: "30 min", icon: "sparkles"),
                GuideStep(stepNumber: 8, title: "Apply Final Coat", description: "Apply second coat. Remove masking tape while still slightly wet for cleanest line.", duration: "2-3 hrs", icon: "checkmark.circle.fill")
              ],
              warnings: ["Never apply paint over damp surfaces", "Minimum application temperature: +5°C", "Oil-based paint over water-based will peel — always prime first"],
              tips: ["Two thin coats always better than one thick coat", "Quality brush and roller give significantly better finish"]),

        Guide(title: "Laying Laminate Flooring", category: "Flooring", icon: "tree.fill",
              steps: [
                GuideStep(stepNumber: 1, title: "Acclimate Flooring", description: "Store laminate packs in the installation room for 48 hours to allow acclimatization to temperature and humidity.", duration: "48 hrs", icon: "clock.fill"),
                GuideStep(stepNumber: 2, title: "Prepare Subfloor", description: "Check floor is level (max 3mm in 1.8m). Sand high spots or use self-leveling compound. Vacuum thoroughly.", duration: "2-4 hrs", icon: "wrench.fill"),
                GuideStep(stepNumber: 3, title: "Install Vapor Barrier", description: "Roll out 200 micron polyethylene vapor barrier. Overlap joints by 200mm and tape. Turn up edges.", duration: "1 hr", icon: "drop.fill"),
                GuideStep(stepNumber: 4, title: "Lay Underlay", description: "Install foam or cork underlay over vapor barrier. Butt joints — do not overlap. Tape if needed.", duration: "1 hr", icon: "square.3.layers.3d.down.right.fill"),
                GuideStep(stepNumber: 5, title: "Plan Layout", description: "Dry lay first row without locking. Plan for minimum 50mm cut at far wall. Stagger joints minimum 300mm.", duration: "30 min", icon: "ruler.fill"),
                GuideStep(stepNumber: 6, title: "Install First Rows", description: "Insert 10mm spacers against all walls. Lock first boards together. Keep rows straight using string line.", duration: "2 hrs", icon: "square.grid.2x2.fill"),
                GuideStep(stepNumber: 7, title: "Complete Installation", description: "Continue installing using tapping block (never hammer directly on laminate). Stagger end joints by 1/3.", duration: "4-8 hrs", icon: "hammer.fill"),
                GuideStep(stepNumber: 8, title: "Install Trim", description: "Remove spacers. Install skirting boards or beading to cover expansion gap. Do not nail through floor.", duration: "2 hrs", icon: "checkmark.circle.fill")
              ],
              warnings: ["Always leave 10mm expansion gap around all fixed objects", "Never install in rooms with >60% RH", "Laminate is NOT waterproof — do not use in bathrooms or wet areas"],
              tips: ["Use pull bar and tapping block for tight fitting", "Cut boards face-up with jigsaw to avoid chipping"])
    ]

    // MARK: - Common Warnings
    static let commonWarnings: [(String, String, String)] = [
        ("Never skip primer", "exclamationmark.triangle.fill",
         "Applying paint directly to new plaster or bare concrete without primer leads to patchy finish, poor adhesion, and peeling within months."),
        ("Moisture causes tile failure", "drop.fill",
         "Tiling over damp surfaces or skipping waterproof membrane in wet areas is the #1 cause of tile failure. Always waterproof bathrooms and showers."),
        ("Don't lay laminate in wet areas", "xmark.circle.fill",
         "Laminate and most engineered wood flooring will swell and buckle when exposed to moisture. Use porcelain or vinyl in bathrooms and kitchens."),
        ("Incompatible adhesives void warranty", "doc.fill",
         "Using incorrect adhesive class for tile type is a common mistake. Ceramic walls need C1, large porcelain floors need C2T — always check tile manufacturer specs."),
        ("Concrete must cure before tiling", "clock.fill",
         "New concrete and screed must cure for minimum 28 days before tiling. Residual moisture will cause adhesive failure and efflorescence."),
        ("Check substrate movement", "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left",
         "Tiling over wooden subfloors or flexible substrates without rigid board will cause grout cracking and tile debonding due to natural flex.")
    ]
}
