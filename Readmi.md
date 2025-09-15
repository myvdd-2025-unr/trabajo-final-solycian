# Análisis de Nacimientos en Argentina 2023

## Descripción general
Este proyecto tiene como objetivo **analizar los nacimientos vivos registrados en la República Argentina durante el año 2023**.  
El propósito principal es poner a disposición un dataset limpio y confiable, acompañado de una aplicación **Shiny interactiva** que permite explorar la información de manera visual y dinámica.

## Fuente de datos
Los datos provienen del portal oficial del Ministerio de Salud de la Nación:  
[http://datos.salud.gob.ar/dataset/nacidos-vivos-registrados-por-jurisdiccion-de-residencia-de-la-madre-republica-argentina-ano/archivo/40e722b8-72eb-49a0-89dc-5ee174bf63b4](http://datos.salud.gob.ar/dataset/nacidos-vivos-registrados-por-jurisdiccion-de-residencia-de-la-madre-republica-argentina-ano/archivo/40e722b8-72eb-49a0-89dc-5ee174bf63b4)

El archivo original descargado se denominó **`nacimientos2023.csv`**.

---

## Proceso de limpieza de datos

La preparación de los datos se realizó en un documento Quarto con salida HTML, denominado:  
**`nacimientos2023_limpio1.qmd`**

### Pasos principales de la limpieza:
1. **Carga del dataset crudo** (`nacimientos2023.csv`).  
2. **Estandarización de nombres de columnas**: todos en minúscula.  
3. **Normalización de variables**:
   - `jurisdiccion`: eliminación de espacios en blanco.  
   - `sexo`: convertido a minúsculas y filtrado únicamente en *masculino* y *femenino*.  
   - `edad_grupo`: homogeneización de etiquetas, unificando casos como “45 y más” y “De 45 y más”.  
   - `nacimientos`: conversión a valores numéricos y eliminación de registros nulos o inválidos.  
4. **Generación del dataset limpio**: se guardó como **`nacimientos2023_limpio1.csv`**.  

El proceso completo quedó documentado en el archivo Quarto **`nacimientos2023_limpio1.qmd`** con salida HTML.

---

## Desarrollo de la Shiny App

El archivo **`app.R`** contiene la aplicación Shiny que permite analizar los nacimientos desde diferentes perspectivas.

### Funcionalidades principales:

- **Pestaña 1: NACIMIENTOS POR SEXO**  
  - Selección de una jurisdicción o visualización de todas.  
  - Gráfico de barras interactivo con `plotly`.  
  - Tabla resumen con cantidades totales.

- **Pestaña 2: COMPARACIÓN ENTRE JURISDICCIONES**  
  - Posibilidad de seleccionar una o varias jurisdicciones para comparar.  
  - Gráfico interactivo de comparación de nacimientos totales.  
  - Tabla con resultados ordenados.  

- **Pestaña 3: EDAD DE LA MADRE VS JURISDICCIONES**  
  - Gráfico de dispersión interactivo que muestra la distribución de nacimientos por grupo etario de la madre en cada jurisdicción.  
  - Opción de aplicar **escala logarítmica** al eje Y.  
  - Explicación lateral sobre el significado de la escala logarítmica.  
  - Tabla de resultados filtrables.  
  - Opción de descargar los datos visualizados en formato `.csv`.

---

## Aspectos estéticos y de diseño

- Los títulos de cada pestaña aparecen en **mayúsculas, en negrita y con un tamaño ampliado**.  
- Los textos de ayuda y menús desplegables también se presentan en mayúsculas para mayor claridad.  
- Debajo del título principal se incluyó:  
  - Un **enlace a la fuente oficial de datos**.  
  - Una breve **descripción general** sobre el contenido de la app.  
- En cada pestaña se agregó un texto explicativo separado, que introduce lo que se observa en la gráfica correspondiente.

---

## Archivos principales del proyecto

- **`nacimientos2023.csv`** → dataset crudo original.  
- **`nacimientos2023_limpio1.qmd`** → script Quarto para limpieza (con salida HTML).  
- **`nacimientos2023_limpio1.csv`** → dataset limpio resultante.  
- **`app.R`** → aplicación Shiny interactiva.  
- **`README.md`** → documentación del proyecto (este archivo).

---

## Objetivo final
Gracias a este flujo de trabajo, se dispone de una **base de datos limpia y confiable** junto con una **herramienta interactiva** que permite explorar y comprender mejor la distribución de los nacimientos en Argentina durante el año 2023, facilitando el análisis tanto por sexo, jurisdicción como por grupo etario de la madre.

