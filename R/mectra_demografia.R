#' Añade año de nacimiento y sexo al nacer segun CUIL
#'
#' Standariza la forma de añadir el año de nacimiento y el sexo al nacer de los que no tenemos en el padron 
#'
#' @name mectra_demografia
#' 
#' @param data Nombre del elemento al que se quiere añadir las etiquetas
#' @param sexo Calcula el sexo al nacer. Genera la variable sexo_calc. Toma valor 1 si es hombre . Default T
#' @param nacimiento Calcula el año de nacimiento. Default T 
#' @return A matrix of the infile
#' @export

# Armar funcion
mectra_demografia <- function(data,sexo=T,nacimiento=T) {
  require(data.table)
  require(tidyverse)
  setDT(data)
  if(sexo == T){
    data <- data[,cuil_dos_cif := str_sub(cuil,1,2)]
    data <- data[,cuil_ulti := str_sub(cuil,11,11)]
    #genero la variable sexo_calc = 1, asumo que son varones a menos se cumplan las condiciones
    data <- data[,mujer := 0]
    data <- data[,mujer := fifelse(cuil_dos_cif==27,1,mujer)]
    data <- data[,mujer := fifelse(cuil_dos_cif==23 & cuil_ulti==4,1,mujer)]
    data$cuil_dos_cif <- NULL
    data$cuil_ulti <- NULL
  }

  # Añade año de nacimiento
  if(nacimiento == T){
    #Calcular las edades faltantes
    dni_anio <- fread(r"(C:\Users\Usuario\Documents\CEP\Paquetes\Mectritas\data\Year_dni.csv)")
    dni_anio <- dni_anio %>% select(-DNI_trabajo, edad_calculada = d3_dni) %>% distinct()
    dni_anio <- dni_anio %>% group_by(edad_calculada) %>% filter(Anio_nac==min(Anio_nac))
    setDT(dni_anio)
    #edad calculada
    data <- data[,documento := as.numeric(str_sub(cuil,3,10))]
    data <- data[,edad_calculada := documento / 100000]
    data <- data[,edad_calculada := trunc(edad_calculada)]
    data <- merge.data.table(data,dni_anio,by=c('edad_calculada'),all.x=TRUE)
    data$documento <- NULL
    data$edad_calculada <- NULL
  }
  return(data)
}












