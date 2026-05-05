import Foundation

enum MarkdownTools {
    static func plainText(from markdown: String) -> String {
        markdown
            .replacingOccurrences(of: #"!\[[^\]]*\]\([^\)]*\)"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\[[^\]]+\]\([^\)]*\)"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"[#>*_`~\-]"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func attributedString(from markdown: String) -> AttributedString {
        if let rendered = try? AttributedString(markdown: markdown) {
            return rendered
        }

        return AttributedString(markdown)
    }
}
