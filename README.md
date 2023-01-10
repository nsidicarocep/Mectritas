# Mectritas
Facilita el procesamiento de MECTRA

## Funciones 

- **``add_claes()``**: agrega las distintas agregaciones de los claes deseadas y sus descripciones (si eso se desea). 

- **``deflactanator()``**: permite deflactar una serie de variables con el IPC del CEP. Se pueden deflactar más de una variable a la vez. 

- **``indexanator()``**: permite indexar las variables deseadas y realizar esa indexación con respecto al máximo, mínimo o alguna fecha seleccionada (esto último para series). A su vez, permite armar el índice no solo por la variable sino en grupos de la variable, de forma tal de tener por ejemplo un índice para cada sector productivo por provincia. 

- **``limpia_cuits()``**: permite filtrar los cuits públicos y los que no utilizamos. Además permite indicar rápidamente de que tipo se tratan

- **``mectra_demografia()``**: es un insumo para utilizar en conjunto a las bases auxiliares de género y edad. Por medio del CUIL se calcula la edad y el sexo biológico al nacer. 

- **``mectra_numerica()``**: convierte todas las variables de la mectra que pueden transformarse en numéricas en numéricas. 

## Formas de uso 

**Añadir CLAES**
```r
# Con una mectra cargada o cualquier base que tenga clae6, clae3, clae2 o letra como variable 
# Para su uso es necesario que solo una de estas variables aparezca, por lo que en caso de tener clae6 y clae3 se deberá seleccionar la más desagregada 

mectra <- add_claes(data = mectra,
                    agregacion_deseada = c('clae2','letra'), # Vector con agregaciones que se desean
                    descripciones = T) # Puede ser T o F. En caso de ser T se agregan las descripciones de las agregaciones deseadas 
```

**Deflactar o inflar variables**
```r

# Requiere una base con variables monetarias y una columna que indique con formato YYYY-MM-DD
mectra <- deflactanator(mectra,
                        mes_base = '2022-09-01', # Mes que se utilizará como base de los precios constantes
                        variables_deflactar = c('remuneracion','apobliss','sueldo'), # Vector de variables que se desean deflactar/inflar
                        variable_mes = 'fecha', # Nombre de la variable que indica la fecha en la base que se quiere deflactar
                        pisar_datos = F) # Puede ser T o F. En caso de ser T se agregan N columnas, una por cada variable a deflactar con el nombre original junto a "_constante"
                        

```

**Convertir variables de MECTRA a numéricas**:
```r
# Convierte todas las variables que son numéricas en formato numérico para trabajar más fácil 
mectra <- mectra_numerica(mectra)

```

**Añadir variables**
```r

mectra <- mectra_demografia(mectra,
                            sexo=T, #Puede ser T o F. Agrega el sexo biológico calculdao en base al CUIL
                            nacimiento=T) #Puede ser T o F. Agrega el año de nacimiento en base al DNI
```

**Indexar variables**
```r
mectra <- indexanator(mectra,
                      'max', # Indica la forma de la indexación. Puede ser max, min o una fecha en particular -en caso de trabajar con series-. La fecha debe ser YYYY-MM-DD. El valor máximo/mínimo/fecha tomará valor 100. 
                      variables_indexar = c('remuneracion','apobliss','sueldo'), # Variables sobre las que se calculará el indice
                    variables_agrupar = 'zona', # Variables que se usarán para definir sobre que grupo se aplicará el índice
                    pisar_datos = F ) # Puede ser T o F. Pisa los datos que se indexaron o genera nuevas columnas con el nombre de las originales junto a "_index"
```

**Indicar o eliminar cuits que no usamos o son públicos**
```r

mectra <- limpia_cuits(mectra,
                       elimina_publico = F, # Retira de la base los CUITs que están en el listado de CUITs públicos
                       indica_publico = T, # Indica si el CUIT es público productivo, público o privado. Toma valor 1, 0 y 2 respectivamente.
                       elimina_cajas = T, # Retira de la base los cuits que están en el archivo filtro_database
                       indica_cajas = F, # Indica si está en filtro_database o no
                       elimina_pub_no_prod = F # Retira de la base los CUITs públicos no productivos, en caso de ser TRUE. Default = F
                       )

```
