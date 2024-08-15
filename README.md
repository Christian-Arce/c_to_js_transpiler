# Traductor de C a JavaScript
Implementación de un esquema de traducción dirigida por la sintaxis que permite la traslación de un código en C a un código equivalente en JavaScript, utilizando las herramientas LEX/FLEX y YACC /BISON.

# Utilización del traductor

1. Clonar el repositorio de GitHub

```
git clone https://github.com/camidorego/c2js_transpiler.git
```

2. Instalación de Flex y Bison(para Linux):
```
sudo apt install flex

sudo apt install bison
```

3. Ubicarse en el directorio del repositorio
```
cd c2js_transpiler
```

4. Compilar y ejecutar el traductor
#### Ejecutar un archivo específico
```
make FILE=prueba/<archivo.c>
```

#### Si no se especifica ningún archivo, por defecto se ejecuta prueba.c
```
make
```

5. Se genera el archivo resultante de Javascript output_file.js

