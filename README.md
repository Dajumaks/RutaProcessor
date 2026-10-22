# RutaProcessor
<<<<<<< HEAD
Procesador del lenguaje Ruta desarrollado en Swift para la asignatura Language Processors.
=======

Procesador léxico y sintáctico del lenguaje **Ruta**, un lenguaje diseñado para programar las rutas de un robot de entregas dentro de un campus universitario. Implementado en **Swift**, sin generadores de analizadores ni librerías de apoyo: el lexer y el parser están escritos a mano a partir de la gramática diseñada.

| | |
|---|---|
| **Autor** | [Josue Daniel Castaño Montoya] |
| **Universidad** | [Universidad Autonoma de Manizales] |
| **Programa** | Ingeniería de sistemas|
| **Asignatura** | Procesadores de Lenguajes |
| **Trabajo** | Taller calificado, II Corte: *Ruta, a Language for the Campus Robot* |
| **Docente** | Harold Morales |
| **Periodo** | 2026-03 |
| **Lenguaje de implementación** | Swift |

## Descripción

El procesador recibe un archivo con un programa Ruta, lo convierte en una secuencia de tokens (análisis léxico) y decide si el programa está bien formado según la gramática del lenguaje (análisis sintáctico). Cuando el programa es inválido, informa la **línea**, la **columna** y el **motivo** del error.

Ejemplo de programa Ruta:

```
robot Tito
  speed = 2

  repeat 4 {
    forward 10 * speed + 5
    turn right
  }

  if front_sensor < 30 then
    stop
  else
    forward 1
  end

  // volver a la base
  return base
```

## Requisitos

- [Swift](https://www.swift.org/install/) instalado y disponible desde la terminal (`swiftc`).
- Windows x64 (el ejecutable incluido fue generado en esta plataforma; el código fuente es portable).

## Estructura del proyecto

```
RutaProcessor/
├── Token.swift        # Representación de un token (tipo, lexema, línea, columna)
├── Errores.swift      # Errores léxicos y sintácticos con posición
├── Lexer.swift        # Análisis léxico
├── Parser.swift       # Análisis sintáctico (descenso recursivo)
├── main.swift         # Punto de entrada
└── examples/
    ├── correcto.ruta
    ├── incorrecto.ruta
    └── ambiguo.ruta
```

## Compilación

```powershell
swiftc Token.swift Errores.swift Lexer.swift Parser.swift main.swift -o RutaProcessor.exe
```

## Ejecución

```powershell
.\RutaProcessor.exe examples\correcto.ruta
```

Salida esperada para un programa válido: la lista de tokens reconocidos (tipo, lexema, línea y columna) y el mensaje `Programa Ruta válido.`

## Definición léxica

| Token | Patrón | Ejemplos |
|---|---|---|
| `ROBOT`, `FORWARD`, `TURN`, `LEFT`, `RIGHT`, `STOP`, `REPEAT`, `IF`, `THEN`, `ELSE`, `END`, `RETURN`, `BASE` | Palabras reservadas | `robot`, `forward`, `turn` |
| `IDENTIFIER` | `[A-Za-z_][A-Za-z0-9_]*` | `Tito`, `speed`, `front_sensor` |
| `NUMBER` | `[0-9]+(\.[0-9]+)?` | `4`, `30`, `2.5` |
| `ASSIGN` | `=` | |
| `PLUS`, `MINUS`, `STAR`, `SLASH` | `+` `-` `*` `/` | |
| `LT`, `GT`, `LE`, `GE`, `EQ`, `NE` | `<` `>` `<=` `>=` `==` `!=` | |
| `LBRACE`, `RBRACE`, `LPAREN`, `RPAREN` | `{` `}` `(` `)` | |
| `NEWLINE` | Salto de línea (separa instrucciones) | |
| `EOF` | Fin del archivo | |

Los espacios, tabuladores y los comentarios de línea (`// ...`) se descartan.

## Gramática (EBNF)

```ebnf
programa      = "robot" IDENTIFIER NEWLINE { NEWLINE } listaInstr EOF ;

listaInstr    = { NEWLINE } { instruccion ( NEWLINE { NEWLINE } | &fin ) } ;

instruccion   = asignacion | avance | giro | "stop" | repetir | condicional | retorno ;

asignacion    = IDENTIFIER "=" expresion ;
avance        = "forward" expresion ;
giro          = "turn" ( "left" | "right" ) ;
retorno       = "return" "base" ;

repetir       = "repeat" expresion "{" listaInstr "}" ;
condicional   = "if" condicion "then" NEWLINE listaInstr
                [ "else" NEWLINE listaInstr ]
                "end" ;

condicion     = expresion ( "<" | ">" | "<=" | ">=" | "==" | "!=" ) expresion ;

expresion     = termino { ( "+" | "-" ) termino } ;
termino       = factor  { ( "*" | "/" ) factor } ;
factor        = NUMBER | IDENTIFIER | "(" expresion ")" ;
```

`&fin` indica que la instrucción puede terminar sin salto de línea cuando le sigue el cierre de su bloque (`}`, `else`, `end`) o el fin del archivo.

### Eliminación de ambigüedades

- **Expresiones:** la precedencia se codifica en la propia gramática con dos niveles (`expresion` para `+ -`, `termino` para `* /`). Así, `forward 10 * speed + 5` tiene un único árbol: `(10 * speed) + 5`.
- **`if-then-else` anidado (dangling else):** el bloque condicional se cierra siempre con `end`, por lo que cada `else` pertenece sin dudas al `if` que lo contiene.

## Programas de prueba

| Archivo | Qué demuestra |
|---|---|
| `examples/correcto.ruta` | Programa válido con asignación, `repeat`, `if/else/end`, comentario y `return base`. |
| `examples/incorrecto.ruta` | Error sintáctico en la línea 3: la expresión `forward 10 *` queda sin su segundo operando. |
| `examples/ambiguo.ruta` | Expresión `10 * speed + 5`, que el procesador acepta con una única interpretación gracias a la precedencia. |

## Manejo de errores

Los errores incluyen posición y causa:

```
Error léxico en línea L, columna C: <mensaje>
Error sintáctico en línea L, columna C: <mensaje>
```

## Notas de implementación

- El lexer trabaja sobre escalares Unicode para tratar de forma uniforme los saltos de línea de Windows (`\r\n`) y de Unix (`\n`).
- El parser es de **descenso recursivo**: cada no terminal de la gramática corresponde a una función de `Parser.swift`.
- No se utilizan generadores de analizadores léxicos o sintácticos ni librerías que los reemplacen.

## Autor

**[Josue Daniel Castaño Montoya]**
[Universidad Autonoma de Manizales], Ingeniería de sistemas
Asignatura: Procesadores de Lenguajes, periodo 2026-03
>>>>>>> ab78ac3 (Initial commit: create project structure)
