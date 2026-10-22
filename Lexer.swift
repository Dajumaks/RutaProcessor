final class Lexer {
    private let characters: [Character]
    private var index = 0
    private var line = 1
    private var column = 1

    private let keywords: [String: String] = [
        "robot": "ROBOT",
        "forward": "FORWARD",
        "turn": "TURN",
        "left": "LEFT",
        "right": "RIGHT",
        "stop": "STOP",
        "repeat": "REPEAT",
        "if": "IF",
        "then": "THEN",
        "else": "ELSE",
        "end": "END",
        "return": "RETURN",
        "base": "BASE"
    ]

    init(source: String) {
    self.characters = source.unicodeScalars.map { Character($0) }
    }   

    private var isAtEnd: Bool {
        index >= characters.count
    }

    private func peek() -> Character? {
        guard !isAtEnd else { return nil }
        return characters[index]
    }

    private func peekNext() -> Character? {
        guard index + 1 < characters.count else { return nil }
        return characters[index + 1]
    }

    @discardableResult
    private func advance() -> Character {
        let character = characters[index]
        index += 1

        if character == "\n" {
            line += 1
            column = 1
        } else {
            column += 1
        }

        return character
    }

    private func isDigit(_ character: Character) -> Bool {
        guard let value = character.asciiValue else {
            return false
        }

        return value >= 48 && value <= 57
    }

    private func isLetter(_ character: Character) -> Bool {
        guard let value = character.asciiValue else {
            return false
        }

        return (value >= 65 && value <= 90)
            || (value >= 97 && value <= 122)
            || value == 95
    }

    private func isIdentifierPart(_ character: Character) -> Bool {
        return isLetter(character) || isDigit(character)
    }

    private func makeToken(
        _ type: String,
        _ lexeme: String,
        _ startLine: Int,
        _ startColumn: Int
    ) -> Token {
        return Token(
            type: type,
            lexeme: lexeme,
            line: startLine,
            column: startColumn
        )
    }

    func tokenize() throws -> [Token] {
        var tokens: [Token] = []

        while !isAtEnd {
            guard let character = peek() else { break }

            if character == " " || character == "\t" || character == "\r" {
                advance()
                continue
            }

            let startLine = line
            let startColumn = column

            if character == "\n" {
                advance()
                tokens.append(
                    makeToken("NEWLINE", "\\n", startLine, startColumn)
                )
                continue
            }

            if character == "/",
               peekNext() == "/" {
                while let current = peek(), current != "\n" {
                    advance()
                }
                continue
            }

            if isLetter(character) {
                var lexeme = ""

                while let current = peek(), isIdentifierPart(current) {
                    lexeme.append(advance())
                }

                let type = keywords[lexeme] ?? "IDENTIFIER"

                tokens.append(
                    makeToken(type, lexeme, startLine, startColumn)
                )
                continue
            }

            if isDigit(character) {
                var lexeme = ""

                while let current = peek(), isDigit(current) {
                    lexeme.append(advance())
                }

                if peek() == ".", let next = peekNext(), isDigit(next) {
                    lexeme.append(advance())

                    while let current = peek(), isDigit(current) {
                        lexeme.append(advance())
                    }
                }

                tokens.append(
                    makeToken("NUMBER", lexeme, startLine, startColumn)
                )
                continue
            }

            switch character {
            case "=":
                advance()
                if peek() == "=" {
                    advance()
                    tokens.append(makeToken("EQ", "==", startLine, startColumn))
                } else {
                    tokens.append(makeToken("ASSIGN", "=", startLine, startColumn))
                }

            case "!":
                advance()
                if peek() == "=" {
                    advance()
                    tokens.append(makeToken("NE", "!=", startLine, startColumn))
                } else {
                    throw RutaError.lexical(
                        "El símbolo ! debe ir seguido de =.",
                        startLine,
                        startColumn
                    )
                }

            case "<":
                advance()
                if peek() == "=" {
                    advance()
                    tokens.append(makeToken("LE", "<=", startLine, startColumn))
                } else {
                    tokens.append(makeToken("LT", "<", startLine, startColumn))
                }

            case ">":
                advance()
                if peek() == "=" {
                    advance()
                    tokens.append(makeToken("GE", ">=", startLine, startColumn))
                } else {
                    tokens.append(makeToken("GT", ">", startLine, startColumn))
                }

            case "+":
                advance()
                tokens.append(makeToken("PLUS", "+", startLine, startColumn))

            case "-":
                advance()
                tokens.append(makeToken("MINUS", "-", startLine, startColumn))

            case "*":
                advance()
                tokens.append(makeToken("STAR", "*", startLine, startColumn))

            case "/":
                advance()
                tokens.append(makeToken("SLASH", "/", startLine, startColumn))

            case "{":
                advance()
                tokens.append(makeToken("LBRACE", "{", startLine, startColumn))

            case "}":
                advance()
                tokens.append(makeToken("RBRACE", "}", startLine, startColumn))

            case "(":
                advance()
                tokens.append(makeToken("LPAREN", "(", startLine, startColumn))

            case ")":
                advance()
                tokens.append(makeToken("RPAREN", ")", startLine, startColumn))

            default:
                throw RutaError.lexical(
                    "Carácter no reconocido: '\(character)'.",
                    startLine,
                    startColumn
                )
            }
        }

        tokens.append(
            makeToken("EOF", "", line, column)
        )

        return tokens
    }
}