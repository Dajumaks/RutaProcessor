import Foundation

guard CommandLine.arguments.count >= 2 else {
    print("Uso: RutaProcessor.exe archivo.ruta")
    exit(1)
}

let path = CommandLine.arguments[1]

do {
    let source = try String(
        contentsOfFile: path,
        encoding: .utf8
    )

    let lexer = Lexer(source: source)
    let tokens = try lexer.tokenize()

    print("TOKENS RECONOCIDOS:")

    for token in tokens where token.type != "NEWLINE" && token.type != "EOF" {
        print("\(token.type): '\(token.lexeme)' [línea \(token.line), columna \(token.column)]")
    }

    let parser = Parser(tokens: tokens)
    try parser.parseProgram()

    print("\nPrograma Ruta válido.")
} catch let error as RutaError {
    print(error.description)
    exit(1)
} catch {
    print("No se pudo leer el archivo: \(error.localizedDescription)")
    exit(1)
}