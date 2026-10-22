final class Parser {
    private let tokens: [Token]
    private var index = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    private var current: Token {
        return tokens[min(index, tokens.count - 1)]
    }

    private func check(_ type: String) -> Bool {
        return current.type == type
    }

    @discardableResult
    private func advance() -> Token {
        let token = current

        if index < tokens.count - 1 {
            index += 1
        }

        return token
    }

    private func match(_ type: String) -> Bool {
        if check(type) {
            advance()
            return true
        }

        return false
    }

    private func consume(
        _ type: String,
        _ message: String
    ) throws -> Token {
        if check(type) {
            return advance()
        }

        throw RutaError.syntax(
            message + " Se encontró '\(current.lexeme)'.",
            current.line,
            current.column
        )
    }

    private func skipNewlines() {
        while match("NEWLINE") {}
    }

    func parseProgram() throws {
        try consume("ROBOT", "El programa debe comenzar con 'robot'.")
        try consume("IDENTIFIER", "Se esperaba el nombre del robot.")
        try consume("NEWLINE", "Se esperaba un salto de línea después del encabezado.")

        skipNewlines()
        try parseStatementList(stops: ["EOF"])
        try consume("EOF", "Hay contenido inesperado al final del programa.")
    }

    private func parseStatementList(stops: Set<String>) throws {
        skipNewlines()

        while !stops.contains(current.type) && !check("EOF") {
            try parseStatement()

            if check("NEWLINE") {
                skipNewlines()
            } else if !stops.contains(current.type) && !check("EOF") {
                throw RutaError.syntax(
                    "Se esperaba un salto de línea entre instrucciones.",
                    current.line,
                    current.column
                )
            }
        }
    }

    private func parseStatement() throws {
        switch current.type {
        case "IDENTIFIER":
            try parseAssignment()

        case "FORWARD":
            try parseForward()

        case "TURN":
            try parseTurn()

        case "STOP":
            advance()

        case "REPEAT":
            try parseRepeat()

        case "IF":
            try parseIf()

        case "RETURN":
            advance()
            try consume("BASE", "Se esperaba 'base' después de 'return'.")

        default:
            throw RutaError.syntax(
                "Se esperaba una instrucción válida de Ruta.",
                current.line,
                current.column
            )
        }
    }

    private func parseAssignment() throws {
        try consume("IDENTIFIER", "Se esperaba un identificador.")
        try consume("ASSIGN", "Se esperaba '=' en la asignación.")
        try parseExpression()
    }

    private func parseForward() throws {
        advance()
        try parseExpression()
    }

    private func parseTurn() throws {
        advance()

        if !match("LEFT") && !match("RIGHT") {
            throw RutaError.syntax(
                "Después de 'turn' debe aparecer 'left' o 'right'.",
                current.line,
                current.column
            )
        }
    }

    private func parseRepeat() throws {
        advance()
        try parseExpression()
        try consume("LBRACE", "Se esperaba '{' después de la expresión de repeat.")

        skipNewlines()
        try parseStatementList(stops: ["RBRACE"])
        try consume("RBRACE", "Falta '}' para cerrar el bloque repeat.")
    }

    private func parseIf() throws {
        advance()
        try parseCondition()
        try consume("THEN", "Se esperaba 'then' después de la condición.")
        try consume("NEWLINE", "Se esperaba un salto de línea después de 'then'.")

        skipNewlines()
        try parseStatementList(stops: ["ELSE", "END"])

        if match("ELSE") {
            try consume("NEWLINE", "Se esperaba un salto de línea después de 'else'.")
            skipNewlines()
            try parseStatementList(stops: ["END"])
        }

        try consume("END", "Falta 'end' para cerrar el bloque if.")
    }

    private func parseCondition() throws {
        try parseExpression()

        let relationalOperators: Set<String> = [
            "LT", "GT", "LE", "GE", "EQ", "NE"
        ]

        guard relationalOperators.contains(current.type) else {
            throw RutaError.syntax(
                "Se esperaba un operador de comparación.",
                current.line,
                current.column
            )
        }

        advance()
        try parseExpression()
    }

    private func parseExpression() throws {
        try parseTerm()

        while check("PLUS") || check("MINUS") {
            advance()
            try parseTerm()
        }
    }

    private func parseTerm() throws {
        try parseFactor()

        while check("STAR") || check("SLASH") {
            advance()
            try parseFactor()
        }
    }

    private func parseFactor() throws {
        if match("NUMBER") || match("IDENTIFIER") {
            return
        }

        if match("LPAREN") {
            try parseExpression()
            try consume("RPAREN", "Falta ')' para cerrar la expresión.")
            return
        }

        throw RutaError.syntax(
            "Se esperaba un número, un identificador o una expresión entre paréntesis.",
            current.line,
            current.column
        )
    }
}