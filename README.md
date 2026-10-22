<div align="center">

# RutaProcessor

**Procesador léxico y sintáctico para Ruta, un lenguaje de dominio específico para programar las rutas de un robot de entregas en un campus universitario.**

![Swift](https://img.shields.io/badge/Swift-F05138?logo=swift&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Windows%20x64-0078D6?logo=windows&logoColor=white)
![Parser](https://img.shields.io/badge/parser-recursive%20descent-informational)
![Status](https://img.shields.io/badge/status-academic%20project-lightgrey)

</div>

---

## Tabla de contenido

- [Acerca del proyecto](#acerca-del-proyecto)
- [Características](#características)
- [El lenguaje Ruta](#el-lenguaje-ruta)
- [Primeros pasos](#primeros-pasos)
- [Uso](#uso)
- [Arquitectura](#arquitectura)
- [Especificación formal](#especificación-formal)
- [Manejo de errores](#manejo-de-errores)
- [Pruebas](#pruebas)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Contexto académico](#contexto-académico)
- [Autor](#autor)

---

## Acerca del proyecto

**RutaProcessor** recibe un archivo con un programa escrito en Ruta, lo transforma en una secuencia de tokens (análisis léxico) y verifica que cumpla la gramática del lenguaje (análisis sintáctico). Si el programa es inválido, informa la **línea**, la **columna** y la **causa** del error en un mensaje pensado para quien escribió el programa.

El lexer y el parser están escritos **a mano**, sin generadores de analizadores ni librerías que hagan el trabajo léxico o sintáctico, de modo que cada parte de la gramática se refleja directamente en el código.

## Características

- Análisis léxico con seguimiento de línea y columna por token.
- Parser de **descenso recursivo**: una función por cada no terminal de la gramática.
- Precedencia aritmética resuelta en la propia gramática (sin ambigüedad).
- Bloques condicionales delimitados con `end`, sin el problema del *dangling else*.
- Comentarios de línea (`//`) y números enteros o decimales.
- Errores léxicos y sintácticos con ubicación exacta y mensaje descriptivo.
- Sin dependencias externas.

## El lenguaje Ruta

Un programa Ruta empieza con la declaración del robot y admite movimientos, giros, variables, expresiones aritméticas, comparaciones, decisiones, bucles y comentarios.

```text
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

| Instrucción | Descripción |
|---|---|
| `nombre = expresión` | Asigna el valor de una expresión a una variable. |
| `forward expresión` | Avanza la cantidad indicada. |
| `turn left` / `turn right` | Gira a la izquierda o a la derecha. |
| `stop` | Detiene el robot. |
| `repeat expresión { ... }` | Repite un bloque de instrucciones. |
| `if cond then ... [else ...] end` | Ejecuta según una comparación. |
| `return base` | Regresa a la base. |

## Primeros pasos

### Requisitos

- [Swift para Windows](https://www.swift.org/install/windows/) instalado, con `swiftc` disponible en la terminal.
- Windows x64.

Verifica la instalación:

```powershell
swiftc --version
```

### Compilación

Desde la raíz del repositorio:

```powershell
swiftc Token.swift Errores.swift Lexer.swift Parser.swift main.swift -o RutaProcessor.exe
```

## Uso

```powershell
.\RutaProcessor.exe <archivo.ruta>
```

Ejemplos:

```powershell
# Programa válido
.\RutaProcessor.exe .\examples\correcto.ruta

# Programa con un error sintáctico
.\RutaProcessor.exe .\examples\incorrecto.ruta

# Expresión con precedencia aritmética
.\RutaProcessor.exe .\examples\ambiguo.ruta
```

Si el programa es válido, se imprime la lista de tokens reconocidos y el mensaje `Programa Ruta válido.`. Si no lo es, se imprime el error y el proceso termina con código de salida `1`.

Formato de la lista de tokens (fragmento ilustrativo):

```text
TOKENS RECONOCIDOS:
ROBOT: 'robot' [línea 1, columna 1]
IDENTIFIER: 'Tito' [línea 1, columna 7]
IDENTIFIER: 'speed' [línea 2, columna 3]
...
```

## Arquitectura

El procesamiento sigue un flujo en dos fases:

```text
archivo .ruta ──▶ Lexer ──▶ [Token] ──▶ Parser ──▶ válido / error con posición
                 (texto)   (secuencia)  (gramática)
```

| Componente | Archivo | Responsabilidad |
|---|---|---|
| Token | `Token.swift` | Estructura con tipo, lexema, línea y columna. |
| Errores | `Errores.swift` | Errores léxicos y sintácticos con posición. |
| Lexer | `Lexer.swift` | Convierte el texto en tokens; descarta espacios y comentarios. |
| Parser | `Parser.swift` | Verifica la estructura según la gramática (descenso recursivo). |
| Entrada | `main.swift` | Lee el archivo, ejecuta ambas fases y reporta el resultado. |

**Decisión de diseño:** el lexer trabaja sobre escalares Unicode para tratar de la misma forma los saltos de línea de Windows (`\r\n`) y de Unix (`\n`). En Swift, `"\r\n"` es un único `Character`, por lo que se separan antes de analizar.

## Especificación formal

### Tokens

| Token | Patrón | Ejemplos |
|---|---|---|
| Palabras reservadas | `robot` `forward` `turn` `left` `right` `stop` `repeat` `if` `then` `else` `end` `return` `base` | `robot`, `forward` |
| `IDENTIFIER` | `[A-Za-z_][A-Za-z0-9_]*` | `Tito`, `speed`, `front_sensor` |
| `NUMBER` | `[0-9]+(\.[0-9]+)?` | `4`, `30`, `2.5` |
| `ASSIGN` | `=` | `=` |
| `PLUS` `MINUS` `STAR` `SLASH` | `+` `-` `*` `/` | `10 * speed + 5` |
| `LT` `GT` `LE` `GE` `EQ` `NE` | `<` `>` `<=` `>=` `==` `!=` | `front_sensor < 30` |
| `LBRACE` `RBRACE` `LPAREN` `RPAREN` | `{` `}` `(` `)` | `repeat 4 {` |
| `NEWLINE` | Salto de línea (separa instrucciones) | |
| `EOF` | Fin de la entrada | |

Se ignoran los espacios, los tabuladores y los comentarios de línea (`// ...`).

### Gramática (EBNF)

```ebnf
programa    = "robot", IDENTIFIER, NEWLINE, listaInstr, EOF ;

listaInstr  = { NEWLINE }, { instruccion, { NEWLINE } } ;

instruccion = asignacion | avance | giro | "stop"
            | repetir | condicional | retorno ;

asignacion  = IDENTIFIER, "=", expresion ;
avance      = "forward", expresion ;
giro        = "turn", ( "left" | "right" ) ;
retorno     = "return", "base" ;

repetir     = "repeat", expresion, "{", listaInstr, "}" ;

condicional = "if", condicion, "then", NEWLINE, listaInstr,
              [ "else", NEWLINE, listaInstr ],
              "end" ;

condicion   = expresion, ( "<" | ">" | "<=" | ">=" | "==" | "!=" ), expresion ;

expresion   = termino, { ( "+" | "-" ), termino } ;
termino     = factor,  { ( "*" | "/" ), factor } ;
factor      = NUMBER | IDENTIFIER | "(", expresion, ")" ;
```

### Eliminación de ambigüedades

| Problema | Solución en la gramática |
|---|---|
| `forward 10 * speed + 5` podría leerse de dos formas. | Tres niveles (`expresion` → `termino` → `factor`) fijan la precedencia: se interpreta como `(10 * speed) + 5`. |
| *Dangling else* en condicionales anidados. | Todo `if` se cierra con `end`, por lo que cada `else` pertenece sin dudas al `if` que lo contiene. |

## Manejo de errores

Los errores se reportan con la posición y la causa:

```text
Error léxico en línea L, columna C: <mensaje>
Error sintáctico en línea L, columna C: <mensaje>
```

Ejemplo con `examples/incorrecto.ruta`, donde la expresión `forward 10 *` queda sin segundo operando:

```text
Error sintáctico en línea 3, columna N: Se esperaba un número, un identificador
o una expresión entre paréntesis. Se encontró '\n'.
```

La columna apunta al punto donde el analizador esperaba el operando faltante.

## Pruebas

| Archivo | Propósito | Resultado esperado |
|---|---|---|
| `examples/correcto.ruta` | Asignaciones, `repeat`, `if/else/end`, comentario y `return base`. | Programa aceptado. |
| `examples/incorrecto.ruta` | Expresión incompleta (`forward 10 *`). | Error sintáctico en la línea 3. |
| `examples/ambiguo.ruta` | Expresión `10 * speed + 5` con precedencia. | Programa aceptado con una única interpretación. |

## Estructura del repositorio

```text
RutaProcessor/
├── Token.swift
├── Errores.swift
├── Lexer.swift
├── Parser.swift
├── main.swift
├── examples/
│   ├── correcto.ruta
│   ├── incorrecto.ruta
│   └── ambiguo.ruta
├── README.md
└── .gitignore
```

## Contexto académico

Proyecto desarrollado como **taller calificado del II Corte** de la asignatura *Procesadores de Lenguajes* (Ingeniería de Sistemas, Universidad Autónoma de Manizales, periodo 2026-03), bajo la dirección del docente Harold Morales. El enunciado, *Ruta, a Language for the Campus Robot*, plantea definir el lenguaje con gramáticas formales y construir su procesador en el lenguaje asignado, en este caso **Swift**.

## Autor

**Josue Daniel Castaño Montoya**
Ingeniería de Sistemas, Universidad Autónoma de Manizales
GitHub: [@Dajumaks](https://github.com/Dajumaks)
