RutaProcessor
Procesador léxico y sintáctico del lenguaje Ruta, un lenguaje diseñado para programar las rutas de un robot de entregas dentro de un campus universitario. Está implementado en Swift, sin generadores de analizadores ni librerías que reemplacen el lexer y el parser, que se desarrollan manualmente a partir de la gramática.
Información	Detalle
Autor	Josue Daniel Castaño Montoya
Universidad	Universidad Autónoma de Manizales
Programa	Ingeniería de Sistemas
Asignatura	Procesadores de Lenguajes
Trabajo	Taller calificado, II Corte: Ruta, a Language for the Campus Robot
Docente	Harold Morales
Periodo	2026-03
Lenguaje de implementación	SwiftDescripción
El procesador recibe un archivo con un programa Ruta, lo convierte en una secuencia de tokens mediante el análisis léxico y comprueba si el programa cumple las reglas sintácticas del lenguaje.

Cuando encuentra un programa inválido, informa la línea, la columna y el motivo del error.

Ejemplo de un programa Ruta:
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

// Volver a la base
return base
Requisitos
- Swift




Requisitos
- Swift instalado y disponible desde la terminal mediante swiftc.
- Windows x64 para compilar y ejecutar el proyecto en el entorno previsto.
Instalación oficial: Swift para Windows.
Estructura del proyecto
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
├── docs/
│   └── trabajo-teorico.md
├── README.md
└── .gitignore


- Token.swift: representación de los tokens, incluyendo tipo, lexema, línea y columna.
- Errores.swift: definición de errores léxicos y sintácticos.
- Lexer.swift: análisis léxico.
- Parser.swift: análisis sintáctico mediante descenso recursivo.
- main.swift: punto de entrada del programa.
- examples/: programas utilizados para las pruebas.
- docs/trabajo-teorico.md: documentación de la gramática y sus ambigüedades.
Compilación
Abre PowerShell en la carpeta raíz del proyecto y ejecuta:
swiftc Token.swift Errores.swift Lexer.swift Parser.swift main.swift -o RutaProcessor.exe


Ejecución
Para ejecutar el programa válido:
.\RutaProcessor.exe .\examples\correcto.ruta


Para probar el programa incorrecto:
.\RutaProcessor.exe .\examples\incorrecto.ruta


Para comprobar la expresión aritmética:
.\RutaProcessor.exe .\examples\ambiguo.ruta


El resultado esperado es que el programa válido sea aceptado y que el programa incorrecto genere un error sintáctico. Estos resultados deben comprobarse ejecutando el proyecto.
Definición léxica
Token	Patrón o descripción	Ejemplos
Palabras reservadas	Palabras definidas por Ruta	robot, forward, turn, stop, repeat, if, then, else, end, return, base
IDENTIFIER	[A-Za-z_][A-Za-z0-9_]*	Tito, speed, front_sensor
NUMBER	[0-9]+(\.[0-9]+)?	4, 30, 2.5
Asignación	=	=
Operadores aritméticos	+, -, *, /	10 * speed + 5
Operadores relacionales	``, =, ==, !=	front_sensor < 30
Delimitadores	DIL0, (, )	DIL1
NEWLINE	Salto de línea	Separación de instrucciones
EOF	Fin del archivo	Final de la entrada

Los espacios y tabuladores se ignoran. Los comentarios de línea comienzan con // y se extienden hasta el final de la línea.
Gramática en EBNF
programa      = "robot", IDENTIFIER, NEWLINE, listaInstr, EOF ;

listaInstr    = { NEWLINE }, { instruccion, { NEWLINE } } ;

instruccion   = asignacion
              | avance
              | giro
              | "stop"
              | repetir
              | condicional
              | retorno ;

asignacion    = IDENTIFIER, "=", expresion ;
avance        = "forward", expresion ;
giro          = "turn", ( "left" | "right" ) ;
retorno       = "return", "base" ;

repetir       = "repeat", expresion, "{", listaInstr, "}" ;

condicional   = "if", condicion, "then", NEWLINE,
                listaInstr,
                [ "else", NEWLINE, listaInstr ],
                "end" ;

condicion     = expresion,
                ( "<" | ">" | "<=" | ">=" | "==" | "!=" ),
                expresion ;

expresion     = termino, { ( "+" | "-" ), termino } ;
termino       = factor, { ( "*" | "/" ), factor } ;
factor        = NUMBER
              | IDENTIFIER
              | "(", expresion, ")" ;


NEWLINE representa un salto de línea. Las llaves delimitan los bloques de repetición y end cierra los condicionales.
Eliminación de ambigüedades
Expresiones aritméticas
La gramática separa las expresiones en tres niveles:
- expresion: suma y resta.
- termino: multiplicación y división.
- factor: números, identificadores y expresiones entre paréntesis.
De esta forma, la expresión:
forward 10 * speed + 5


se interpreta como:
(10 * speed) + 5


La multiplicación tiene mayor precedencia que la suma.
Condicionales anidados
El uso de end permite delimitar los bloques condicionales. Así se evita la ambigüedad conocida como dangling else, en la que un else podría asociarse a más de un if.
Programas de prueba
Archivo	Propósito
examples/correcto.ruta	Comprueba instrucciones válidas, asignaciones, repetición y condicionales.
examples/incorrecto.ruta	Comprueba la detección de una expresión incompleta, como forward 10 *.
examples/ambiguo.ruta	Comprueba el reconocimiento de 10 * speed + 5 con precedencia aritmética.

Manejo de errores
Los errores léxicos y sintácticos deben informar la ubicación del problema y una descripción comprensible.

Ejemplos del formato esperado:
Error léxico en línea L, columna C: mensaje del error
Error sintáctico en línea L, columna C: mensaje del error


Notas de implementación
- El lexer identifica los tokens directamente a partir del texto de entrada.
- El parser utiliza descenso recursivo para comprobar la estructura sintáctica.
- La precedencia aritmética se implementa mediante las funciones que procesan expresiones, términos y factores.
- No se utilizan generadores de analizadores léxicos o sintácticos.
Autor
Josue Daniel Castaño Montoya

Universidad Autónoma de Manizales — Ingeniería de Sistemas
Asignatura: Procesadores de Lenguajes
Periodo: 2026-03
</WritingBlock>