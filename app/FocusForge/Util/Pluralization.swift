import Foundation

extension Int {
    /// Returns "1 minute" / "2 minutes" without manual ternary at every call site.
    /// Pass an explicit plural form when the suffix isn't just `+s` (e.g. "day"/"days" works,
    /// but "child"/"children" would need pluralized("child", plural: "children")).
    func pluralized(_ singular: String, plural: String? = nil) -> String {
        let form = self == 1 ? singular : (plural ?? "\(singular)s")
        return "\(self) \(form)"
    }
}
