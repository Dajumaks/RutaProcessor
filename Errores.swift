enum RutaError: Error, CustomStringConvertible {
    case lexical(String, Int, Int)
    case syntax(String, Int, Int)

    var description: String {
        switch self {
        case .lexical(let message, let line, let column):
            return "Error léxico en línea \(line), columna \(column): \(message)"

        case .syntax(let message, let line, let column):
            return "Error sintáctico en línea \(line), columna \(column): \(message)"
        }
    }
}