import UIKit

enum MigraineReportPDFBuilder {

    struct ReportInput {
        let profile: UserProfile
        let fromDate: Date
        let toDate: Date
        let attacks: [MigraineAttack]
    }
    private static func display(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "—" : trimmed
    }

    static func buildPDF(input: ReportInput) throws -> URL {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter @72dpi
        let margin: CGFloat = 36
        let contentWidth = pageRect.width - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { ctx in
            var page = 1
            var y = margin

            func beginNewPage() {
                ctx.beginPage()
                drawFooter(page: page, pageRect: pageRect, margin: margin)
                y = margin
            }

            func ensureSpace(_ needed: CGFloat) {
                if y + needed > pageRect.height - margin {
                    page += 1
                    beginNewPage()
                }
            }

            beginNewPage()

            // Title
            y = drawText(
                "Migrainie — 30-Day Migraine Report",
                font: .boldSystemFont(ofSize: 20),
                color: .black,
                in: CGRect(x: margin, y: y, width: contentWidth, height: 28)
            ) + 6

            // Date range
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none

            y = drawText(
                "\(df.string(from: input.fromDate))  →  \(df.string(from: input.toDate))",
                font: .systemFont(ofSize: 12),
                color: .darkGray,
                in: CGRect(x: margin, y: y, width: contentWidth, height: 16)
            ) + 6

            // Generated stamp
            let gen = DateFormatter()
            gen.dateStyle = .medium
            gen.timeStyle = .short

            y = drawText(
                "Generated: \(gen.string(from: Date()))",
                font: .systemFont(ofSize: 10),
                color: .gray,
                in: CGRect(x: margin, y: y, width: contentWidth, height: 14)
            ) + 14

            // Patient Summary
            ensureSpace(140)
            y = drawSectionHeader("Patient Summary", x: margin, y: y, width: contentWidth) + 8

            let p = input.profile

            // Adjust these field names if your UserProfile differs:
            let name = p.username
             
            let ageText: String = {
                let trimmed = String(describing: p.age).trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty || trimmed == "0" ? "—" : trimmed
            }()

            let age = display(p.age)
            let height = display(p.heightCm)
            let weight = display(p.weightKg)
            let sex = display(p.sex)
            let conditions = display(p.healthConditions)
            let meds = display(p.medications)

            y = drawKeyValues([
                ("Name", name.isEmpty ? "—" : name),
                ("Age", ageText),

                ("Sex", sex.isEmpty ? "—" : sex),
                ("Height", height),
                ("Weight", weight),
                ("Known conditions", conditions.isEmpty ? "—" : conditions),
                ("Medications", meds.isEmpty ? "—" : meds),
            ], x: margin, y: y, width: contentWidth) + 18

            // Overview
            ensureSpace(100)
            y = drawSectionHeader("Overview (last 30 days)", x: margin, y: y, width: contentWidth) + 8

            let attacks = input.attacks.sorted(by: { $0.startDate > $1.startDate })
            let total = attacks.count
            let migraineDays = countMigraineDays(attacks: attacks)
            let avgSeverity = averageSeverity(attacks: attacks)

            y = drawKeyValues([
                ("Total attacks", "\(total)"),
                ("Migraine days", "\(migraineDays)"),
                ("Average severity", avgSeverity == nil ? "—" : String(format: "%.1f / 10", avgSeverity!))
            ], x: margin, y: y, width: contentWidth) + 18

            // Attack Log
            ensureSpace(60)
            y = drawSectionHeader("Attack Log", x: margin, y: y, width: contentWidth) + 8

            if attacks.isEmpty {
                ensureSpace(40)
                y = drawText(
                    "No attacks logged in the selected period.",
                    font: .systemFont(ofSize: 12),
                    color: .darkGray,
                    in: CGRect(x: margin, y: y, width: contentWidth, height: 18)
                ) + 12
            } else {
                ensureSpace(26)
                y = drawTableHeader(x: margin, y: y, width: contentWidth) + 6

                let dtf = DateFormatter()
                dtf.dateStyle = .medium
                dtf.timeStyle = .short

                for a in attacks {
                    ensureSpace(88)

                    let start = dtf.string(from: a.startDate)
                    let end = a.endDate.map { dtf.string(from: $0) } ?? "Ongoing / not recorded"
                    let severity = "\(a.severity)/10"
                    let aura = a.hasAura ? "Yes" : "No"
                    let triggers = a.triggers.isEmpty ? "—" : a.triggers.joined(separator: ", ")
                    let notes = (a.notes?.isEmpty == false) ? a.notes! : "—"

                    let healthLine: String = {
                        guard let ctx = a.linkedContextSnapshot else { return "Health: —" }
                        let sleep = ctx.sleepHours != nil ? String(format: "%.1f h", ctx.sleepHours!) : "—"
                        let steps = ctx.steps != nil ? "\(Int(ctx.steps!))" : "—"
                        let hr = ctx.avgHeartRateBpm != nil ? "\(Int(ctx.avgHeartRateBpm!)) bpm" : "—"
                        return "Health: Sleep \(sleep) · Steps \(steps) · HR \(hr)"
                    }()

                    y = drawAttackRow(
                        start: start,
                        end: end,
                        severity: severity,
                        aura: aura,
                        triggers: triggers,
                        notes: notes,
                        health: healthLine,
                        x: margin,
                        y: y,
                        width: contentWidth
                    ) + 10
                }
            }

            // Footer note
            _ = drawText(
                "Generated by Migrainie. This report is patient-entered data and should be interpreted clinically.",
                font: .systemFont(ofSize: 10),
                color: .gray,
                in: CGRect(x: margin, y: pageRect.height - margin - 18, width: contentWidth, height: 14)
            )
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Migrainie_30Day_Report_\(Int(Date().timeIntervalSince1970)).pdf")

        try data.write(to: url, options: Data.WritingOptions.atomic)


        return url
    }
}

// MARK: - Drawing helpers

private func drawFooter(page: Int, pageRect: CGRect, margin: CGFloat) {
    let footer = "Page \(page)"
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 10),
        .foregroundColor: UIColor.gray
    ]
    let size = (footer as NSString).size(withAttributes: attrs)
    let rect = CGRect(
        x: pageRect.width - margin - size.width,
        y: pageRect.height - margin + 6,
        width: size.width,
        height: 12
    )
    (footer as NSString).draw(in: rect, withAttributes: attrs)
}

private func drawText(_ text: String, font: UIFont, color: UIColor, in rect: CGRect) -> CGFloat {
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = .byWordWrapping

    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: style
    ]

    let attributed = NSAttributedString(string: text, attributes: attrs)
    let framesetter = CTFramesetterCreateWithAttributedString(attributed as CFAttributedString)

    let path = CGPath(rect: rect, transform: nil)
    let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, nil)
    CTFrameDraw(frame, UIGraphicsGetCurrentContext()!)

    let suggested = CTFramesetterSuggestFrameSizeWithConstraints(
        framesetter,
        CFRangeMake(0, attributed.length),
        nil,
        CGSize(width: rect.width, height: .greatestFiniteMagnitude),
        nil
    )

    return rect.minY + ceil(suggested.height)
}

private func drawSectionHeader(_ title: String, x: CGFloat, y: CGFloat, width: CGFloat) -> CGFloat {
    let headerY = drawText(
        title,
        font: .boldSystemFont(ofSize: 14),
        color: .black,
        in: CGRect(x: x, y: y, width: width, height: 18)
    )

    let lineRect = CGRect(x: x, y: headerY + 4, width: width, height: 1)
    UIColor(white: 0.85, alpha: 1).setFill()
    UIBezierPath(rect: lineRect).fill()

    return headerY + 8
}

private func drawKeyValues(_ pairs: [(String, String)], x: CGFloat, y: CGFloat, width: CGFloat) -> CGFloat {
    var yy = y
    let leftW: CGFloat = 140
    let rightW = width - leftW

    for (k, v) in pairs {
        _ = drawText(
            "\(k):",
            font: .boldSystemFont(ofSize: 12),
            color: .black,
            in: CGRect(x: x, y: yy, width: leftW, height: 16)
        )
        yy = drawText(
            v,
            font: .systemFont(ofSize: 12),
            color: .darkGray,
            in: CGRect(x: x + leftW, y: yy, width: rightW, height: 16)
        ) + 6
    }
    return yy
}

private func drawTableHeader(x: CGFloat, y: CGFloat, width: CGFloat) -> CGFloat {
    let bg = CGRect(x: x, y: y, width: width, height: 20)
    UIColor(white: 0.95, alpha: 1).setFill()
    UIBezierPath(roundedRect: bg, cornerRadius: 6).fill()

    _ = drawText("Start", font: .boldSystemFont(ofSize: 10), color: .black,
                 in: CGRect(x: x + 8, y: y + 4, width: 150, height: 12))
    _ = drawText("End", font: .boldSystemFont(ofSize: 10), color: .black,
                 in: CGRect(x: x + 160, y: y + 4, width: 250, height: 12))
    _ = drawText("Severity", font: .boldSystemFont(ofSize: 10), color: .black,
                 in: CGRect(x: x + width - 80, y: y + 4, width: 72, height: 12))
    return y + 20
}

private func drawAttackRow(
    start: String,
    end: String,
    severity: String,
    aura: String,
    triggers: String,
    notes: String,
    health: String,
    x: CGFloat,
    y: CGFloat,
    width: CGFloat
) -> CGFloat {
    let box = CGRect(x: x, y: y, width: width, height: 110)

    UIColor(white: 0.98, alpha: 1).setFill()
    UIBezierPath(roundedRect: box, cornerRadius: 10).fill()

    _ = drawText(start, font: .systemFont(ofSize: 11), color: .black,
                 in: CGRect(x: x + 8, y: y + 8, width: width - 16, height: 14))

    _ = drawText(end, font: .systemFont(ofSize: 11), color: .darkGray,
                 in: CGRect(x: x + 8, y: y + 24, width: width - 16, height: 14))

    _ = drawText("Severity: \(severity)   Aura: \(aura)",
                 font: .systemFont(ofSize: 10),
                 color: .darkGray,
                 in: CGRect(x: x + 8, y: y + 40, width: width - 16, height: 12))

    _ = drawText("Triggers: \(triggers)",
                 font: .systemFont(ofSize: 10),
                 color: .darkGray,
                 in: CGRect(x: x + 8, y: y + 54, width: width - 16, height: 12))

    _ = drawText(health,
                 font: .systemFont(ofSize: 10),
                 color: .darkGray,
                 in: CGRect(x: x + 8, y: y + 66, width: width - 16, height: 12))

    // Notes can be long—truncate by limiting height
    _ = drawText("Notes: \(notes)",
                 font: .systemFont(ofSize: 10),
                 color: .darkGray,
                 in: CGRect(x: x + 8, y: y + 78, width: width - 16, height: 14))

    return y + 110
}

private func countMigraineDays(attacks: [MigraineAttack]) -> Int {
    let cal = Calendar.current
    let days = Set(attacks.map { cal.startOfDay(for: $0.startDate) })
    return days.count
}

private func averageSeverity(attacks: [MigraineAttack]) -> Double? {
    guard !attacks.isEmpty else { return nil }
    let sum = attacks.reduce(0) { $0 + $1.severity }
    return Double(sum) / Double(attacks.count)
}
//
//  MigraineReportPDFBuilder.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 16/12/25.
//

